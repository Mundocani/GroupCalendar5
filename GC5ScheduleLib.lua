----------------------------------------
-- Group Calendar 5 Copyright (c) 2018 John Stephen
-- This software is licensed under the MIT license.
-- See the included LICENSE.txt file for more information.
----------------------------------------

local _

-- Invite Statuses

GroupCalendar.CALENDAR_EVENTCOLOR_MODERATOR = {r = 0.54, g = 0.75, b = 1.0}

GroupCalendar.CALENDAR_INVITESTATUS_COLORS =
{
	[CALENDAR_INVITESTATUS_CONFIRMED]     = GREEN_FONT_COLOR,
	[CALENDAR_INVITESTATUS_ACCEPTED]      = {r = 0.6, g = 1, b = 1},
	[CALENDAR_INVITESTATUS_TENTATIVE]     = ORANGE_FONT_COLOR,
	[CALENDAR_INVITESTATUS_DECLINED]      = GRAY_FONT_COLOR,
	[CALENDAR_INVITESTATUS_OUT]           = RED_FONT_COLOR,
	[CALENDAR_INVITESTATUS_STANDBY]       = YELLOW_FONT_COLOR,
	[CALENDAR_INVITESTATUS_INVITED]       = NORMAL_FONT_COLOR,
	[CALENDAR_INVITESTATUS_SIGNEDUP]      = {r = 0.6, g = 1, b = 1},
	[CALENDAR_INVITESTATUS_NOT_SIGNEDUP]  = NORMAL_FONT_COLOR,
}

GroupCalendar.CALENDAR_INVITESTATUS_COLOR_CODES = {}

for vKey, vColor in pairs(GroupCalendar.CALENDAR_INVITESTATUS_COLORS) do
	GroupCalendar.CALENDAR_INVITESTATUS_COLOR_CODES[vKey] = string.format("|cff%02x%02x%02x", vColor.r * 255 + 0.5, vColor.g * 255 + 0.5, vColor.b * 255 + 0.5)
end

GroupCalendar.CALENDAR_INVITESTATUS_NAMES =
{
	[CALENDAR_INVITESTATUS_CONFIRMED]    = CALENDAR_STATUS_CONFIRMED,
	[CALENDAR_INVITESTATUS_ACCEPTED]     = CALENDAR_STATUS_ACCEPTED,
	[CALENDAR_INVITESTATUS_TENTATIVE]    = CALENDAR_STATUS_TENTATIVE,
	[CALENDAR_INVITESTATUS_DECLINED]     = CALENDAR_STATUS_DECLINED,
	[CALENDAR_INVITESTATUS_OUT]          = CALENDAR_STATUS_OUT,
	[CALENDAR_INVITESTATUS_STANDBY]      = CALENDAR_STATUS_STANDBY,
	[CALENDAR_INVITESTATUS_INVITED]      = CALENDAR_STATUS_INVITED,
	[CALENDAR_INVITESTATUS_SIGNEDUP]     = CALENDAR_STATUS_SIGNEDUP,
	[CALENDAR_INVITESTATUS_NOT_SIGNEDUP] = nil,
}

GroupCalendar.CALENDAR_CALENDARTYPE_COLORS =
{
--	["PLAYER"]				= ,
--	["GUILD_ANNOUNCEMENT"]	= ,
--	["GUILD_EVENT"]			= ,
	["SYSTEM"]				= {r=1.0, g=1.0, b=0.6},
	["HOLIDAY"]				= HIGHLIGHT_FONT_COLOR,
	["RAID_LOCKOUT"]		= NORMAL_FONT_COLOR,
	["RAID_RESET"]			= HIGHLIGHT_FONT_COLOR,
}

GroupCalendar.EVENT_MAX_TITLE_LENGTH = 31
GroupCalendar.EVENT_MAX_DESCRIPTION_LENGTH = 255

----------------------------------------
GroupCalendar._Calendar = {}
----------------------------------------

GroupCalendar._Calendar.cMaxHistory = 14

function GroupCalendar._Calendar:Construct(pOwnersName, pCalendarID, pCalendarData, pReadOnly)
	self.OwnersName = pOwnersName
	self.CalendarID = pCalendarID
	self.CalendarData = pCalendarData
	self.ReadOnly = pReadOnly
	
	self.Schedules = {}
	
	-- Add the method table to all of the events in the calendar
	
	local vMetaTable = (pReadOnly and GroupCalendar._CachedEventMetaTable) or GroupCalendar._APIEventMetaTable
	
	if self.CalendarData then
		for vDate, vEvents in pairs(self.CalendarData) do
			for _, vEvent in ipairs(vEvents) do
				setmetatable(vEvent, vMetaTable)
			end
		end
	end
	
	--
	
	if not self.ReadOnly then
		GroupCalendar.EventLib:RegisterEvent("CALENDAR_UPDATE_EVENT_LIST", self.CalendarUpdateEventList, self)
		GroupCalendar.EventLib:RegisterEvent("CVAR_UPDATE", self.CVarUpdate, self)
		GroupCalendar.EventLib:RegisterEvent("CALENDAR_UPDATE_PENDING_INVITES", self.Synchronize, self)
	end
	
	-- Install event monitoring to aid in debugging
	--[[
	if pCalendarID == "PLAYER" then
		GroupCalendar.EventLib:RegisterEvent("CALENDAR_UPDATE_EVENT_LIST", self.DebugEvents, self)
		GroupCalendar.EventLib:RegisterEvent("CALENDAR_OPEN_EVENT", self.DebugEvents, self)
		GroupCalendar.EventLib:RegisterEvent("CALENDAR_CLOSE_EVENT", self.DebugEvents, self)
		GroupCalendar.EventLib:RegisterEvent("CALENDAR_UPDATE_EVENT", self.DebugEvents, self)
		GroupCalendar.EventLib:RegisterEvent("CALENDAR_UPDATE_INVITE_LIST", self.DebugEvents, self)
		GroupCalendar.EventLib:RegisterCustomEvent("GC5_EVENT_CHANGED", self.DebugEvents, self)
		GroupCalendar.EventLib:RegisterCustomEvent("GC5_CALENDAR_CHANGED", self.DebugEvents, self)
		GroupCalendar.EventLib:RegisterEvent("CALENDAR_ACTION_PENDING", self.DebugEvents, self)
		GroupCalendar.EventLib:RegisterEvent("CALENDAR_NEW_EVENT", self.DebugEvents, self)
	end
	]]
end

function GroupCalendar._Calendar:DebugEvents(pEventID, ...)
	if GroupCalendar.Debug.events then
		local vParam = select(1, ...) or ""
		
		GroupCalendar:DebugMessage("Calendar:DebugEvents: %s%s: %s", GREEN_FONT_COLOR_CODE, pEventID, tostring(vParam))
	end
end

function GroupCalendar._Calendar:CalendarUpdateEventList()
	GroupCalendar.BlizzardCalendarReady = true
	self:FlushCaches()
end

function GroupCalendar._Calendar:GetSelectedEvent()
	if GroupCalendar.WoWCalendar.OpenedEvent then
		return GroupCalendar.WoWCalendar.OpenedEvent
	end
	
	if not self.CalendarData then
		return
	end
	
	local vDate = GroupCalendar.DateLib:ConvertMDYToDate(
						GroupCalendar.WoWCalendar.SelectedEventMonth,
						GroupCalendar.WoWCalendar.SelectedEventDay,
						GroupCalendar.WoWCalendar.SelectedEventYear)
	local vEvents = self.CalendarData[vDate]
	
	if not vEvents then
		return
	end
	
	for _, vEvent in ipairs(vEvents) do
		if vEvent.Index == GroupCalendar.WoWCalendar.SelectedEventIndex then
			return vEvent
		end
	end
end

function GroupCalendar._Calendar:FlushCaches()
	if self.ReadOnly then
		return
	end
	
	if self.CalendarID ~= "PLAYER" then
		for vDate, vSchedule in pairs(self.Schedules) do
			self.Schedules[vDate] = nil
		end
	else
		self:Synchronize()
	end
	
	GroupCalendar.EventLib:DispatchEvent("GC5_CALENDAR_CHANGED")
end

function GroupCalendar._Calendar:CVarUpdate(pName, pValue)
	if pName == "calendarShowDarkmoon"
	or pName == "calendarShowWeeklyHolidays"
	or pName == "calendarShowBattlegrounds" then
		self:FlushCaches()
	end
end

function GroupCalendar._Calendar:GetSchedule(pMonth, pDay, pYear)
	if not pMonth or not pDay or not pYear then
		error("GetSchedule: month, day and year expected")
	end
	
	local vDate = GroupCalendar.DateLib:ConvertMDYToDate(pMonth, pDay, pYear)
	local vSchedule = self.Schedules[vDate]
	
	if not vSchedule then
		vSchedule = GroupCalendar:New(GroupCalendar._CalendarDay, self.OwnersName, self.CalendarID, self.CalendarData, self.ReadOnly)
		vSchedule:SetDate(pMonth, pDay, pYear)
		self.Schedules[vDate] = vSchedule
	end
	
	return vSchedule
end

function GroupCalendar._Calendar:GetLocalSchedule(pMonth, pDay, pYear)
	
end

function GroupCalendar._Calendar:Synchronize()
	local currentDate = GroupCalendar.WoWCalendar:GetDate()
	self.CurrentMonth = currentDate.month
	self.CurrentDay = currentDate.monthDay
	self.CurrentYear = currentDate.year
	self.CurrentDate = GroupCalendar.DateLib:ConvertMDYToDate(self.CurrentMonth, self.CurrentDay, self.CurrentYear)
	
	local vCutoffDate = self.CurrentDate - self.cMaxHistory
	
	-- Mark the schedules so we can tell which ones don't get used
	
	for vDate, vSchedule in pairs(self.Schedules) do
		vSchedule.Unused = true
	end
	
	for vDate = vCutoffDate, self.CurrentDate + 365 do
		local vMonth, vDay, vYear = GroupCalendar.DateLib:ConvertDateToMDY(vDate)
		
		if self:HasDayEvents(vMonth, vDay, vYear) then
			local vSchedule = self.Schedules[vDate]
			
			if not vSchedule then
				vSchedule = GroupCalendar:New(GroupCalendar._CalendarDay, self.OwnersName, self.CalendarID, self.CalendarData, self.ReadOnly)
				self.Schedules[vDate] = vSchedule
			else
				vSchedule.Unused = nil
			end
			
			vSchedule:SetDate(vMonth, vDay, vYear)
		end
	end
	
	-- Remove unused schedules
	
	for vDate, vSchedule in pairs(self.Schedules) do
		if vSchedule.Unused then
			self.Schedules[vDate] = nil
		end 
	end
end

function GroupCalendar._Calendar:HasDayEvents(pMonth, pDay, pYear)
	local vMonthOffset = GroupCalendar.WoWCalendar:GetMonthOffset(pMonth, pYear)
	local vNumEvents = GroupCalendar.WoWCalendar:GetNumDayEvents(vMonthOffset, pDay)
	
	SetCVar("calendarShowLockouts", 1)
	
	for vEventIndex = 1, vNumEvents do
		local event = GroupCalendar.WoWCalendar:GetDayEvent(vMonthOffset, pDay, vEventIndex)
		
		if (self.CalendarID == GroupCalendar._CalendarDay.cBlizzardCalendarIDs[event.calendarType])
		or (self.CalendarID ~= "BLIZZARD" and not GroupCalendar._CalendarDay.cBlizzardCalendarIDs[event.calendarType]) then
			return true
		end
	end
	
	return false
end

function GroupCalendar._Calendar:NewEvent(pMonth, pDay, pYear, pCalendarType)
	if self.ReadOnly then
		error("Can't create new events in a read-only calendar")
	end
	
	if self:IsAfterMaxCreateDate(pMonth, pDay, pYear) then
		error("Can't create events that far in the future")
	end
	
	local vEvent = {}
	setmetatable(vEvent, GroupCalendar._APIEventMetaTable)
	vEvent:NewEvent(self.OwnersName, pMonth, pDay, pYear, pCalendarType)
	
	return vEvent
end

function GroupCalendar._Calendar:IsAfterMaxCreateDate(month, day, year)
	if not month or not day or not year then
		error("Expected month, day, year")
	end
	
	local maxCreateDate = GroupCalendar.WoWCalendar:GetMaxCreateDate()
	
	if year > maxCreateDate.year then
		return true
	elseif year < maxCreateDate.year then
		return false
	elseif month > maxCreateDate.month then
		return true
	elseif month < maxCreateDate.month then
		return false
	else
		return day > maxCreateDate.monthDay
	end
end

----------------------------------------
GroupCalendar._CalendarDay = {}
----------------------------------------

function GroupCalendar._CalendarDay:Construct(pOwnersName, pCalendarID, pCalendarData, pReadOnly)
	self.OwnersName = pOwnersName
	self.CalendarID = pCalendarID
	self.CalendarData = pCalendarData
	self.ReadOnly = pReadOnly
	
	self.Events = nil
end

GroupCalendar._CalendarDay.cBlizzardCalendarIDs =
{
	SYSTEM = "BLIZZARD",
	HOLIDAY = "BLIZZARD",
	RAID_RESET = "BLIZZARD"
}

function GroupCalendar._CalendarDay:SetDate(pMonth, pDay, pYear)
	local vDate = GroupCalendar.DateLib:ConvertMDYToDate(pMonth, pDay, pYear)
	
	if not self.Events then
		if self.CalendarData then
			self.Events = self.CalendarData[vDate]
		end
		
		if not self.Events then
			self.Events = {}
		end
	end
	
	-- Synchronize to the Blizzard database if we're not read-only
	
	if not self.ReadOnly then
		self:SynchronizeEvents(pMonth, pDay, pYear)
		
		if self.CalendarData then
			if #self.Events > 0 then
				self.CalendarData[vDate] = self.Events
			else
				self.CalendarData[vDate] = nil
			end
		end
	end
end

function GroupCalendar._CalendarDay:SynchronizeEvents(pMonth, pDay, pYear)
	if self.CalendarID == "PLAYER"
	and not GroupCalendar.BlizzardCalendarReady then
		return -- Can't do anything until the WoW calendar's have loaded
	end
	
	-- Mark existing event records so we can determine if
	-- they're still active once we're done
	
	if self.Events then
		for _, vEvent in ipairs(self.Events) do
			vEvent.Orphaned = true
		end
	else
		self.Events = {}
	end
	
	-- Collect the events from the WoW calendar
	
	local vMonthOffset = GroupCalendar.WoWCalendar:GetMonthOffset(pMonth, pYear)
	local vNumEvents = GroupCalendar.WoWCalendar:GetNumDayEvents(vMonthOffset, pDay)
	
	SetCVar("calendarShowLockouts", 1)
	
	local vAPIEvent = {}
	
	setmetatable(vAPIEvent, GroupCalendar._APIEventMetaTable)
	
	local vCurrentDateTimeStamp = GroupCalendar.DateLib:GetServerDateTimeStamp()
	
	local vCalendarChanged
	
	for vEventIndex = 1, vNumEvents do
		vAPIEvent:SetEvent(self.OwnersName, pMonth, pDay, pYear, vEventIndex)
		
		if (self.CalendarID == self.cBlizzardCalendarIDs[vAPIEvent.CalendarType])
		or (self.CalendarID ~= "BLIZZARD" and not self.cBlizzardCalendarIDs[vAPIEvent.CalendarType]) then
			local vEvent = self:FindExistingEvent(vAPIEvent)
			
			if vEvent then
				local vChanged
				
				for vKey, vValue in pairs(vAPIEvent) do
					if vEvent[vKey] ~= vValue then
						vEvent[vKey] = vValue
						vChanged = true
					end
				end
				
				vEvent.CacheUpdateDate, vEvent.CacheUpdateTime = GroupCalendar.DateLib:GetServerDateTime()
				
				vEvent.Orphaned = nil
				
				if vChanged then
					vCalendarChanged = true
					GroupCalendar.BroadcastLib:Broadcast(vEvent, "CHANGED")
				end
			else
				vEvent = GroupCalendar:DuplicateTable(vAPIEvent, true)
				setmetatable(vEvent, GroupCalendar._APIEventMetaTable)
				
				vEvent.CreationDate, vEvent.CreationTime = GroupCalendar.DateLib:GetServerDateTime()
				vEvent.CacheUpdateDate, vEvent.CacheUpdateTime = GroupCalendar.DateLib:GetServerDateTime()
				
				if self.CalendarID == "PLAYER"
				and not vEvent:IsCooldownEvent()
				and not vEvent:HasPassed(vCurrentDateTimeStamp)
				and vEvent.InvitedBy ~= GroupCalendar.PlayerName then
					vEvent.Unseen = true
				end
				
				if not self.Events then
					self.Events = {}
				end
				
				table.insert(self.Events, vEvent)
				
				vCalendarChanged = true
				GroupCalendar.EventLib:DispatchEvent("GC5_EVENT_ADDED", vEvent)
			end
		end
	end
	
	for vIndex = #self.Events, 1, -1 do
		local vEvent = self.Events[vIndex]
		
		if vEvent.Orphaned then
			vCalendarChanged = true
			table.remove(self.Events, vIndex)
			GroupCalendar.BroadcastLib:Broadcast(vEvent, "DELETED")
		end
	end
	
	if vCalendarChanged then
		GroupCalendar.EventLib:DispatchEvent("GC5_CALENDAR_CHANGED", vEvent)
	end
end

function GroupCalendar._CalendarDay:FindExistingEvent(pEvent)
	local vBestScore, vBestEvent

	for _, vEvent in ipairs(self.Events) do
		if vEvent.Orphaned then
			if pEvent.CalendarType == vEvent.CalendarType
			and pEvent.SequenceType == vEvent.SequenceType then
				local vScore = 0
				
				if pEvent.Title == vEvent.Title then vScore = vScore + 1 end
				if pEvent.TitleTag == vEvent.TitleTag then vScore = vScore + 1 end
				
				if pEvent.Hour == vEvent.Hour
				and pEvent.Minute == vEvent.Minute then vScore = vScore + 1 end
				
				if pEvent.Month == vEvent.Month
				and pEvent.Day == vEvent.Day
				and pEvent.Year == vEvent.Year then vScore = vScore + 1 end
				
				if pEvent.EventType == vEvent.EventType
				and pEvent.TextureID == vEvent.TextureID
				and pEvent.Difficulty == vEvent.Difficulty then vScore = vScore + 1 end
				
				if pEvent.ModStatus == vEvent.ModStatus then vScore = vScore + 0.25 end
				if pEvent.InviteStatus == vEvent.InviteStatus then vScore = vScore + 0.25 end
				if pEvent.InviteType == vEvent.InviteType then vScore = vScore + 0.25 end
				if pEvent.InvitedBy == vEvent.InvitedBy then vScore = vScore + 0.5 end
				
				if vScore and vScore >= 3 and (not vBestScore or vScore > vBestScore) then
					vBestScore = vScore
					vBestEvent = vEvent
				end
			end -- if pCalendarTYpe
		end -- if Orphaned
	end -- for
	
	return vBestEvent
end

function GroupCalendar:AddTooltipEvents(pTooltip, pEvents, pUseLocalTime)
	if not pEvents then
		return
	end
	
	for vIndex, vEvent in ipairs(pEvents) do
		local vColor = vEvent:GetEventColor()
		local vOwner = tern((vEvent.RealmName ~= GroupCalendar.RealmName) and vEvent.OwnersName,
		                       string.format(GroupCalendar.cForeignRealmFormat, vEvent.OwnersName, vEvent.RealmName),
		                       vEvent.OwnersName)
		
		local vEventFormat = vEvent.InvitedBy and vEvent.InvitedBy ~= "" and GroupCalendar.cTooltipScheduleItemFormat or "%s"
		local vTitle = vEventFormat:format(vEvent.Title, vOwner)
		
		if vEvent:IsAllDayEvent() then
			pTooltip:AddDoubleLine(
					GroupCalendar.cAllDay,
					vTitle,
					vColor.r, vColor.g, vColor.b, vColor.r, vColor.g, vColor.b)
		else
			local vTime = GroupCalendar.DateLib:ConvertHMToTime(vEvent.Hour, vEvent.Minute)
			
			if pUseLocalTime then
				vTime = GroupCalendar.DateLib:GetLocalTimeFromServerTime(vTime)
			end
			
			pTooltip:AddDoubleLine(
					GroupCalendar.DateLib:GetShortTimeString(vTime),
					vTitle,
					vColor.r, vColor.g, vColor.b, vColor.r, vColor.g, vColor.b)
		end
	end
end

function GroupCalendar:GetEventTypeTextures(eventType)
	local textures = GroupCalendar.WoWCalendar:EventGetTextures(eventType)
	return textures
end

function GroupCalendar:InitializeEventDefaults()
	GroupCalendar.DefaultEventLimits = {}
	GroupCalendar.DefaultEventLevel = {}
	
	local vEventTypeNames = {GroupCalendar.WoWCalendar:EventGetTypes()}
	
	for vEventType, vEventTypeName in ipairs(vEventTypeNames) do
		GroupCalendar.DefaultEventLimits[vEventType] = {}
		GroupCalendar.DefaultEventLevel[vEventType] = {}
		
		if vEventType == CALENDAR_EVENTTYPE_RAID or vEventType == CALENDAR_EVENTTYPE_DUNGEON or vEventType == CALENDAR_EVENTTYPE_HEROIC_DUNGEON then
			local vEventTypeTextures = GroupCalendar:GetEventTypeTextures(vEventType)
			
			for vTextureIndex, vTextureInfo in ipairs(vEventTypeTextures) do
				local vLimit, vMinLevel
				
				-- Dungeons are always 5-man
				
				if vEventType == CALENDAR_EVENTTYPE_DUNGEON or vEventType == CALENDAR_EVENTTYPE_HEROIC_DUNGEON then
					vLimit = 5
					
					if vTextureInfo.ExpLevel == 1 then
						vMinLevel = 60
					elseif vTextureInfo.ExpLevel == 2 then
						vMinLevel = 70
					else
						vMinLevel = 10
					end
					
				-- Classic raids are 20 for ZG and AQR and 40 for everything else
				
				elseif vTextureInfo.ExpLevel == 0 then
					
					if vTextureInfo.TextureName == "LFGIcon-ZulGurub"
					or vTextureInfo.TextureName == "LFGIcon-AQRuins" then
						vLimit = 20
						vMinLevel = 58
					else
						vLimit = 40
						vMinLevel = 58
					end
				
				-- TBC raids are 10-man for Karazhan and Zul'Aman, 25 for everything else
				
				elseif vTextureInfo.ExpLevel == 0 then
					
					if vTextureInfo.TextureName == "LFGIcon-Karazhan"
					or vTextureInfo.TextureName == "LFGIcon-ZulAman" then
						vLimit = 10
						vMinLevel = 68
					else
						vLimit = 25
						vMinLevel = 70
					end
					
				-- WotLK raids are 10-man for non-heroic, 25 for
				-- heroic (I'm assuming this is the default for the future too)
				
				else
					
					if vTextureInfo.Name and vTextureInfo.Name:sub(-1) == ")" then -- Cheesy, but what else is there?
						vLimit = 25
						vMinLevel = 80
					else
						vLimit = 10
						vMinLevel = 78
					end
				end
				
				GroupCalendar.DefaultEventLimits[vEventType][vTextureIndex] = vLimit
				GroupCalendar.DefaultEventLevel[vEventType][vTextureIndex] = vMinLevel
			end -- for vTextureIndex
		end -- if vEventType
	end -- for vEventType
end

----------------------------------------
GroupCalendar._BaseEventMethods = {}
----------------------------------------

----------------------------------------
-- Get

function GroupCalendar._BaseEventMethods:GetTexture()
	if not GroupCalendar.EventTypeTextures then
		GroupCalendar.EventTypeTextures = {}
	end
	
	local vEventTypeTextures = GroupCalendar:GetEventTypeTextures(self.EventType)
	
	return GroupCalendar:GetTextureFile(
		self.TextureIndex and vEventTypeTextures[self.TextureIndex] and vEventTypeTextures[self.TextureIndex].TextureName,
		self.CalendarType, self.NumSequenceDays ~= 2 and self.SequenceType or "", self.EventType, self.TitleTag)
end

function GroupCalendar._BaseEventMethods:GetLocation()
	local vEventTypeTextures = GroupCalendar:GetEventTypeTextures(self.EventType)
	
	if not vEventTypeTextures
	or not vEventTypeTextures[self.TextureIndex] then
		return ""
	end
	
	return vEventTypeTextures[self.TextureIndex].Name
end

function GroupCalendar._BaseEventMethods:GetEventColor()
	if self:IsPlayerCreated() then
		if GroupCalendar.CALENDAR_INVITESTATUS_COLORS[self.InviteStatus] then
			return GroupCalendar.CALENDAR_INVITESTATUS_COLORS[self.InviteStatus]
		end
	elseif GroupCalendar.CALENDAR_CALENDARTYPE_COLORS[self.CalendarType] then
		return GroupCalendar.CALENDAR_CALENDARTYPE_COLORS[self.CalendarType]
	end
	
	-- Default to normal color
	
	return NORMAL_FONT_COLOR
end

function GroupCalendar._BaseEventMethods:GetLevelRange()
	return self.MinLevel, self.MaxLevel
end

function GroupCalendar._BaseEventMethods:GetLimits()
	return self.Limits
end

function GroupCalendar._BaseEventMethods:GetDefaultPartySize()
	if not GroupCalendar.DefaultEventLimits then
		GroupCalendar:InitializeEventDefaults()
	end
	
	if not GroupCalendar.DefaultEventLimits[self.EventType] then
		return
	else
		return GroupCalendar.DefaultEventLimits[self.EventType][self.TextureIndex],
		       GroupCalendar.DefaultEventLevel[self.EventType][self.TextureIndex]
	end
end

function GroupCalendar._BaseEventMethods:GetUID()
	if self.CalendarType == "HOLIDAY"
	or self.CalendarType == "SYSTEM"
	or self.CalendarType == "RAID_RESET" then
		return string.format("%s//%04d%02d%02d//%d", self.CalendarType, self.Year, self.Month, self.Day, self.Index)
	end
	
	if not self.UID then
		self.UID = math.random(1000000)
	end
	
	return self.RealmName.."//"..self.OwnersName.."//"..self.UID
end

function GroupCalendar._BaseEventMethods:GetCreationDateTime()
	if not self.CreationDate then
		self.CreationDate, self.CreationTime = GroupCalendar.DateLib:GetServerDateTime()
	end
	
	return self.CreationDate, self.CreationTime
end

function GroupCalendar._BaseEventMethods:GetModifiedDateTime()
	if not self.CreationDate then
		self.CacheUpdateDate, self.CacheUpdateTime = GroupCalendar.DateLib:GetServerDateTime()
	end
	
	return self.CacheUpdateDate, self.CacheUpdateTime
end

function GroupCalendar._BaseEventMethods:GetSecondsToStart(pCurrentDateTimeStamp)
	local vDate = GroupCalendar.DateLib:ConvertMDYToDate(self.Month, self.Day, self.Year)
	local vTime60 = GroupCalendar.DateLib:ConvertHMSToTime60(self.Hour, self.Minute, 0) or 0
	local vDateTimeStamp = vDate * GroupCalendar.DateLib.cSecondsPerDay + vTime60
	
	return vDateTimeStamp - pCurrentDateTimeStamp
end

function GroupCalendar._BaseEventMethods:HasPassed(pCurrentDateTimeStamp)
	local vDuration = (self.Duration or (4 * 60)) * 60
	
	return self:GetSecondsToStart(pCurrentDateTimeStamp) + vDuration < 0
end

----------------------------------------
-- Status

function GroupCalendar._BaseEventMethods:IsAllDayEvent()
	if self.SequenceType == "ONGOING" then
		return true
	end

	if self.TitleTag
	and GroupCalendar.TitleTagInfo[self.TitleTag] then
		return GroupCalendar.TitleTagInfo[self.TitleTag].AllDay
	end
	
	return false
end

function GroupCalendar._BaseEventMethods:IsCooldownEvent()
	if self.CalendarType == "RAID_LOCKOUT" then
		return true
	end
	    
	if self.TitleTag
	and GroupCalendar.TitleTagInfo[self.TitleTag] then
		return GroupCalendar.TitleTagInfo[self.TitleTag].IsCooldown
	end
	
	return self.TitleTag ~= nil
end

function GroupCalendar._BaseEventMethods:IsBirthdayEvent()
	return self.TitleTag == "BRTH"
end

function GroupCalendar._BaseEventMethods:IsPersonalEvent()
	if self.TitleTag
	and GroupCalendar.TitleTagInfo[self.TitleTag] then
		return GroupCalendar.TitleTagInfo[self.TitleTag].IsPersonal
	end
	
	return (self.CalendarType == "PLAYER" or self.CalendarType == "GUILD_EVENT" or self.CalendarType == "GUILD" or self.CalendarType == "GUILD_ANNOUNCEMENT" or self.CalendarType == "COMMUNITY_EVENT")
	   and self.TitleTag ~= nil
end

function GroupCalendar._BaseEventMethods:IsDungeonEvent()
	return (self.CalendarType == "PLAYER" or self.CalendarType == "GUILD_EVENT" or self.CalendarType == "GUILD" or self.CalendarType == "GUILD_ANNOUNCEMENT" or self.CalendarType == "COMMUNITY_EVENT")
	   and self.TitleTag == nil
end

function GroupCalendar._BaseEventMethods:IsSignupEvent()
	return self.InviteType == CALENDAR_INVITETYPE_SIGNUP
end

function GroupCalendar._BaseEventMethods:IsAnnouncementEvent()
	return self.CalendarType == "GUILD_ANNOUNCEMENT" or self.CalendarType == "GUILD"
end

function GroupCalendar._BaseEventMethods:IsPlayerCreated()
	return self.CalendarType == "PLAYER"
	    or self.CalendarType == "GUILD"
		or self.CalendarType == "GUILD_ANNOUNCEMENT"
		or self.CalendarType == "GUILD_EVENT"
		or self.CalendarType == "ARENA"
		or self.CalendarType == "COMMUNITY_EVENT"
end

function GroupCalendar._BaseEventMethods:UsesLevelLimits()
	if self.TitleTag
	and GroupCalendar.TitleTagInfo[self.TitleTag] then
		return GroupCalendar.TitleTagInfo[self.TitleTag].UsesLevelLimits
	end
	
	return (self.CalendarType == "PLAYER"
	     or self.CalendarType == "GUILD"
	     or self.CalendarType == "GUILD_EVENT"
	     or self.CalendarType == "GUILD_ANNOUNCEMENT"
	     or self.CalendarType == "COMMUNITY_EVENT")
	   and self.TitleTag == nil
end

function GroupCalendar._BaseEventMethods:UsesAttendance()
	if self.TitleTag
	and GroupCalendar.TitleTagInfo[self.TitleTag] then
		return GroupCalendar.TitleTagInfo[self.TitleTag].UsesAttendance
	end
	
	return (self.CalendarType == "PLAYER" or self.CalendarType == "GUILD_EVENT" or self.CalendarType == "COMMUNITY_EVENT")
	   and (self.TitleTag == nil or self.TitleTag == "")
end

function GroupCalendar._BaseEventMethods:PlayerIsQualified()
	return true
end

function GroupCalendar._BaseEventMethods:IsExpired()
	local vServerDate, vServerTime = GroupCalendar.DateLib:GetServerDateTime()
	local vEventDate, vEventTime = GroupCalendar.DateLib:ConvertMDYToDate(self.Month, self.Day, self.Year), GroupCalendar.DateLib:ConvertHMToTime(self.Hour, self.Minute)
	
	return vEventDate < vServerDate or (vEventDate == vServerDate and vEventTime and vEventTime < vServerTime)
end

function GroupCalendar._BaseEventMethods:EventIsVisible(pIsPlayerEvent)
	if not self:IsPlayerCreated() then
		return true
	end
	
	if pIsPlayerEvent then
		return true
	end
	
	return self.ModStatus == "CREATOR" or self:IsAttending()
end

function GroupCalendar._BaseEventMethods:IsAttending()
	return not self.TitleTag
	and (self.InviteStatus == CALENDAR_INVITESTATUS_ACCEPTED
	    or self.InviteStatus == CALENDAR_INVITESTATUS_TENTATIVE
	    or self.InviteStatus == CALENDAR_INVITESTATUS_SIGNEDUP
	    or self.InviteStatus == CALENDAR_INVITESTATUS_CONFIRMED
	    or self.InviteStatus == CALENDAR_INVITESTATUS_STANDBY)
end

function GroupCalendar._BaseEventMethods:GetAttendance()
	return self.Attendance
end

function GroupCalendar._BaseEventMethods:GetInviteStatus(pPlayerName)
	local vAttendance = self:GetAttendance()
	
	if not vAttendance then
		if pPlayerName == self.OwnersName then
			return self.InviteStatus
		elseif self.CalendarType == "GUILD_EVENT" or self.CalendarType == "COMMUNITY_EVENT" then
			return CALENDAR_INVITESTATUS_NOT_SIGNEDUP
		else
			return
		end
	end
	
	if not vAttendance[pPlayerName] then
		if self.CalendarType == "GUILD_EVENT" or self.CalendarType == "COMMUNITY_EVENT" then
			return CALENDAR_INVITESTATUS_NOT_SIGNEDUP
		else
			return
		end
	end
	
	return vAttendance[pPlayerName].InviteStatus
end

----------------------------------------
GroupCalendar._APIEventMethods = {}
----------------------------------------

for vKey, vValue in pairs(GroupCalendar._BaseEventMethods) do
	GroupCalendar._APIEventMethods[vKey] = vValue
end

function GroupCalendar._APIEventMethods:NewEvent(pOwnersName, pMonth, pDay, pYear, pCalendarType)
	self.Month = pMonth
	self.Day = pDay
	self.Year = pYear
	self.Index = nil
	
	self.OwnersName = pOwnersName
	self.RealmName = GroupCalendar.RealmName
	
	self.Title = ""
	self.TitleTag = nil
	self.Hour = 20
	self.Minute = 0
	self.Duration = 180
	self.MinLevel = nil
	self.MaxLevel = nil
	
	if pCalendarType then
		self.CalendarType = pCalendarType
	elseif CanEditGuildEvent() then
		self.CalendarType = "GUILD_EVENT"
	else
		self.CalendarType = "PLAYER"
	end
	
	self.SequenceType = nil
	self.EventType = CALENDAR_EVENTTYPE_OTHER
	self.TextureID = nil
	self.ModStatus = "CREATOR"
	self.InviteStatus = CALENDAR_INVITESTATUS_CONFIRMED
	self.InvitedBy = GroupCalendar.PlayerName
	self.InviteType = CALENDAR_INVITETYPE_NORMAL
	
	self.Difficulty = nil
	
	self.Description = ""
	self.DescriptionTag = nil
end

function GroupCalendar._APIEventMethods:SetEvent(pOwnersName, pMonth, pDay, pYear, pIndex)
	if not pIndex then
		return self:NewEvent(pOwnersName, pMonth, pDay, pYear)
	end
	
	self.Month = pMonth
	self.Day = pDay
	self.Year = pYear
	self.Index = pIndex
	
	self.OwnersName = pOwnersName
	self.RealmName = GroupCalendar.RealmName
	
	local monthOffset = GroupCalendar.WoWCalendar:GetMonthOffset(self.Month, self.Year)
	local event = GroupCalendar.WoWCalendar:GetDayEvent(monthOffset, self.Day, self.Index)

	self.Title = event.title

	if (event.sequenceType == "END") then
		self.Hour = event.endTime.hour;
		self.Minute = event.endTime.minute;
	else
		self.Hour = event.startTime.hour;
		self.Minute = event.startTime.minute;
	end

	self.CalendarType = event.calendarType
	self.SequenceType = event.sequenceType
	self.EventType = event.eventType
	self.TextureID = event.iconTexture
	self.ModStatus = event.modStatus
	self.InviteStatus = event.inviteStatus
	self.InvitedBy = event.invitedBy
	self.Difficulty = event.difficulty
	self.InviteType = event.inviteType
	self.SequenceIndex = event.sequenceType
	self.NumSequenceDays = event.numSequenceDays
	self.DifficultyName = event.difficultyName
	self.DontDisplayBanner = event.dontDisplayBanner
	self.DontDisplayEnd = event.dontDisplayEnd

	self.TitleTag = GroupCalendar.WoWCalendar:EventGetTitleTag()
	
	self.EventCanComplain = GroupCalendar.WoWCalendar:ContextMenuEventCanComplain(monthOffset, self.Day, self.Index)
	
	-- Correct the calendar type
	self:ContextSelectEvent()
	local currentCalendarType = GroupCalendar.WoWCalendar:ContextMenuEventGetCalendarType() 
	if self.CalendarType == "GUILD" and currentCalendarType ~= "GUILD" then
		self.CalendarType = "PLAYER"
	end
	
	if self.Difficulty == ""
	or self.Difficulty == 0 then
		self.Difficulty = nil
	end
	
	if self.Difficulty then
		self.Title = string.format(DUNGEON_NAME_WITH_DIFFICULTY, self.Title or "nil", self.DifficultyName or "nil")
	end
	
	self.Title = GroupCalendar.WoWCalendar:GetDisplayTitle(self.CalendarType, self.SequenceType, self.Title)
	
	if self.CalendarType == "HOLIDAY" then
		local holidayInfo = GroupCalendar.WoWCalendar:GetHolidayInfo(monthOffset, self.Day, self.Index)
		self.Description = holidayInfo.description
	elseif self.CalendarType == "RAID_LOCKOUT"
	or self.CalendarType == "RAID_RESET" then
		self.Description = ""
	end
	
	if self.SequenceType == "ONGOING" then
		self.Hour = nil
		self.Minute = nil
	end
	
	if not self.InvitedBy or self.InvitedBy == "" then
		self.InvitedBy = (self.CalendarType == "RAID_LOCKOUT" and GroupCalendar.PlayerData.Name)
		              or (self.CalendarType == "HOLIDAY" and "Holiday")
		              or (self.CalendarType == "SYSTEM" and GroupCalendar.cBlizzardOwner)
		              or (self.CalendarType == "RAID_RESET" and GroupCalendar.cBlizzardOwner)
	end
end

function GroupCalendar._APIEventMethods:Open()
	if GroupCalendar.WoWCalendar.OpenedEvent then
		GroupCalendar.WoWCalendar.OpenedEvent:Close()
	end
	
	SetCVar("calendarShowLockouts", 1) -- Make sure this is on so indices are correct
	
	if self.Index then
		GroupCalendar.WoWCalendar:OpenEvent(GroupCalendar.WoWCalendar:GetMonthOffset(self.Month, self.Year), self.Day, self.Index)
		GroupCalendar.WoWCalendar.OpenedEvent = self
	else
		if self.CalendarType == "GUILD_EVENT" then
			GroupCalendar.WoWCalendar:CreateGuildSignUpEvent()
		elseif self.CalendarType == "GUILD_ANNOUNCEMENT" then
			GroupCalendar.WoWCalendar:CreateGuildAnnouncementEvent()
		elseif self.CalendarType == "COMMUNITY_EVENT" then
			GroupCalendar.WoWCalendar:CreateCommunitySignUpEvent()
		else
			GroupCalendar.WoWCalendar:CreatePlayerEvent()
		end
		
		GroupCalendar.WoWCalendar.OpenedEvent = self
		
		self:InitializeNewEvent()
	end
	
	GroupCalendar.EventLib:RegisterEvent("CALENDAR_OPEN_EVENT", self.CalendarOpenEvent, self)
	GroupCalendar.EventLib:RegisterEvent("CALENDAR_CLOSE_EVENT", self.EventClosed, self)
	GroupCalendar.EventLib:RegisterEvent("CALENDAR_UPDATE_EVENT", self.CalendarUpdateEvent, self)
	GroupCalendar.EventLib:RegisterEvent("CALENDAR_UPDATE_INVITE_LIST", self.CalendarUpdateEventInvites, self)
	GroupCalendar.EventLib:RegisterEvent("CALENDAR_UPDATE_ERROR", self.CalendarUpdateError, self)
	
	if self.OriginalEvent then
		GroupCalendar.BroadcastLib:Listen(self.OriginalEvent, self.ShadowEventMessage, self)
	end
end

function GroupCalendar._APIEventMethods:InitializeNewEvent()
	GroupCalendar.WoWCalendar:EventSetDate(self.Month, self.Day, self.Year)
	
	GroupCalendar.WoWCalendar:EventSetTime(self.Hour or 0, self.Minute or 0)
	
	GroupCalendar.WoWCalendar:EventSetTitle(self.Title)
	GroupCalendar.WoWCalendar:EventSetTitleTag(self.TitleTag)
	GroupCalendar.WoWCalendar:EventSetDescription(self.Description)
	GroupCalendar.WoWCalendar:EventSetDescriptionTag(self.DescriptionTag)
	GroupCalendar.WoWCalendar:EventSetType(self.EventType)
	if self.TextureIndex then
		GroupCalendar.WoWCalendar:EventSetTextureID(self.TextureIndex)
	end
	
	self:GetEventInfo()
end

function GroupCalendar._APIEventMethods:SetEventMode(pMode)
	if self.Index then
		return -- Can't change mode on an existing event
	end
	
	if pMode == "SIGNUP" and CanEditGuildEvent() then
		if self.CalendarType == "GUILD_EVENT" then
			return
		end
		
		self.ChangingMode = true
		GroupCalendar.WoWCalendar:CloseEvent()
		GroupCalendar.WoWCalendar:CreateGuildSignUpEvent()
		self.ChangingMode = nil
	
		self.CalendarType = "GUILD_EVENT"
		self.InviteType = CALENDAR_INVITETYPE_NORMAL
	elseif pMode == "ANNOUNCE" and CanEditGuildEvent() then
		if self.CalendarType == "GUILD_ANNOUNCEMENT" then
			return
		end
		
		self.ChangingMode = true
		GroupCalendar.WoWCalendar:CloseEvent()
		GroupCalendar.WoWCalendar:CreateGuildAnnouncementEvent()
		self.ChangingMode = nil
		
		self.CalendarType = "GUILD_ANNOUNCEMENT"
		self.InviteType = CALENDAR_INVITETYPE_NORMAL
	elseif pMode == "COMMUNITY" then
		if self.CalendarType == "COMMUNITY_EVENT" then
			return
		end
		
		self.ChangingMode = true
		GroupCalendar.WoWCalendar:CloseEvent()
		GroupCalendar.WoWCalendar:CreateCommunitySignUpEvent()
		self.ChangingMode = nil
		
		self.CalendarType = "COMMUNITY_EVENT"
		self.InviteType = CALENDAR_INVITETYPE_NORMAL
	else
		if self.CalendarType == "PLAYER" then
			return
		end
		
		self.ChangingMode = true
		GroupCalendar.WoWCalendar:CloseEvent()
		GroupCalendar.WoWCalendar:CreatePlayerEvent()
		self.ChangingMode = nil
		
		self.CalendarType = "PLAYER"
		self.InviteType = CALENDAR_INVITETYPE_NORMAL
	end
	
	GroupCalendar.WoWCalendar.OpenedEvent = self
	
	self:InitializeNewEvent()
	
	GroupCalendar.BroadcastLib:Broadcast(self, "CHANGED")
end

function GroupCalendar._APIEventMethods:Close()
	assert(GroupCalendar.WoWCalendar.OpenedEvent == self)
	
	GroupCalendar.WoWCalendar:CloseEvent()
end

function GroupCalendar._APIEventMethods:GetShadowCopy()
	local vEvent = GroupCalendar:DuplicateTable(self, true)
	
	vEvent.OriginalEvent = self
	vEvent.Group = self.Group -- Don't clone the group
	
	setmetatable(vEvent, getmetatable(self))
	
	return vEvent
end

function GroupCalendar._APIEventMethods:ShadowEventMessage(pEvent, pMessageID, ...)
	if pMessageID == "CHANGED" then
		for vField, vValue in pairs(self.OriginalEvent) do
			if type(vValue) ~= "table" then
				self[vField] = vValue
			else
				-- Attendance needs to be merged?
			end
		end
	end
	
	GroupCalendar.BroadcastLib:Broadcast(self, pMessageID, ...)
end

function GroupCalendar._APIEventMethods:IsOpened()
	return GroupCalendar.WoWCalendar.OpenedEvent == self
end

function GroupCalendar._APIEventMethods:Save()
	assert(GroupCalendar.WoWCalendar.OpenedEvent == self)
	
	self:UpdateDescriptionTag()
	
	if self.Index then
		GroupCalendar.WoWCalendar:UpdateEvent()
	else
		GroupCalendar.WoWCalendar:AddEvent()
	end
end

function GroupCalendar._APIEventMethods:Copy()
	self:ContextSelectEvent()
	GroupCalendar.WoWCalendar:ContextMenuEventCopy()
end

function GroupCalendar._APIEventMethods:Delete()
	-- If there's an index then it's an existing event
	if self.Index then
		
		-- Select the event for the ContextMenu* API
		self:ContextSelectEvent()
		
		-- Remove the event or the invitation, as appropriate
		if self.ModStatus == "CREATOR" then
			GroupCalendar.WoWCalendar:ContextMenuEventRemove()
		else
			GroupCalendar.WoWCalendar:ContextInviteRemove()
		end

	-- Nothing to do for new events
	else
	end
end

function GroupCalendar._APIEventMethods:LoadDefaults()
	local vPartySize, vMinLevel = self:GetDefaultPartySize()
	
	--[[ Don't bother setting default limits since they're not supported yet
	if vPartySize then
		self.Limits = GroupCalendar:DuplicateTable(GroupCalendar.DefaultLimits[vPartySize], true)
	end
	]]
	
	self:SetLevelRange(vMinLevel, nil)
	
	local vEventTypeTextures = GroupCalendar:GetEventTypeTextures(self.EventType)
	
	if vEventTypeTextures and vEventTypeTextures[self.TextureIndex] then
		self:SetTitle(vEventTypeTextures[self.TextureIndex].Name)
	end
	
	local vDefaults = self.TitleTag
	              and GroupCalendar.TitleTagInfo[self.TitleTag]
	              and GroupCalendar.TitleTagInfo[self.TitleTag].Defaults
	
	if vDefaults then
		-- Change the mode
		
		if vDefaults.CalendarType == "GUILD_ANNOUNCEMENT" then
			self:SetEventMode("ANNOUNCE")
		elseif vDefaults.CalendarType == "GUILD_EVENT" then
			self:SetEventMode("SIGNUP")
		elseif vDefaults.CalendarType == "COMMUNITY_EVENT" then
			self:SetEventMode("COMMUNITY")
		elseif vDefaults.CalendarType == "PLAYER" then
			self:SetEventMode("NORMAL")
		end
		
		-- Set the title
		
		if vDefaults.Title then
			self:SetTitle(vDefaults.Title:format(GroupCalendar.PlayerName))
		end
	end
	
	-- Clear out fields which aren't used
	
	if self:IsAllDayEvent() then
		self.Hour = 0 -- Midnight
		self.Minute = 0
		self.Duration = 1440 -- 24 hours
	end
	
	if not self:UsesLevelLimits() then
		self.MinLevel = nil
		self.MaxLevel = nil
	end
end

----------------------------------------
-- Get

function GroupCalendar._APIEventMethods:CanSendInvite(pIgnoreOpenedEvent)
	assert(GroupCalendar.WoWCalendar.OpenedEvent == self or pIgnoreOpenedEvent)
	
	return GroupCalendar.WoWCalendar:CanSendInvite()
end

function GroupCalendar._APIEventMethods:GetEventInfo(pIgnoreOpenedEvent)
	local changed
	
	if not pIgnoreOpenedEvent then
		assert(GroupCalendar.WoWCalendar.OpenedEvent == self)
	end
	
	if self.ChangingMode then
		return
	end
	
	local eventInfo = GroupCalendar.WoWCalendar:GetEventInfo()
	
	if eventInfo.textureIndex == 0 then
		eventInfo.textureIndex = nil
	end
	
	if self.TextureIndex ~= eventInfo.textureIndex then
		self.TextureIndex = eventInfo.textureIndex
		changed = true
	end
	
	if self.Description ~= eventInfo.description then
		self.Description = eventInfo.description
		changed = true
	end
	
	if self.Creator ~= eventInfo.creator then
		self.Creator = eventInfo.creator
		changed = true
	end
	
	if self.RepeatOption ~= eventInfo.repeatOption then
		self.RepeatOption = eventInfo.repeatOption
		changed = true
	end
	
	if self.MaxSize ~= eventInfo.maxSize then
		self.MaxSize = eventInfo.maxSize
		changed = true
	end
	
	if self.LockoutWeekday ~= eventInfo.lockoutWeekday then
		self.LockoutWeekday = eventInfo.lockoutWeekday
		changed = true
	end
	
	if self.LockoutMonth ~= eventInfo.lockoutMonth then
		self.LockoutMonth = eventInfo.lockoutMonth
		changed = true
	end
	
	if self.LockoutDay ~= eventInfo.lockoutDay then
		self.LockoutDay = eventInfo.lockoutDay
		changed = true
	end
	
	if self.LockoutYear ~= eventInfo.lockoutYear then
		self.LockoutYear = eventInfo.lockoutYear
		changed = true
	end
	
	if self.LockoutHour ~= eventInfo.lockoutHour then
		self.LockoutHour = eventInfo.lockoutHour
		changed = true
	end
	
	if self.LockoutMinute ~= eventInfo.lockoutMinute then
		self.LockoutMinute = eventInfo.lockoutMinute
		changed = true
	end
	
	if self.Locked ~= eventInfo.isLocked then
		self.Locked = eventInfo.isLocked
		changed = true
	end
	
	if self.AutoApprove ~= eventInfo.autoApprove then
		self.AutoApprove = eventInfo.autoApprove
		changed = true
	end
	
	if self.PendingInvite ~= eventInfo.pendingInvite then
		self.PendingInvite = eventInfo.pendingInvite
		changed = true
	end
	
	if self.InviteStatus ~= eventInfo.inviteStatus then
		self.InviteStatus = eventInfo.inviteStatus
		changed = true
	end
	
	if self.InviteType ~= eventInfo.inviteType then
		self.InviteType = eventInfo.inviteType
		changed = true
	end
	
	if self.CalendarType ~= eventInfo.calendarType then
		self.CalendarType = eventInfo.calendarType
		changed = true
	end
	
	if self:DecodeDescriptionTag() then
		changed = true
	end
	
	if self:RefreshAttendance(pIgnoreOpenedEvent) then
		changed = true
	end
	
	self.CacheUpdateDate, self.CacheUpdateTime = GroupCalendar.DateLib:GetServerDateTime()
	
	if changed then
		GroupCalendar.BroadcastLib:Broadcast(self, "CHANGED")
	end
	
	if self.OriginalEvent then
		self.OriginalEvent:GetEventInfo(true)
	end
	
	return changed
end

function GroupCalendar._APIEventMethods:GetEventAttendance(pIgnoreOpenedEvent)
	if not pIgnoreOpenedEvent then
		assert(GroupCalendar.WoWCalendar.OpenedEvent == self)
	end
	
	if self.ChangingMode then
		return
	end
	
	local vChanged
	
	if self:RefreshAttendance(pIgnoreOpenedEvent) then
		vChanged = true
	end
	
	self.CacheUpdateDate, self.CacheUpdateTime = GroupCalendar.DateLib:GetServerDateTime()
	
	if vChanged then
		GroupCalendar.BroadcastLib:Broadcast(self, "CHANGED")
	end
	
	if self.OriginalEvent then
		self.OriginalEvent:GetEventAttendance(true)
	end
	
	return vChanged
end

function GroupCalendar._APIEventMethods:DecodeDescriptionTag()
	local vDescriptionTag = GroupCalendar.WoWCalendar:EventGetDescriptionTag()
	local vChanged
	
	if not self.DescriptionTags then
		self.DescriptionTags = {}
	else
		for vKey, _ in pairs(self.DescriptionTags) do
			self.DescriptionTags[vKey] = nil
		end
	end
	
	if vDescriptionTag then
		for vTag, vParameters in vDescriptionTag:gmatch("(%w+):?([^/]*)") do
			self.DescriptionTags[vTag] = vParameters
		end
	end
	
	if self.DescriptionTags.L then
		local _, _, vMin, vMax = self.DescriptionTags.L:find("(.*),(.*)")
		
		vMin = tonumber(vMin)
		vMax = tonumber(vMax)
		
		if vMin ~= self.MinLevel then
			self.MinLevel = vMin
			vChanged = true
		end
		
		if vMax ~= self.MaxLevel then
			self.MaxLevel = vMax
			vChanged = true
		end
	else
		if self.MinLevel then
			self.MinLevel = nil
			vChanged = true
		end
		
		if self.MaxLevel then
			self.MaxLevel = nil
			vChanged = true
		end
	end
	
	if self.DescriptionTags.D then
		local vDuration = tonumber(self.DescriptionTags.D)
		
		if vDuration ~= self.Duration then
			self.Duration = vDuration
			vChanged = true
		end
	elseif self.Duration then
		self.Duration = nil
		vChanged = true
	end
	
	if self.DescriptionTags.C then
		self.Limits = {}
		
		for vTagData in self.DescriptionTags.C:gmatch("[^:]+") do
			if vTagData == "ROLE" then
				self.Limits.Mode = "ROLE"
				self.Limits.RoleLimits = {}
			else
				local _, _, vRoleCode, vMin, vMax, vClassReservations = vTagData:find("(.)(%d*),?(%d*)(.*)")
				
				if vRoleCode == "X" then
					self.Limits.MaxAttendance = tonumber(vMin)
				elseif vRoleCode == "H"
				    or vRoleCode == "T"
				    or vRoleCode == "R"
				    or vRoleCode == "M" then
					local vRoleLimit = {}
					
					vRoleLimit.Min = tonumber(vMin)
					vRoleLimit.Max = tonumber(vMax)
					
					if vClassReservations ~= "" then
						vRoleLimit.Class = {}
						
						for vClassCode, vClassMin in vClassReservations:gmatch("([A-Z])(%d*)") do
							local vClassID = GroupCalendar.ClassInfoByClassCode[vClassCode].ClassID
							vRoleLimit.Class[vClassID] = tonumber(vClassMin)
						end
					end
					
					self.Limits.RoleLimits[vRoleCode] = vRoleLimit
				end
			end
		end
	elseif self.Limits then
		self.Limits = nil
		vChanged = true
	end

	return vChanged
end

----------------------------------------
-- Set

function GroupCalendar._APIEventMethods:SetDate(pMonth, pDay, pYear)
	assert(GroupCalendar.WoWCalendar.OpenedEvent == self)
	
	self.Month, self.Day, self.Year = pMonth, pDay, pYear
	GroupCalendar.WoWCalendar:EventSetDate(pMonth, pDay, pYear)
end

function GroupCalendar._APIEventMethods:SetTime(pHour, pMinute)
	assert(GroupCalendar.WoWCalendar.OpenedEvent == self)
	
	self.Hour, self.Minute = pHour, pMinute
	GroupCalendar.WoWCalendar:EventSetTime(pHour or 0, pMinute or 0)
end

function GroupCalendar._APIEventMethods:SetLockoutDate(pMonth, pDay, pYear)
	assert(GroupCalendar.WoWCalendar.OpenedEvent == self)
	
	self.LockoutMonth, self.LockoutDay, self.LockoutYear = pMonth, pDay, pYear
	GroupCalendar.WoWCalendar:EventSetLockoutDate(pMonth, pDay, pYear)
end

function GroupCalendar._APIEventMethods:SetLockoutTime(pHour, pMinute)
	assert(GroupCalendar.WoWCalendar.OpenedEvent == self)
	
	self.LockoutHour, self.LockoutMinute = pHour, pMinute
	GroupCalendar.WoWCalendar:EventSetLockoutTime(pHour, pMinute)
end

function GroupCalendar._APIEventMethods:SetTitle(pTitle)
	assert(GroupCalendar.WoWCalendar.OpenedEvent == self)
	
	self.Title = pTitle
	GroupCalendar.WoWCalendar:EventSetTitle(pTitle)
end

function GroupCalendar._APIEventMethods:SetTitleTag(pTitleTag)
	assert(GroupCalendar.WoWCalendar.OpenedEvent == self)
	
	self.TitleTag = pTitleTag
	GroupCalendar.WoWCalendar:EventSetTitleTag(pTitleTag)
end

function GroupCalendar._APIEventMethods:SetDescription(pDescription)
	assert(GroupCalendar.WoWCalendar.OpenedEvent == self)
	
	self.Description = pDescription
	GroupCalendar.WoWCalendar:EventSetDescription(pDescription)
end

function GroupCalendar._APIEventMethods:SetDescriptionTag(pDescriptionTag)
	assert(GroupCalendar.WoWCalendar.OpenedEvent == self)
	
	self.DescriptionTag = pDescriptionTag
	GroupCalendar.WoWCalendar:EventSetDescriptionTag(pDescriptionTag)
	GroupCalendar.BroadcastLib:Broadcast(self, "CHANGED")
end

function GroupCalendar._APIEventMethods:SetType(pEventType, pTextureIndex)
	assert(GroupCalendar.WoWCalendar.OpenedEvent == self)
	
	self.EventType = pEventType
	self.TextureIndex = pTextureIndex
	
	GroupCalendar.WoWCalendar:EventSetType(pEventType)
	
	if self.TextureIndex then
		GroupCalendar.WoWCalendar:EventSetTextureID(self.TextureIndex)
	end
end

function GroupCalendar._APIEventMethods:SetRepeatOption(pRepeatOption)
	assert(GroupCalendar.WoWCalendar.OpenedEvent == self)
	
	self.RepeatOption = pRepeatOption
	GroupCalendar.WoWCalendar:EventSetRepeatOption(pRepeatOption)
end

function GroupCalendar._APIEventMethods:SetLocked(pLocked)
	assert(GroupCalendar.WoWCalendar.OpenedEvent == self)
	
	if pLocked then
		GroupCalendar.WoWCalendar:EventSetLocked()
	else
		GroupCalendar.WoWCalendar:EventClearLocked()
	end
end

function GroupCalendar._APIEventMethods:SetDuration(pMinutes)
	self.Duration = pMinutes
	self:UpdateDescriptionTag()
end

function GroupCalendar._APIEventMethods:SetLimits(pLimits)
	self.Limits = GroupCalendar:DuplicateTable(pLimits, true)
	self:UpdateDescriptionTag()
end

function GroupCalendar._APIEventMethods:SetLevelRange(pMinLevel, pMaxLevel)
	assert(GroupCalendar.WoWCalendar.OpenedEvent == self)
	
	self.MinLevel = pMinLevel
	self.MaxLevel = pMaxLevel
	
	self:UpdateDescriptionTag()
end

function GroupCalendar._APIEventMethods:UpdateDescriptionTag()
	if not self.DescriptionTags then
		self.DescriptionTags = {}
	end
	
	if self.MinLevel or self.MaxLevel then
		self.DescriptionTags.L = (self.MinLevel or "")..","..(self.MaxLevel or "")
	else
		self.DescriptionTags.L = nil
	end
	
	if self.Duration then
		self.DescriptionTags.D = tostring(self.Duration)
	else
		self.DescriptionTags.D = nil
	end
	
	if self.Limits then
		self.DescriptionTags.C = self:GetAutoConfirmString()
	else
		self.DescriptionTags.C = nil
	end
	
	local vDescriptionTag
	
	for vTag, vValue in pairs(self.DescriptionTags) do
		if vDescriptionTag then
			vDescriptionTag = vDescriptionTag.."/"..vTag..":"..vValue
		else
			vDescriptionTag = vTag..":"..vValue
		end
	end
	
	self:SetDescriptionTag(vDescriptionTag)
end

function GroupCalendar._APIEventMethods:GetAutoConfirmString()
	local vString = "ROLE"
	
	if self.Limits then
		if self.Limits.MaxAttendance then
			vString = vString..":X"..self.Limits.MaxAttendance
		end
		
		if self.Limits.RoleLimits then
			for vRoleCode, vRoleLimit in pairs(self.Limits.RoleLimits) do
				vString = vString..":"..vRoleCode..(vRoleLimit.Min or "")..","..(vRoleLimit.Max or "")
				
				if vRoleLimit.Class then
					for vClassID, vClassLimit in pairs(vRoleLimit.Class) do
						local vClassCode = GroupCalendar.ClassInfoByClassID[vClassID].ClassCode
						
						vString = vString..vClassCode..vClassLimit
					end
				end
			end
		end
	end
	
	return vString
end

----------------------------------------
-- Attendance

function GroupCalendar._APIEventMethods:RefreshAttendance(pIgnoreOpenedEvent)
	assert(GroupCalendar.WoWCalendar.OpenedEvent == self or pIgnoreOpenedEvent)
	
	if GroupCalendar.Debug.invites then
		GroupCalendar:DebugMessage(NORMAL_FONT_COLOR_CODE.."RefreshAttendance, MinLevel=%s", tostring(self.MinLevel))
	end
	
	local changed
	
	if not self.Attendance then
		self.Attendance = {}
	else
		for name, info in pairs(self.Attendance) do
			info.Unused = true
		end
	end
	
	self.NumInvites = GroupCalendar.WoWCalendar:GetNumInvites() or 0
	if GroupCalendar.Debug.invites then
		GroupCalendar:DebugMessage("NumInvites=%s", tostring(self.NumInvites))
	end
	for inviteIndex = 1, self.NumInvites do
		local invite = GroupCalendar.WoWCalendar:EventGetInvite(inviteIndex)
		local inviteResponseTime = GroupCalendar.WoWCalendar:EventGetInviteResponseTime(inviteIndex)
		
		if GroupCalendar.Debug.invites then
			GroupCalendar:DebugMessage("Invite #%s for %s", tostring(inviteIndex), tostring(invite.name))
		end

		local responseDate, responseTime
		if inviteResponseTime then
			responseDate = GroupCalendar.DateLib:ConvertMDYToDate(inviteResponseTime.month, inviteResponseTime.monthDay, inviteResponseTime.year)
			responseTime = GroupCalendar.DateLib:ConvertHMToTime(inviteResponseTime.hour, inviteResponseTime.minute)
		end
		
		local info = self.Attendance[invite.name or ""]
		if not invite.name then
			-- The server didn't respond, probably laggy
		elseif not info then
			-- Use the current date/time if no stamp is found
			
			if not vResponseDate
			and (invite.inviteStatus == CALENDAR_INVITESTATUS_ACCEPTED
			  or invite.inviteStatus == CALENDAR_INVITESTATUS_TENTATIVE
			  or invite.inviteStatus == CALENDAR_INVITESTATUS_CONFIRMED
			  or invite.inviteStatus == CALENDAR_INVITESTATUS_STANDBY
			  or invite.inviteStatus == CALENDAR_INVITESTATUS_SIGNEDUP) then
				vResponseDate, vResponseTime = GroupCalendar.DateLib:GetServerDateTime()
			end
			
			-- Create the new record
			
			info =
			{
				Name = invite.name,
				Level = invite.level,
				ClassName = invite.className,
				ClassID = invite.classFilename,
				RoleCode = GroupCalendar:GetPlayerDefaultRoleCode(invite.name, invite.classFilename),
				InviteStatus = invite.inviteStatus,
				ModStatus = invite.modStatus,
				InviteIsMine = vInviteIsMine,
				ResponseDate = responseDate,
				ResponseTime = responseTime,
			}
			
			self.Attendance[invite.name] = info
			changed = true
		else
			info.Unused = nil
			
			if info.Name ~= invite.name then
				info.Name = invite.name
				changed = true
			end
			
			if info.Level ~= invite.level then
				info.Level = invite.level
				changed = true
			end
			
			if info.ClassName ~= invite.className then
				info.ClassName = invite.className
				changed = true
			end
			
			if info.ClassID ~= invite.classFilename then
				info.ClassID = invite.classFilename
				changed = true
			end
			
			if info.InviteStatus ~= invite.inviteStatus then
				info.InviteStatus = invite.inviteStatus
				changed = true
			end
			
			if info.ModStatus ~= invite.modStatus then
				info.ModStatus = invite.modStatus
				changed = true
			end
			
			if info.InviteIsMine ~= invite.inviteIsMine then
				info.InviteIsMine = invite.inviteIsMine
				changed = true
			end
			
			if not responseDate then
				if not info.ResponseDate
				and (invite.inviteStatus == CALENDAR_INVITESTATUS_ACCEPTED
				  or invite.inviteStatus == CALENDAR_INVITESTATUS_TENTATIVE
				  or invite.inviteStatus == CALENDAR_INVITESTATUS_CONFIRMED
				  or invite.inviteStatus == CALENDAR_INVITESTATUS_STANDBY
				  or invite.inviteStatus == CALENDAR_INVITESTATUS_SIGNEDUP) then
					info.ResponseDate, info.ResponseTime = GroupCalendar.DateLib:GetServerDateTime()
					changed = true
				end
			
			elseif info.ResponseDate ~= responseDate
			or info.ResponseTime ~= responseTime then
				info.ResponseDate = responseDate
				info.ResponseTime = responseTime
				
				changed = true
			end
		end
	end -- for inviteIndex
	
	for name, info in pairs(self.Attendance) do
		if info.Unused then
			self.Attendance[name] = nil
			changed = true
		end
	end
	
	self.CacheUpdateDate, self.CacheUpdateTime = GroupCalendar.DateLib:GetServerDateTime()
	
	if changed then
		if GroupCalendar.Debug.invites then
			GroupCalendar:DebugMessage(NORMAL_FONT_COLOR_CODE.."Sending INVITES_CHANGED, MinLevel=%s", tostring(self.MinLevel))
		end
		
		GroupCalendar.BroadcastLib:Broadcast(self, "INVITES_CHANGED")

		if GroupCalendar.Debug.invites then
			GroupCalendar:DebugMessage(NORMAL_FONT_COLOR_CODE.."Sent INVITES_CHANGED, MinLevel=%s", tostring(self.MinLevel))
		end
	end
	
	if self.OriginalEvent then
		if GroupCalendar.Debug.invites then
			GroupCalendar:DebugMessage(NORMAL_FONT_COLOR_CODE.."Refreshing OriginalEvent, MinLevel=%s", tostring(self.MinLevel))
		end
		
		self.OriginalEvent:RefreshAttendance(true)

		if GroupCalendar.Debug.invites then
			GroupCalendar:DebugMessage(NORMAL_FONT_COLOR_CODE.."Refreshed OriginalEvent, MinLevel=%s", tostring(self.MinLevel))
		end
	end
	
	return changed
end

function GroupCalendar._APIEventMethods:MassInvite(pMinLevel, pMaxLevel, pMinRank)
	local _, vDefaultMaxLevel = GroupCalendar.WoWCalendar:DefaultGuildFilter()
	
	GroupCalendar.WoWCalendar:MassInviteGuild(pMinLevel or 1, pMaxLevel or vDefaultMaxLevel, pMinRank)
end

function GroupCalendar._APIEventMethods:ReadyToContinueInvites()
	if not self.DesiredAttendance then
		return false
	end
	
	if self.WaitingForEventID then
		return false
	end
	
	if GroupCalendar.WoWCalendar:IsActionPending() then
		-- Listen for action pending events so we can tell when the API is available again
		
		if not GroupCalendar.EventLib:EventIsRegistered("CALENDAR_ACTION_PENDING", self.CalendarActionPending, self) then
			GroupCalendar.EventLib:RegisterEvent("CALENDAR_ACTION_PENDING", self.CalendarActionPending, self)
		end
		
		return false
	end
	
	GroupCalendar.EventLib:UnregisterEvent("CALENDAR_ACTION_PENDING", self.CalendarActionPending, self)
	
	if not GroupCalendar.WoWCalendar:CanSendInvite() then
		-- Start the timer so we can tell when invites are available again
		GroupCalendar.SchedulerLib:ScheduleUniqueRepeatingTask(0.1, self.CheckCanSendInvite, self)
		return false
	end
	
	GroupCalendar.SchedulerLib:UnscheduleTask(self.CheckCanSendInvite, self)
	
	return true
end

function GroupCalendar._APIEventMethods:CalendarActionPending(pEventID, pBusy)
	if pBusy then return end
	
	GroupCalendar.EventLib:UnregisterEvent("CALENDAR_ACTION_PENDING", self.CalendarActionPending, self)
	
	if GroupCalendar.Debug.invites then
		GroupCalendar:DebugMessage("CalendarActionPending: Free")
	end
	
	self:CheckDesiredAttendance()
end

function GroupCalendar._APIEventMethods:WaitForEvent(pEventID)
	assert(self.WaitingForEventID == nil)
	
	self.WaitingForEventID = pEventID
	GroupCalendar.EventLib:RegisterEvent(self.WaitingForEventID, self.ProcessWaitForEvent, self)
end

function GroupCalendar._APIEventMethods:ProcessWaitForEvent(pEventID, pParam)
	assert(self.WaitingForEventID ~= nil)
	
	if self.WaitingForEventID ~= pEventID then
		error("Unexpected event "..tostring(pEventID))
	end
	
	GroupCalendar.EventLib:UnregisterEvent(self.WaitingForEventID, self.ProcessWaitForEvent, self)
	
	self.WaitingForEventID = nil
	
	if GroupCalendar.Debug.invites then
		GroupCalendar:DebugMessage("CalendarActionPending: Found event %s", pEventID)
	end
	
	self:CheckDesiredAttendance()
end

function GroupCalendar._APIEventMethods:CheckCanSendInvite()
	if not GroupCalendar.WoWCalendar:CanSendInvite() then
		return
	end
	
	GroupCalendar.SchedulerLib:UnscheduleTask(self.CheckCanSendInvite, self)
	
	if GroupCalendar.Debug.invites then
		GroupCalendar:DebugMessage(GREEN_FONT_COLOR_CODE.."CanSendInvite")
	end
	
	self:CheckDesiredAttendance()
end

function GroupCalendar._APIEventMethods:FindInviteByName(name)
	local numInvites = GroupCalendar.WoWCalendar:GetNumInvites()
	
	for index = 1, numInvites do
		local invite = GroupCalendar.WoWCalendar:EventGetInvite(index)
		
		if invite.name == name then
			return index, invite
		end
	end
end

function GroupCalendar._APIEventMethods:GetDesiredAttendanceCount()
	if not self.DesiredAttendance then
		return 0
	end
	
	local vTotalChanges = 0
	
	-- Removed players
	
	for vName, vInfo in pairs(self.Attendance) do
		if not self.DesiredAttendance[vName] then
			vTotalChanges = vTotalChanges + 1
		end
	end
	
	-- New/updated players

	for vName, vInfo in pairs(self.DesiredAttendance) do
		local vCurrentInfo = self.Attendance[vName]
		
		if not vCurrentInfo then
			vTotalChanges = vTotalChanges + 1
		elseif vCurrentInfo.ModStatus ~= "CREATOR"
		and (vCurrentInfo.ModStatus ~= vInfo.ModStatus or vCurrentInfo.InviteStatus ~= vInfo.InviteStatus) then
			vTotalChanges = vTotalChanges + 1
		end
	end

	return vTotalChanges
end

function GroupCalendar._APIEventMethods:GetDesiredNewAttendanceCount()
	if not self.DesiredAttendance then
		return 0
	end
	
	local vTotalChanges = 0
	
	for vName, vInfo in pairs(self.DesiredAttendance) do
		local vCurrentInfo = self.Attendance[vName]
		
		if not vCurrentInfo then
			vTotalChanges = vTotalChanges + 1
		end
	end
	
	return vTotalChanges
end

function GroupCalendar._APIEventMethods:AllDesiredAttendanceIsInGuild()
	local vMinLevel, vMaxLevel, vMinRank
	
	for vName, vInfo in pairs(self.DesiredAttendance) do
		local vPlayerInfo = GroupCalendar.GuildLib:GetPlayer(vName)
		
		if not vPlayerInfo then
			return false
		end
		
		if not self.Attendance[vName]
		or self.Attendance[vName].ModStatus ~= "CREATOR" then
			if not vMinLevel or vPlayerInfo.Level < vMinLevel then
				vMinLevel = vPlayerInfo.Level
			end
			
			if not vMaxLevel or vPlayerInfo.Level > vMaxLevel then
				vMaxLevel = vPlayerInfo.Level
			end
			
			if not vMinRank or vPlayerInfo.GuildRank > vMinRank then
				vMinRank = vPlayerInfo.GuildRank
			end
		end
	end

	return true, vMinLevel, vMaxLevel, vMinRank
end

function GroupCalendar._APIEventMethods:CheckDesiredAttendance()
	if self.CheckingDesiredAttendance then
		return
	end
	
	if GroupCalendar.Debug.invites then
		GroupCalendar:DebugMessage("CheckDesiredAttendance")
	end
	
	self.CheckingDesiredAttendance = true
	GroupCalendar.EventLib:UnregisterEvent("CALENDAR_UPDATE_INVITE_LIST", self.CalendarUpdateEventInvites, self)
	
	self:CheckDesiredAttendance_Body()
	
	self.CheckingDesiredAttendance = nil
	GroupCalendar.EventLib:RegisterEvent("CALENDAR_UPDATE_INVITE_LIST", self.CalendarUpdateEventInvites, self)

	if GroupCalendar.Debug.invites then
		GroupCalendar:DebugMessage("CheckDesiredAttendance: Done")
	end
	
	self:RefreshAttendance()
end

function GroupCalendar._APIEventMethods:CheckDesiredAttendance_Body()
	local vEventMinLevel = self.MinLevel or 1
	local vEventMaxLevel = self.MaxLevel or MAX_PLAYER_LEVEL_TABLE[#MAX_PLAYER_LEVEL_TABLE]
	
	-- If this is a new private event, and everyone on the list is a guild member,
	-- and there are invitees missing, use the mass invite feature
	
	if not self.Index -- New event
	and self.CalendarType ~= "GUILD_EVENT"
	and CanEditGuildEvent()  -- Mass invite is available to this player
	and self:GetDesiredNewAttendanceCount() > 0 then
		local vAllGuild, vMinLevel, vMaxLevel, vMinRank = self:AllDesiredAttendanceIsInGuild()
		
		if vAllGuild then
			if not self:ReadyToContinueInvites() then
				return
			end
			
			if vMinLevel < vEventMinLevel then
				vMinLevel = vEventMinLevel
			end
			
			if vMaxLevel > vEventMaxLevel then
				vMaxLevel = vEventMaxLevel
			end
			
			GroupCalendar.BroadcastLib:Broadcast(self, "INVITE_QUEUE_UPDATE", GroupCalendar.cWaitingForServerInvite)
			
			self:WaitForEvent("CALENDAR_UPDATE_INVITE_LIST")
			
			self:MassInvite(1, nil, vMinRank + 1)
		end
	end
	
	--
	
	while self.DesiredAttendance ~= nil do
		-- Remove unwanted players
		
		for name, info in pairs(self.Attendance) do
			if not self:ReadyToContinueInvites() then
				return
			end
			
			if not self.DesiredAttendance[name] then
				GroupCalendar.BroadcastLib:Broadcast(self, "INVITE_QUEUE_UPDATE", string.format("Removing %s", name))
				
				local index, invite = self:FindInviteByName(name)
				
				assert(index ~= nil)
				assert(invite.modStatus ~= "CREATOR")
				
				if GroupCalendar.Debug.invites then
					GroupCalendar:DebugMessage("Calendar.EventRemoveInvite(%s)", name)
				end
				
				self:WaitForEvent("CALENDAR_UPDATE_INVITE_LIST")
				GroupCalendar.WoWCalendar:EventRemoveInvite(index)
				
				if GroupCalendar.Debug.invites then
					GroupCalendar:DebugMessage("Calendar.EventRemoveInvite(%s): Done", name)
				end
			end
		end
		
		-- Invite missing players
		
		if not self:ReadyToContinueInvites() then
			return
		end
		
		for name, info in pairs(self.DesiredAttendance) do
			GroupCalendar.BroadcastLib:Broadcast(self, "INVITE_QUEUE_UPDATE", string.format(GroupCalendar.cAddingInviteFormat, name))
			
			if not self.Attendance[name] then
				if GroupCalendar.Debug.invites then
					GroupCalendar:DebugMessage("Calendar.EventInvite(%s)", name)
				end
				
				self:WaitForEvent("CALENDAR_UPDATE_INVITE_LIST")
				GroupCalendar.WoWCalendar:EventInvite(name)
			end
			
			if not self:ReadyToContinueInvites() then
				return
			end
		end
		
		-- Update mis-matched player status
		
		if not self:ReadyToContinueInvites() then
			return
		end
		
		for name, info in pairs(self.DesiredAttendance) do
			local currentInfo = self.Attendance[name]
			
			if (currentInfo.ModStatus ~= "CREATOR" and currentInfo.ModStatus ~= info.ModStatus)
			or currentInfo.InviteStatus ~= info.InviteStatus then
				GroupCalendar.BroadcastLib:Broadcast(self, "INVITE_QUEUE_UPDATE", string.format("Updating %s", name))
				
				local index, invite = self:FindInviteByName(name)
				
				assert(index ~= nil)
				
				if GroupCalendar.Debug.invites then
					GroupCalendar:DebugMessage("EventSetInviteStatus/Moderator(%s): Index=%s, Status=%s", name, tostring(index), tostring(info.InviteStatus))
				end
				
				if currentInfo.InviteStatus ~= info.InviteStatus then
					GroupCalendar:DebugMessage("EventSetInviteStatus(%s, %s)", tostring(index), tostring(info.InviteStatus))
					GroupCalendar.WoWCalendar:EventSetInviteStatus(index, info.InviteStatus)
				end
				
				if currentInfo.ModStatus ~= "CREATOR" and currentInfo.ModStatus ~= info.ModStatus then
					if info.ModStatus == "MODERATOR" then
						GroupCalendar.WoWCalendar:EventSetModerator(index)
					else
						GroupCalendar.WoWCalendar:EventClearModerator(index)
					end
				end
			end
			
			if not self:ReadyToContinueInvites() then
				return
			end
		end
		
		-- All clear
		
		self.DesiredAttendance = nil
		GroupCalendar.BroadcastLib:Broadcast(self, "INVITE_QUEUE_END")
	end -- while
end

function GroupCalendar._APIEventMethods:PlayerInviteIsPending(pPlayerName)
	if not self.DesiredAttendance then
		return false
	end
	
	local vCurrentInfo = self.Attendance and self.Attendance[pPlayerName]
	local vDesiredInfo = self.DesiredAttendance[pPlayerName]
	
	if (vCurrentInfo == nil) ~= (vDesiredInfo == nil) then
		return true
	end
	
	if not vCurrentInfo then
		return false
	end
	
	return vCurrentInfo.InviteStatus ~= vDesiredInfo.InviteStatus
	   or vCurrentInfo.ModStatus ~= vDesiredInfo.ModStatus
end

----------------------------------------
-- Invites

function GroupCalendar._APIEventMethods:BeginBatchInvites()
	self.DoingBatchInvites = true
end

function GroupCalendar._APIEventMethods:EndBatchInvites()
	self.DoingBatchInvites = nil
	self:DesiredAttendanceChanged()
end

function GroupCalendar._APIEventMethods:CancelPendingInvites()
	if not self.DesiredAttendance then
		return
	end
	
	self.DesiredAttendance = nil
	
	if self.WaitingForEventID then
		GroupCalendar.EventLib:UnregisterEvent(self.WaitingForEventID, self.ProcessWaitForEvent, self)
		self.WaitingForEventID = nil
	end

	GroupCalendar.EventLib:UnregisterEvent("CALENDAR_ACTION_PENDING", self.CalendarActionPending, self)
	GroupCalendar.SchedulerLib:UnscheduleTask(self.CheckCanSendInvite, self)
	
	GroupCalendar.BroadcastLib:Broadcast(self, "INVITE_QUEUE_END")
end

function GroupCalendar._APIEventMethods:CalendarUpdateError(pEvent, pMessage)
	if not self.DesiredAttendance then
		return
	end
	
	self:CancelPendingInvites()
	
	GroupCalendar:ErrorMessage(GroupCalendar.cInviteErrorMessage, tostring(pMessage))
end

function GroupCalendar._APIEventMethods:InvitePlayer(pPlayerName)
	if self.Attendance and self.Attendance[pPlayerName] then
		return
	end
	
	local vDesiredAttendance = self:GetDesiredAttendance(true)
	
	if vDesiredAttendance[pPlayerName] then
		return
	end
	
	vDesiredAttendance[pPlayerName] =
	{
		Name = pPlayerName,
		InviteStatus = CALENDAR_INVITESTATUS_INVITED,
		ModStatus = "",
	}
	
	if GroupCalendar.Debug.invites then
		GroupCalendar:DebugMessage(RED_FONT_COLOR_CODE.."InvitePlayer(%s)", pPlayerName)
	end
	
	if not self.DoingBatchInvites then
		self:DesiredAttendanceChanged()
	end
end

function GroupCalendar._APIEventMethods:UninvitePlayer(pPlayerName)
	local vCurrentInfo = self.Attendance[pPlayerName]
	
	if not vCurrentInfo and not self.DesiredAttendance then
		return
	end
	
	if vCurrentInfo and vCurrentInfo.ModStatus == "CREATOR" then
		return -- Can't uninvite the creator
	end
	
	local vDesiredAttendance = self:GetDesiredAttendance(true)
	
	vDesiredAttendance[pPlayerName] = nil
	
	if GroupCalendar.Debug.invites then
		GroupCalendar:DebugMessage(RED_FONT_COLOR_CODE.."UninvitePlayer(%s)", pPlayerName)
	end
	
	if not self.DoingBatchInvites then
		self:DesiredAttendanceChanged()
	end
end

function GroupCalendar._APIEventMethods:ContextSelectEvent()
	local monthOffset = GroupCalendar.WoWCalendar:GetMonthOffset(self.Month, self.Year)
	GroupCalendar.WoWCalendar:ContextMenuSelectEvent(monthOffset, self.Day, self.Index)
end

function GroupCalendar._APIEventMethods:SetConfirmedStatus()
	-- If it's a new event or if the event is open and it's for
	-- the creator then set the status manually since the normal
	-- APIs won't work
	
	if not self.Index
	or (GroupCalendar.WoWCalendar.OpenedEvent == self and self.ModStatus == "CREATOR") then
		self:SetInviteStatus(GroupCalendar.PlayerName, CALENDAR_INVITESTATUS_CONFIRMED)
		
		return
	end
	
	-- If the event isn't currently open then use the context APIs
	-- to set the status.  These APIs don't work for the creator
	
	if self.ModStatus == "CREATOR" then
		return -- Can't use context APIs for creator
	end
	
	if GroupCalendar.WoWCalendar.OpenedEvent ~= self then
		self:ContextSelectEvent()
		
		if self:IsSignupEvent() then
			GroupCalendar.WoWCalendar:ContextMenuEventSignUp()
		else
			GroupCalendar.WoWCalendar:ContextInviteAvailable()
		end
		
		return
	end
	
	-- The event is currently opened and it isn't the creator. Use
	-- the normal event response APIs
	
	if self:IsSignupEvent() then
		GroupCalendar.WoWCalendar:EventSignUp()
	else
		GroupCalendar.WoWCalendar:EventAvailable()
	end
end

function GroupCalendar._APIEventMethods:SetTentativeStatus()
	-- If it's a new event or if the event is open and it's for
	-- the creator then set the status manually since the normal
	-- APIs won't work
	
	if not self.Index
	or (GroupCalendar.WoWCalendar.OpenedEvent == self and self.ModStatus == "CREATOR") then
		self:SetInviteStatus(GroupCalendar.PlayerName, CALENDAR_INVITESTATUS_TENTATIVE)
		return
	end
	
	-- If the event isn't currently open then use the context APIs
	-- to set the status.  These APIs don't work for the creator
	
	if self.ModStatus == "CREATOR" then
		return -- Can't use context APIs for creator
	end
	
	if GroupCalendar.WoWCalendar.OpenedEvent ~= self then
		self:ContextSelectEvent()
		GroupCalendar.WoWCalendar:ContextInviteTentative()
		
		return
	end
	
	-- The event is currently opened and it isn't the creator. Use
	-- the normal event response APIs
	
	GroupCalendar.WoWCalendar:EventTentative()
end

function GroupCalendar._APIEventMethods:SetDeclinedStatus()
	-- If it's a new event or if the event is open and it's for
	-- the creator then set the status manually since the normal
	-- APIs won't work
	
	if not self.Index
	or (GroupCalendar.WoWCalendar.OpenedEvent == self and self.ModStatus == "CREATOR") then
		if self.CalendarType == "GUILD_EVENT" then
			self:SetInviteStatus(GroupCalendar.PlayerName, CALENDAR_INVITESTATUS_OUT)
		else
			self:SetInviteStatus(GroupCalendar.PlayerName, CALENDAR_INVITESTATUS_DECLINED)
		end
		
		return
	end
	
	-- If the event isn't currently open then use the context APIs
	-- to set the status.  These APIs don't work for the creator
	
	if self.ModStatus == "CREATOR" then
		return -- Can't use context APIs for creator
	end
	
	if GroupCalendar.WoWCalendar.OpenedEvent ~= self then
		self:ContextSelectEvent()
		
		if self:IsSignupEvent() then
			GroupCalendar.WoWCalendar:ContextInviteRemove()
		else
			GroupCalendar.WoWCalendar:ContextInviteDecline()
		end
		
		return
	end
	
	-- The event is currently opened and it isn't the creator. Use
	-- the normal event response APIs
	
	if self:IsSignupEvent() then
		GroupCalendar.WoWCalendar:RemoveEvent()
	else
		GroupCalendar.WoWCalendar:EventDecline()
	end
end

function GroupCalendar._APIEventMethods:SetInviteStatus(pPlayerName, pInviteStatus)
	local vDesiredAttendance = self:GetDesiredAttendance(true)
	
	assert(vDesiredAttendance[pPlayerName] ~= nil)
	
	vDesiredAttendance[pPlayerName].InviteStatus = pInviteStatus
	vDesiredAttendance[pPlayerName].Queued = false
	
	if GroupCalendar.Debug.invites then
		GroupCalendar:DebugMessage(RED_FONT_COLOR_CODE.."SetInviteStatus(%s, %s)", pPlayerName, tostring(pInviteStatus))
	end

	if not self.DoingBatchInvites then
		self:DesiredAttendanceChanged()
	end
end

function GroupCalendar._APIEventMethods:SetModerator(pPlayerName, pModerator)
	local vDesiredAttendance = self:GetDesiredAttendance(true)
	
	assert(vDesiredAttendance[pPlayerName] ~= nil)
	
	vDesiredAttendance[pPlayerName].ModStatus = pModerator and "MODERATOR"
	vDesiredAttendance[pPlayerName].Queued = false
	
	if GroupCalendar.Debug.invites then
		GroupCalendar:DebugMessage(RED_FONT_COLOR_CODE.."SetModerator(%s, %s)", pPlayerName, tostring(pModerator))
	end
	
	if not self.DoingBatchInvites then
		self:DesiredAttendanceChanged()
	end
end

function GroupCalendar._APIEventMethods:SetInviteRoleCode(pPlayerName, pRoleCode)
	assert(self.Attendance[pPlayerName] ~= nil)
	
	self.Attendance[pPlayerName].RoleCode = pRoleCode
	
	if self.OriginalEvent then
		self.OriginalEvent:SetInviteRoleCode(pPlayerName, pRoleCode)
	end
end

function GroupCalendar._APIEventMethods:GetAttendance()
	if self.DesiredAttendance then
		return self.DesiredAttendance
	end
	
	return self.Attendance
end

function GroupCalendar._APIEventMethods:GetDesiredAttendance(pCreate)
	if not self.DesiredAttendance and pCreate then
		if self.Attendance then
			self.DesiredAttendance = GroupCalendar:DuplicateTable(self.Attendance, true)
		else
			self.DesiredAttendance = {}
		end
		
		GroupCalendar.BroadcastLib:Broadcast(self, "INVITE_QUEUE_BEGIN")
		GroupCalendar.WoWCalendar:ResetInviteActionCount()
	end
	
	return self.DesiredAttendance
end

function GroupCalendar._APIEventMethods:GetPlayerInvite(pPlayerName)
	local vAttendance = self:GetAttendance()
	
	return vAttendance and vAttendance[pPlayerName]
end

function GroupCalendar._APIEventMethods:DesiredAttendanceChanged()
	assert(GroupCalendar.WoWCalendar.OpenedEvent == self)
	
	if GroupCalendar.Debug.invites then
		GroupCalendar:DebugMessage("DesiredAttendanceChanged")
	end
	
	self:CheckDesiredAttendance()
end

----------------------------------------
-- Status

function GroupCalendar._APIEventMethods:CanDelete()
	if not self:IsPlayerCreated() then
		return false
	end
	
	if self.Index then
		return GroupCalendar.WoWCalendar:ContextMenuEventCanEdit(GroupCalendar.WoWCalendar:GetMonthOffset(self.Month, self.Year), self.Day, self.Index)
	else
		return true
	end
end

function GroupCalendar._APIEventMethods:CanEdit()
	if self.ModStatus ~= "MODERATOR"
	and self.ModStatus ~= "CREATOR" then
		return false
	end
	
	if not self:IsPlayerCreated() then
		return false
	end
	
	if self.TitleTag
	and (not GroupCalendar.TitleTagInfo[self.TitleTag]
	  or not GroupCalendar.TitleTagInfo[self.TitleTag].CanEdit) then
		return false
	end
	
	if self.Index then
		return GroupCalendar.WoWCalendar:ContextMenuEventCanEdit(GroupCalendar.WoWCalendar:GetMonthOffset(self.Month, self.Year), self.Day, self.Index)
	else
		return true
	end
end

function GroupCalendar._APIEventMethods:CanCopy()
	return self.Index and self:CanEdit()
end

function GroupCalendar._APIEventMethods:CanComplain()
	if not self.Index then
		return false
	end
	
	return self.EventCanComplain
end

function GroupCalendar._APIEventMethods:Complain()
	self:ContextSelectEvent()
	GroupCalendar.WoWCalendar:ContextMenuEventComplain()
end

function GroupCalendar._APIEventMethods:CanRemove()
	return self.Index
	and self.ModStatus ~= "CREATOR"
	and (self.CalendarType == "PLAYER"
	or (self.CalendarType == "GUILD_EVENT" and self.InviteType == CALENDAR_INVITETYPE_NORMAL)
	or (self.CalendarType == "COMMUNITY_EVENT" and self.InviteType == CALENDAR_INVITETYPE_NORMAL))
end

function GroupCalendar._APIEventMethods:Remove()
	self:ContextSelectEvent()
	GroupCalendar.WoWCalendar:ContextInviteRemove()
end

function GroupCalendar._APIEventMethods:IsGuildWide()
	return self.CalendarType == "GUILD_ANNOUNCEMENT" or self.CalendarType == "GUILD" or self.CalendarType == "GUILD_EVENT"
end

function GroupCalendar._APIEventMethods:CanRSVP()
	if not self:UsesAttendance() then
		return false
	end
	
	return not self:IsExpired()
end

----------------------------------------
-- Events

function GroupCalendar._APIEventMethods:CalendarOpenEvent()
	self:GetEventInfo()
end

function GroupCalendar._APIEventMethods:EventClosed()
	assert(GroupCalendar.WoWCalendar.OpenedEvent == self)
	
	if self.ChangingMode then
		if GroupCalendar.Debug.invites then
			GroupCalendar:DebugMessage(RED_FONT_COLOR_CODE.."Ignoring event closed -- event is transitioning")
		end
		
		return
	end
	
	if GroupCalendar.Debug.invites then
		GroupCalendar:DebugMessage(RED_FONT_COLOR_CODE.."Event closed")
	end
	
	GroupCalendar.WoWCalendar:ClearQueue()
	
	GroupCalendar.WoWCalendar.OpenedEvent = nil
	
	if self.DesiredAttendance then
		self:CancelPendingInvites()
		GroupCalendar:NoteMessage(GroupCalendar.cInvitesCanceledMessage)
	end
	
	
	GroupCalendar.EventLib:UnregisterEvent("CALENDAR_OPEN_EVENT", self.CalendarOpenEvent, self)
	GroupCalendar.EventLib:UnregisterEvent("CALENDAR_CLOSE_EVENT", self.EventClosed, self)
	GroupCalendar.EventLib:UnregisterEvent("CALENDAR_UPDATE_EVENT", self.CalendarUpdateEvent, self)
	GroupCalendar.EventLib:UnregisterEvent("CALENDAR_UPDATE_INVITE_LIST", self.CalendarUpdateEventInvites, self)
	GroupCalendar.EventLib:UnregisterEvent("CALENDAR_UPDATE_ERROR", self.CalendarUpdateError, self)
	
	GroupCalendar.BroadcastLib:StopListening(nil, self.ShadowEventMessage, self)

	GroupCalendar.BroadcastLib:Broadcast(self, "CLOSED")
end

function GroupCalendar._APIEventMethods:CalendarUpdateEvent()
	self:GetEventInfo()
end

function GroupCalendar._APIEventMethods:CalendarUpdateEventInvites()
	self:GetEventAttendance()
end

----------------------------------------
GroupCalendar._CachedEventMethods = {}
----------------------------------------

for vName, vFunction in pairs(GroupCalendar._BaseEventMethods) do
	GroupCalendar._CachedEventMethods[vName] = vFunction
end

function GroupCalendar._CachedEventMethods:Open()
end

function GroupCalendar._CachedEventMethods:Close()
end

function GroupCalendar._CachedEventMethods:Save()
	error("Can't save cached events")
end

function GroupCalendar._CachedEventMethods:Delete()
	error("Can't delete cached events")
end

function GroupCalendar._CachedEventMethods:CanEdit()
	return false
end

function GroupCalendar._CachedEventMethods:CanCopy()
	return false
end

function GroupCalendar._CachedEventMethods:CanDelete()
	return false
end

function GroupCalendar._CachedEventMethods:CanRSVP()
	return false
end

function GroupCalendar._CachedEventMethods:CanComplain()
	return false
end

function GroupCalendar._CachedEventMethods:CanRemove()
	return false
end

function GroupCalendar._CachedEventMethods:IsGuildWide()
	return self.CalendarType == "GUILD_ANNOUNCEMENT"
end

function GroupCalendar._CachedEventMethods:CanSendInvite(pIgnoreOpenedEvent)
	return false
end

function GroupCalendar._CachedEventMethods:SetInviteRoleCode(pPlayerName, pRoleCode)
	assert(self.Attendance[pPlayerName] ~= nil)
	
	self.Attendance[pPlayerName].RoleCode = pRoleCode
end

function GroupCalendar._CachedEventMethods:GetAttendance()
	return self.Attendance
end

function GroupCalendar._CachedEventMethods:GetPlayerInvite(pPlayerName)
	local vAttendance = self:GetAttendance()
	
	return vAttendance and vAttendance[pPlayerName]
end

function GroupCalendar._CachedEventMethods:PlayerInviteIsPending(pPlayerName)
	return false
end

----------------------------------------
GroupCalendar._APIEventMetaTable = {__index = GroupCalendar._APIEventMethods}
GroupCalendar._CachedEventMetaTable = {__index = GroupCalendar._CachedEventMethods}
----------------------------------------

----------------------------------------
GroupCalendar.WoWCalendar = {}
----------------------------------------

function GroupCalendar.WoWCalendar:Init()
	-- Copy methods from Blizzrds API under this one
	for name, body in pairs(C_Calendar) do
		if not self[name] then
			self[name] = function (self, ...)
				return body(...)
			end
		end
	end

	self.Month = 0
	self.Year = 0
	
	self.GetExtendedInfoQueue = {}
	
	self.TitleTag = nil
	self.DescriptionTag = nil
	
	GroupCalendar.EventLib:RegisterEvent("CALENDAR_NEW_EVENT", self.NewEventCreated, self)
end

function GroupCalendar.WoWCalendar:ResetInviteActionCount(...)
end

function GroupCalendar.WoWCalendar:QueueInviteAction(...)
end

function GroupCalendar.WoWCalendar:PlayerHasInviteAction(...)
end

function GroupCalendar.WoWCalendar:ClearQueue(...)
end

function GroupCalendar.WoWCalendar:BeginHardwareEvent()
	self.HardwareEventAvailable = true
	self.InviteQueue:HardwareEvent()
end

function GroupCalendar.WoWCalendar:EndHardwareEvent()
	self.HardwareEventAvailable = false
end

function GroupCalendar.WoWCalendar:GetEventExtendedInfo(pEventData)
	if true or pEventData.SequenceType == "ONGOING" then
		return -- No extended info for ongoing events
	end
	
	GroupCalendar:DebugMessage(HIGHLIGHT_FONT_COLOR_CODE.."GetEventExtendedInfo: %s (%s/%s/%s index %s)", tostring(pEventData.Title), tostring(pEventData.Month), tostring(pEventData.Day), tostring(pEventData.Year), tostring(pEventData.Index))
	table.insert(self.GetExtendedInfoQueue, pEventData)
	
	if #self.GetExtendedInfoQueue == 1 then
		self:GetNextExtendedInfo()
	end
end

function GroupCalendar.WoWCalendar:GetNextExtendedInfo()
	if #self.GetExtendedInfoQueue == 0 then
		return
	end
	
	local vEvent = self.GetExtendedInfoQueue[1]
	
	--GroupCalendar:DebugMessage("GetNextExtendedInfo: %s (%s/%s/%s index %s)", tostring(vEvent.Title), tostring(vEvent.Month), tostring(vEvent.Day), tostring(vEvent.Year), tostring(vEvent.Index))
	
	GroupCalendar.EventLib:UnregisterEvent("CALENDAR_OPEN_EVENT", self.UpdateNextQueuedEvent, self)
	GroupCalendar.EventLib:RegisterEvent("CALENDAR_OPEN_EVENT", self.UpdateNextQueuedEvent, self)
	
	GroupCalendar.SchedulerLib:ScheduleUniqueTask(2, self.GetNextExtendedInfo, self)
	
	-- GroupCalendar.WoWCalendar:CloseEvent()
	
	local monthOffset = GroupCalendar.WoWCalendar:GetMonthOffset(vEvent.Month, vEvent.Year)
	--GroupCalendar:DebugMessage("GetNextExtendedInfo: CalendarOpenEvent(%s, %s, %s)", tostring(monthOffset), tostring(vEvent.Day), tostring(vEvent.Index))
	GroupCalendar.WoWCalendar:OpenEvent(monthOffset, vEvent.Day, vEvent.Index)
end

function GroupCalendar.WoWCalendar:UpdateNextQueuedEvent()
	GroupCalendar.SchedulerLib:UnscheduleTask(self.GetNextExtendedInfo, self)
	GroupCalendar.EventLib:UnregisterEvent("CALENDAR_OPEN_EVENT", self.UpdateNextQueuedEvent, self)
	
	local vEvent = table.remove(self.GetExtendedInfoQueue, 1)
	
	if not vEvent then
		return
	end
	
	if vEvent:UpdateExtendedInfo() then
		GroupCalendar.EventLib:DispatchEvent("GC5_EVENT_CHANGED", vEvent)
	end
	
	GroupCalendar.WoWCalendar:CloseEvent()
	
	self:GetNextExtendedInfo()
end

function GroupCalendar.WoWCalendar:ProcessTitle(pTitle)
	local vTagStart, vTagEnd, vTagData
	
	if pTitle then
		vTagStart, vTagEnd, vTagData = pTitle:find("%s?%[(.*)%]")
	end
	
	if vTagStart then
		self.Title = pTitle:sub(1, vTagStart - 1)..pTitle:sub(vTagEnd + 1)
		self.TitleTag = vTagData
	else
		self.Title = pTitle
		self.TitleTag = nil
	end
	
	-- Process tradeskill cooldowns
	if self.TitleTag then
		local _, _, vRecipeIDString = self.TitleTag:find("RECIPE_(.*)")
		if vRecipeIDString then
			local vRecipeID = tonumber(vRecipeIDString)
			local vRecipeInfo = C_TradeSkillUI.GetRecipeInfo(vRecipeID)
			if vRecipeInfo then
				self.Title = GroupCalendar.cCooldownEventName:format(vRecipeInfo.name)
			end
		end
	end
	
	return self.Title
end

function GroupCalendar.WoWCalendar:ProcessDescription(description)
	local tagStart, tagEnd, tagData
	
	if description then
		tagStart, tagEnd, tagData = description:find("%s?%[(.*)%]")
	end
	
	if tagStart then
		self.Description = description:sub(1, tagStart - 1)..description:sub(tagEnd + 1)
		self.DescriptionTag = tagData
	else
		self.Description = description
		self.DescriptionTag = nil
	end
	
	return self.Description
end

function GroupCalendar.WoWCalendar:NewEventCreated()
	if self.OpenedEvent then
		self.OpenedEvent:EventClosed()
		self.OpenedEvent = nil
	end
end

----------------------------------------
-- WoW API hooks and extensions
----------------------------------------

function GroupCalendar.WoWCalendar:CreatePlayerEvent(...)
	if self.OpenedEvent then
		self.OpenedEvent:Close()
	end
	
	self.SelectedEventMonth = nil
	self.SelectedEventYear = nil
	self.SelectedEventDay = nil
	self.SelectedEventIndex = nil
	
	self.Description = ""
	self.DescriptionTag = ""
	self.Title = ""
	self.TitleTag = ""
	
	return C_Calendar.CreatePlayerEvent(...)
end

function GroupCalendar.WoWCalendar:GetMonthOffset(month, year)
	local calendarDate = C_Calendar.GetDate()
	local calendarMonthYear = calendarDate.year * 12 + calendarDate.month
	local monthYear = year * 12 + month
	return monthYear - calendarMonthYear
end

function GroupCalendar.WoWCalendar:CreateGuildSignUpEvent(...)
	if self.OpenedEvent then
		self.OpenedEvent:Close()
	end
	
	self.SelectedEventMonth = nil
	self.SelectedEventYear = nil
	self.SelectedEventDay = nil
	self.SelectedEventIndex = nil
	
	self.Description = ""
	self.DescriptionTag = ""
	self.Title = ""
	self.TitleTag = ""
	
	return C_Calendar.CreateGuildSignUpEvent(...)
end

function GroupCalendar.WoWCalendar:CreateGuildAnnouncementEvent(...)
	if self.OpenedEvent then
		self.OpenedEvent:Close()
	end
	
	self.SelectedEventMonth = nil
	self.SelectedEventYear = nil
	self.SelectedEventDay = nil
	self.SelectedEventIndex = nil
	
	self.Description = ""
	self.DescriptionTag = ""
	self.Title = ""
	self.TitleTag = ""
	
	return C_Calendar.CreateGuildAnnouncementEvent(...)
end

function GroupCalendar.WoWCalendar:OpenEvent(pMonthOffset, pDay, pIndex, ...)
	if self.OpenedEvent then
		self.OpenedEvent:Close()
	end
	
	self.SelectedEventMonth = self.Month + pMonthOffset
	self.SelectedEventYear = self.Year
	self.SelectedEventDay = pDay
	self.SelectedEventIndex = pIndex
	
	while self.SelectedEventMonth > 12 do
		self.SelectedEventMonth = self.SelectedEventMonth - 12
		self.SelectedEventYear = self.SelectedEventYear + 1
	end
	
	while self.SelectedEventMonth < 1 do
		self.SelectedEventMonth = self.SelectedEventMonth + 12
		self.SelectedEventYear = self.SelectedEventYear - 1
	end
	
	self.Description = nil
	self.DescriptionTag = nil
	self.Title = nil
	self.TitleTag = nil
	
	return C_Calendar.OpenEvent(pMonthOffset, pDay, pIndex, ...)
end

function GroupCalendar.WoWCalendar:EventSetDate(pMonth, pDay, pYear, ...)
	self.SelectedEventMonth = pMonth
	self.SelectedEventYear = pDay
	self.SelectedEventDay = pYear
	
	return C_Calendar.EventSetDate(pMonth, pDay, pYear, ...)
end

function GroupCalendar.WoWCalendar:CloseEvent(...)
	local vResult = C_Calendar.CloseEvent(...)
	
	if self.OpenedEvent and not self.OpenedEvent.ChangingMode then
		self.OpenedEvent:EventClosed()
		self.OpenedEvent = nil
	end
	
	return vResult
end

function GroupCalendar.WoWCalendar:CalendarNewArenaTeamEvent(...)
	if self.OpenedEvent then
		self.OpenedEvent:Close()
	end
	
	self.SelectedEventMonth = nil
	self.SelectedEventYear = nil
	self.SelectedEventDay = nil
	self.SelectedEventIndex = nil
	
	self.Description = ""
	self.DescriptionTag = ""
	self.Title = ""
	self.TitleTag = ""
	
	return CalendarNewArenaTeamEvent(...)
end

function GroupCalendar.WoWCalendar:GetDayEvent(...)
	local result = C_Calendar.GetDayEvent(...)
	result.title = self:ProcessTitle(result.title)
	return result
end

function GroupCalendar.WoWCalendar:EventSetTitle(pTitle)
	if not self.Title then
		self:GetEventInfo()
	end
	
	self.Title = pTitle or ""
	
	if self.TitleTag and self.TitleTag ~= "" then
		local result = self.Title.." ["..self.TitleTag.."]"
		local trunc = self.Title:len()
		
		local count = 10
		
		while result:len() > GroupCalendar.EVENT_MAX_TITLE_LENGTH do
			count = count - 1
			
			if count == 0 then
				error("CalendarEventSetTitle locked up while truncating")
			end
			
			local trunc = result:len() - GroupCalendar.EVENT_MAX_TITLE_LENGTH
			result = self.Title:sub(1, -(trunc + 1)).." ["..self.TitleTag.."]"
		end
		
		return C_Calendar.EventSetTitle(result)
	else
		return C_Calendar.EventSetTitle(self.Title)
	end
end

function GroupCalendar.WoWCalendar:GetEventInfo()
	local eventInfo  = C_Calendar.GetEventInfo()
	
	if not eventInfo then
		return nil
	end
	
	eventInfo.title = self:ProcessTitle(eventInfo.title)
	eventInfo.description = self:ProcessDescription(eventInfo.description)
	
	return eventInfo
end

function GroupCalendar.WoWCalendar:EventSetDescription(pDescription)
	if not self.Description then
		self:GetEventInfo()
	end
	
	self.Description = pDescription
	
	if self.DescriptionTag and self.DescriptionTag ~= "" then
		local vResult = self.Description.."\r["..self.DescriptionTag.."]"
		local vTrunc = self.Description:len()
		
		while vResult:len() > GroupCalendar.EVENT_MAX_DESCRIPTION_LENGTH do
			local vTrunc = vResult:len() - GroupCalendar.EVENT_MAX_DESCRIPTION_LENGTH
			vResult = self.Description:sub(1, -(vTrunc + 1)).."\r["..self.DescriptionTag.."]"
		end

		return C_Calendar.EventSetDescription(vResult)
	else
		return C_Calendar.EventSetDescription(self.Description)
	end
end

function GroupCalendar.WoWCalendar:EventSetTitleTag(pTitleTag)
	if not self.Title then
		self:GetEventInfo()
	end
	
	self.TitleTag = pTitleTag
	self:EventSetTitle(self.Title) -- This will update the title tag portion as well
end

function GroupCalendar.WoWCalendar:EventGetTitleTag()
	if not self.Title then
		self:GetEventInfo()
	end
	
	return self.TitleTag
end

function GroupCalendar.WoWCalendar:EventSetDescriptionTag(pDescriptionTag)
	if not self.Description then
		self:GetEventInfo()
	end
	
	self.DescriptionTag = pDescriptionTag
	self:EventSetDescription(self.Description) -- This will update the description tag portion as well
end

function GroupCalendar.WoWCalendar:EventGetDescriptionTag()
	if not self.Description then
		self:GetEventInfo()
	end
	
	return self.DescriptionTag
end

function GroupCalendar.WoWCalendar:SetAbsMonth(pMonth, pYear, ...)
	if self.Month == pMonth and self.Year == pYear then
		return
	end
	
	self.Month = pMonth
	self.Year = pYear
	
	return C_Calendar.SetAbsMonth(pMonth, pYear, ...)
end

function GroupCalendar.WoWCalendar:GetAbsDayEvent(pMonth, pDay, pYear, pEventIndex)
	return self:GetDayEvent(self:GetMonthOffset(pMonth, pYear), pDay, pEventIndex)
end

function GroupCalendar.WoWCalendar:GetDisplayTitle(pCalendarType, pSequenceType, pTitle)
	local vTitleFormats = GroupCalendar.CALENDAR_CALENDARTYPE_NAMEFORMAT[pCalendarType]
	local vTitleFormat
	
	if vTitleFormats then
		vTitleFormat = vTitleFormats[pSequenceType]
	end
	
	if not vTitleFormat then
		vTitleFormat = "%s"
	end
	
	return vTitleFormat:format(pTitle or "")
end

function GroupCalendar.WoWCalendar:GetMonthOffset(pMonth, pYear)
	pMonth = pMonth + 12 * (pYear - self.Year)
	
	return pMonth - self.Month
end

function GroupCalendar.WoWCalendar:GetNumAbsDayEvents(pMonth, pDay, pYear)
	return self:GetNumDayEvents(self:GetMonthOffset(pMonth, pYear), pDay)
end

function GroupCalendar.WoWCalendar:RemoveAbsEvent(pMonth, pDay, pYear, pEventIndex)
	return self:ContextMenuEventRemove(self:GetMonthOffset(pMonth, pYear), pDay, pEventIndex)
end

----------------------------------------
--
----------------------------------------

GroupCalendar.CALENDAR_CALENDARTYPE_TEXTURE_PATHS = {
--	["PLAYER"]				= "",
--	["GUILD_ANNOUNCEMENT"]	= "",
--	["GUILD_EVENT"]			= "",
--	["SYSTEM"]				= "",
	["HOLIDAY"]				= "Interface\\Calendar\\Holidays\\",
--	["RAID_LOCKOUT"]		= "",
--	["RAID_RESET"]			= "",
}

GroupCalendar.CALENDAR_CALENDARTYPE_TEXTURES =
{
	["PLAYER"] = {
--		[""]				= "",
	},
	["GUILD_ANNOUNCEMENT"] = {
--		[""]				= "",
	},
	["GUILD_EVENT"] = {
--		[""]				= "",
	},
	["SYSTEM"] = {
--		[""]				= "",
	},
	["HOLIDAY"] = {
		["START"]			= "Interface\\Calendar\\Holidays\\Calendar_DefaultHoliday",
--		["ONGOING"]			= "",
		["END"]				= "Interface\\Calendar\\Holidays\\Calendar_DefaultHoliday",
		["INFO"]			= "Interface\\Calendar\\Holidays\\Calendar_DefaultHoliday",
--		[""]				= "",
	},
	["RAID_LOCKOUT"] = {
--		[""]				= "",
	},
	["RAID_RESET"] = {
--		[""]				= "",
	},
	["COMMUNITY_EVENT"] = {
--		[""]				= "",
	},
}

GroupCalendar.CALENDAR_CALENDARTYPE_TEXTURE_APPEND =
{
--	["PLAYER"] = {
--	},
--	["GUILD_ANNOUNCEMENT"] = {
--	},
--	["GUILD_EVENT"] = {
--	},
--	["SYSTEM"] = {
--	},
	["HOLIDAY"] = {
		["START"]			= "Start",
		["ONGOING"]			= "Ongoing",
		["END"]				= "End",
		["INFO"]			= "Info",
		[""]				= "",
	},
--	["RAID_LOCKOUT"] = {
--	},
--	["RAID_RESET"] = {
--	},
}

GroupCalendar.CALENDAR_CALENDARTYPE_TCOORDS =
{
	["PLAYER"] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
	["GUILD_ANNOUNCEMENT"] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
	["GUILD_EVENT"] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
	["SYSTEM"] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
	["HOLIDAY"] = {
		left	= 0.0,
		right	= 0.7109375,
		top		= 0.0,
		bottom	= 0.7109375,
	},
	["RAID_LOCKOUT"] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
	["RAID_RESET"] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
}

GroupCalendar.CALENDAR_MONTH_NAMES =
{
	MONTH_JANUARY,
	MONTH_FEBRUARY,
	MONTH_MARCH,
	MONTH_APRIL,
	MONTH_MAY,
	MONTH_JUNE,
	MONTH_JULY,
	MONTH_AUGUST,
	MONTH_SEPTEMBER,
	MONTH_OCTOBER,
	MONTH_NOVEMBER,
	MONTH_DECEMBER,
}

GroupCalendar.CALENDAR_FULLDATE_MONTH_NAMES =
{
	FULLDATE_MONTH_JANUARY,
	FULLDATE_MONTH_FEBRUARY,
	FULLDATE_MONTH_MARCH,
	FULLDATE_MONTH_APRIL,
	FULLDATE_MONTH_MAY,
	FULLDATE_MONTH_JUNE,
	FULLDATE_MONTH_JULY,
	FULLDATE_MONTH_AUGUST,
	FULLDATE_MONTH_SEPTEMBER,
	FULLDATE_MONTH_OCTOBER,
	FULLDATE_MONTH_NOVEMBER,
	FULLDATE_MONTH_DECEMBER,
}

-- Event Types

GroupCalendar.CALENDAR_EVENTTYPE_TEXTURE_PATHS = {
	[CALENDAR_EVENTTYPE_RAID]		= "Interface\\LFGFrame\\LFGIcon-",
	[CALENDAR_EVENTTYPE_DUNGEON]	= "Interface\\LFGFrame\\LFGIcon-",
}
GroupCalendar.CALENDAR_EVENTTYPE_TEXTURES = {
	[CALENDAR_EVENTTYPE_RAID]		= "Interface\\LFGFrame\\LFGIcon-Raid",
	[CALENDAR_EVENTTYPE_DUNGEON]	= "Interface\\LFGFrame\\LFGIcon-Dungeon",
	[CALENDAR_EVENTTYPE_PVP]		= "Interface\\Calendar\\UI-Calendar-Event-PVP",
	[CALENDAR_EVENTTYPE_MEETING]	= "Interface\\Calendar\\MeetingIcon",
	[CALENDAR_EVENTTYPE_OTHER]		= "Interface\\Calendar\\UI-Calendar-Event-Other",
}

GroupCalendar.CALENDAR_EVENTTYPE_TCOORDS = {
	[CALENDAR_EVENTTYPE_RAID] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
	[CALENDAR_EVENTTYPE_DUNGEON] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
	[CALENDAR_EVENTTYPE_PVP] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
	[CALENDAR_EVENTTYPE_MEETING] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
	[CALENDAR_EVENTTYPE_OTHER] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
}

GroupCalendar.CALENDAR_CALENDARTYPE_NAMEFORMAT =
{
	HOLIDAY =
	{
		START = CALENDAR_EVENTNAME_FORMAT_START,
		END = CALENDAR_EVENTNAME_FORMAT_END,
	},
	RAID_LOCKOUT =
	{
		[""] = CALENDAR_EVENTNAME_FORMAT_RAID_LOCKOUT,
	},
	RAID_RESET =
	{
		[""] = CALENDAR_EVENTNAME_FORMAT_RAID_RESET,
	},
}

GroupCalendar.TitleTagInfo =
{
	BRTH =
	{
		CanEdit = true,
		AllDay = true,
		Texture = GroupCalendar.AddonPath.."Textures\\Icon-Birth",
		IsPersonal = true,
		IsCooldown = false,
		UsesAttendance = true,
		Defaults = {CalendarType = "PLAYER", Title = GroupCalendar.cBirthdayTitleFormat},
	},
	MD =
	{
		CanEdit = true,
		Texture = "Interface\\Icons\\Spell_Holy_SealOfSacrifice", -- Doctor
		TexCoords = {left = 0.0625, right = 0.9375, top = 0.0625, bottom = 0.9375},
		IsPersonal = true,
		UsesAttendance = true,
		Defaults = {CalendarType = "PLAYER", Title = GroupCalendar.cDoctorEventName},
	},
	DDS =
	{
		CanEdit = true,
		Texture = "Interface\\Icons\\INV_Misc_Bone_09", -- Dentist
		TexCoords = {left = 0.0625, right = 0.9375, top = 0.0625, bottom = 0.9375},
		IsPersonal = true,
		UsesAttendance = true,
		Defaults = {CalendarType = "PLAYER", Title = GroupCalendar.cDentistEventName},
	},
	VAC =
	{
		CanEdit = true,
		Texture = GroupCalendar.AddonPath.."Textures\\Icon-Vacation", -- Vacation
		IsPersonal = true,
		UsesAttendance = true,
		Defaults = {CalendarType = "PLAYER", Title = GroupCalendar.cVacationEventName},
	},
	RP =
	{
		CanEdit = true,
		Texture = GroupCalendar.AddonPath.."Textures\\Icon-RP", -- Roleplaying
		IsPersonal = false,
		UsesAttendance = true,
		Defaults = {Title = GroupCalendar.cRoleplayEventName},
	},
	
	-- Cooldowns
	
	XMUT =
	{
		CanEdit = false,
		Texture = "Interface\\Icons\\Trade_Alchemy", -- Transmutes
		TexCoords = {left = 0.0625, right = 0.9375, top = 0.0625, bottom = 0.9375},
		IsPersonal = true,
		IsCooldown = true,
		UsesAttendance = false,
	},
	ALCH =
	{
		CanEdit = false,
		Texture = "Interface\\Icons\\INV_Potion_106", -- Alchemy Research
		TexCoords = {left = 0.0625, right = 0.9375, top = 0.0625, bottom = 0.9375},
		IsPersonal = true,
		IsCooldown = true,
		UsesAttendance = false,
	},
	VOID =
	{
		CanEdit = false,
		Texture = "Interface\\Icons\\INV_Enchant_ShardPrismaticLarge", -- Void Shatter
		TexCoords = {left = 0.0625, right = 0.9375, top = 0.0625, bottom = 0.9375},
		IsPersonal = true,
		IsCooldown = true,
		UsesAttendance = false,
	},
	SPHR =
	{
		CanEdit = false,
		Texture = "Interface\\Icons\\INV_Enchant_VoidSphere", -- Void Sphere 
		TexCoords = {left = 0.0625, right = 0.9375, top = 0.0625, bottom = 0.9375},
		IsPersonal = true,
		IsCooldown = true,
		UsesAttendance = false,
	},
	MOON =
	{
		CanEdit = false,
		Texture = "Interface\\Icons\\INV_Fabric_MoonRag_01", -- Mooncloth
		TexCoords = {left = 0.0625, right = 0.9375, top = 0.0625, bottom = 0.9375},
		IsPersonal = true,
		IsCooldown = true,
		UsesAttendance = false,
	},
	PMON = 
	{
		CanEdit = false,
		Texture = "Interface\\Icons\\INV_Fabric_Moonshroud", -- Primal Mooncloth
		TexCoords = {left = 0.0625, right = 0.9375, top = 0.0625, bottom = 0.9375},
		IsPersonal = true,
		IsCooldown = true,
		UsesAttendance = false,
	},
	SPEL =
	{
		CanEdit = false,
		Texture = "Interface\\Icons\\INV_Fabric_Spellfire", -- Spellcloth
		TexCoords = {left = 0.0625, right = 0.9375, top = 0.0625, bottom = 0.9375},
		IsPersonal = true,
		IsCooldown = true,
		UsesAttendance = false,
	},
	SHAD =
	{
		CanEdit = false,
		Texture = "Interface\\Icons\\INV_Fabric_Felcloth_Ebon", -- Shadowcloth
		TexCoords = {left = 0.0625, right = 0.9375, top = 0.0625, bottom = 0.9375},
		IsPersonal = true,
		IsCooldown = true,
		UsesAttendance = false,
	},
	EBON =
	{
		CanEdit = false,
		Texture = "Interface\\Icons\\INV_Fabric_Ebonweave", -- Ebonweave
		TexCoords = {left = 0.0625, right = 0.9375, top = 0.0625, bottom = 0.9375},
		IsPersonal = true,
		IsCooldown = true,
		UsesAttendance = false,
	},
	SWEV =
	{
		CanEdit = false,
		Texture = "Interface\\Icons\\INV_Fabric_Spellweave", -- Spellweave
		TexCoords = {left = 0.0625, right = 0.9375, top = 0.0625, bottom = 0.9375},
		IsPersonal = true,
		IsCooldown = true,
		UsesAttendance = false,
	},
	SHRD =
	{
		CanEdit = false,
		Texture = "Interface\\Icons\\INV_Fabric_Moonshroud", -- Moonshroud
		TexCoords = {left = 0.0625, right = 0.9375, top = 0.0625, bottom = 0.9375},
		IsPersonal = true,
		IsCooldown = true,
		UsesAttendance = false,
	},
	GLSS =
	{
		CanEdit = false,
		Texture = "Interface\\Icons\\INV_Misc_Gem_02", -- Brilliant Glass
		TexCoords = {left = 0.0625, right = 0.9375, top = 0.0625, bottom = 0.9375},
		IsPersonal = true,
		IsCooldown = true,
		UsesAttendance = false,
	},
	ICYP =
	{
		CanEdit = false,
		Texture = "Interface\\Icons\\INV_Misc_Gem_Diamond_02", -- Icy Prism
		TexCoords = {left = 0.0625, right = 0.9375, top = 0.0625, bottom = 0.9375},
		IsPersonal = true,
		IsCooldown = true,
		UsesAttendance = false,
	},
	FIRP =
	{
		CanEdit = false,
		Texture = "Interface\\Icons\\INV_Misc_Gem_Ruby_01", -- Fire Prism
		TexCoords = {left = 0.0625, right = 0.9375, top = 0.0625, bottom = 0.9375},
		IsPersonal = true,
		IsCooldown = true,
		UsesAttendance = false,
	},
	INSC =
	{
		CanEdit = false,
		Texture = "Interface\\Icons\\INV_Inscription_Tradeskill01", -- Inscription Research
		TexCoords = {left = 0.0625, right = 0.9375, top = 0.0625, bottom = 0.9375},
		IsPersonal = true,
		IsCooldown = true,
		UsesAttendance = false,
	},
	INSN =
	{
		CanEdit = false,
		Texture = "Interface\\Icons\\INV_Inscription_Tradeskill01", -- Northrend Inscription Research
		TexCoords = {left = 0.0625, right = 0.9375, top = 0.0625, bottom = 0.9375},
		IsPersonal = true,
		IsCooldown = true,
		UsesAttendance = false,
	},
	TITN =
	{
		CanEdit = false,
		Texture = "Interface\\Icons\\INV_Ingot_Titansteel_blue", -- Smelt Titansteel
		TexCoords = {left = 0.0625, right = 0.9375, top = 0.0625, bottom = 0.9375},
		IsPersonal = true,
		IsCooldown = true,
		UsesAttendance = false,
	},
}

GroupCalendar.CALENDAR_TITLETAG_DEFAULT_TCOORDS =
{
	left	= 0.0,
	right	= 1.0,
	top		= 0.0,
	bottom	= 1.0,
}

GroupCalendar.CALENDAR_TITLETAG_TCOORDS =
{
}

function GroupCalendar:GetTextureFile(pTextureName, pCalendarType, pSequenceType, pEventType, pTitleTag)
	local vTexture, vTexCoords
	
	-- GroupCalendar:DebugMessage("GetTextureFile: %s (CalType: %s SeqType: %s EventType: %s)", pTextureName or "nil", pCalendarType or "nil", pSequenceType or "nil", pEventType or "nil")
	
	if pTitleTag and self.TitleTagInfo[pTitleTag] then
		vTexture = self.TitleTagInfo[pTitleTag].Texture
		vTexCoords = self.TitleTagInfo[pTitleTag].TexCoords or GroupCalendar.CALENDAR_TITLETAG_DEFAULT_TCOORDS
	elseif pTextureName and pTextureName ~= "" then
		-- pTextureName is actually a texture ID which can be used directly in the call to SetTexture()
		vTexture = pTextureName
		if self.CALENDAR_CALENDARTYPE_TEXTURE_PATHS[pCalendarType] then
			-- vTexture = self.CALENDAR_CALENDARTYPE_TEXTURE_PATHS[pCalendarType]..pTextureName
			-- if self.CALENDAR_CALENDARTYPE_TEXTURE_APPEND[pCalendarType] then
			-- 	vTexture = vTexture..self.CALENDAR_CALENDARTYPE_TEXTURE_APPEND[pCalendarType][pSequenceType]
			-- end
			vTexCoords = self.CALENDAR_CALENDARTYPE_TCOORDS[pCalendarType]
		elseif self.CALENDAR_EVENTTYPE_TEXTURE_PATHS[pEventType] then
			-- vTexture = self.CALENDAR_EVENTTYPE_TEXTURE_PATHS[pEventType]..pTextureName
			vTexCoords = self.CALENDAR_EVENTTYPE_TCOORDS[pEventType]
		elseif self.CALENDAR_CALENDARTYPE_TEXTURES[pCalendarType][pSequenceType] then
			-- vTexture = self.CALENDAR_CALENDARTYPE_TEXTURES[pCalendarType][pSequenceType]
			vTexCoords = self.CALENDAR_CALENDARTYPE_TCOORDS[pCalendarType]
		elseif self.CALENDAR_EVENTTYPE_TEXTURES[pEventType] then
			-- vTexture = self.CALENDAR_EVENTTYPE_TEXTURES[pEventType]
			vTexCoords = self.CALENDAR_EVENTTYPE_TCOORDS[pEventType]
		end
	elseif self.CALENDAR_CALENDARTYPE_TEXTURES[pCalendarType] and self.CALENDAR_CALENDARTYPE_TEXTURES[pCalendarType][pSequenceType] then
		vTexture = self.CALENDAR_CALENDARTYPE_TEXTURES[pCalendarType][pSequenceType]
		vTexCoords = self.CALENDAR_CALENDARTYPE_TCOORDS[pCalendarType]
	elseif self.CALENDAR_EVENTTYPE_TEXTURES[pEventType] then
		vTexture = self.CALENDAR_EVENTTYPE_TEXTURES[pEventType]
		vTexCoords = self.CALENDAR_EVENTTYPE_TCOORDS[pEventType]
	end
		
	return vTexture, vTexCoords
end

function GroupCalendar:GetTextureCache()
	if not self.textureCache then
		self.textureCache = {}
		self.textureCache[CALENDAR_EVENTTYPE_RAID] = self:TextureCacheForEventType(CALENDAR_EVENTTYPE_RAID, C_Calendar.EventGetTextures(CALENDAR_EVENTTYPE_RAID))
		self.textureCache[CALENDAR_EVENTTYPE_DUNGEON] = self:TextureCacheForEventType(CALENDAR_EVENTTYPE_DUNGEON, C_Calendar.EventGetTextures(CALENDAR_EVENTTYPE_DUNGEON))
	end
	return self.textureCache
end

function GroupCalendar:TextureCacheForEventType(eventType, textures)
	local eventTypeTextureCache = {}

	local overlappingMapIDs = (eventType == CALENDAR_EVENTTYPE_RAID or eventType == CALENDAR_EVENTTYPE_DUNGEON) and {}

	local cacheIndex = 1
	for textureIndex, texture in ipairs(textures) do
		if not eventTypeTextureCache[cacheIndex] then
			eventTypeTextureCache[cacheIndex] = {}
		end


		local difficultyName, instanceType, isHeroic, isChallengeMode, displayHeroic, displayMythic, toggleDifficultyID = GetDifficultyInfo(texture.difficultyId)
		if not difficultyName then
			difficultyName = ""
		end

		if overlappingMapIDs and overlappingMapIDs[texture.mapId] then
			-- Already exists a map, collapse the difficulty
			local firstCacheIndex = overlappingMapIDs[texture.mapId]
			local cacheEntry = eventTypeTextureCache[firstCacheIndex]

			if cacheEntry.isLFR and not texture.isLfr then
				-- Prefer a non-LFR name over a LFR name
				cacheEntry.title = texture.title
				cacheEntry.isLFR = nil
			end

			if cacheEntry.displayHeroic or cacheEntry.displayMythic and (not displayHeroic and not displayMythic) then
				-- Prefer normal difficulty name over higher difficulty
				cacheEntry.title = texture.title
				cacheEntry.displayHeroic = nil
				cacheEntry.displayMythic = nil
			end

			table.insert(cacheEntry.difficulties, { textureIndex = textureIndex, difficultyName = difficultyName })
		else
			eventTypeTextureCache [cacheIndex].textureIndex = textureIndex
			eventTypeTextureCache [cacheIndex].title = texture.title
			eventTypeTextureCache [cacheIndex].texture = texture.iconTexture
			eventTypeTextureCache [cacheIndex].expansionLevel = texture.expansionLevel
			eventTypeTextureCache [cacheIndex].difficultyName = difficultyName
			eventTypeTextureCache [cacheIndex].isLFR = texture.isLfr
			eventTypeTextureCache [cacheIndex].displayHeroic = displayHeroic
			eventTypeTextureCache [cacheIndex].displayMythic = displayMythic

			if overlappingMapIDs then
				if not overlappingMapIDs[texture.mapId] then
					overlappingMapIDs[texture.mapId] = cacheIndex
				end
				eventTypeTextureCache [cacheIndex].difficulties = { { textureIndex = textureIndex, difficultyName = difficultyName } }
			end

			cacheIndex = cacheIndex + 1
		end
	end

	return eventTypeTextureCache
end

function GroupCalendar:GetEventTexture(index, eventType)
	local textureCache = self:GetTextureCache()
	local eventTextureCache = textureCache[eventType]

	if not eventTextureCache then
		return nil
	end

	for cacheIndex, textureInfo in ipairs(eventTextureCache) do
		if textureInfo.difficulties then
			for difficultyIndex, difficultyInfo in ipairs(textureInfo.difficulties) do
				if difficultyInfo.textureIndex == index then
					return textureInfo, difficultyInfo
				end
			end
		end

		if textureInfo.textureIndex and index == textureInfo.textureIndex then
			return textureInfo
		end
	end
	return nil
end

function GroupCalendar:toluastring(pValue)
	if type(pValue) == "string" then
		return "\""..pValue.."\""
	else
		return tostring(pValue)
	end
end

function GroupCalendar:ShowFunctionParameters(pFunctionName, pResult, ...)
	local vFunctionParams

	for vIndex = 1, select("#", ...) do
		if not vFunctionParams then
			vFunctionParams = self:toluastring(select(vIndex, ...))
		else
			vFunctionParams = vFunctionParams..", "..self:toluastring(select(vIndex, ...))
		end
	end
	
	local vResults
	
	for vIndex, vResult in ipairs(pResult) do
		if not vResults then
			vResults = self:toluastring(vResult)
		else
			vResults = vResults..", "..self:toluastring(vResult)
		end
	end
	
	GroupCalendar:DebugMessage("%s(%s) returned %s", pFunctionName, vFunctionParams or "", vResults or "nil")
end

function GroupCalendar:MonitorCalendarAPI()
	if self.PatchedWoWCalendarAPI then
		return
	end

	self.InWoWAPI = {}

	for name, body in pairs(C_Calendar) do
		if type(body) == "function" then
			C_Calendar[name] = function (...)
				local result = {body(...)}

				GroupCalendar:ShowFunctionParameters(name, result, ...)

				return unpack(result)
			end
		end
	end

	self.PatchedWoWCalendarAPI = true
end
