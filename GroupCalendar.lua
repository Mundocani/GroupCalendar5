----------------------------------------
-- Group Calendar 5 Copyright (c) 2018 John Stephen
-- All rights reserved, unuauthorized redistribution is prohibited
----------------------------------------

GroupCalendar_Data = nil

function GroupCalendar:Initialize()
	GroupCalendar.EventLib:UnregisterEvent("PLAYER_ENTERING_WORLD", GroupCalendar.Initialize, GroupCalendar)
	
	GroupCalendar.WoWCalendar:Init()
	
	GroupCalendar:InitializeData()
	
	self:InitializeRealm()
	self:InitializeCharacter()
	self.Alts = GroupCalendar:New(GroupCalendar._Alts)
	self.WhisperLog = GroupCalendar:New(GroupCalendar._WhisperLog)
	
	self:InitializeCalendars()

	self:InitializeTradeskill()
	
	self:InstallSlashCommand()
	
	-- Queue a command to start loading the calendar data
	
	self.SchedulerLib:ScheduleTask(5, function ()
		local calendarDate = self.WoWCalendar:GetDate()
		
		self.WoWCalendar:SetAbsMonth(calendarDate.month, calendarDate.year)
		self.WoWCalendar:OpenCalendar()
	end)
	
	--
	
	self.MessageFrame = GroupCalendar:New(GroupCalendar._MessageFrame)
	
	GameTimeFrame:SetScript("OnEnter", function (...) self:GameTimeFrame_OnEnter(...) end)
	GameTimeFrame:SetScript("OnUpdate", function (...) self:GameTimeFrame_OnUpdate(...) end)
	
	self.EventLib:RegisterCustomEvent("GC5_CALENDAR_CHANGED", self.CheckForNewEvents, self)
	
	-- Disable the built-in reminder glow/icon
	
	GameTimeCalendarInvitesTexture:SetTexture("")
	GameTimeCalendarInvitesGlow:SetTexture("")
	
	--
	
	self.EventLib:DispatchEvent("GC5_INIT")
	self:DebugMessage("Group Calendar initialized")
end

function GroupCalendar:ShowTooltip(pOwnerFrame, pTitle, pDescription)
	--[[
	GameTooltip:SetOwner(pOwnerFrame, "ANCHOR_NONE")
	GameTooltip:SetPoint("BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -CONTAINER_OFFSET_X - 13, CONTAINER_OFFSET_Y)
	GameTooltip:SetText(pTitle, 1, 1, 1)
	GameTooltip:AddLine(pDescription, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1)
	GameTooltip:Show()
	]]
	GameTooltip_AddNewbieTip(pOwnerFrame, pTitle, 1, 1, 1, pDescription)
end

function GroupCalendar:HideTooltip()
	GameTooltip:Hide()
end

function GroupCalendar:FlushEventCaches()
	for _, vCalendar in pairs(self.Calendars) do
		vCalendar:FlushCaches()
	end
end

function GroupCalendar:GetLatestVersionInfo()
	if not self.LatestVersionInfo then
		self.LatestVersionInfo = GroupCalendar:New(GroupCalendar._Version, "5.0")
	end
	
	return self.LatestVersionInfo
end

function GroupCalendar:GameTimeFrame_OnEnter(pGameTimeFrame)
	local vDate, vTime, vMonth, vDay, vYear = self.DateLib:GetServerDateTime()
	local vEvents = self:GetDayEvents(vMonth, vDay, vYear)
	local vLocalDate, vLocalTime = self.DateLib:GetLocalDateTime()
	
	local vDateString, vTimeString
	
	if GroupCalendar.Clock.Data.ShowLocalTime then
		vDateString = GroupCalendar.DateLib:GetLongDateString(vLocalDate, true)
		vTimeString = GroupCalendar.DateLib:GetShortTimeString(vLocalTime, true).." "..GroupCalendar.cServerTimeNote:format(GroupCalendar.DateLib:GetShortTimeString(vTime, true))
	else
		vDateString = GroupCalendar.DateLib:GetLongDateString(vDate, true)
		vTimeString = GroupCalendar.DateLib:GetShortTimeString(vTime, true).." "..GroupCalendar.cLocalTimeNote:format(GroupCalendar.DateLib:GetShortTimeString(vLocalTime, true))
	end
	
	GameTooltip:SetOwner(pGameTimeFrame, "ANCHOR_BOTTOMLEFT")
	GameTooltip:AddDoubleLine(
			vDateString,
			vTimeString,
			NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b,
			NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
	GroupCalendar:AddTooltipEvents(GameTooltip, vEvents, GroupCalendar.Clock.Data.ShowLocalTime)
	
	GameTooltip:AddLine(GroupCalendar.cMinimapButtonHint)
	GameTooltip:AddLine(GroupCalendar.cMinimapButtonHint2)
	
	GameTooltip:Show()
end

function GroupCalendar:GameTimeFrame_OnUpdate()
end

function GroupCalendar:GetDayEvents(pMonth, pDay, pYear, pRecycleTable)
	local vEvents = pRecycleTable
	
	if vEvents then
		for vKey, _ in pairs(vEvents) do
			vEvents[vKey] = nil
		end
	end
	
	for vCalendarID, vCalendar in pairs(GroupCalendar.Calendars) do
		if vCalendarID == "BLIZZARD" or vCalendarID == "PLAYER" or GroupCalendar.PlayerData.Prefs.ShowAlts then
			local vCalendarDay = vCalendar:GetSchedule(pMonth, pDay, pYear)
			
			for _, vEvent in ipairs(vCalendarDay.Events) do
				if vEvent:EventIsVisible(vCalendarID == "PLAYER")
				and (self.PlayerData.Prefs.ShowLockouts or vEvent.CalendarType ~= "RAID_LOCKOUT") then
					if not vEvents then
						vEvents = {}
					end
					
					table.insert(vEvents, vEvent)
				end
			end
		end
	end
	
	if GroupCalendar.Clock.Data.ShowLocalTime then
		local vDay2Offset
		
		if GroupCalendar.DateLib:GetServerToLocalOffset() < 0 then
			vDay2Offset = 1
		else
			vDay2Offset = -1
		end
		
		local vMonth2, vDay2, vYear2 = GroupCalendar.DateLib:ConvertDateToMDY(GroupCalendar.DateLib:ConvertMDYToDate(pMonth, pDay, pYear) + vDay2Offset)
		
		for vCalendarID, vCalendar in pairs(GroupCalendar.Calendars) do
			local vCalendarDay = vCalendar:GetSchedule(vMonth2, vDay2, vYear2)
			
			for _, vEvent in ipairs(vCalendarDay.Events) do
				if vEvent:EventIsVisible(vCalendarID == "PLAYER")
				and (self.PlayerData.Prefs.ShowLockouts or vEvent.CalendarType ~= "RAID_LOCKOUT") then
					if not vEvents then
						vEvents = {}
					end
					
					table.insert(vEvents, vEvent)
				end
			end
		end
	end
	
	if vEvents then
		table.sort(vEvents, GroupCalendar.CompareEventTimes)

		-- Prune out events outside the range if we're using local date/times
		
		if GroupCalendar.Clock.Data.ShowLocalTime then
			local vNumEvents = #vEvents
			local vIndex = 1
			
			while vIndex <= vNumEvents do
				local vEvent = vEvents[vIndex]
				local vLocalDate, vLocalTime = GroupCalendar.DateLib:GetLocalDateTimeFromServerDateTime(GroupCalendar.DateLib:ConvertMDYToDate(vEvent.Month, vEvent.Day, vEvent.Year), GroupCalendar.DateLib:ConvertHMToTime(vEvent.Hour, vEvent.Minute))
				local vLocalMonth, vLocalDay, vLocalYear = GroupCalendar.DateLib:ConvertDateToMDY(vLocalDate)
				
				if vLocalMonth ~= pMonth
				or vLocalDay ~= pDay
				or vLocalYear ~= pYear then
					table.remove(vEvents, vIndex)
					vNumEvents = vNumEvents - 1
				else
					vIndex = vIndex + 1
				end
			end
		end
	end
	
	return vEvents
end

function GroupCalendar:CanCreateEventOnDate(month, day, year)
	return self:IsTodayOrLater(month, day, year) and not self:IsAfterMaxCreateDate(month, day, year)
end

function GroupCalendar:IsTodayOrLater(month, day, year)
	local calendarDate = self.WoWCalendar:GetDate()
	
	if year > calendarDate.year then
		return true
	elseif year < calendarDate.year then
		return false
	elseif month > calendarDate.month then
		return true
	elseif month < calendarDate.month then
		return false
	else
		return day >= calendarDate.monthDay
	end
end

function GroupCalendar:IsAfterMaxCreateDate(month, day, year)
	local maxCreateDate = self.WoWCalendar:GetMaxCreateDate()
	
	if year > maxCreateDate.year then
		return true
	elseif year < maxCreateDate.year then
		return false
	elseif month > maxCreateDate.month then
		return true
	elseif month < maxCreateDate.month then
		return false
	else
		return day > calendarDate.monthDay
	end
end

----------------------------------------
-- Utilities
----------------------------------------

function GroupCalendar:ReverseTable(pTable)
	local vTable = {}
	
	for vKey, vValue in pairs(pTable) do
		vTable[vValue] = vKey
	end
	
	return vTable
end

function GroupCalendar:SetEditBoxAutoCompleteText(pEditBox, pText)
	local vEditBoxText = pEditBox:GetText():upper()
	local vEditBoxTextLength = vEditBoxText:len()
	
	pEditBox:SetText(pText)
	pEditBox:HighlightText(vEditBoxTextLength, -1)
end

GroupCalendar.cDeformat =
{
	s = "(.-)",
	d = "(-?[%d]+)",
	f = "(-?[%d%.e%+%-]+)",
	g = "(-?[%d%.]+)",
	["%"] = "%%",
}

function GroupCalendar:ConvertFormatStringToSearchPattern(pFormat)
	local vFormat = pFormat:gsub(
			"[%[%]%.]",
			function (pChar) return "%"..pChar end)
	
	return vFormat:gsub(
			"%%[%-%d%.]-([sdgf%%])",
			self.cDeformat)
end

function GroupCalendar:FormatItemList(pList)
	local vNumItems = #pList
	
	if vNumItems == 0 then
		return ""
	elseif vNumItems == 1 then
		return string.format(self.cSingleItemFormat, pList[1])
	elseif vNumItems == 2 then
		return string.format(self.cTwoItemFormat, pList[1], pList[2])
	else
		local vStartIndex, vEndIndex, vPrefix, vRepeat, vSuffix = string.find(self.cMultiItemFormat, "(.*){{(.*)}}(.*)")
		local vResult
		local vParamIndex = 1
		
		if vPrefix and string.find(vPrefix, "%%") then
			vResult = string.format(vPrefix, pList[1])
			vParamIndex = 2
		else
			vResult = vPrefix or ""
		end
		
		if vRepeat then
			for vIndex = vParamIndex, vNumItems - 1 do
				vResult = vResult..string.format(vRepeat, pList[vIndex])
			end
		end
			
		if vSuffix then
			vResult = vResult..string.format(vSuffix, pList[vNumItems])
		end
		
		return vResult
	end
end

function GroupCalendar:Reset()
	GroupCalendar_Data = nil
	ReloadUI()
end

function GroupCalendar:ConfirmDelete(pMessage, pParam, pConfirmFunc)
	if not StaticPopupDialogs.GC5_CONFIRM_DELETE then
		StaticPopupDialogs.GC5_CONFIRM_DELETE =
		{
			preferredIndex = 3,
			text = "",
			button1 = DELETE,
			button2 = CANCEL,
			OnAccept = nil,
			timeout = 0,
			whileDead = 1,
			hideOnEscape = 1,
		}
	end
	StaticPopupDialogs.GC5_CONFIRM_DELETE.text = pMessage
	StaticPopupDialogs.GC5_CONFIRM_DELETE.OnAccept = pConfirmFunc
	StaticPopup_Show("GC5_CONFIRM_DELETE", pParam)
end

----------------------------------------
-- /cal
----------------------------------------

function GroupCalendar:InstallSlashCommand()
	SlashCmdList.CAL = function (...) GroupCalendar:ExecuteCommand(...) end
	SLASH_CAL1 = "/cal"
end

function GroupCalendar:ExecuteCommand(pCommandString, ...)
	local _, _, vCommand, vParameter = string.find(pCommandString, "([^%s]+)%s*(.*)")
	local vCommandFunc = self.Commands[strlower(vCommand or "help")] or self.Commands.help
	
	vCommandFunc(self, vParameter)
end

GroupCalendar.CommandHelp =
{
	GroupCalendar.cHelpHeader,
	HIGHLIGHT_FONT_COLOR_CODE.."/cal help"..NORMAL_FONT_COLOR_CODE.." "..GroupCalendar.cHelpHelp,
	HIGHLIGHT_FONT_COLOR_CODE.."/cal reset"..NORMAL_FONT_COLOR_CODE.." "..GroupCalendar.cHelpReset,
	HIGHLIGHT_FONT_COLOR_CODE.."/cal debug switch on|off"..NORMAL_FONT_COLOR_CODE.." "..GroupCalendar.cHelpDebug,
}

----------------------------------------
GroupCalendar.Commands = {}
----------------------------------------

function GroupCalendar.Commands:help()
	for _, vString in ipairs(self.CommandHelp) do
		self:NoteMessage(vString)
	end
end

function GroupCalendar.Commands:reset()
	if not StaticPopupDialogs.GC5_CONFIRM_RESET then
		StaticPopupDialogs.GC5_CONFIRM_RESET =
		{
			preferredIndex = 3,
			text = GroupCalendar.cConfirmReset,
			button1 = RESET,
			button2 = CANCEL,
			OnAccept = function() GroupCalendar:Reset() end,
			timeout = 0,
			whileDead = 1,
			hideOnEscape = 1,
		}
	end
	StaticPopup_Show("GC5_CONFIRM_RESET")	
end

function GroupCalendar.Commands:debug(pParameter)
	local _, _, vSwitch, vState = pParameter:find("([^%s]+) ?(.*)")
	
	vSwitch = vSwitch:lower()
	vState = vState:lower()
	
	if vSwitch == "off" then
		for vKey, _ in pairs(GroupCalendar.Debug) do
			GroupCalendar.Debug[vKey] = nil
		end
		
		GroupCalendar:NoteMessage("All debug messages disabled")
	else
		GroupCalendar.Debug[vSwitch] = vState == "on" or vState == "true"
		GroupCalendar:NoteMessage("Debug flag %s is now set to %s", vSwitch, tostring(GroupCalendar.Debug[vSwitch]))
	end
end

----------------------------------------
GroupCalendar._MinimapReminder = {}
----------------------------------------

function GroupCalendar._MinimapReminder:New()
	return CreateFrame("Frame", nil, GameTimeFrame)
end

function GroupCalendar._MinimapReminder:Construct()
	self:SetAllPoints()
	self:SetFrameLevel(GameTimeFrame:GetFrameLevel() + 2)
	
	self.Enabled = false
	self.OnDuration = 0.4
	self.OffDuration = 0.2
	self.FadeDuration = 0.5
	self.FlashDuration = 60 * 60
	self.ShowingIcon = false
	self.Icon = nil
	--[[
	self.Texture = self:CreateTexture(nil, "BACKGROUND")
	self.Texture:SetWidth(32)
	self.Texture:SetHeight(32)
	self.Texture:SetPoint("TOPLEFT", self, "TOPLEFT", 8, -8)
	self.Texture:SetTexture("")
	]]
	self.OverlayTexture = self:CreateTexture(nil, "BORDER")
	self.OverlayTexture:SetAllPoints(true)
	self.OverlayTexture:SetTexture(GroupCalendar.AddonPath.."Textures\\CalendarButton-ReminderFrame")
	self.OverlayTexture:SetTexCoord(0, 0.78125, 0, 0.78125)
	
	self.HighlightTexture = self:CreateTexture("GC5MinimapHighlight", "OVERLAY")
	self.HighlightTexture:SetBlendMode("ADD")
	self.HighlightTexture:SetAllPoints(true)
	self.HighlightTexture:SetTexture(GroupCalendar.AddonPath.."Textures\\CalendarButton-Hilight")
	self.HighlightTexture:SetTexCoord(0, 0.78125, 0, 0.78125)
	
	self.HighlightTexture:Hide()
end

function GroupCalendar._MinimapReminder:ShowIcon(pIcon, pTexCoords)
	--GroupCalendar.Clock.Frame:SetBackground(pIcon, pTexCoords)
end

function GroupCalendar._MinimapReminder:HideIcon()
	--GroupCalendar.Clock.Frame:SetBackground(nil)
end

function GroupCalendar._MinimapReminder:StartFlashing(pIcon, pTexCoords)
	if pIcon then
		self:ShowIcon(pIcon, pTexCoords)
	end
	
	if not self.Enabled then
		self.Enabled = true
		self:UpdateIcon()
	end
end

function GroupCalendar._MinimapReminder:StopFlashing()
	self.Enabled = false
	self:UpdateIcon()
end

function GroupCalendar._MinimapReminder:Stop()
	self:StopFlashing()
	self:HideIcon()
end

function GroupCalendar._MinimapReminder:UpdateIcon()
	local vShowNotifyIcon = false
	
	if self.FlashAnimation then
		self.FlashAnimation:Stop()
		self.HighlightTexture:Hide()
	end
	
	if self.Enabled then
		if not self.FlashAnimation then
			self.FlashAnimation = self.HighlightTexture:CreateAnimationGroup()
			local fadeIn = self.FlashAnimation:CreateAnimation("Alpha")
			fadeIn:SetDuration(self.FadeDuration)
			fadeIn:SetFromAlpha(0)
			fadeIn:SetToAlpha(1)
			fadeIn:SetOrder(1)
			fadeIn:SetEndDelay(self.OnDuration)
			
			local fadeOut = self.FlashAnimation:CreateAnimation("Alpha")
			fadeOut:SetDuration(self.FadeDuration)
			fadeOut:SetFromAlpha(1)
			fadeOut:SetToAlpha(0)
			fadeOut:SetOrder(2)
			fadeOut:SetEndDelay(self.OffDuration)
			
			self.FlashAnimation:SetLooping("REPEAT")
		end

		self.HighlightTexture:SetAlpha(0)
		self.HighlightTexture:Show()
		self.HighlightTexture:SetVertexColor(1, 0.6, 0.2)
		
		self.FlashAnimation:Play()
		
		vShowNotifyIcon = true
	else
		self.HighlightTexture:Hide()
	end

	if vShowNotifyIcon then
		self:Show()
	else
		self:Hide()
	end
end

function GroupCalendar:StartFlashingReminder()
	if not self.MinimapReminder then
		self.MinimapReminder = GroupCalendar:New(GroupCalendar._MinimapReminder)
	end
	
	self.MinimapReminder:StartFlashing()
end
	
function GroupCalendar:StopFlashingReminder()
	if self.MinimapReminder then
		self.MinimapReminder:Stop()
	end
end

function GroupCalendar:ShowReminderIcon(pIcon, pTexCoords)
	if not self.MinimapReminder then
		self.MinimapReminder = GroupCalendar:New(GroupCalendar._MinimapReminder)
	end
	
	self.MinimapReminder:ShowIcon(pIcon, pTexCoords)
end

function GroupCalendar:HideReminderIcon()
	if self.MinimapReminder then
		self.MinimapReminder:HideIcon()
	end
end

function GroupCalendar:CheckForNewEvents()
	GroupCalendar.SchedulerLib:RescheduleTask(1, self.CheckForNewEventsNow, self)
end

function GroupCalendar:CheckForNewEventsNow()
	local vCalendar = GroupCalendar.Calendars.PLAYER
	
	for vDate, vSchedule in pairs(vCalendar.Schedules) do
		for _, vEvent in pairs(vSchedule.Events) do
			if vEvent.Unseen then
				GroupCalendar:StartFlashingReminder()
				return
			end
		end
	end
	
	GroupCalendar:StopFlashingReminder()
end

function GroupCalendar:MarkAllEventsAsSeen()
	local vCalendar = GroupCalendar.Calendars.PLAYER
	
	for vDate, vSchedule in pairs(vCalendar.Schedules) do
		for _, vEvent in pairs(vSchedule.Events) do
			vEvent.Unseen = nil
		end
	end
	
	GroupCalendar:StopFlashingReminder()
end

----------------------------------------
GroupCalendar._MessageFrame = {}
----------------------------------------

function GroupCalendar._MessageFrame:New()
	return CreateFrame("MessageFrame", nil, UIParent)
end

function GroupCalendar._MessageFrame:Construct()
	self:SetFading(true)
	self:SetFadeDuration(3)
	self:SetTimeVisible(10)
	
	self:SetInsertMode("BOTTOM")
	self:SetFrameStrata("HIGH")
	self:SetWidth(768)
	self:SetHeight(100)
	self:SetPoint("TOP", UIParent, "TOP", 0, -122)
	self:SetFontObject(PVPInfoTextFont)
	self:SetJustifyH("CENTER")
end

----------------------------------------
GroupCalendar._Version = {}
----------------------------------------

GroupCalendar._Version.cBuildLevelByCode =
{
	d = 4,
	a = 3,
	b = 2,
	f = 1,
}

GroupCalendar._Version.cBuildCodeByLevel = GroupCalendar:ReverseTable(GroupCalendar._Version.cBuildLevelByCode)

function GroupCalendar._Version:Construct(pString)
	if pString then
		self:FromString(pString)
	end
end

function GroupCalendar._Version:FromString(pString)
	local _, _, vMajor, vMinor, vBugFix, vBuildLevelCode, vBuildNumber = string.find(pString, "[vV]?(%d+)%.(%d+)%.?(%d*)(%w?)(%d*)")
	local vBuildLevel
	
	vMajor = tonumber(vMajor)
	
	if not vMajor then
		vMajor = 0
	end
	
	vMinor = tonumber(vMinor)
	
	if not vMinor then
		vMinor = 0
	end
	
	vBugFix = tonumber(vBugFix)
	
	if not vBugFix then
		vBugFix = 0
	end
	
	if vBuildLevelCode == "" then
		vBuildLevel = 0
	else
		vBuildLevel = self.cBuildLevelByCode[vBuildLevelCode]
		
		if not vBuildLevel then
			vBuildLevel = 5
		end
	end
	
	vBuildNumber = tonumber(vBuildNumber)
	
	if not vBuildNumber then
		vBuildNumber = 0
	end
	
	self.Major = vMajor
	self.Minor = vMinor
	self.BugFix = vBugFix
	self.BuildLevel = vBuildLevel
	self.BuildNumber = vBuildNumber
end

function GroupCalendar._Version:LessThan(pVersion)
	if self.Major ~= pVersion.Major then
		return self.Major < pVersion.Major
	end
	
	if self.Minor ~= pVersion.Minor then
		return self.Minor < pVersion.Minor
	end
	
	if self.BugFix ~= pVersion.BugFix then
		return self.BugFix < pVersion.BugFix
	end
	
	if self.BuildLevel ~= pVersion.BuildLevel then
		return self.BuildLevel > pVersion.BuildLevel
	end
	
	if self.BuildNumber ~= pVersion.BuildNumber then
		return self.BuildNumber < pVersion.BuildNumber
	end
	
	return false
end

function GroupCalendar._Version:ToString()
	local vString = string.format("%d.%d", self.Major, self.Minor)
	
	if self.BugFix > 0 then
		vString = vString.."."..self.BugFix
	end
	
	if self.BuildLevel > 0 then
		vString = string.format("%s%s%d", vString, GroupCalendar._Version.cBuildCodeByLevel[self.BuildLevel] or "?", self.BuildNumber)
	end
	
	return vString
end

----------------------------------------
-- Calendars
----------------------------------------

function GroupCalendar:InitializeCalendars()
	self.Calendars = {}
	
	self.Calendars.BLIZZARD = GroupCalendar:New(GroupCalendar._Calendar, GroupCalendar.cBlizzardOwner, "BLIZZARD", nil, false)
	
	for vRealmName, vRealmData in pairs(self.Data.Realms) do
		for vCharacterGUID, vCharacterData in pairs(vRealmData.Characters) do
			local vCalendarID, vReadOnly
			
			if vCharacterData == self.PlayerData then
				vCalendarID = "PLAYER"
				vReadOnly = false
			else
				vCalendarID = vCharacterData.GUID
				vReadOnly = true
			end
			
			self.Calendars[vCalendarID] = GroupCalendar:New(GroupCalendar._Calendar, vCharacterData.Name, vCalendarID, vCharacterData.Events, vReadOnly)
		end
	end
end

----------------------------------------
-- Roles
----------------------------------------

function GroupCalendar:GetPlayerDefaultRoleCode(pPlayerName, pClassID)
	if not self.RealmData.DefaultRoles
	or not self.RealmData.DefaultRoles[pPlayerName] then
		if not pClassID or pClassID == "" then
			return "?"
		end
		
		if not self.ClassInfoByClassID[pClassID] then
			error(string.format("Unknown class ID %s", tostring(pClassID)))
		end
		
		return self.ClassInfoByClassID[pClassID].DefaultRole
	end
	
	return self.RealmData.DefaultRoles[pPlayerName]
end

function GroupCalendar:SetPlayerDefaultRoleCode(pPlayerName, pRoleCode)
	if not self.RealmData.DefaultRoles then
		self.RealmData.DefaultRoles = {}
	end
	
	self.RealmData.DefaultRoles[pPlayerName] = pRoleCode
end

----------------------------------------
-- Event templates
----------------------------------------

function GroupCalendar:AutoCompleteEventTitle(pEditBox)
	local vEditBoxText = pEditBox:GetText()
	local vUpperEditBoxText = vEditBoxText:upper()
	local vUpperEditBoxTextLen = vUpperEditBoxText:len()
	
	local vTemplate = self:FindEventTemplateByPartialTitle(vEditBoxText)
	
	if vTemplate then
		GroupCalendar:SetEditBoxAutoCompleteText(pEditBox, vTemplate.Title)
		return nil, nil, vTemplate
	end
	
	for vEventType = CALENDAR_EVENTTYPE_RAID, CALENDAR_EVENTTYPE_OTHER do
		local vEventTypeTextures = GroupCalendar:GetEventTypeTextures(vEventType)
		
		for vTextureIndex, vTextureInfo in ipairs(vEventTypeTextures) do
			local vName
			
			if vTextureInfo.DifficultyName == "" then
				vName = vTextureInfo.Name
			else
				vName = DUNGEON_NAME_WITH_DIFFICULTY:format(vTextureInfo.Name, vTextureInfo.DifficultyName)
			end
			
			if vName:upper():sub(1, vUpperEditBoxTextLen) == vUpperEditBoxText then
				GroupCalendar:SetEditBoxAutoCompleteText(pEditBox, vName)
				return vEventType, vTextureIndex
			end
		end
	end
end

function GroupCalendar:FindEventTemplateByTitle(pTitle)
	local vUpperTitle = pTitle:upper()
	
	for vIndex, vTemplate in ipairs(self.PlayerData.EventTemplates) do
		local vTemplateTitle = self.WoWCalendar:GetDisplayTitle(vTemplate.CalendarType, vTemplate.SequenceType, vTemplate.Title or "")
		local vTemplateUpperTitle = vTemplateTitle:upper()
		
		if vTemplateUpperTitle == vUpperTitle then
			return vTemplate, vIndex
		end
	end
end

function GroupCalendar:FindEventTemplateByPartialTitle(pTitle)
	if not self.PlayerData.EventTemplates then
		return
	end
	
	local vUpperTitle = pTitle:upper()
	local vUpperTitleLen = vUpperTitle:len()
	
	for vIndex, vTemplate in ipairs(self.PlayerData.EventTemplates) do
		local vTemplateTitle = self.WoWCalendar:GetDisplayTitle(vTemplate.CalendarType, vTemplate.SequenceType, vTemplate.Title or "")
		local vTemplateUpperTitle = vTemplateTitle:upper()
		
		if vTemplateUpperTitle:sub(1, vUpperTitleLen) == vUpperTitle then
			return vTemplate, vIndex
		end
	end
end

function GroupCalendar:FindEventTemplateByEvent(pEvent)
	if not self.PlayerData.EventTemplates then
		return
	end
	
	for vIndex, vTemplate in ipairs(self.PlayerData.EventTemplates) do
		if pEvent.CalendarType == vTemplate.CalendarType
		and pEvent.EventType == vTemplate.EventType
		and pEvent.TitleTag == vTemplate.TitleTag
		and pEvent.TextureIndex == vTemplate.TextureIndex then
			if not vTemplate.Title then
				vTemplate.Title = "" -- Fix missing Title field
			end
			
			return vTemplate, vIndex
		end
	end
end

GroupCalendar.EventTemplateFields =
{
	Hour = true,
	Minute = true,
	Second = true,
	
	Limits = true,
	CalendarType = true,
	Description = true,
	DescriptionTag = true,
	Title = true,
	TitleTag = true,
	TextureIndex = true,
	TextureID = true,
	EventType = true,
	MinLevel = true,
	MaxLevel = true,
	
	Attendance = true,
}

function GroupCalendar:SaveEventTemplate(pEvent)
	-- Remove any existing template
	
	if self.PlayerData.EventTemplates then
		local _, vIndex = self:FindEventTemplateByEvent(pEvent)
		
		if vIndex then
			table.remove(self.PlayerData.EventTemplates, vIndex)
		end
	else
		self.PlayerData.EventTemplates = {}
	end
	
	-- Make a deep duplicate of the event
	
	local vTemplate = {}
	
	for vField, _ in pairs(GroupCalendar.EventTemplateFields) do
		if type(pEvent[vField]) == "table" then
			vTemplate[vField] = GroupCalendar:DuplicateTable(pEvent[vField], true)
		else
			vTemplate[vField] = pEvent[vField]
		end
	end
	
	-- Change all attendance to "invited" in the template
	
	if vTemplate.Attendance then
		for _, vInfo in pairs(vTemplate.Attendance) do
			vInfo.InviteStatus = self.CALENDAR_INVITESTATUS_INVITED
		end
	end
	
	-- Eliminate fields we want ignored
	
	vTemplate.Year = nil
	vTemplate.Month = nil
	vTemplate.Day = nil
	
	vTemplate.CacheUpdateDate = nil
	vTemplate.CacheUpdateTime = nil
	
	vTemplate.Group = nil
	
	-- Ensure required fields are present
	
	if not vTemplate.Title then
		vTemplate.Title = ""
	end
	
	-- Save the template at the front of the list to give it
	-- higher priority next time around
	
	table.insert(self.PlayerData.EventTemplates, 1, vTemplate)
end

----------------------------------------
-- Database repairs/upgrades
----------------------------------------

function GroupCalendar:InitializeData()
	-- Purge the data if the user is downgrading from a newer build
	
	if GroupCalendar_Data then
		local vThisVersion = GroupCalendar:New(GroupCalendar._Version, GroupCalendar.cVersionString)
		local vLastVersion = GroupCalendar:New(GroupCalendar._Version, GroupCalendar_Data.LastVersion)
		
		if not GroupCalendar_Data.LastVersion
		or vThisVersion:LessThan(vLastVersion) then -- Downgrading, purge the old data
			GroupCalendar_Data = nil
		end
	end
	
	-- Initialize the data
	
	if not GroupCalendar_Data
	or not GroupCalendar_Data.LastVersion then
		GroupCalendar_Data =
		{
			Realms = {},
			Prefs = {},
			Debug = {},
			LastVersion = GroupCalendar.cVersionString,
		}
	end
	
	-- Perform repairs and upgrades
	
	-- Done
	
	self.Debug = GroupCalendar_Data.Debug
	self.Data = GroupCalendar_Data
	
	GroupCalendar_Data.LastVersion = GroupCalendar.cVersionString
end

----------------------------------------
-- Running event
----------------------------------------

function GroupCalendar:GetEventElapsedSeconds(pEvent)
	local vEvent = pEvent.OriginalEvent or pEvent
	local vElapsed = vEvent.ElapsedSeconds or 0
	
	if self.RunningEvent == pEvent then
		local vDate, vTime60 = GroupCalendar.DateLib:GetServerDateTime60()
		
		vElapsed = vElapsed + (vDate * GroupCalendar.DateLib.cSecondsPerDay + vTime60)
					        - (vEvent.StartDate * GroupCalendar.DateLib.cSecondsPerDay + vEvent.StartTime60)
	end
	
	return vElapsed
end

function GroupCalendar:StartEvent(pEvent, pNotificationFunc)
	if self.RunningEvent then
		self:StopEvent(self.RunningEvent)
	end
	
	self.RunningEvent = pEvent
	
	local vEvent = self.RunningEvent.OriginalEvent or self.RunningEvent
	
	if not vEvent.StartDate then
		vEvent.StartDate, vEvent.StartTime60 = GroupCalendar.DateLib:GetServerDateTime60()
	end
	
	GroupCalendar.EventLib:RegisterCustomEvent("MC2RAIDLIB_RAID_CHANGED", self.EventRaidChanged, self)
	
	GroupCalendar.EventLib:DispatchEvent("GC5_EVENT_START", self.RunningEvent)
	
	self:EventRaidChanged()
	
	self.RaidInvites = GroupCalendar:New(GroupCalendar._RaidInvites)
	self.RaidInvites:BeginInvites(pEvent.Title, true, pNotificationFunc)
end

function GroupCalendar:StopEvent()
	if not self.RunningEvent then
		return
	end
	
	self.RaidInvites:EndInvites()
	self.RaidInvites = nil
	
	local vSavedRunningEvent = self.RunningEvent
	local vEvent = self.RunningEvent.OriginalEvent or self.RunningEvent
	
	vEvent.ElapsedSeconds = self:GetEventElapsedSeconds(self.RunningEvent)
	vEvent.StartDate, vEvent.StartTime60 = nil, nil
	
	self.RunningEvent = nil
	
	GroupCalendar.EventLib:UnregisterCustomEvent("MC2RAIDLIB_RAID_CHANGED", self.EventRaidChanged, self)
	
	GroupCalendar.EventLib:DispatchEvent("GC5_EVENT_STOP")
	
	GroupCalendar.BroadcastLib:Broadcast(vSavedRunningEvent, "INVITES_CHANGED")
end

function GroupCalendar:RestartEvent(pEvent)
	if pEvent == self.RunningEvent then
		self:StopEvent()
	end
	
	local vEvent = pEvent.OriginalEvent or pEvent
	
	pEvent.Group = nil
	vEvent.Group = nil
	vEvent.StartDate = nil
	vEvent.StartTime60 = nil
	vEvent.ElapsedSeconds = nil
	
	for vName, vPlayerInfo in pairs(vEvent:GetAttendance()) do
		vPlayerInfo.RaidInviteStatus = nil
	end
	
	GroupCalendar.BroadcastLib:Broadcast(pEvent, "INVITES_CHANGED")
end

function GroupCalendar:EventRaidChanged()
	if not self.RunningEvent.Group then
		self.RunningEvent.Group = {}
		
		if self.RunningEvent.OriginalEvent then
			self.RunningEvent.OriginalEvent.Group = self.RunningEvent.Group
		end
	else
		for _, vMemberInfo in pairs(self.RunningEvent.Group) do
			vMemberInfo.LeftGroup = true
		end
	end
	
	for vMemberName, vPlayerInfo in pairs(GroupCalendar.RaidLib.PlayersByName) do
		local vMemberInfo = self.RunningEvent.Group[vMemberName]
		
		if not vMemberInfo then
			self.RunningEvent.Group[vMemberName] = GroupCalendar:DuplicateTable(vPlayerInfo, true)
		else
			vMemberInfo.LeftGroup = nil
			
			for vKey, vValue in pairs(vPlayerInfo) do
				vMemberInfo[vKey] = vValue
			end
		end
	end
	
	GroupCalendar.BroadcastLib:Broadcast(self.RunningEvent, "INVITES_CHANGED")
end

----------------------------------------
-- Initialize after saved variables are loaded
----------------------------------------

GroupCalendar.EventLib:RegisterEvent("PLAYER_ENTERING_WORLD", GroupCalendar.Initialize, GroupCalendar)
