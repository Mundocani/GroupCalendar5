----------------------------------------
-- Group Calendar 5 Copyright 2005 - 2016 John Stephen, wobbleworks.com
-- All rights reserved, unauthorized redistribution is prohibited
----------------------------------------

----------------------------------------
GroupCalendar.UI._SettingsView = {}
----------------------------------------

function GroupCalendar.UI._SettingsView:New(pParent)
	return CreateFrame("Frame", nil, pParent)
end

function GroupCalendar.UI._SettingsView:Construct(pParent)
	self:SetScript("OnShow", self.OnShow)
end

function GroupCalendar.UI._SettingsView:OnShow()
	if not self.Initialized then
		self.Initialized = true
		self.Title = self:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
		self.Title:SetPoint("TOP", self, "TOP", 17, -7)
		self.Title:SetText(GroupCalendar.cSettingsTitle)
		
		self.ThemeMenu = GroupCalendar:New(GroupCalendar.UIElementsLib._TitledDropDownMenuButton, self, function (...) self:ThemeMenuFunc(...) end, 130)
		self.ThemeMenu:SetPoint("TOPLEFT", self, "TOPLEFT", 200, -90)
		self.ThemeMenu:SetTitle(GroupCalendar.cThemeLabel)
		
		self.StartDayMenu = GroupCalendar:New(GroupCalendar.UIElementsLib._TitledDropDownMenuButton, self, function (...) self:StartDayMenuFunc(...) end, 130)
		self.StartDayMenu:SetPoint("TOPLEFT", self.ThemeMenu, "BOTTOMLEFT", 0, -15)
		self.StartDayMenu:SetTitle(GroupCalendar.cStartDayLabel)
		
		self.TwentyFourHourTime = GroupCalendar:New(GroupCalendar.UIElementsLib._CheckButton, self, GroupCalendar.cTwentyFourHourTime)
		self.TwentyFourHourTime:SetPoint("TOPLEFT", self.StartDayMenu, "BOTTOMLEFT", 0, -15)
		self.TwentyFourHourTime:SetScript("OnClick", function (pCheckButton)
			GroupCalendar.Data.TwentyFourHourTime = pCheckButton:GetChecked() ~= nil
			SetCVar("timeMgrUseMilitaryTime", GroupCalendar.Data.TwentyFourHourTime and 1 or 0)
			self.TwentyFourHourTime:SetChecked(GetCVarBool("timeMgrUseMilitaryTime"))
		end)
		
		self.RecordTradeskills = GroupCalendar:New(GroupCalendar.UIElementsLib._CheckButton, self, GroupCalendar.cRecordTradeskills)
		self.RecordTradeskills:SetPoint("TOPLEFT", self.TwentyFourHourTime, "BOTTOMLEFT", 0, -30)
		self.RecordTradeskills:SetScript("OnClick", function (pCheckButton)
			GroupCalendar.Data.Prefs.DisableTradeskills = not pCheckButton:GetChecked()
			self.RecordTradeskills:SetChecked(not GroupCalendar.Data.Prefs.DisableTradeskills)
		end)
		
		self.RememberInvites = GroupCalendar:New(GroupCalendar.UIElementsLib._CheckButton, self, GroupCalendar.cRememberInvites)
		self.RememberInvites:SetPoint("TOPLEFT", self.RecordTradeskills, "BOTTOMLEFT", 0, -15)
		self.RememberInvites:SetScript("OnClick", function (pCheckButton)
			GroupCalendar.Data.Prefs.DisableInviteMemory = not pCheckButton:GetChecked()
			self.RememberInvites:SetChecked(not GroupCalendar.Data.Prefs.DisableInviteMemory)
		end)
		
		self.AnnounceEvents = GroupCalendar:New(GroupCalendar.UIElementsLib._CheckButton, self, GroupCalendar.cAnnounceEvents)
		self.AnnounceEvents:SetPoint("TOPLEFT", self.RememberInvites, "BOTTOMLEFT", 0, -30)
		self.AnnounceEvents:SetScript("OnClick", function (pCheckButton)
			GroupCalendar.Data.Prefs.DisableEventReminders = not pCheckButton:GetChecked()
			GroupCalendar.Reminders:CalculateReminders()
			self.AnnounceEvents:SetChecked(not GroupCalendar.Data.Prefs.DisableEventReminders)
		end)
		
		self.AnnounceTradeskills = GroupCalendar:New(GroupCalendar.UIElementsLib._CheckButton, self, GroupCalendar.cAnnounceTradeskills)
		self.AnnounceTradeskills:SetPoint("TOPLEFT", self.AnnounceEvents, "BOTTOMLEFT", 0, -15)
		self.AnnounceTradeskills:SetScript("OnClick", function (pCheckButton)
			GroupCalendar.Data.Prefs.DisableTradeskillReminders = not pCheckButton:GetChecked()
			GroupCalendar.Reminders:CalculateReminders()
			self.AnnounceTradeskills:SetChecked(not GroupCalendar.Data.Prefs.DisableTradeskillReminders)
		end)
		
		self.AnnounceBirthdays = GroupCalendar:New(GroupCalendar.UIElementsLib._CheckButton, self, GroupCalendar.cAnnounceBirthdays)
		self.AnnounceBirthdays:SetPoint("TOPLEFT", self.AnnounceTradeskills, "BOTTOMLEFT", 0, -15)
		self.AnnounceBirthdays:SetScript("OnClick", function (pCheckButton)
			GroupCalendar.Data.Prefs.DisableBirthdayReminders = not pCheckButton:GetChecked()
			GroupCalendar.Reminders:CalculateReminders()
			self.AnnounceBirthdays:SetChecked(not GroupCalendar.Data.Prefs.DisableBirthdayReminders)
		end)
		
		self.ShowMinimapClock = GroupCalendar:New(GroupCalendar.UIElementsLib._CheckButton, self, GroupCalendar.cShowMinimapClock)
		self.ShowMinimapClock:SetPoint("TOPLEFT", self.AnnounceBirthdays, "BOTTOMLEFT", 0, -15)
		self.ShowMinimapClock:SetScript("OnClick", function (pCheckButton)
			GroupCalendar.Clock.Data.HideMinimapClock = not pCheckButton:GetChecked()
			self.ShowMinimapClock:SetChecked(not GroupCalendar.Clock.Data.HideMinimapClock)
			GroupCalendar.EventLib:DispatchEvent("GC5_PREFS_CHANGED")
		end)
	end
	self:UpdateThemeMenuValue()
	self:UpdateStartDayMenuValue()
	self.TwentyFourHourTime:SetChecked(GetCVarBool("timeMgrUseMilitaryTime"))
	self.AnnounceBirthdays:SetChecked(not GroupCalendar.Data.Prefs.DisableBirthdayReminders)
	self.AnnounceEvents:SetChecked(not GroupCalendar.Data.Prefs.DisableEventReminders)
	self.AnnounceTradeskills:SetChecked(not GroupCalendar.Data.Prefs.DisableTradeskillReminders)
	self.RecordTradeskills:SetChecked(not GroupCalendar.Data.Prefs.DisableTradeskills)
	self.RememberInvites:SetChecked(not GroupCalendar.Data.Prefs.DisableInviteMemory)
	self.ShowMinimapClock:SetChecked(not GroupCalendar.Clock.Data.HideMinimapClock)
end

function GroupCalendar.UI._SettingsView:UpdateThemeMenuValue()
	local currentThemeID = GroupCalendar.Data.ThemeID or GroupCalendar.DefaultThemeID
	for themeID, themeData in pairs(GroupCalendar.Themes) do
		if themeID == currentThemeID then
			self.ThemeMenu:SetCurrentValueText(themeData.Name)
		end
	end
end

GroupCalendar.UI._SettingsView.weekdays = {WEEKDAY_SUNDAY, WEEKDAY_MONDAY, WEEKDAY_TUESDAY, WEEKDAY_WEDNESDAY, WEEKDAY_THURSDAY, WEEKDAY_FRIDAY, WEEKDAY_SATURDAY}

function GroupCalendar.UI._SettingsView:UpdateStartDayMenuValue()
	local startDay = GroupCalendar.Data.StartDay or 1
	for index, name in ipairs(self.weekdays) do
		if index == startDay then
			self.StartDayMenu:SetCurrentValueText(name)
		end
	end
end

function GroupCalendar.UI._SettingsView:ThemeMenuFunc(menu, menuID)
	local currentThemeID = GroupCalendar.Data.ThemeID or GroupCalendar.DefaultThemeID
	for themeID, themeData in pairs(GroupCalendar.Themes) do
		menu:AddToggle(themeData.Name,
			function ()
				return GroupCalendar.Data.THemeID == themeID
			end,
			function (menu, value) -- set
				GroupCalendar.Data.ThemeID = themeID
				GroupCalendar.UI.Window.MonthView:SetThemeID(themeID)
				self:UpdateThemeMenuValue()
			end, nil, {
			})
	end
end

function GroupCalendar.UI._SettingsView:StartDayMenuFunc(menu, menuID)
	for index, name in ipairs(self.weekdays) do
		menu:AddToggle(
			name,
			function ()
				return (GroupCalendar.Data.StartDay or 1) == index
			end,
			function (menu, value)
				GroupCalendar.Data.StartDay = pItemID
				GroupCalendar.UI.Window.MonthView:SetStartDay(GroupCalendar.Data.StartDay)
				self:UpdateStartDayMenuValue()
			end
		)
	end
end
