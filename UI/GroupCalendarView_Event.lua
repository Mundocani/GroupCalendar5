----------------------------------------
-- Group Calendar 5 Copyright (c) 2018 John Stephen
-- This software is licensed under the MIT license.
-- See the included LICENSE.txt file for more information.
----------------------------------------

GroupCalendar.UI._EventSidebar = {}

function GroupCalendar.UI._EventSidebar:New(pParent)
	return GroupCalendar:New(GroupCalendar.UIElementsLib._SidebarWindowFrame, pParent)
end

function GroupCalendar.UI._EventSidebar:Construct(pParent)
	self:SetWidth(350)
	self:SetHeight(500)
	self:SetPoint("TOPLEFT", pParent, "TOPRIGHT", -1, -20)
	
	self.BottomTrim = self:CreateTexture(nil, "ARTWORK")
	self.BottomTrim:SetHeight(32)
	self.BottomTrim:SetWidth(256)
	self.BottomTrim:SetTexture(GroupCalendar.UI.AddonPath.."Textures\\HorizontalTrim")
	self.BottomTrim:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, 4)
	self.BottomTrim:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -8, 4)
	
	self.DoneButton = GroupCalendar:New(GroupCalendar.UIElementsLib._PushButton, self, "Done", 105)
	self.DoneButton:SetPoint("RIGHT", self.BottomTrim, "RIGHT", -7, -2)
	self.DoneButton:SetScript("OnClick", function (frame, ...)
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		
		self.EventEditor:ClearFocus()
		self.EventViewer:SaveEventFields()
		self.EventInvite:SaveEventFields()
		self.EventGroup:SaveEventFields()
		
		GroupCalendar:SaveEventTemplate(self.Event)
		
		GroupCalendar.UI.Window.MonthView:SelectDate(self.Event.Month, self.Event.Day, self.Event.Year)
		
		self.Event:Save()
	end)
	self.DoneButton:SetScript("OnUpdate", function (pDoneButton, ...)
		if self.IsNewEvent then
			if GroupCalendar.WoWCalendar:CanAddEvent() then
				pDoneButton:Enable()
			else
				pDoneButton:Disable()
			end
		else
			if (GroupCalendar.WoWCalendar:EventHaveSettingsChanged() or self.EventEditor:HasChangedEditFields())
			and not GroupCalendar.WoWCalendar:IsActionPending() then
				pDoneButton:Enable()
			else
				pDoneButton:Disable()
			end
		end
	end)
	
	self.CopyButton = GroupCalendar:New(GroupCalendar.UIElementsLib._PushButton, self, CALENDAR_COPY_EVENT, 105)
	self.CopyButton:SetPoint("RIGHT", self.DoneButton, "LEFT")
	self.CopyButton:SetScript("OnClick", function (frame, ...)
		self.Event:Copy()
	end)
	
	self.DeleteButton = GroupCalendar:New(GroupCalendar.UIElementsLib._PushButton, self, GroupCalendar.cDelete, 105)
	self.DeleteButton:SetPoint("RIGHT", self.CopyButton, "LEFT")
	self.DeleteButton:SetScript("OnClick", function (frame, ...)
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		
		if self.Event.Index then
			GroupCalendar.UI:ShowConfirmDeleteEvent(function ()
				self:DeleteEvent()
			end)
		else
			self:DeleteEvent()
		end
	end)
	
	self.TabbedView = GroupCalendar:New(GroupCalendar.UIElementsLib._TabbedView, self, 0, -2)
	
	self.EventViewer = GroupCalendar:New(GroupCalendar.UI._EventViewer, self)
	self.TabbedView:AddView(self.EventViewer, "Event")
	
	self.EventEditor = GroupCalendar:New(GroupCalendar.UI._EventEditor, self)
	self.TabbedView:AddView(self.EventEditor, "Edit")
	
	self.EventInvite = GroupCalendar:New(GroupCalendar.UI._EventInvite, self)
	self.TabbedView:AddView(self.EventInvite, INVITE)
	
	self.EventGroup = GroupCalendar:New(GroupCalendar.UI._EventGroup, self)
	self.TabbedView:AddView(self.EventGroup, GROUP)
	
	self:SetScript("OnShow", self.OnShow)
	self:SetScript("OnHide", self.OnHide)
end

function GroupCalendar.UI._EventSidebar:DeleteEvent()
	self.Event:Delete()
	self:SetEvent(nil)
	GroupCalendar.UI.Window:ShowDaySidebar()
end

function GroupCalendar.UI._EventSidebar:SetEvent(event, isNewEvent)
	-- Ignore repeated calls on the same event
	if event == self.Event then
		return
	end
	
	-- Shut down existing listeners
	GroupCalendar.BroadcastLib:StopListening(nil, self.EventMessage, self)
	GroupCalendar.EventLib:UnregisterEvent("CALENDAR_NEW_EVENT", self.NewEventCreated, self)
	
	-- Switch events
	local previousEvent = self.Event
	self.Event = event
	self.IsNewEvent = isNewEvent

	-- Close the previous event
	if previousEvent and GroupCalendar.WoWCalendar.OpenedEvent == previousEvent then
		previousEvent:Close()
	end
	
	-- Signal the calendar that user has now seen this event
	if event and event.Unseen then
		event.Unseen = nil
		GroupCalendar.EventLib:DispatchEvent("GC5_CALENDAR_CHANGED")
	end
		
	-- Use a shadow copy so the cached version doesn't get modified unless changes are committed
	if event and not isNewEvent and event.OwnersName == GroupCalendar.PlayerName then
		self.Event = event:GetShadowCopy()
	else
		self.Event = event
	end
	
	-- Open the event
	if self.Event then
		self.Event:Open()
	end

	-- Set the event on each tab
	self.EventViewer:SetEvent(self.Event, self.IsNewEvent)
	self.EventEditor:SetEvent(self.Event, self.IsNewEvent)
	self.EventInvite:SetEvent(self.Event, self.IsNewEvent)
	self.EventGroup:SetEvent(self.Event, self.IsNewEvent)

	-- Refresh the tab list
	self:Refresh()

	-- Start listening
	if self.Event then
		GroupCalendar.BroadcastLib:Listen(self.Event, self.EventMessage, self)
		GroupCalendar.EventLib:RegisterEvent("CALENDAR_NEW_EVENT", self.NewEventCreated, self)
	end

	-- Adjust the Done button text
	if isNewEvent then
		self.DoneButton.Text:SetText(CALENDAR_CREATE)
	else
		self.DoneButton.Text:SetText(APPLY)
	end
end

function GroupCalendar.UI._EventSidebar:NewEventCreated()
	self:SetEvent(nil)
	self:Hide()
	GroupCalendar.UI.Window:ShowDaySidebar()
end

function GroupCalendar.UI._EventSidebar:EventMessage(pEvent, pMessageID)
	if pMessageID == "DELETED"
	or pMessageID == "CLOSED" then
		self:SetEvent(nil)
		self:Hide()
		GroupCalendar.UI.Window:ShowDaySidebar()
	elseif pMessageID == "CHANGED" then
		self:Refresh()
	end
end

function GroupCalendar.UI._EventSidebar:Refresh()
	if not self.Event then
		return
	end
	
	self.Title:SetText(self.Event.Title)

	-- Show the Edit and Invite tabs
	if self.Event:CanEdit() then
		self.TabbedView:ShowView(self.EventEditor)

		-- Show the Invite tab if the event uses attendance
		if self.Event:UsesAttendance() then
			self.TabbedView:ShowView(self.EventInvite)
		else
			self.TabbedView:HideView(self.EventInvite)
		end

	-- Hide the Edit and Invite tabs
	else
		self.TabbedView:HideView(self.EventEditor)
		self.TabbedView:HideView(self.EventInvite)
	end

	-- Show/hide the Group tab
	if self.Event:UsesAttendance() then
		self.TabbedView:ShowView(self.EventGroup)
	else
		self.TabbedView:HideView(self.EventGroup)
	end

	if self.Event:CanDelete() then
		self.DeleteButton:Show()
	else
		self.DeleteButton:Hide()
	end
	
	if self.Event:CanCopy() then
		self.CopyButton:Show()
	else
		self.CopyButton:Hide()
	end
	
	if self.Event:CanEdit() then
		self.DoneButton:Show()
	else
		self.DoneButton:Hide()
	end
end

function GroupCalendar.UI._EventSidebar:OnShow()
	if self.IsNewEvent
	or (self.Event.ModStatus == "CREATOR" and self.Event:CanEdit()) then
		if not self.IsNewEvent and self.Event:UsesAttendance() then
			self.TabbedView:SelectView(self.EventGroup)
		else
			self.TabbedView:SelectView(self.EventEditor)
		end
	elseif self.Event == GroupCalendar.RunningEvent then
		self.TabbedView:SelectView(self.EventGroup)
	else
		self.TabbedView:SelectView(self.EventViewer)
	end
	
	GroupCalendar.UI.Window.MonthView:SelectDate(self.Event.Month, self.Event.Day, self.Event.Year)
end

function GroupCalendar.UI._EventSidebar:OnHide()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE)
	self:SetEvent(nil)
	GroupCalendar.UI.Window.MonthView:SelectDate(nil)
end
