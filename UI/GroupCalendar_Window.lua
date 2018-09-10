----------------------------------------
-- Group Calendar 5 Copyright 2005 - 2016 John Stephen, wobbleworks.com
-- All rights reserved, unauthorized redistribution is prohibited
----------------------------------------

GroupCalendar.UI._Window = {}

function GroupCalendar.UI._Window:New()
	return GroupCalendar:New(GroupCalendar.UIElementsLib._PortaitWindow, GroupCalendar.cTitle:format(GroupCalendar.cVersionString), 550, 550, "GroupCalendar5Window")
end

function GroupCalendar.UI._Window:Construct()
	self:Hide()
	self:SetToplevel(true)
end

function GroupCalendar.UI._Window:Initialize()
	if self.DidInitialize then return end
	self.DidInitialize = true
	
	table.insert(UISpecialFrames, "GroupCalendar5Window")
	UIPanelWindows.GroupCalendar5Window = {area = "left", pushable = 9, whileDead = 1, width = 550}
	
	self.Clock = GroupCalendar:New(GroupCalendar._Clock, 54)
	
	self.Clock:SetParent(self)
	self.Clock:SetPoint("TOPLEFT", self, "TOPLEFT", 11, -9)
	
	self.TabbedView = GroupCalendar:New(GroupCalendar.UIElementsLib._TabbedView, self, 0, 1)
	
	-- Month view
	
	self.MonthView = GroupCalendar:New(GroupCalendar.UI._MonthView, self)
	self.MonthView:SetPoint("TOPLEFT", self, "TOPLEFT", 0, -40)
	self.MonthView:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
	
	self.TabbedView:AddView(self.MonthView, GroupCalendar.cCalendar)
	
	-- Settings view
	
	self.SettingsView = GroupCalendar:New(GroupCalendar.UI._SettingsView, self)
	self.SettingsView:SetPoint("TOPLEFT", self, "TOPLEFT", 0, -40)
	self.SettingsView:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
	
	self.TabbedView:AddView(self.SettingsView, GroupCalendar.cSettings)
	
	-- Partners view
	
	self.PartnersView = GroupCalendar:New(GroupCalendar.UI._PartnersView, self)
	self.PartnersView:SetPoint("TOPLEFT", self, "TOPLEFT", 0, -40)
	self.PartnersView:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
	
	self.TabbedView:AddView(self.PartnersView, GroupCalendar.cPartners)
	
	-- Export view
	
	self.ExportView = GroupCalendar:New(GroupCalendar.UI._ExportView, self)
	self.ExportView:SetPoint("TOPLEFT", self, "TOPLEFT", 0, -40)
	self.ExportView:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
	
	self.TabbedView:AddView(self.ExportView, GroupCalendar.cExport)
	
	-- About view
	
	self.AboutView = GroupCalendar:New(GroupCalendar.UI._AboutView, self)
	self.AboutView:SetPoint("TOPLEFT", self, "TOPLEFT", 0, -40)
	self.AboutView:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
	
	self.TabbedView:AddView(self.AboutView, GroupCalendar.cAbout)
	
	-- Newer Version frame
	
	self.NewerVersionFrame = CreateFrame("Frame", nil, self)
	self.NewerVersionFrame:SetWidth(229)
	self.NewerVersionFrame:SetHeight(18)
	self.NewerVersionFrame:SetPoint("BOTTOM", self, "TOP", 22, -13)
	self.NewerVersionFrame.LeftTexture = self.NewerVersionFrame:CreateTexture(nil, "BACKGROUND")
	self.NewerVersionFrame.LeftTexture:SetTexture("Interface\\Calendar\\CalendarFrame_TopAndBottom")
	self.NewerVersionFrame.LeftTexture:SetWidth(47)
	self.NewerVersionFrame.LeftTexture:SetHeight(18)
	self.NewerVersionFrame.LeftTexture:SetPoint("LEFT", self.NewerVersionFrame, "LEFT")
	self.NewerVersionFrame.LeftTexture:SetTexCoord(0.81640625, 1, 0.00390625, 0.05859375)
	
	self.NewerVersionFrame.RightTexture = self.NewerVersionFrame:CreateTexture(nil, "BACKGROUND")
	self.NewerVersionFrame.RightTexture:SetTexture("Interface\\Calendar\\CalendarFrame_TopAndBottom")
	self.NewerVersionFrame.RightTexture:SetWidth(182)
	self.NewerVersionFrame.RightTexture:SetHeight(18)
	self.NewerVersionFrame.RightTexture:SetPoint("RIGHT", self.NewerVersionFrame, "RIGHT")
	self.NewerVersionFrame.RightTexture:SetTexCoord(0, 0.7109375, 0.16796875, 0.22265625)
	
	self.NewerVersionMessage = self.NewerVersionFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	self.NewerVersionMessage:SetHeight(25)
	self.NewerVersionMessage:SetPoint("CENTER", self.NewerVersionFrame, "CENTER", 0, -2)
	
	--
	
	self:SetScript("OnDragStart", function (self, button) if button == "LeftButton" then self:StartMoving() end end)
	self:SetScript("OnDragStop", self.StopMovingOrSizing)
	self:SetScript("OnMouseUp", self.StopMovingOrSizing)
	self:SetScript("OnShow", self.OnShow)
	self:SetScript("OnHide", self.OnHide)
	
	self:RegisterForDrag("LeftButton")
	
	self.EventSidebar = GroupCalendar:New(GroupCalendar.UI._EventSidebar, self)
	self.EventSidebar:Hide()
	
	self.DaySidebar = GroupCalendar:New(GroupCalendar.UI._DaySidebar, self)
	self.DaySidebar:Hide()
end

function GroupCalendar.UI._Window:Show()
	self:Initialize()
	self.Inherited.Show(self)
end

function GroupCalendar.UI._Window:OpenNewEvent(pMonth, pDay, pYear, pCalendarType)
	local vEvent = GroupCalendar.Calendars.PLAYER:NewEvent(pMonth, pDay, pYear, pCalendarType)
	
	self:ShowEventSidebar(vEvent, true)
end

function GroupCalendar.UI._Window:OnShow()
	PlaySound(SOUNDKIT.IG_SPELLBOOK_OPEN)
	
	-- Ensure no event is lingering open
	
	if CalendarFrame_CloseEvent then
		CalendarFrame_CloseEvent()
	else
		GroupCalendar.WoWCalendar:CalendarCloseEvent()
	end
	
	--
	
	self.TabbedView:SelectView(self.MonthView)
	
	GroupCalendar:StopFlashingReminder()
	
	-- Update the guild roster
	
	if IsInGuild() and GetNumGuildMembers() == 0 then
		GuildRoster()
	end
	
	--
	
	local vLatestVersion = GroupCalendar:GetLatestVersionInfo()
	
	if vLatestVersion and false then
		self.NewerVersionMessage:SetText(string.format(GroupCalendar.cNewerVersionMessage, vLatestVersion:ToString()))
		self.NewerVersionFrame:Show()
	else
		self.NewerVersionFrame:Hide()
	end
	
	-- If an event is running, open the editor to it
	
	if GroupCalendar.RunningEvent then
		self:ShowEventSidebar(GroupCalendar.RunningEvent)
	end
end

function GroupCalendar.UI._Window:OnHide()
	PlaySound(SOUNDKIT.IG_SPELLBOOK_CLOSE)
	
	self:HideSidebars()
	HideUIPanel(self)
	
	GroupCalendar:MarkAllEventsAsSeen()
end

function GroupCalendar.UI._Window:HideSidebars()
	self.DaySidebar:Hide()
	self.EventSidebar:Hide()
end

function GroupCalendar.UI._Window:ShowDaySidebar(pMonth, pDay, pYear)
	if not pMonth then
		pMonth, pDay, pYear = self.MonthView.SelectedMonth, self.MonthView.SelectedDay, self.MonthView.SelectedYear
	end
	
	-- If the day sidebar is already shown and the same date is being
	-- requested, then toggle the sidebar off
	
	if self.DaySidebar:IsVisible()
	and self.DaySidebar.Month == pMonth
	and self.DaySidebar.Day == pDay
	and self.DaySidebar.Year == pYear then
		self.DaySidebar:Hide()
		return
	end
	
	--
	
	self:HideSidebars()
	
	if not pMonth then
		return
	end
	
	self.DaySidebar:SetDate(pMonth, pDay, pYear)
	self.DaySidebar:Show()
end

function GroupCalendar.UI._Window:ShowEventSidebar(pEvent, pIsNewEvent)
	self:HideSidebars()
	
	self.MonthView:SelectDate(pEvent.Month, pEvent.Day, pEvent.Year)
	
	self.EventSidebar:SetEvent(pEvent, pIsNewEvent)
	self.EventSidebar:Show()
end
