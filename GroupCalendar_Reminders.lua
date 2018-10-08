----------------------------------------
-- Group Calendar 5 Copyright 2005 - 2016 John Stephen, wobbleworks.com
-- All rights reserved, unauthorized redistribution is prohibited
----------------------------------------

----------------------------------------
GroupCalendar.Reminders = {}
----------------------------------------

GroupCalendar.Reminders.cReminderIntervals = {0, 60, 300, 900, 1800, 3600}
GroupCalendar.Reminders.cNumReminderIntervals = #GroupCalendar.Reminders.cReminderIntervals

function GroupCalendar.Commands:reminder(pOption)
	if pOption:lower() == "off" then
		GroupCalendar.Data.Prefs.DisableReminders = true
		GroupCalendar:NoteMessage("Reminders disabled")
	elseif pOption:lower() == "on" then
		GroupCalendar.Data.Prefs.DisableReminders = nil
		GroupCalendar:NoteMessage("Reminders enabled")
		GroupCalendar.Reminders:CalculateReminders()
	else
		GroupCalendar:ErrorMessage("Unknown reminder option, use 'on' or 'off'")
	end
end

function GroupCalendar.Commands:birth(pOption)
	if pOption:lower() == "off" then
		GroupCalendar.Data.Prefs.DisableBirthdayReminders = true
		GroupCalendar:NoteMessage("Birthday reminders disabled")
	elseif pOption:lower() == "on" then
		GroupCalendar.Data.Prefs.DisableBirthdayReminders = nil
		GroupCalendar:NoteMessage("Birthday reminders enabled")
		GroupCalendar.Reminders:CalculateReminders()
	else
		GroupCalendar:ErrorMessage("Unknown birthday option, use 'on' or 'off'")
	end
end

function GroupCalendar.Commands:attend(pOption)
	if pOption:lower() == "off" then
		GroupCalendar.Data.Prefs.DisableAttendNotices = true
		GroupCalendar:NoteMessage("Attendance notices disabled")
	elseif pOption:lower() == "on" then
		GroupCalendar.Data.Prefs.DisableAttendNotices = nil
		GroupCalendar:NoteMessage("Attendance notices enabled")
	else
		GroupCalendar:ErrorMessage("Unknown attendance notices option, use 'on' or 'off'")
	end
end

function GroupCalendar.Reminders:EventConfirmMessage(pMessage, pName, pEvent)
	if GroupCalendar.Data.Prefs.DisableAttendNotices then
		return
	end
	
	GroupCalendar:NoteMessage(
			pMessage:gsub("%$(%w+)",
			{
				name = pName,
				event = pEvent.Title,
				date = GroupCalendar.DateLib:GetShortDateString(GroupCalendar.DateLib:ConvertMDYToDate(pEvent.Month, pEvent.Day, pEvent.Year), true)
			}))
end

function GroupCalendar.Reminders:EventNeedsReminder(pEvent, pCurrentDateTimeStamp)
	-- Don't remind for events they're not attending
	
	if not pEvent:IsCooldownEvent()
	and not pEvent:IsAttending()
	and pEvent.TitleTag ~= "BRTH" then
		return false
	end
	
	-- Don't remind for events which don't have a start time (birthdays and vacations)
	
	if not pEvent.Hour then
		return false
	end
	
	-- Don't remind if all reminders have been issued
	
	if pEvent.ReminderIndex == 0 then
		return false
	end
	
	-- Don't remind if the event has passed
	
	if pEvent:HasPassed(pCurrentDateTimeStamp) then
		return false
	end
	
	-- Don't remind for dungeon resets
	
	if pEvent.CalendarType == "RAID_LOCKOUT" then
		return false
	end
	
	return true
end

function GroupCalendar.Reminders:CalculateReminders()
	-- Gather up events
	
	local vCurrentDate, vCurrentTime = GroupCalendar.DateLib:GetServerDateTime()
	local vCurrentDateTimeStamp = vCurrentDate * 86400 + vCurrentTime * 60
	
	-- Recycle the previous event table
	
	if self.Events then
		for vKey, _ in pairs(self.Events) do
			self.Events[vKey] = nil
		end
	else
		self.Events = {}
	end
	
	-- Collect the events
	
	for vDate = vCurrentDate - 1, vCurrentDate + 1 do
		for vCalendarID, vCalendar in pairs(GroupCalendar.Calendars) do
			local vMonth, vDay, vYear = GroupCalendar.DateLib:ConvertDateToMDY(vDate)
			local vSchedule = vCalendar:GetSchedule(vMonth, vDay, vYear)
			
			for _, vEvent in ipairs(vSchedule.Events) do
				if vEvent:EventIsVisible(vCalendar.CalendarID == "PLAYER") then
					if self:EventNeedsReminder(vEvent, vCurrentDateTimeStamp) then
						if not vEvent.ReminderIndex then
							vEvent.ReminderIndex = self.cNumReminderIntervals
						end
						
						table.insert(self.Events, vEvent)
					end
				end
			end
		end -- for vCalendar
	end -- for vDate
	
	-- Sort the events
	
	table.sort(self.Events, GroupCalendar.CompareEventTimes)
	
	--GroupCalendar:DebugTable(self.Events, "Reminder events")
	
	-- Calculate the time to the first event
	
	self:DoReminders()
end

function GroupCalendar.Reminders:GetEventReminderInterval(pEvent, pCurrentDateTimeStamp)
	-- Ignore the event if the final reminder has already
	-- been issued
	
	if pEvent.ReminderIndex == 0 then
		return
	end
	
	-- Calculate the seconds remaining until the event starts
	
	local vTimeRemaining = pEvent:GetSecondsToStart(pCurrentDateTimeStamp)
	
	-- If the event is starting or started then skip
	-- right to the final reminder
	
	if vTimeRemaining <= 0 then
		pEvent.ReminderIndex = 0
		return nil, vTimeRemaining, true
	end
	
	-- Track intervals so the caller can be notified when it changes
	
	local vReminderIntervalPassed = false
	
	-- If the event hasn't gotten any reminders yet, see if it's time for the first one
	
	if not pEvent.ReminderIndex then
		local vReminderRemaining = vTimeRemaining - self.cReminderIntervals[self.cNumReminderIntervals]
		
		if vReminderRemaining > 0 then
			return vReminderRemaining, vTimeRemaining, false
		end
		
		pEvent.ReminderIndex = self.cNumReminderIntervals
		vReminderIntervalPassed = true
	end
	
	while vTimeRemaining <= self.cReminderIntervals[pEvent.ReminderIndex - 1] do
		pEvent.ReminderIndex = pEvent.ReminderIndex - 1
		
		vReminderIntervalPassed = true
		
		if pEvent.ReminderIndex == 0 then
			return nil, vTimeRemaining, vReminderIntervalPassed
		end
	end
	
	return vTimeRemaining - self.cReminderIntervals[pEvent.ReminderIndex - 1], vTimeRemaining, vReminderIntervalPassed
end

function GroupCalendar.Reminders:DoReminders()
	local vCurrentDate, vCurrentTime = GroupCalendar.DateLib:GetServerDateTime()
	local vCurrentDateTimeStamp = vCurrentDate * 86400 + vCurrentTime * 60
	
	local vMinTimeRemaining = nil
	local vIndex = 1
	
	if not GroupCalendar.Data.Prefs.DisableReminders then
		while vIndex <= #self.Events do
			local vEvent = self.Events[vIndex]

			if (vEvent:IsBirthdayEvent() and not GroupCalendar.Data.Prefs.DisableBirthdayReminders)
			or (vEvent:IsCooldownEvent() and not GroupCalendar.Data.Prefs.DisableTradeskillReminders)
			or (not vEvent:IsBirthdayEvent() and not vEvent:IsCooldownEvent() and not GroupCalendar.Data.Prefs.DisableEventReminders) then
				local vReminderTimeRemaining, vTimeRemaining, vReminderIntervalPassed = self:GetEventReminderInterval(vEvent, vCurrentDateTimeStamp)
				
				if vIndex == 1 then
					if vTimeRemaining <= 3600 then -- Show the icon for one hour before the event
						GroupCalendar:ShowReminderIcon(vEvent:GetTexture())
					else
						GroupCalendar:HideReminderIcon()
					end
				end
				
				if vReminderIntervalPassed then
					if vTimeRemaining <= 0 then
						if vEvent:IsBirthdayEvent() then
							if not not GroupCalendar.Data.Prefs.DisableBirthdayReminders then
								local vMessage = vEvent.Title
								
								if not vMessage or vMessage == "" then
									vMessage = string.format(GroupCalendar.cHappyBirthdayFormat, vEvent.InvitedBy)
								end
								
								GroupCalendar.MessageFrame:AddMessage(vMessage)
								GroupCalendar:NoteMessage(vMessage)
							end
						elseif vEvent:IsCooldownEvent() then
							if not not GroupCalendar.Data.Prefs.DisableTradeskillReminders then
								local vMessage = vEvent.Title
								
								if vEvent.OwnersName ~= GroupCalendar.PlayerName then
									vMessage = vMessage..string.format(" (%s)", vEvent.OwnersName)
								end
								
								GroupCalendar.MessageFrame:AddMessage(vMessage)
								GroupCalendar:NoteMessage(vMessage)
							end
						elseif vTimeRemaining < -120 then
							local vMessage = string.format(GroupCalendar.cAlreadyStartedFormat, vEvent.Title)
							
							if vEvent.OwnersName ~= GroupCalendar.PlayerName then
								vMessage = vMessage..string.format(" (%s)", vEvent.OwnersName)
							end
							
							GroupCalendar.MessageFrame:AddMessage(vMessage)
							GroupCalendar:NoteMessage(vMessage)
						else
							local vMessage = string.format(GroupCalendar.cStartingNowFormat, vEvent.Title)
							
							if vEvent.OwnersName ~= GroupCalendar.PlayerName then
								vMessage = vMessage..string.format(" (%s)", vEvent.OwnersName)
							end
							
							GroupCalendar.MessageFrame:AddMessage(vMessage)
							GroupCalendar:NoteMessage(vMessage)
						end
					else
						local vMinutesRemaining = math.floor(vTimeRemaining / 60 + 0.5)
						local vFormat
						
						if vEvent:IsCooldownEvent() then
							if vMinutesRemaining == 1 then
								vFormat = GroupCalendar.cAvailableMinuteFormat
							else
								vFormat = GroupCalendar.cAvailableMinutesFormat
							end
						else
							if vMinutesRemaining == 1 then
								vFormat = GroupCalendar.cStartsMinuteFormat
							else
								vFormat = GroupCalendar.cStartsMinutesFormat
							end
						end
						
						local vMessage = string.format(vFormat, vEvent.Title, vMinutesRemaining)
						
						if vEvent.OwnersName ~= GroupCalendar.PlayerName then
							vMessage = vMessage..string.format(" (%s)", vEvent.OwnersName)
						end
						
						GroupCalendar.MessageFrame:AddMessage(vMessage)
						GroupCalendar:NoteMessage(vMessage)
					end
				end -- if vReminderIntervalPassed
				
				if vReminderTimeRemaining
				and vReminderTimeRemaining > 0 then
					if not vMinTimeRemaining or vReminderTimeRemaining < vMinTimeRemaining then
						vMinTimeRemaining = vReminderTimeRemaining
					end
					
					if vEvent.ReminderIndex == self.cNumReminderIntervals then
						break
					end
					
					vIndex = vIndex + 1
				else
					table.remove(self.Events, vIndex)
				end
			else
				vIndex = vIndex + 1
			end -- if disabled
		end -- while
	end -- if
	
	--
	
	if vMinTimeRemaining then
		GroupCalendar.SchedulerLib:ScheduleUniqueTask(vMinTimeRemaining, self.DoReminders, self)
	else
		GroupCalendar.SchedulerLib:UnscheduleTask(self.DoReminders, self)
		GroupCalendar:HideReminderIcon()
	end
end

function GroupCalendar.Reminders:DumpReminders()
	GroupCalendar:DebugTable(GroupCalendar.Reminders, "Reminders")
end

function GroupCalendar.Reminders:PlayerEnteringWorld()
	GroupCalendar.SchedulerLib:ScheduleUniqueTask(30, self.CalculateReminders, self)
end

function GroupCalendar.Reminders:EventChanged()
	GroupCalendar.SchedulerLib:ScheduleUniqueTask(5, self.CalculateReminders, self)
end

GroupCalendar.EventLib:RegisterEvent("PLAYER_ENTERING_WORLD", GroupCalendar.Reminders.PlayerEnteringWorld, GroupCalendar.Reminders)
GroupCalendar.EventLib:RegisterCustomEvent("GC5_EVENT_CHANGED", GroupCalendar.Reminders.EventChanged, GroupCalendar.Reminders)
GroupCalendar.EventLib:RegisterCustomEvent("GC5_EVENT_ADDED", GroupCalendar.Reminders.EventChanged, GroupCalendar.Reminders)
GroupCalendar.EventLib:RegisterCustomEvent("GC5_EVENT_DELETED", GroupCalendar.Reminders.EventChanged, GroupCalendar.Reminders)
