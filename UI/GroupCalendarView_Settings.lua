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
		function self.ThemeMenu.ItemClicked(pMenu, pItemID)
			GroupCalendar.Data.ThemeID = pItemID
			pMenu:SetSelectedValue(GroupCalendar.Data.ThemeID)
			GroupCalendar.UI.Window.MonthView:SetThemeID(GroupCalendar.Data.ThemeID)
		end
		
		self.StartDayMenu = GroupCalendar:New(GroupCalendar.UIElementsLib._TitledDropDownMenuButton, self, function (...) self:StartDayMenuFunc(...) end, 130)
		self.StartDayMenu:SetPoint("TOPLEFT", self.ThemeMenu, "BOTTOMLEFT", 0, -15)
		self.StartDayMenu:SetTitle(GroupCalendar.cStartDayLabel)
		function self.StartDayMenu.ItemClicked(pMenu, pItemID)
			GroupCalendar.Data.StartDay = pItemID
			pMenu:SetSelectedValue(GroupCalendar.Data.StartDay)
			GroupCalendar.UI.Window.MonthView:SetStartDay(GroupCalendar.Data.StartDay)
		end
		
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
	self.ThemeMenu:SetSelectedValue(GroupCalendar.Data.ThemeID or GroupCalendar.DefaultThemeID)
	self.StartDayMenu:SetSelectedValue(GroupCalendar.Data.StartDay)
	self.TwentyFourHourTime:SetChecked(GetCVarBool("timeMgrUseMilitaryTime"))
	self.AnnounceBirthdays:SetChecked(not GroupCalendar.Data.Prefs.DisableBirthdayReminders)
	self.AnnounceEvents:SetChecked(not GroupCalendar.Data.Prefs.DisableEventReminders)
	self.AnnounceTradeskills:SetChecked(not GroupCalendar.Data.Prefs.DisableTradeskillReminders)
	self.RecordTradeskills:SetChecked(not GroupCalendar.Data.Prefs.DisableTradeskills)
	self.RememberInvites:SetChecked(not GroupCalendar.Data.Prefs.DisableInviteMemory)
	self.ShowMinimapClock:SetChecked(not GroupCalendar.Clock.Data.HideMinimapClock)
end

function GroupCalendar.UI._SettingsView:ThemeMenuFunc(pMenu, pMenuID)
	local vCurrentThemeID = GroupCalendar.Data.ThemeID or GroupCalendar.DefaultThemeID
	for vThemeID, vThemeData in pairs(GroupCalendar.Themes) do
		pMenu:AddNormalItem(vThemeData.Name, vThemeID, nil, GroupCalendar.Data.ThemeID == vThemeID)
	end
end

function GroupCalendar.UI._SettingsView:StartDayMenuFunc(pMenu, pMenuID)
	pMenu:AddNormalItem(WEEKDAY_SUNDAY, 1, nil, not GroupCalendar.Data.StartDay or GroupCalendar.Data.StartDay == 1)
	pMenu:AddNormalItem(WEEKDAY_MONDAY, 2, nil, GroupCalendar.Data.StartDay == 2)
	pMenu:AddNormalItem(WEEKDAY_TUESDAY, 3, nil, GroupCalendar.Data.StartDay == 3)
	pMenu:AddNormalItem(WEEKDAY_WEDNESDAY, 4, nil, GroupCalendar.Data.StartDay == 4)
	pMenu:AddNormalItem(WEEKDAY_THURSDAY, 5, nil, GroupCalendar.Data.StartDay == 5)
	pMenu:AddNormalItem(WEEKDAY_FRIDAY, 6, nil, GroupCalendar.Data.StartDay == 6)
	pMenu:AddNormalItem(WEEKDAY_SATURDAY, 7, nil, GroupCalendar.Data.StartDay == 7)
end
