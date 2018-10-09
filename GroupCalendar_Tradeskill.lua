----------------------------------------
-- Group Calendar 5 Copyright 2005 - 2016 John Stephen, wobbleworks.com
-- All rights reserved, unauthorized redistribution is prohibited
----------------------------------------

local _

function GroupCalendar:InitializeTradeskill()
	self.Tradeskill = GroupCalendar:New(GroupCalendar._Tradeskill)
end

----------------------------------------
GroupCalendar._Tradeskill = {}
----------------------------------------

function GroupCalendar._Tradeskill:Construct()
	GroupCalendar.EventLib:RegisterEvent("TRADE_SKILL_SHOW", self.TradeSkillShow, self)
	GroupCalendar.EventLib:RegisterEvent("TRADE_SKILL_CLOSE", self.TradeSkillClose, self)
end

function GroupCalendar._Tradeskill:TradeSkillShow()
	self.TradeSkillOpen = true
	self:UpdateCurrentTradeskillCooldown()
end

function GroupCalendar._Tradeskill:TradeSkillClose()
	self:UpdateCurrentTradeskillCooldown()

	self.TradeSkillOpen = false
	
	if self.NewEvent then
		if self.NewEvent:IsOpened() then
			self.NewEvent:Save()
		end
		
		self.NewEvent = nil
	end
end

function GroupCalendar._Tradeskill:UpdateCurrentTradeskillCooldown()
	if GroupCalendar.Data.Prefs.DisableTradeskills then
		return
	end
	
	local vServerDate, vServerTime = GroupCalendar.DateLib:GetServerDateTime()
	local vRecipeIDs = C_TradeSkillUI.GetAllRecipeIDs()

	for _, vRecipeID in ipairs(vRecipeIDs) do
		local vRecipeInfo = C_TradeSkillUI.GetRecipeInfo(vRecipeID)
		local vCooldown = C_TradeSkillUI.GetRecipeCooldown(vRecipeID)

		if vCooldown and vCooldown > 0 then
			local vCooldownID = "RECIPE_"..vRecipeID

			local vCooldownDate, vCooldownTime = GroupCalendar.DateLib:AddOffsetToDateTime(vServerDate, vServerTime, vCooldown / 60)
			local vMonth, vDay, vYear = GroupCalendar.DateLib:ConvertDateToMDY(vCooldownDate)
			local vHour, vMinute = GroupCalendar.DateLib:ConvertTimeToHM(vCooldownTime)
			
			-- Add an event for the new cooldown if there isn't already one
				
			if not self:HasCooldownIDEvent(vCooldownID, vMonth, vDay, vYear) then
				self.NewEvent = GroupCalendar.Calendars.PLAYER:NewEvent(vMonth, vDay, vYear, "PLAYER")
					
				self.NewEvent:Open()
				self.NewEvent:SetTitle(vRecipeInfo.name)
				self.NewEvent:SetTitleTag(vCooldownID)
				self.NewEvent:SetType(CALENDAR_EVENTTYPE_OTHER, 1)
				self.NewEvent:SetTime(vHour, vMinute)
				self.NewEvent:SetDuration(nil)
				self.NewEvent:Save()
			end -- if not HasCooldownIDEvent
				
			-- Delete any older occurances of this cooldown
				
			for vDate = vCooldownDate - 30, vCooldownDate - 1 do
				local vMonth, vDay, vYear = GroupCalendar.DateLib:ConvertDateToMDY(vDate)
				local vMonthOffset = GroupCalendar.WoWCalendar:GetMonthOffset(vMonth, vYear)
				local vNumEvents = GroupCalendar.WoWCalendar:GetNumDayEvents(vMonthOffset, vDay) 
					
				for vEventIndex = 1, vNumEvents do
					local vTitle, vHour, vMinute,
							vCalendarType, vSequenceType, vEventType,
							vTextureID,
							vModStatus, vInviteStatus, vInvitedBy = GroupCalendar.WoWCalendar:GetDayEvent(vMonthOffset, vDay, vEventIndex)
					local vTitleTag = GroupCalendar.WoWCalendar:EventGetTitleTag()
						
					if vTitleTag == vCooldownID then
						GroupCalendar.WoWCalendar:ContextMenuEventRemove(vMonthOffset, vDay, vEventIndex)
						break
					end
				end -- for vEventIndex
			end -- for vDate
		end -- if vCooldown
	end -- for vSkillIndex
end

function GroupCalendar._Tradeskill:HasCooldownIDEvent(pCooldownID, pMonth, pDay, pYear)
	local vNumEvents = GroupCalendar.WoWCalendar:GetNumAbsDayEvents(pMonth, pDay, pYear)
	
	for vEventIndex = 1, vNumEvents do
		local vTitle, vHour, vMinute = GroupCalendar.WoWCalendar:GetAbsDayEvent(pMonth, pDay, pYear, vEventIndex)
		local vTitleTag = GroupCalendar.WoWCalendar:EventGetTitleTag()

		if vTitleTag == pCooldownID then
			return true, vEventIndex
		end
	end
end
