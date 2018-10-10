----------------------------------------
-- Group Calendar 5 Copyright (c) 2018 John Stephen
-- This software is licensed under the MIT license.
-- See the included LICENSE.txt file for more information.
----------------------------------------

----------------------------------------
GroupCalendar.UI._DaySidebar = {}
----------------------------------------

function GroupCalendar.UI._DaySidebar:New(pParent)
	return GroupCalendar:New(GroupCalendar.UIElementsLib._SidebarWindowFrame, pParent)
end

function GroupCalendar.UI._DaySidebar:Construct(pParent)
	self:SetWidth(350)
	self:SetHeight(500)
	self:SetPoint("TOPLEFT", pParent, "TOPRIGHT", -1, -20)
	
	self.DateText = self:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	self.DateText:SetPoint("TOP", self, "TOP", 0, -33)
	
	self.BottomTrim = self:CreateTexture(nil, "ARTWORK")
	self.BottomTrim:SetHeight(32)
	self.BottomTrim:SetWidth(256)
	self.BottomTrim:SetTexture(GroupCalendar.UI.AddonPath.."Textures\\HorizontalTrim")
	self.BottomTrim:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, 4)
	self.BottomTrim:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -8, 4)
	
	self.NewEventButton = GroupCalendar:New(GroupCalendar.UIElementsLib._PushButton, self, GroupCalendar.cNewEvent, 120)
	self.NewEventButton:SetPoint("RIGHT", self.BottomTrim, "RIGHT", 0, -2)
	self.NewEventButton:SetScript("OnClick", function (pButton, pMouseButton)
		GroupCalendar.UI.Window:OpenNewEvent(self.Month, self.Day, self.Year)
	end)
	
	self.PasteEventButton = GroupCalendar:New(GroupCalendar.UIElementsLib._PushButton, self, GroupCalendar.cPasteEvent, 120)
	self.PasteEventButton:SetPoint("RIGHT", self.NewEventButton, "LEFT")
	self.PasteEventButton:SetScript("OnClick", function (pButton, pMouseButton)
		GroupCalendar.WoWCalendar:ContextMenuEventPaste(GroupCalendar.WoWCalendar:GetMonthOffset(self.Month, self.Year), self.Day)
	end)
	self.PasteEventButton:SetScript("OnUpdate", function (pButton)
		pButton:SetEnabled(GroupCalendar.WoWCalendar:ContextMenuEventClipboard() and not self.ReadOnly)
	end)
	
	--
	
	self.ItemHeight = 22
	
	self.ScrollingList = GroupCalendar:New(GroupCalendar.UIElementsLib._ScrollingItemList, self, self._ListItem, self.ItemHeight)
	self.ScrollingList.RedrawFunc = function () self:Refresh() end
	self.ScrollingList:SetPoint("TOPLEFT", self, "TOPLEFT", 10, -62)
	self.ScrollingList:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -9, 32)
	
	self.ItemFrames = {}
	
	self.Events = {}
	
	self:SetScript("OnShow", function (self)
		PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN)
		self:Refresh()
		GroupCalendar.EventLib:RegisterCustomEvent("GC5_CALENDAR_CHANGED", self.Rebuild, self)
		GroupCalendar.EventLib:RegisterCustomEvent("GC5_PREFS_CHANGED", self.Rebuild, self)
		
		GroupCalendar.UI.Window.MonthView:SelectDate(self.Month, self.Day, self.Year)
	end)

	self:SetScript("OnHide", function (self)
		--
		
		for vEventIndex, vEvent in ipairs(self.Events) do
			vEvent.Unseen = nil
		end
		
		GroupCalendar.EventLib:DispatchEvent("GC5_CALENDAR_CHANGED")
		
		--
		
		PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE)
		GroupCalendar.EventLib:UnregisterEvent("GC5_CALENDAR_CHANGED", self.Rebuild, self)
		GroupCalendar.EventLib:UnregisterEvent("GC5_PREFS_CHANGED", self.Rebuild, self)
		
		GroupCalendar.UI.Window.MonthView:SelectDate(nil)
	end)
end

function GroupCalendar.UI._DaySidebar:SetDate(pMonth, pDay, pYear)
	if self.Month ~= pMonth
	or self.Day ~= pDay
	or self.Year ~= pYear then
		for vEventIndex, vEvent in ipairs(self.Events) do
			vEvent.Unseen = nil
		end
		
		GroupCalendar.EventLib:DispatchEvent("GC5_CALENDAR_CHANGED")
	end
	
	self.Month = pMonth
	self.Day = pDay
	self.Year = pYear
	
	self.ReadOnly = not GroupCalendar:CanCreateEventOnDate(pMonth, pDay, pYear)
	
	self.NewEventButton:SetEnabled(not self.ReadOnly)
	
	self:Rebuild()
end

function GroupCalendar.UI._DaySidebar:Rebuild()
	if GroupCalendar.Calendars.PLAYER:IsAfterMaxCreateDate(self.Month, self.Day, self.Year) then
		self.NewEventButton:Hide()
	else
		self.NewEventButton:Show()
	end
	
	self:Refresh()
end

function GroupCalendar.CompareEventTimes(event1, event2)
	if event1.Year < event2.Year then
		return true
	elseif event1.Year > event2.Year then
		return false
	end

	if event1.Month < event2.Month then
		return true
	elseif event1.Month > event2.Month then
		return false
	end

	if event1.Day < event2.Day then
		return true
	elseif event1.Day > event2.Day then
		return false
	end

	if (event1.Hour or 24) < (event2.Hour or 24) then
		return true
	elseif (event1.Hour or 24) > (event2.Hour or 24) then
		return false
	end
	
	if (event1.Minute or 0) < (event2.Minute or 0) then
		return true
	elseif (event1.Minute or 0) > (event2.Minute or 0) then
		return false
	end
	
	return (event1.Title or "") < (event2.Title or "")
end
	
function GroupCalendar.UI._DaySidebar:Refresh()
	-- Rebuild the event list
	
	self.Events = GroupCalendar:GetDayEvents(self.Month, self.Day, self.Year, self.Events)
	
	-- Update the date text
	
	self.DateText:SetText(GroupCalendar.DateLib:GetLongDateString(GroupCalendar.DateLib:ConvertMDYToDate(self.Month, self.Day, self.Year), true))
	
	-- Update the list
	
	self.ScrollingList:SetNumItems(#self.Events)
	
	for vEventIndex, vEventData in ipairs(self.Events) do
		local vItemFrame = self.ScrollingList.ItemFrames[vEventIndex]
		if vItemFrame then vItemFrame:SetEvent(vEventData) end
	end
end

----------------------------------------
GroupCalendar.UI._DaySidebar._ListItem = {}
----------------------------------------

function GroupCalendar.UI._DaySidebar._ListItem:New(pParent)
	return CreateFrame("Button", nil, pParent)
end

function GroupCalendar.UI._DaySidebar._ListItem:Construct(pParent)
	local vWidth = 288
	
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	
	self:SetWidth(vWidth)
	self:SetHeight(pParent.ItemHeight)
	
	local vIconWidth = pParent.ItemHeight - 2
	local vTimeTextWidth = 65
	local vOwnerTextWidth = 60
	local vRightMargin = 3
	local vTitleTextWidth = vWidth - vTimeTextWidth - vOwnerTextWidth
	
	self.IconTexture = self:CreateTexture(nil, "BORDER")
	self.IconTexture:SetWidth(vIconWidth)
	self.IconTexture:SetHeight(vIconWidth)
	self.IconTexture:SetTexture(0, 1, 0)
	self.IconTexture:SetPoint("LEFT", self, "LEFT", 0, 0)
	
	self.OwnerText = self:CreateFontString(nil, "BORDER", "SystemFont_Tiny")
	self.OwnerText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
	self.OwnerText:SetJustifyH("RIGHT")
	self.OwnerText:SetJustifyV("BOTTOM")
	-- self.OwnerText:SetWidth(vOwnerTextWidth)
	self.OwnerText:SetHeight(pParent.ItemHeight)
	self.OwnerText:SetPoint("RIGHT", self, "RIGHT", -vRightMargin, 6)
	self.OwnerText:SetText("Gizmodo")
	
	self.OwnerIcon = self:CreateTexture(nil, "BORDER")
	self.OwnerIcon:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")
	self.OwnerIcon:SetWidth(16)
	self.OwnerIcon:SetHeight(16)
	self.OwnerIcon:SetPoint("RIGHT", self.OwnerText, "LEFT", 0, -6)
	
	self.TitleText = self:CreateFontString(nil, "BORDER", "GameFontNormal")
	self.TitleText:SetJustifyH("LEFT")
	self.TitleText:SetJustifyV("BOTTOM")
	self.TitleText:SetHeight(pParent.ItemHeight)
	self.TitleText:SetPoint("LEFT", self.IconTexture, "RIGHT", vTimeTextWidth + 6, 5)
	self.TitleText:SetPoint("RIGHT", self.OwnerIcon, "LEFT")
	self.TitleText:SetText("Uldar")
	
	self.TimeText = self:CreateFontString(nil, "BORDER", "GameFontNormal")
	self.TimeText:SetJustifyH("RIGHT")
	self.TimeText:SetJustifyV("BOTTOM")
	self.TimeText:SetWidth(vTimeTextWidth)
	self.TimeText:SetHeight(pParent.ItemHeight)
	self.TimeText:SetPoint("LEFT", self.IconTexture, "RIGHT", 0, 5)
	self.TimeText:SetText("12:59pm")
	
	self.Circled = self:CreateTexture(nil, "BACKGROUND")
	self.Circled:SetTexture(GroupCalendar.UI.AddonPath.."Textures\\CircledDate")
	self.Circled:SetPoint("TOPLEFT", self.TimeText, "TOPLEFT", 5, -5)
	self.Circled:SetPoint("BOTTOMRIGHT", self.TimeText, "BOTTOMRIGHT", 7, -6)
	
	self:SetHighlightTexture("Interface\\HelpFrame\\HelpFrameButton-Highlight")
	local vHighlightTexture = self:GetHighlightTexture()
	vHighlightTexture:SetTexCoord(0, 1, 0, 0.578125)
	vHighlightTexture:SetBlendMode("ADD")
	
	self:SetScript("OnClick", self.OnClick)
end

function GroupCalendar.UI._DaySidebar._ListItem:SetEvent(pEvent)
	self.Event = pEvent
	
	if not self.Event then
		return
	end
	
	local vColor = self.Event:GetEventColor()
	
	self.TitleText:SetTextColor(vColor.r, vColor.g, vColor.b)
	
	if self.Event:IsAllDayEvent() then
		self.TitleText:SetText(self.Event.Title)
		self.TimeText:SetText(GroupCalendar.cAllDay)
	else
		local vTime = GroupCalendar.DateLib:ConvertHMToTime(self.Event.Hour, self.Event.Minute)
		
		if GroupCalendar.Clock.Data.ShowLocalTime then
			vTime = GroupCalendar.DateLib:GetLocalTimeFromServerTime(vTime)
		end
		
		local vTimeString = GroupCalendar.DateLib:GetShortTimeString(vTime)
		
		self.TitleText:SetText(self.Event.Title)
		self.TimeText:SetText(vTimeString)
	end

	self.OwnerText:SetText(self.Event.OwnersName or "")
	
	if self.Event.ModStatus == "CREATOR" then
		self.OwnerIcon:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")
		self.OwnerIcon:Show()
	elseif self.Event.ModStatus == "MODERATOR" then
		self.OwnerIcon:SetTexture("Interface\\GroupFrame\\UI-Group-AssistantIcon")
		self.OwnerIcon:Show()
	else
		self.OwnerIcon:Hide()
	end
	
	local vTexturePath, vTexCoords = GroupCalendar:GetTextureFile(pEvent.TextureID, pEvent.CalendarType, pEvent.NumSequenceDays ~= 2 and pEvent.SequenceType or "", pEvent.EventType, pEvent.TitleTag)
	
	if pEvent.SequenceType == "ONGOING" and vTexturePath ~= nil then
		-- start texture is right before ongoing texture. this works, probably not a good idea in the long run though.
		vTexturePath = vTexturePath - 1
	end
	
	self.IconTexture:SetTexture(vTexturePath)
	
	if vTexCoords then
		self.IconTexture:SetTexCoord(vTexCoords.left, vTexCoords.right, vTexCoords.top, vTexCoords.bottom)
	else
		self.IconTexture:SetTexCoord(0, 1, 0, 1)
	end

	-- Circle the date if necessary
	
	if pEvent:IsAttending() then
		self.Circled:SetVertexColor(vColor.r, vColor.g, vColor.b, 0.7)
		self.Circled:Show()
	else
		self.Circled:Hide()
	end
end

function GroupCalendar.UI._DaySidebar._ListItem:OnClick(pButton)
	if pButton == "RightButton" then
		GroupCalendar.UI.Window.MonthView.EventMenu:Toggle(self.Event.Month, self.Event.Day, self.Event.Year, self.Event)
	else
		GroupCalendar.UI.Window:ShowEventSidebar(self.Event)
	end
end
