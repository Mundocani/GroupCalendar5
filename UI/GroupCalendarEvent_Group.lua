----------------------------------------
-- Group Calendar 5 Copyright (c) 2018 John Stephen
-- This software is licensed under the MIT license.
-- See the included LICENSE.txt file for more information.
----------------------------------------

GroupCalendar.cInviteStatusMessages =
{
	SELECT = GroupCalendar.cInviteNeedSelectionStatus,
	READY = GroupCalendar.cInviteReadyStatus,
	INVITING = GroupCalendar.cInviteInvitingStatus,
	COMPLETE = GroupCalendar.cInviteCompleteStatus,
	CONVERTING = GroupCalendar.cInviteConvertingToRaidStatus,
	WAITING = GroupCalendar.cInviteAwaitingAcceptanceStatus,
	FULL = GroupCalendar.cRaidFull,
}

----------------------------------------
GroupCalendar.UI._EventGroup = {}
----------------------------------------

GroupCalendar.UI._EventGroup.GroupByTitle =
{
	ROLE = GroupCalendar.cViewByRole,
	CLASS = GroupCalendar.cViewByClass,
	STATUS = GroupCalendar.cViewByStatus,
}

GroupCalendar.UI._EventGroup.SortByTitle =
{
	DATE = GroupCalendar.cViewByDate,
	RANK = GroupCalendar.cViewByRank,
	NAME = GroupCalendar.cViewByName,
}

function GroupCalendar.UI._EventGroup:New(pParentFrame)
	return CreateFrame("Frame", nil, pParentFrame)
end

function GroupCalendar.UI._EventGroup:Construct(pParentFrame)
	self:SetAllPoints()
	
	self:SetScript("OnShow", self.OnShow)
	self:SetScript("OnHide", self.OnHide)
	
	self.Groups = {}
	self.SelectedPlayers = {}
end

function GroupCalendar.UI._EventGroup:Initialize()
	if self.Initialized then return end
	self.Initialized = true
	self.ViewMenu = GroupCalendar:New(GroupCalendar.UIElementsLib._TitledDropDownMenuButton, self, function (...) self:ViewMenuFunc(...) end, 180)
	self.ViewMenu:SetPoint("TOPRIGHT", self, "TOPRIGHT", -9, -29)
	self.ViewMenu.ItemClicked = function (pMenu, pItemID)
		if pItemID:sub(1, 6) == "GROUP_" then
			self:SetGroupBy(pItemID:sub(7))
		elseif pItemID:sub(1, 5) == "SORT_" then
			self:SetSortBy(pItemID:sub(6))
		end
	end
	
	self.TotalsSection = CreateFrame("Frame", nil, self)
	self.TotalsSection:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -9, 32)
	self.TotalsSection:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, 32)
	self.TotalsSection:SetHeight(64)
	self.TotalsSection.Background = GroupCalendar:New(GroupCalendar.UIElementsLib._StretchTextures, GroupCalendar.UIElementsLib._PanelSectionBackgroundInfo, self.TotalsSection, "BACKGROUND")
	
	self.TotalLabelH = self.TotalsSection:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	self.TotalLabelH:SetPoint("TOPRIGHT", self.TotalsSection, "TOPRIGHT", -45, -6)
	self.TotalLabelH:SetText(GroupCalendar.RAID_CLASS_COLOR_CODES.PRIEST..GroupCalendar.cHPluralLabel)
	
	self.TotalValues = {}
	
	self.TotalValues.H = self.TotalsSection:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	self.TotalValues.H:SetPoint("LEFT", self.TotalLabelH, "RIGHT", 4, 0)
	self.TotalValues.H:SetText("7 (+4)")
	
	self.TotalLabelT = self.TotalsSection:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	self.TotalLabelT:SetPoint("TOPRIGHT", self.TotalLabelH, "TOPRIGHT", 0, -14)
	self.TotalLabelT:SetText(GroupCalendar.RAID_CLASS_COLOR_CODES.WARRIOR..GroupCalendar.cTPluralLabel)
	
	self.TotalValues.T = self.TotalsSection:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	self.TotalValues.T:SetPoint("LEFT", self.TotalLabelT, "RIGHT", 4, 0)
	self.TotalValues.T:SetText("0")
	
	self.TotalLabelR = self.TotalsSection:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	self.TotalLabelR:SetPoint("TOPRIGHT", self.TotalLabelT, "TOPRIGHT", 0, -14)
	self.TotalLabelR:SetText(GroupCalendar.RAID_CLASS_COLOR_CODES.MAGE..GroupCalendar.cRPluralLabel)
	
	self.TotalValues.R = self.TotalsSection:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	self.TotalValues.R:SetPoint("LEFT", self.TotalLabelR, "RIGHT", 4, 0)
	self.TotalValues.R:SetText("0")
	
	self.TotalLabelM = self.TotalsSection:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	self.TotalLabelM:SetPoint("TOPRIGHT", self.TotalLabelR, "TOPRIGHT", 0, -14)
	self.TotalLabelM:SetText(GroupCalendar.RAID_CLASS_COLOR_CODES.ROGUE..GroupCalendar.cMPluralLabel)
	
	self.TotalValues.M = self.TotalsSection:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	self.TotalValues.M:SetPoint("LEFT", self.TotalLabelM, "RIGHT", 4, 0)
	self.TotalValues.M:SetText("0")
	
	self.StartEventHelp = self.TotalsSection:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	self.StartEventHelp:SetPoint("TOPLEFT", self.TotalsSection, "TOPLEFT", 15, -5)
	self.StartEventHelp:SetPoint("BOTTOMRIGHT", self.TotalsSection, "BOTTOMRIGHT", -100, 5)
	self.StartEventHelp:SetText(GroupCalendar.cStartEventHelp)
	
	--
	
	self.StatusSection = CreateFrame("Frame", nil, self)
	self.StatusSection:SetPoint("BOTTOMRIGHT", self.TotalsSection, "TOPRIGHT", 0, 0)
	self.StatusSection:SetPoint("BOTTOMLEFT", self.TotalsSection, "TOPLEFT", 0, 0)
	self.StatusSection:SetHeight(25)
	self.StatusSection.Background = GroupCalendar:New(GroupCalendar.UIElementsLib._StretchTextures, GroupCalendar.UIElementsLib._PanelSectionBackgroundInfo, self.StatusSection, "BACKGROUND")
	
	self.StartEventButton = GroupCalendar:New(GroupCalendar.UIElementsLib._PushButton, self.StatusSection, GroupCalendar.cStart, 100)
	self.StartEventButton:SetPoint("LEFT", self.StatusSection, "LEFT", 15, 0)
	self.StartEventButton:SetScript("OnClick", function ()
		local vEvent = self.Event.OriginalEvent or self.Event
		
		if GroupCalendar.RunningEvent ~= self.Event
		and IsModifierKeyDown() and (vEvent.StartDate or vEvent.ElapsedSeconds) then
			GroupCalendar:RestartEvent(self.Event)
			self:Rebuild()
		else
			self:StartEvent()
		end
	end)
	
	self.StartEventButton:SetScript("OnUpdate", function (pButton)
		local vEvent = self.Event.OriginalEvent or self.Event
		
		if vEvent.StartDate or vEvent.ElapsedSeconds then -- The event has been started before
			if IsModifierKeyDown() then
				pButton:SetTitle(GroupCalendar.cRestart)
			else
				pButton:SetTitle(GroupCalendar.cResume)
			end
		else -- It's a fresh event
			pButton:SetTitle(GroupCalendar.cStart)
		end
	end)
	
	self.StopEventButton = GroupCalendar:New(GroupCalendar.UIElementsLib._PushButton, self.StatusSection, GroupCalendar.cPause, 100)
	self.StopEventButton:SetPoint("LEFT", self.StartEventButton, "LEFT")
	self.StopEventButton:SetScript("OnClick", function ()
		self:ClearSelection()
		
		GroupCalendar:StopEvent()

		if IsModifierKeyDown() then
			GroupCalendar:RestartEvent(self.Event)
			GroupCalendar:StartEvent(self.Event, function (...) self:InviteNotification(...) end)
		end
	end)
	self.StopEventButton:SetScript("OnUpdate", function (pButton)
		if IsModifierKeyDown() then
			pButton:SetTitle(GroupCalendar.cRestart)
		else
			pButton:SetTitle(GroupCalendar.cPause)
		end
	end)
	
	self.EventStatus = self.StatusSection:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	self.EventStatus:SetPoint("LEFT", self.StartEventButton, "RIGHT", 10, 0)
	self.EventStatus:SetText("99:99:99")
	
	self.GrandTotalLabel = self.StatusSection:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	self.GrandTotalLabel:SetPoint("RIGHT", self.StatusSection, "RIGHT", -45, 0)
	self.GrandTotalLabel:SetText(GroupCalendar.cTotalLabel)
	
	self.GrandTotalValue = self.StatusSection:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	self.GrandTotalValue:SetPoint("LEFT", self.GrandTotalLabel, "RIGHT", 4, 0)
	self.GrandTotalValue:SetText("0")
	
	--
	
	self.AutoSelectButton = GroupCalendar:New(GroupCalendar.UIElementsLib._PushButton, self.TotalsSection, "Select...", 100)
	self.AutoSelectButton:SetPoint("TOPLEFT", self.TotalsSection, "TOPLEFT", 15, -6)
	self.AutoSelectButton:SetScript("OnClick", function ()
		GroupCalendar.UI.RoleLimitsDialog:SetParent(self)
		GroupCalendar.UI.RoleLimitsDialog:SetFrameLevel(self:GetFrameLevel() + 50)
		GroupCalendar.UI.RoleLimitsDialog:ClearAllPoints()
		GroupCalendar.UI.RoleLimitsDialog:SetPoint("CENTER", self, "CENTER")
		GroupCalendar.UI.RoleLimitsDialog:Open(self.AutoSelectLimits or self.Event.Limits, GroupCalendar.cAutoConfirmRoleLimitsTitle, true, function (pLimits)
			self.AutoSelectLimits = pLimits
			self:AutoSelectFromLimits(pLimits)
		end)
	end)
	
	self.AutoSelectHelp = self.TotalsSection:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	self.AutoSelectHelp:SetPoint("LEFT", self.AutoSelectButton, "RIGHT", 10, 0)
	self.AutoSelectHelp:SetPoint("RIGHT", self.StartEventHelp, "RIGHT", 0, 0)
	self.AutoSelectHelp:SetPoint("TOP", self.AutoSelectButton, "TOP", 0, 5)
	self.AutoSelectHelp:SetPoint("BOTTOM", self.AutoSelectButton, "BOTTOM", 0, -5)
	self.AutoSelectHelp:SetText(GroupCalendar.cNoSelection)
	self.AutoSelectHelp:SetJustifyH("LEFT")
	
	self.InviteSelectedButton = GroupCalendar:New(GroupCalendar.UIElementsLib._PushButton, self.TotalsSection, INVITE, 100)
	self.InviteSelectedButton:SetPoint("TOPLEFT", self.AutoSelectButton, "BOTTOMLEFT", 0, -5)
	self.InviteSelectedButton:SetScript("OnClick", function (pFrame, pButton)
		self:InviteSelectedPlayers()
	end)
	
	self.InviteSelectedHelp = self.TotalsSection:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	self.InviteSelectedHelp:SetPoint("LEFT", self.InviteSelectedButton, "RIGHT", 10, 0)
	self.InviteSelectedHelp:SetPoint("RIGHT", self.StartEventHelp, "RIGHT", 0, 0)
	self.InviteSelectedHelp:SetPoint("TOP", self.InviteSelectedButton, "TOP", 0, 5)
	self.InviteSelectedHelp:SetPoint("BOTTOM", self.InviteSelectedButton, "BOTTOM", 0, -5)
	self.InviteSelectedHelp:SetText(GroupCalendar.cInviteNeedSelectionStatus)
	self.InviteSelectedHelp:SetJustifyH("LEFT")
	
	self.ScrollingList = GroupCalendar:New(GroupCalendar.UIElementsLib._ScrollingItemList, self, self._ListItem, self._ListItem.cItemHeight)
	self.ScrollingList.DrawingFunc = function () self:Refresh() end
	
	self.ScrollingList:SetPoint("TOPLEFT", self, "TOPLEFT", 10, -62)
	self.ScrollingList:SetPoint("BOTTOMRIGHT", self.StatusSection, "TOPRIGHT", 0, 0)
	
	self.ExpandAll = GroupCalendar:New(GroupCalendar.UIElementsLib._ExpandAllButton, self)
	self.ExpandAll:SetPoint("TOPLEFT", self.ScrollingList, "TOPLEFT", 5, 25)
	self.ExpandAll:SetScript("OnClick", function (pButton)
		self:SetExpandAll(not not pButton:GetChecked()) -- I don't like using 'not not', but it's the easiest way to force a boolean value :/
	end)
	
	self.SelectAllButton = GroupCalendar:New(GroupCalendar.UIElementsLib._CheckButton, self, ALL)
	self.SelectAllButton:SetWidth(14)
	self.SelectAllButton:SetHeight(14)
	self.SelectAllButton:SetPoint("LEFT", self.ExpandAll.TabRight, "RIGHT", 3, -2)
	self.SelectAllButton:SetScript("OnClick", function (pButton)
		if pButton:GetChecked() then
			self:SelectAll()
		else
			self:ClearSelection()
		end
	end)
end

function GroupCalendar.UI._EventGroup:StartEvent()
	GroupCalendar:StopEvent()

	GroupCalendar:StartEvent(self.Event, function (...)
		self:InviteNotification(...)
	end)
end

function GroupCalendar.UI._EventGroup:SetEvent(pEvent, pIsNewEvent)
	self:Initialize()
	GroupCalendar.EventLib:UnregisterEvent("GROUP_ROSTER_UPDATE", self.ScheduleRebuild, self)
	GroupCalendar.EventLib:UnregisterEvent("PARTY_LEADER_CHANGED", self.ScheduleRebuild, self)
	GroupCalendar.EventLib:UnregisterEvent("GC5_PREFS_CHANGED", self.Refresh, self)
	
	GroupCalendar.BroadcastLib:StopListening(nil, self.EventMessage, self)
	
	GroupCalendar.SchedulerLib:UnscheduleTask(self.UpdateElapsed, self)
	GroupCalendar.SchedulerLib:UnscheduleTask(self.Rebuild, self)
	
	--
	
	self.Event = pEvent
	self.IsNewEvent = pIsNewEvent
	
	if not self.Event then
		for vKey, _ in ipairs(self.Groups) do
			self.Groups[vKey] = nil
		end
		
		self.InvitedGroup = nil
		self.AcceptedGroup = nil
		self.TentativeGroup = nil
		self.ConfirmedGroup = nil
		self.StandbyGroup = nil
		self.DeclinedGroup = nil
		self.OutGroup = nil
		
		return
	end
	
	self.InvitedGroup = GroupCalendar:New(GroupCalendar._PlayerGroup, CALENDAR_STATUS_INVITED, self.Event, false)
	self.AcceptedGroup = GroupCalendar:New(GroupCalendar._PlayerGroup, CALENDAR_STATUS_ACCEPTED, self.Event, true)
	self.TentativeGroup = GroupCalendar:New(GroupCalendar._PlayerGroup, CALENDAR_STATUS_TENTATIVE, self.Event, true)
	self.ConfirmedGroup = GroupCalendar:New(GroupCalendar._PlayerGroup,CALENDAR_STATUS_CONFIRMED, self.Event, true)
	self.StandbyGroup = GroupCalendar:New(GroupCalendar._PlayerGroup, CALENDAR_STATUS_STANDBY, self.Event, true)
	self.DeclinedGroup = GroupCalendar:New(GroupCalendar._PlayerGroup, CALENDAR_STATUS_DECLINED, self.Event, false)
	self.OutGroup = GroupCalendar:New(GroupCalendar._PlayerGroup, CALENDAR_STATUS_OUT, self.Event, false)
	self.LeftGroup = GroupCalendar:New(GroupCalendar._PlayerGroup, "Left Group", self.Event, false)
	self.UnknownGroup = GroupCalendar:New(GroupCalendar._PlayerGroup, GroupCalendar.cUnknown, self.Event, false)
	
	self.SortBy = "NAME"
	self:SetGroupBy("ROLE")
	
	GroupCalendar.BroadcastLib:Listen(self.Event, self.EventMessage, self)
	
	GroupCalendar.EventLib:RegisterEvent("GROUP_ROSTER_UPDATE", self.ScheduleRebuild, self, true)
	GroupCalendar.EventLib:RegisterEvent("PARTY_LEADER_CHANGED", self.ScheduleRebuild, self, true)
	GroupCalendar.EventLib:RegisterCustomEvent("GC5_PREFS_CHANGED", self.Refresh, self)
end

function GroupCalendar.UI._EventGroup:SaveEventFields()
	-- Nothing to do, event is updated as the user manipulates it
end

function GroupCalendar.UI._EventGroup:SetExpandAll(pExpandAll)
	for vIndex, vGroup in ipairs(self.Groups) do
		if vGroup:GetNumMembers() > 0 then
			vGroup.Expanded = pExpandAll
		end
	end
	
	self:Refresh()
end

function GroupCalendar.UI._EventGroup:AllSelected()
	local attendance = self.Event:GetAttendance()
	
	if not attendance then
		return false
	end
	
	for name, playerInfo in pairs(attendance) do
		if self:IsSelectAllCandidate(playerInfo)
		and not self.SelectedPlayers[name] then
			return false
		end
	end
	
	if next(self.SelectedPlayers) then
		return true
	else
		return false
	end
end

function GroupCalendar.UI._EventGroup:SelectAll()
	local attendance = self.Event:GetAttendance()
	
	for vKey, _ in pairs(self.SelectedPlayers) do
		self.SelectedPlayers[vKey] = nil
	end
	
	for name, playerInfo in pairs(attendance) do
		if self:IsSelectAllCandidate(playerInfo) then
			self.SelectedPlayers[name] = true
		end
	end
	
	self:Refresh()
end

function GroupCalendar.UI._EventGroup:IsSelectAllCandidate(playerInfo)
	return (playerInfo.InviteStatus == CALENDAR_INVITESTATUS_ACCEPTED
	     or playerInfo.InviteStatus == CALENDAR_INVITESTATUS_TENTATIVE
	     or playerInfo.InviteStatus == CALENDAR_INVITESTATUS_SIGNEDUP
	     or playerInfo.InviteStatus == CALENDAR_INVITESTATUS_STANDBY
	     or playerInfo.InviteStatus == CALENDAR_INVITESTATUS_CONFIRMED)
	and (not self.Event.Group
	  or not self.Event.Group[playerInfo.Name]
	  or self.Event.Group[playerInfo.Name].LeftGroup)
end

function GroupCalendar.UI._EventGroup:ClearSelection()
	for vKey, _ in pairs(self.SelectedPlayers) do
		self.SelectedPlayers[vKey] = nil
	end
	
	self:Refresh()
end

function GroupCalendar.UI._EventGroup:AutoSelectFromLimits(pLimits)
	local vAvailableSlots = GroupCalendar:New(GroupCalendar._AvailableSlots, pLimits, "ROLE")
	local attendance = self.Event:GetAttendance()
	
	vAvailableSlots:AddEventGroup(self.Event)
	
	self:ClearSelection()
	
	for name, playerInfo in pairs(attendance) do
		if (playerInfo.InviteStatus == CALENDAR_INVITESTATUS_STANDBY
		or playerInfo.InviteStatus == CALENDAR_INVITESTATUS_CONFIRMED
		or playerInfo.InviteStatus == CALENDAR_INVITESTATUS_TENTATIVE)
		and (not self.Event.Group
		 or not self.Event.Group[name]
		 or self.Event.Group[name].LeftGroup) then
			if vAvailableSlots:AddPlayer(playerInfo) then
				self.SelectedPlayers[name] = true
			end
		end
	end
	
	self:Refresh()
end

function GroupCalendar.UI._EventGroup:InviteSelectedPlayers()
	local attendance = self.Event:GetAttendance()
	
	for vPlayerName, _ in pairs(self.SelectedPlayers) do
		local playerInfo = attendance and attendance[vPlayerName]
		local playerGroupInfo = self.Event.Group and self.Event.Group[vPlayerName]
		
		if (playerInfo or playerGroupInfo)
		and (not playerGroupInfo or playerGroupInfo.LeftGroup) then
			GroupCalendar.RaidInvites:InvitePlayer(vPlayerName)
		end
	end
end

function GroupCalendar.UI._EventGroup:InviteNotification(pMessageID, ...)
	if not self.Event then
		return
	end
	
	if pMessageID == "STATUS" then
		local vStatus = select(1, ...)
		self.RaidInviteStatus = vStatus
		self:Rebuild()
	elseif pMessageID == "PLAYER" then
		local vPlayerName = select(1, ...)
		local vStatus = select(2, ...)
		local playerInfo = self.Event:GetAttendance()[vPlayerName]
		
		if not playerInfo then
			return
		end
		
		if vStatus == "JOINED" then
			vStatus = nil
			self.SelectedPlayers[vPlayerName] = nil
		end
		
		playerInfo.RaidInviteStatus = vStatus
		self:Rebuild()
	end
end

function GroupCalendar.UI._EventGroup:EventMessage(pEvent, pMessageID)
	if pMessageID == "INVITES_CHANGED" then
		self:Rebuild()
	end
end

function GroupCalendar.UI._EventGroup:OnShow()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN)
	self:Initialize()
	self:Rebuild()
	GroupCalendar.SchedulerLib:ScheduleUniqueRepeatingTask(0.25, self.UpdateElapsed, self)
end

function GroupCalendar.UI._EventGroup:OnHide()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE)
	
	GroupCalendar.SchedulerLib:UnscheduleTask(self.UpdateElapsed, self)
	GroupCalendar.SchedulerLib:UnscheduleTask(self.Rebuild, self)
end

function GroupCalendar.UI._EventGroup:UpdateElapsed()
	local vElapsed = GroupCalendar:GetEventElapsedSeconds(self.Event)
	
	if vElapsed == 0 then
		self.EventStatus:SetText("")
	else
		local vHours = math.floor(vElapsed / 3600)
		local vHoursRemainder = vElapsed - vHours * 3600
		local vMinutes = math.floor(vHoursRemainder / 60)
		local vSeconds = vHoursRemainder - vMinutes * 60
		
		self.EventStatus:SetText(string.format("%02d:%02d:%02d", vHours, vMinutes, vSeconds))
	end
end

function GroupCalendar.UI._EventGroup:SetGroupBy(pGroupBy)
	for vKey, _ in ipairs(self.Groups) do
		self.Groups[vKey] = nil
	end
	
	self.GroupBy = pGroupBy
	
	table.insert(self.Groups, self.InvitedGroup)
	table.insert(self.Groups, self.AcceptedGroup)
	table.insert(self.Groups, self.TentativeGroup)
	
	self.RoleGroups = nil
	self.ClassGroups = nil
	
	if self.GroupBy == "ROLE" then
		self.RoleGroups = {}
		
		self.RoleGroups.H = GroupCalendar:New(GroupCalendar._PlayerGroup, GroupCalendar.cHPluralRole, self.Event, true)
		self.RoleGroups.T = GroupCalendar:New(GroupCalendar._PlayerGroup, GroupCalendar.cTPluralRole, self.Event, true)
		self.RoleGroups.R = GroupCalendar:New(GroupCalendar._PlayerGroup, GroupCalendar.cRPluralRole, self.Event, true)
		self.RoleGroups.M = GroupCalendar:New(GroupCalendar._PlayerGroup, GroupCalendar.cMPluralRole, self.Event, true)
		
		table.insert(self.Groups, self.RoleGroups.H)
		table.insert(self.Groups, self.RoleGroups.T)
		table.insert(self.Groups, self.RoleGroups.R)
		table.insert(self.Groups, self.RoleGroups.M)
	elseif self.GroupBy == "CLASS" then
		self.ClassGroups = {}
		
		for _, vClassID in ipairs(CLASS_SORT_ORDER) do
			self.ClassGroups[vClassID] = GroupCalendar:New(GroupCalendar._PlayerGroup, LOCALIZED_CLASS_NAMES_MALE[vClassID], self.Event, true)
			table.insert(self.Groups, self.ClassGroups[vClassID])
		end
	elseif self.GroupBy == "STATUS" then
		table.insert(self.Groups, self.ConfirmedGroup)
	end
	
	table.insert(self.Groups, self.UnknownGroup)
	table.insert(self.Groups, self.StandbyGroup)
	table.insert(self.Groups, self.LeftGroup)
	table.insert(self.Groups, self.DeclinedGroup)
	table.insert(self.Groups, self.OutGroup)
	
	self:Rebuild()
end

function GroupCalendar.UI._EventGroup:SetSortBy(pSortBy)
	self.SortBy = pSortBy
	self:Rebuild()
end

function GroupCalendar.UI._EventGroup:ScheduleRebuild()
	GroupCalendar.SchedulerLib:ScheduleUniqueTask(0.5, self.Rebuild, self)
end

function GroupCalendar.UI._EventGroup:RefreshMetaTable()
	-- Attach the meta table to each member
	
	GroupCalendar._GroupPlayerMethods.EventGroup = self
	
	local attendance = self.Event:GetAttendance()
	
	if attendance then
		for _, vInfo in pairs(attendance) do
			setmetatable(vInfo, GroupCalendar.GroupPlayerMetaTable)
		end
	end
	
	if self.Event.Group then
		for _, vInfo in pairs(self.Event.Group) do
			setmetatable(vInfo, GroupCalendar.GroupPlayerMetaTable)
		end
	end
end

function GroupCalendar.UI._EventGroup:Rebuild()
	GroupCalendar.SchedulerLib:UnscheduleTask(self.Rebuild, self)
	
	if not self.Event then
		error("No event")
	end
	
	self:RefreshMetaTable()
	
	-- Rebuild the groups
	
	self:BeginRebuildGroups()
	
	local attendance = self.Event:GetAttendance()
	
	if attendance then
		for _, vInfo in pairs(attendance) do
			self:AddGroupPlayer(vInfo)
		end
	end
	
	if GroupCalendar.RunningEvent == self.Event then
		for name, playerInfo in pairs(self.Event.Group) do
			if not attendance or not attendance[name] then
				self:AddGroupPlayer(playerInfo)
			end
		end
	end

	self:EndRebuildGroups()
end

function GroupCalendar.UI._EventGroup:BeginRebuildGroups()
	for _, vGroup in ipairs(self.Groups) do
		vGroup:BeginRebuild()
	end
end

function GroupCalendar.UI._EventGroup:AddGroupPlayer(playerInfo)
	-- Figure out which group to put it in
	
	local inviteStatus = playerInfo:GetInviteStatus()
	local vGroup
	
	-- Players who left the group always go into LeftGroup
	
	if inviteStatus == "LEFT" then
		vGroup = self.LeftGroup
	elseif inviteStatus == "STANDBY" then
		vGroup = self.StandbyGroup
	elseif inviteStatus == CALENDAR_INVITESTATUS_INVITED then
		vGroup = self.InvitedGroup
	elseif inviteStatus == CALENDAR_INVITESTATUS_ACCEPTED
	or inviteStatus == CALENDAR_INVITESTATUS_SIGNEDUP then
		vGroup = self.AcceptedGroup
	elseif inviteStatus == CALENDAR_INVITESTATUS_TENTATIVE then
		vGroup = self.TentativeGroup
	elseif inviteStatus == CALENDAR_INVITESTATUS_STANDBY then
		vGroup = self.StandbyGroup
	elseif inviteStatus == CALENDAR_INVITESTATUS_DECLINED then
		vGroup = self.DeclinedGroup
	elseif inviteStatus == CALENDAR_INVITESTATUS_OUT then
		vGroup = self.OutGroup
	elseif self.ClassGroups then
		vGroup = self.ClassGroups[playerInfo.ClassID] or self.UnknownGroup
	elseif self.RoleGroups then
		local roleCode = (playerInfo and playerInfo.RoleCode) or GroupCalendar:GetPlayerDefaultRoleCode(playerInfo.Name, playerInfo.ClassID)

		vGroup = self.RoleGroups[roleCode] or self.UnknownGroup
	else
		vGroup = self.ConfirmedGroup
	end
	
	vGroup:AddPlayerInfo(playerInfo)
end

function GroupCalendar.UI._EventGroup:EndRebuildGroups()
	for _, vGroup in ipairs(self.Groups) do
		vGroup:EndRebuild()
	end
	
	self:Refresh()
end

function GroupCalendar.UI._EventGroup:Refresh()
	self:RefreshMetaTable()
	
	local vNumItems = 0
	local vAllExpanded = true
	
	for vIndex, vGroup in ipairs(self.Groups) do
		if vGroup:GetNumMembers() > 0 then
			vNumItems = vNumItems + self:GetGroupVisibleItems(vGroup)
			
			if not vGroup.Expanded then
				vAllExpanded = false
			end
		end
	end
	
	self.ScrollingList:SetNumItems(vNumItems)
	
	self.ExpandAll:SetChecked(vAllExpanded)
	
	--
	
	local vNumVisibleItems = self.ScrollingList:GetNumVisibleItems()
	local vItemIndex = 1 - self.ScrollingList:GetOffset()
	
	for vIndex, vGroup in ipairs(self.Groups) do
		if vGroup:GetNumMembers() > 0 then
			vItemIndex = self:AddGroupItem(vGroup, vItemIndex, vNumVisibleItems, 0)
			
			if vItemIndex > vNumVisibleItems then
				break
			end
		end
	end
	
	self.ViewMenu:SetSelectedValue(string.format(GroupCalendar.cViewByFormat, self.GroupByTitle[self.GroupBy], self.SortByTitle[self.SortBy]))
	
	--
	
	
	local vEvent = self.Event.OriginalEvent or self.Event
	
	if GroupCalendar.RunningEvent == self.Event then
		self.StartEventButton:Hide()
		self.StopEventButton:Show()
		self.StartEventHelp:Hide()
		
		self.AutoSelectButton:Show()
		self.AutoSelectHelp:Show()
		self.InviteSelectedButton:Show()
		self.InviteSelectedHelp:Show()
		
		self.SelectAllButton:Show()
	else
		self.StartEventButton:Show()
		self.StopEventButton:Hide()
		self.StartEventHelp:Show()
		
		self.AutoSelectButton:Hide()
		self.AutoSelectHelp:Hide()
		self.InviteSelectedButton:Hide()
		self.InviteSelectedHelp:Hide()
		
		self.SelectAllButton:Hide()
		
		if vEvent.StartDate or vEvent.ElapsedSeconds then
			self.StartEventHelp:SetText(GroupCalendar.cResumeEventHelp)
		else
			self.StartEventHelp:SetText(GroupCalendar.cStartEventHelp)
		end

	end
	
	-- Total up the selected players
	
	local vTotals =
	{
		H = {Confirmed = 0, Standby = 0},
		T = {Confirmed = 0, Standby = 0},
		R = {Confirmed = 0, Standby = 0},
		M = {Confirmed = 0, Standby = 0},
		["?"] = {Confirmed = 0, Standby = 0},
	}
	
	local vNumSelected = 0
	
	if GroupCalendar.RunningEvent == self.Event then
		local attendance = self.Event:GetAttendance()
		
		-- When the event is running the confirmed count is players
		-- who are in the group or invited to the group or selected
		-- and the standby count is all other players who are eligible
		-- to be invited
		
		if attendance then
			for name, playerInfo in pairs(attendance) do
				local inviteStatus = playerInfo:GetInviteStatus()
				local roleCode = (playerInfo and playerInfo.RoleCode) or GroupCalendar:GetPlayerDefaultRoleCode(name, playerInfo.ClassID)
				
				if self.SelectedPlayers[name]
				or inviteStatus == "INVITED"
				or inviteStatus == "JOINED" then
					if self.SelectedPlayers[name] then
						vNumSelected = vNumSelected + 1
					end
					
					if roleCode then
						vTotals[roleCode].Confirmed = vTotals[roleCode].Confirmed + 1
					end
				elseif inviteStatus == CALENDAR_INVITESTATUS_CONFIRMED
				or inviteStatus == CALENDAR_INVITESTATUS_TENTATIVE
				or inviteStatus == CALENDAR_INVITESTATUS_STANDBY
				or inviteStatus == "OFFLINE" then
					if roleCode then
						vTotals[roleCode].Standby = vTotals[roleCode].Standby + 1
					end
				end
			end
		end
		
		for name, playerInfo in pairs(self.Event.Group) do
			if not attendance or not attendance[name] then -- If they're in the main attendance list they've already been processed
				local inviteStatus = playerInfo:GetInviteStatus()
				local roleCode = (playerInfo and playerInfo.RoleCode) or GroupCalendar:GetPlayerDefaultRoleCode(name, playerInfo.ClassID)
				
				if self.SelectedPlayers[name]
				or inviteStatus == "INVITED"
				or inviteStatus == "JOINED" then
					if self.SelectedPlayers[name] then
						vNumSelected = vNumSelected + 1
					end
					
					if roleCode then
						vTotals[roleCode].Confirmed = vTotals[roleCode].Confirmed + 1
					end
				elseif inviteStatus == "OFFLINE" then
					if roleCode then
						vTotals[roleCode].Standby = vTotals[roleCode].Standby + 1
					end
				end
			end
		end
	else
		-- When the event is not running the confirmed count is players who are
		-- confirmed for the event and the standby count is only players are are
		-- on standby for the event
		
		local attendance = self.Event:GetAttendance()
		
		if attendance then
			for name, playerInfo in pairs(attendance) do
				local roleCode = (playerInfo and playerInfo.RoleCode) or GroupCalendar:GetPlayerDefaultRoleCode(name, playerInfo.ClassID)
				
				if roleCode then
					local inviteStatus = playerInfo:GetInviteStatus()
					
					if inviteStatus == CALENDAR_INVITESTATUS_CONFIRMED then
						vTotals[roleCode].Confirmed = vTotals[roleCode].Confirmed + 1
					elseif inviteStatus == CALENDAR_INVITESTATUS_STANDBY
					or inviteStatus == CALENDAR_INVITESTATUS_TENTATIVE then
						vTotals[roleCode].Standby = vTotals[roleCode].Standby + 1
					end
				end
			end
		end
	end
	
	local vTotalConfirmed, vTotalStandby = 0, 0
	
	for roleCode, vRoleTotals in pairs(vTotals) do
		if self.TotalValues[roleCode] then
			if vRoleTotals.Standby > 0 then
				self.TotalValues[roleCode]:SetText(string.format("%d (+%d)", vRoleTotals.Confirmed, vRoleTotals.Standby))
			else
				self.TotalValues[roleCode]:SetText(vRoleTotals.Confirmed)
			end
		end
		
		vTotalConfirmed = vTotalConfirmed + vRoleTotals.Confirmed
		vTotalStandby = vTotalStandby + vRoleTotals.Standby
	end
	
	if vTotalStandby > 0 then
		self.GrandTotalValue:SetText(string.format("%d (+%d)", vTotalConfirmed, vTotalStandby))
	else
		self.GrandTotalValue:SetText(vTotalConfirmed)
	end
	
	-- Update the selection status text
	
	if vNumSelected == 0 then
		self.AutoSelectHelp:SetText(GroupCalendar.cNoSelection)
	elseif vNumSelected == 1 then
		self.AutoSelectHelp:SetText(GroupCalendar.cSingleSelection)
	else
		self.AutoSelectHelp:SetText(string.format(GroupCalendar.cMultiSelection, vNumSelected))
	end
	
	self.SelectAllButton:SetChecked(self:AllSelected())
	
	-- Update the invite status text
	
	local vRaidInviteStatus = self.RaidInviteStatus or "READY"
	
	if vRaidInviteStatus == "READY"
	and vNumSelected == 0 then
		vRaidInviteStatus = "SELECT"
	end
	
	self.InviteSelectedHelp:SetText(GroupCalendar.cInviteStatusMessages[vRaidInviteStatus] or tostring(vRaidInviteStatus))
end

function GroupCalendar.UI._EventGroup:GetGroupVisibleItems(pGroup)
	local vNumItems = 1
	
	if pGroup.Expanded then
		local vNumMembers = pGroup:GetNumMembers()
		
		for vIndex = 1, vNumMembers do
			local memberGroup, memberInfo = pGroup:GetIndexedMember(vIndex)
			
			if memberGroup then
				vNumItems = vNumItems + self:GetGroupVisibleItems(memberGroup)
			else
				vNumItems = vNumItems + 1
			end
		end
	end
	
	return vNumItems
end

function GroupCalendar.UI._EventGroup:PlayerMenuFunc(pItem, pMenu, pMenuID)
	local memberGroup, memberInfo = pItem.Group:GetIndexedMember(pItem.MemberIndex)
	
	if not pMenuID then
		local attendance = self.Event:GetAttendance()
		local attendanceInfo = attendance and attendance[memberInfo.Name]
		local playerInfo = GroupCalendar.RaidLib.PlayersByName[memberInfo.Name]
		local selfPlayerInfo = GroupCalendar.RaidLib.PlayersByName[GroupCalendar.PlayerName]
		local vCanSendInvite = self.Event:CanEdit()
		local vIsGuildEvent = self.Event:IsGuildWide()
		local vIsCreator = memberInfo.Name == self.Event.Creator
		
		pMenu:AddCategoryTitle(memberInfo.Name)
		pMenu:AddFunction(REMOVE, function ()
			self.Event:UninvitePlayer(memberInfo.Name)
		end, not self.Event:CanEdit());

		if attendanceInfo then
			pMenu:AddCategoryTitle(STATUS)
			
			-- Invited status can't be set, so only display it if that's their current status
			if attendanceInfo.InviteStatus == CALENDAR_INVITESTATUS_INVITED then
				pMenu:AddToggle(CALENDAR_STATUS_INVITED, function () return true end, nil, not vCanSendInvite)
			end
			
			if vIsGuildEvent then
				-- Accepted status can't be set, so only display it if that's their current status
				if attendanceInfo.InviteStatus == CALENDAR_INVITESTATUS_ACCEPTED then
					pMenu:AddToggle(CALENDAR_STATUS_ACCEPTED, true, nil, not vCanSendInvite)
				end
				
				-- Signed up status can't be set, so only display it if that's their current status
				if attendanceInfo.InviteStatus == CALENDAR_INVITESTATUS_SIGNEDUP then
					pMenu:AddToggle(CALENDAR_STATUS_SIGNEDUP, true, nil, not vCanSendInvite)
				end
				
				pMenu:AddToggle(
					CALENDAR_STATUS_TENTATIVE,
					function ()
						return attendanceInfo.InviteStatus == CALENDAR_INVITESTATUS_TENTATIVE
					end,
					function ()
						self.Event:SetInviteStatus(memberInfo.Name, CALENDAR_INVITESTATUS_TENTATIVE)
					end,
					not vCanSendInvite)
				
				-- Declined status can't be set, so only display it if that's their current status
				if attendanceInfo.InviteStatus == CALENDAR_INVITESTATUS_DECLINED then
					pMenu:AddToggle(CALENDAR_STATUS_DECLINED, true, nil, not vCanSendInvite)
				end
			else
				pMenu:AddToggle(
					CALENDAR_STATUS_ACCEPTED,
					function ()
						return attendanceInfo.InviteStatus == CALENDAR_INVITESTATUS_ACCEPTED
					end,
					function ()
						self.Event:SetInviteStatus(memberInfo.Name, CALENDAR_INVITESTATUS_ACCEPTED)
					end,
					not vCanSendInvite)
				pMenu:AddToggle(
					CALENDAR_STATUS_TENTATIVE,
					function ()
						return attendanceInfo.InviteStatus == CALENDAR_INVITESTATUS_TENTATIVE
					end,
					function ()
						self.Event:SetInviteStatus(memberInfo.Name, CALENDAR_INVITESTATUS_TENTATIVE)
					end,
					not vCanSendInvite)
				pMenu:AddToggle(
					CALENDAR_STATUS_DECLINED,
					function ()
						return attendanceInfo.InviteStatus == CALENDAR_INVITESTATUS_DECLINED
					end,
					function ()
						self.Event:SetInviteStatus(memberInfo.Name, CALENDAR_INVITESTATUS_DECLINED)
					end,
					not vCanSendInvite)
			end
			
			pMenu:AddToggle(
				CALENDAR_STATUS_CONFIRMED,
				function ()
					return attendanceInfo.InviteStatus == CALENDAR_INVITESTATUS_CONFIRMED
				end,
				function ()
					self.Event:SetInviteStatus(memberInfo.Name, CALENDAR_INVITESTATUS_CONFIRMED)
				end,
				not vCanSendInvite)
			pMenu:AddToggle(
				CALENDAR_STATUS_STANDBY,
				function ()
					return attendanceInfo.InviteStatus == CALENDAR_INVITESTATUS_STANDBY
				end,
				function ()
					self.Event:SetInviteStatus(memberInfo.Name, CALENDAR_INVITESTATUS_STANDBY)
				end,
				not vCanSendInvite)
			pMenu:AddToggle(
				CALENDAR_STATUS_OUT,
				function ()
					return attendanceInfo.InviteStatus == CALENDAR_INVITESTATUS_OUT
				end,
				function ()
					self.Event:SetInviteStatus(memberInfo.Name, CALENDAR_INVITESTATUS_OUT)
				end,
				not vCanSendInvite)
		end
		
		pMenu:AddDivider()

		pMenu:AddToggle(
			CALENDAR_INVITELIST_SETMODERATOR,
			function ()
				return attendanceInfo and (attendanceInfo.ModStatus == "MODERATOR" or attendanceInfo.ModStatus == "CREATOR")
			end,
			function ()
				local attendanceInfo = self.Event:GetAttendance()[memberInfo.Name]
				self.Event:SetModerator(memberInfo.Name, attendanceInfo.ModStatus ~= "MODERATOR")
				self:Refresh()
			end,
			(attendanceInfo and attendanceInfo.ModStatus == "CREATOR") or not vCanSendInvite)
		
		local inRaid = playerInfo ~= nil

		-- Party / raid section
		pMenu:AddCategoryTitle(VOICE_CHAT_PARTY_RAID)

		-- Invite
		pMenu:AddFunction(CALENDAR_INVITELIST_INVITETORAID, function ()
			if not GroupCalendar.RaidInvites then
				self:StartEvent()
			end
			GroupCalendar.RaidInvites:InvitePlayer(memberInfo.Name)
		end, function ()
			return inRaid or selfPlayerInfo.Rank == 0
		end)

		-- Remove
		pMenu:AddFunction(REMOVE, function ()
			UninviteUnit(memberInfo.Name)
		end, function ()
			return not inRaid or selfPlayerInfo.Rank <= playerInfo.Rank
		end)

		-- Promote to leader
		pMenu:AddFunction(PARTY_PROMOTE, function ()
			PromoteToLeader(memberInfo.Name)
		end, function ()
			return not inRaid or playerInfo.Rank == 2 or selfPlayerInfo.Rank ~= 2
		end)

		-- Promote to assistant
		pMenu:AddFunction(SET_RAID_ASSISTANT, function ()
			PromoteToAssistant(memberInfo.Name)
		end, function ()
			return not inRaid or playerInfo.Rank > 0 or selfPlayerInfo.Rank ~= 2
		end)

		-- Demote
		pMenu:AddFunction(DEMOTE, function ()
			DemoteAssistant(memberInfo.Name)
		end, function ()
			return not inRaid or selfPlayerInfo.Rank <= playerInfo.Rank or playerInfo.Rank == 0
		end)

		local vClassID = (attendanceInfo and attendanceInfo.ClassID) or playerInfo.ClassID
		local roleCode = (attendanceInfo and attendanceInfo.RoleCode) or GroupCalendar:GetPlayerDefaultRoleCode(memberInfo.Name, vClassID)
		
		pMenu:AddSingleChoiceGroup(
			"Role",
			{
				{title = GroupCalendar.cHRole, value = "H"},
				{title = GroupCalendar.cTRole, value = "T"},
				{title = GroupCalendar.cRRole, value = "R"},
				{title = GroupCalendar.cMRole, value = "M"}
			},
			-- get
			function ()
				local roleCode = (attendanceInfo and attendanceInfo.RoleCode) or GroupCalendar:GetPlayerDefaultRoleCode(memberInfo.Name, vClassID)
				return roleCode
			end,
			-- set
			function (roleCode)
				if self.Event:GetAttendance()[memberInfo.Name] then
					self.Event:SetInviteRoleCode(memberInfo.Name, roleCode)
				end
				GroupCalendar:SetPlayerDefaultRoleCode(memberInfo.Name, roleCode)
				self:Rebuild()
			end
		)
	end
end

function GroupCalendar.UI._EventGroup:AddGroupItem(pGroup, pFirstItemIndex, pNumVisibleItems, pIndent)
	local vNumMembers = pGroup:GetNumMembers()
	local vItemIndex = pFirstItemIndex
	
	if vItemIndex > 0 then
		local vItemFrame = self.ScrollingList.ItemFrames[vItemIndex]
		
		vItemFrame:SetCategory(
				pGroup:GetColorCode(), pGroup.Title, nil, pGroup:GetInfoText(),
				pGroup.Expanded,
				pIndent,
				function (...) self:ListItemFunc(...) end)
		
		vItemFrame.Group = pGroup
		vItemFrame.MemberIndex = nil
	end
	
	vItemIndex = vItemIndex + 1
	
	if vItemIndex > pNumVisibleItems then
		return vItemIndex
	end
	
	--
	
	if not pGroup.Expanded then
		return vItemIndex
	end
	
	local vMemberIndent = pIndent + 10
	
	for vIndex = 1, vNumMembers do
		local memberGroup, memberInfo = pGroup:GetIndexedMember(vIndex)
		
		if vItemIndex > 0 then
			local vItemFrame = self.ScrollingList.ItemFrames[vItemIndex]
			local vInfoText
			
			if memberInfo.ResponseDate then
				local vDate, vTime = memberInfo.ResponseDate, memberInfo.ResponseTime
				
				if GroupCalendar.Clock.Data.ShowLocalTime then
					vDate, vTime = GroupCalendar.DateLib:GetLocalDateTimeFromServerDateTime(vDate, vTime)
				end
				
				vInfoText = GroupCalendar.DateLib:GetShortDateString(vDate).." "..GroupCalendar.DateLib:GetShortTimeString(vTime)
			end
			
			vItemFrame:SetPlayer(
					self.Event,
					memberInfo, vInfoText,
					self.SelectedPlayers[memberInfo.Name] ~= nil,
					vMemberIndent,
					function (...) self:ListItemFunc(...) end,
					function (...) self:PlayerMenuFunc(...) end)
			
			vItemFrame.Group = pGroup
			vItemFrame.MemberIndex = vIndex
		end
		
		vItemIndex = vItemIndex + 1
		
		if vItemIndex > pNumVisibleItems then
			return vItemIndex
		end
	end
	
	return vItemIndex
end

function GroupCalendar.UI._EventGroup:ViewMenuFunc(menu, menuID)
	menu:AddSingleChoiceGroup(
		-- title
		GroupCalendar.cViewGroupBy,

		-- items
		{
			{title = self.GroupByTitle.ROLE, value = "ROLE"},
			{title = self.GroupByTitle.CLASS, value = "CLASS"},
			{title = self.GroupByTitle.STATUS, value = "STATUS"},
		},

		-- get
		function ()
			return self.GroupBy
		end,

		-- set
		function (value)
			self:SetGroupBy(value)
		end
	)

	menu:AddSingleChoiceGroup(
		-- title
		GroupCalendar.cViewSortBy,

		-- items
		{
			{title = self.SortByTitle.DATE, value = "DATE"},
			{title = self.SortByTitle.RANK, value = "RANK"},
			{title = self.SortByTitle.NAME, value = "NAME"},
		},

		-- get
		function ()
			return self.SortBy
		end,

		-- set
		function (value)
			self:SetSortBy(value)
		end
	)
end

function GroupCalendar.UI._EventGroup:ListItemFunc(pItem, pButton, pPartID)
	local memberGroup, memberInfo
	
	if pItem.MemberIndex then
		memberGroup, memberInfo = pItem.Group:GetIndexedMember(pItem.MemberIndex)
	end
	
	if pButton == "LeftButton" then
		if pPartID == "EXPAND" then
			pItem.Group.Expanded = not pItem.Group.Expanded
			self:Refresh()
		elseif pPartID == "CHECKBOX" then
			if memberInfo.Name then
				if self.SelectedPlayers[memberInfo.Name] then
					self.SelectedPlayers[memberInfo.Name] = nil
				else
					self.SelectedPlayers[memberInfo.Name] = true
				end
				
				self:Refresh()
			end
		elseif pPartID == "ASSIST" then
			local attendanceInfo = self.Event:GetAttendance()[memberInfo.Name]
			
			if not attendanceInfo then
				return
			end
			
			self.Event:SetModerator(memberInfo.Name, attendanceInfo.ModStatus ~= "MODERATOR")
			self:Refresh()
		elseif pPartID == "LEADER" then
			self:Refresh()
		elseif pPartID == "CONFIRM" then
			self.Event:SetInviteStatus(memberInfo.Name, CALENDAR_INVITESTATUS_CONFIRMED)
		elseif pPartID == "STANDBY" then
			self.Event:SetInviteStatus(memberInfo.Name, CALENDAR_INVITESTATUS_STANDBY)
		elseif pPartID == "INVITE" then
			GroupCalendar.RaidInvites:InvitePlayer(memberInfo.Name)
		end
	end
end

----------------------------------------
GroupCalendar.UI._EventGroup._ListItem = {}
----------------------------------------

GroupCalendar.UI._EventGroup._ListItem.cItemHeight = 16

function GroupCalendar.UI._EventGroup._ListItem:New(pParent)
	return CreateFrame("Button", nil, pParent)
end

function GroupCalendar.UI._EventGroup._ListItem:Construct(pParent)
	self:SetHeight(self.cItemHeight)
	
	if not GroupCalendar_ListFont_Tiny then
		GroupCalendar_ListFont_Tiny = CreateFont("GroupCalendar_ListFont_Tiny")
		GroupCalendar_ListFont_Tiny:SetFontObject(SystemFont_Tiny)
		GroupCalendar_ListFont_Tiny:SetTextColor(1, 1, 1)
	end
	
	self.CheckButton = GroupCalendar:New(GroupCalendar.UIElementsLib._CheckButton, self)
	self.CheckButton:SetWidth(self.cItemHeight - 2)
	self.CheckButton:SetHeight(self.cItemHeight - 2)
	self.CheckButton:SetPoint("LEFT", self.ExpandButton, "RIGHT")
	self.CheckButton:SetScript("OnClick", function (pCheckButton, pMouseButton)
		self.SelectionFunc(self, pMouseButton, pCheckButton.DisplayMode)
	end)
	
	self.Menu = GroupCalendar:New(GroupCalendar.UIElementsLib._DropDownMenuButton, self, function (...) if self.MenuFunc then self:MenuFunc(...) end end, self.cItemHeight + 3)
	self.Menu:SetPoint("RIGHT", self, "RIGHT")
	self.Menu.ItemClicked = function (pMenu, pItemID)
		self.SelectionFunc(self, "MENU", pItemID)
	end
	
	--
	
	self.Title = self:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	self.Title:SetPoint("LEFT", self.CheckButton, "RIGHT", 2, 0)
	self.Title:SetJustifyH("LEFT")
	self.Title:SetWordWrap(false)

	self.InfoText = self:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	self.InfoText:SetPoint("RIGHT", self.Menu, "LEFT")
	self.InfoText:SetPoint("BOTTOM", self.Title, "BOTTOM", 0, 1)
	self.InfoText:SetJustifyH("RIGHT")
	self.InfoText:SetWordWrap(false)
	
	self.TitleNote = self:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	self.TitleNote:SetPoint("RIGHT", self.InfoText, "LEFT")
	self.TitleNote:SetPoint("LEFT", self.Title, "RIGHT")
	self.TitleNote:SetPoint("BOTTOM", self.InfoText, "BOTTOM")
	self.TitleNote:SetJustifyH("LEFT")
	self.TitleNote:SetWordWrap(false)
	
	--
	
	self.InviteButton = GroupCalendar:New(GroupCalendar.UIElementsLib._PushButton, self, INVITE, 60)
	self.InviteButton:SetHeight(self.cItemHeight)
	self.InviteButton.Text:SetFontObject(GameFontNormalSmall)
	self.InviteButton:SetPoint("RIGHT", self.Menu, "LEFT", -3, 0)
	self.InviteButton:SetScript("OnClick", function (pButtonFrame, pMouseButton)
		self.SelectionFunc(self, pMouseButton, "INVITE")
	end)
	self.InviteButton:SetScript("OnEnter", function () self:OnEnter() end)
	self.InviteButton:SetScript("OnLeave", function () self:OnLeave() end)
	
	--
	
	self.StandbyButton = GroupCalendar:New(GroupCalendar.UIElementsLib._PushButton, self, GroupCalendar.cStandby, 60)
	self.StandbyButton:SetHeight(self.cItemHeight)
	self.StandbyButton.Text:SetFontObject(GameFontNormalSmall)
	self.StandbyButton:SetPoint("RIGHT", self.InviteButton, "RIGHT")
	self.StandbyButton:SetScript("OnClick", function (pButtonFrame, pMouseButton)
		self.SelectionFunc(self, pMouseButton, "STANDBY")
	end)
	self.StandbyButton:SetScript("OnEnter", function () self:OnEnter() end)
	self.StandbyButton:SetScript("OnLeave", function () self:OnLeave() end)
	
	self.ConfirmButton = GroupCalendar:New(GroupCalendar.UIElementsLib._PushButton, self, GroupCalendar.cConfirm, 60)
	self.ConfirmButton:SetHeight(self.cItemHeight)
	self.ConfirmButton.Text:SetFontObject(GameFontNormalSmall)
	self.ConfirmButton:SetPoint("RIGHT", self.StandbyButton, "LEFT", -3, 0)
	self.ConfirmButton:SetScript("OnClick", function (pButtonFrame, pMouseButton)
		self.SelectionFunc(self, pMouseButton, "CONFIRM")
	end)
	self.ConfirmButton:SetScript("OnEnter", function () self:OnEnter() end)
	self.ConfirmButton:SetScript("OnLeave", function () self:OnLeave() end)
	
	self:SetScript("OnEnter", self.OnEnter)
	self:SetScript("OnLeave", self.OnLeave)
end

function GroupCalendar.UI._EventGroup._ListItem:OnEnter()
	if not self.PlayerInfo then
		return
	end
	
	local vStatus
	
	if GroupCalendar.CALENDAR_INVITESTATUS_NAMES[self.PlayerInfo.InviteStatus] then
		vStatus = GroupCalendar.CALENDAR_INVITESTATUS_COLOR_CODES[self.PlayerInfo.InviteStatus]..GroupCalendar.CALENDAR_INVITESTATUS_NAMES[self.PlayerInfo.InviteStatus]
	else
		vStatus = ""
	end
	
	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	GameTooltip:AddDoubleLine(self.ClassColorCode..self.PlayerInfo.Name, vStatus or "nil")
	GameTooltip:AddDoubleLine(string.format(TOOLTIP_UNIT_LEVEL_CLASS,
			self.PlayerInfo.Level and self.PlayerInfo.Level or "?",
			self.PlayerInfo.ClassID and GroupCalendar.cClassName[self.PlayerInfo.ClassID] and GroupCalendar.cClassName[self.PlayerInfo.ClassID].Male or UNKNOWN),
			self.PlayerRoleCode and GroupCalendar.RoleInfoByID[self.PlayerRoleCode].Name or "")
	
	if self.PlayerInfoText then
		GameTooltip:AddLine("")
		GameTooltip:AddLine(string.format(GroupCalendar.cRespondedDateFormat, self.PlayerInfoText))
	end
	
	GameTooltip:Show()
end

function GroupCalendar.UI._EventGroup._ListItem:OnLeave()
	if not self.PlayerInfo then
		return
	end
	
	GameTooltip:Hide()
end

function GroupCalendar.UI._EventGroup._ListItem:FormatTitle(pColorCode, pTitle, pTitleNote)
	return (pColorCode or "")..pTitle..(pTitleNote and string.format(" (%s)", pTitleNote) or "")
end

function GroupCalendar.UI._EventGroup._ListItem:SetCategory(pColorCode, pTitle, pTitleNote, pInfoText, pExpanded, pIndent, pSelectionFunc)
	self.PlayerInfo = nil
	self.PlayerInfoText = nil
	self.Event = nil
	
	self.CheckButton:ClearAllPoints()
	self.CheckButton:SetPoint("LEFT", self, "LEFT", pIndent or 0, 0)
	self.CheckButton:SetDisplayMode("EXPAND")
	self.CheckButton:SetChecked(pExpanded)
	self.CheckButton:SetEnabled(true)
	self.CheckButton:Show()
	
	self.Title:SetFontObject(GameFontNormal)
	self.TitleNote:SetFontObject(GameFontNormalSmal)
	self.InfoText:SetFontObject(GameFontNormal)
	self.InfoText:SetPoint("BOTTOM", self.Title, "BOTTOM")

	self.Title:SetText((pColorCode or "")..pTitle)
	self.TitleNote:SetText(pTitleNote and string.format(" (%s)", pTitleNote) or "")
	
	self.InviteButton:Hide()
	self.ConfirmButton:Hide()
	self.StandbyButton:Hide()
	self.Menu:Hide()
	
	self.InfoText:SetPoint("RIGHT", self, "RIGHT")
	self.InfoText:SetText((pColorCode or "")..(pInfoText or ""))
	
	self.SelectionFunc = pSelectionFunc
end

function GroupCalendar.UI._EventGroup._ListItem:SetPlayer(
			pEvent,
			playerInfo, pInfoText,
			pSelected,
			pIndent,
			pSelectionFunc,
			pMenuFunc)
	
	self.PlayerInfo = playerInfo
	self.PlayerInfoText = pInfoText
	self.Event = pEvent
	
	self.CheckButton:ClearAllPoints()
	self.CheckButton:SetPoint("LEFT", self, "LEFT", pIndent or 0, 0)
	
	self.Title:SetFontObject(GameFontNormal)
	self.TitleNote:SetFontObject(GroupCalendar_ListFont_Tiny)
	self.InfoText:SetFontObject(GroupCalendar_ListFont_Tiny)
	self.InfoText:SetPoint("BOTTOM", self.Title, "BOTTOM", 0, 1)
	
	self.CheckButton:SetChecked(pSelected)
	
	local vEventIsRunning = GroupCalendar.RunningEvent == pEvent
	
	if not vEventIsRunning then
		if playerInfo.ModStatus == "CREATOR" then
			self.CheckButton:SetDisplayMode("LEADER")
			self.CheckButton:SetChecked(true)
			
		elseif playerInfo.ModStatus == "MODERATOR" then
			self.CheckButton:SetDisplayMode("ASSIST")
			self.CheckButton:SetChecked(true)
		
		else
			self.CheckButton:SetDisplayMode("ASSIST")
			self.CheckButton:SetChecked(false)
		end
		
		local attendanceInfo = self.Event:GetAttendance()[GroupCalendar.PlayerName] -- Use the current player's name to determine enabling
		
		self.CheckButton:SetEnabled(attendanceInfo and (attendanceInfo.ModStatus == "CREATOR" or attendanceInfo.ModStatus == "MODERATOR"))
		self.CheckButton:Show()
	elseif pEvent.Group
	and pEvent.Group[playerInfo.Name]
	and not pEvent.Group[playerInfo.Name].LeftGroup then
		self.CheckButton:Hide()
	
	else
		self.CheckButton:SetDisplayMode("CHECKBOX")
		self.CheckButton:SetEnabled(true)
		self.CheckButton:Show()
	end
	
	--
	
	local vRosterInfo = GroupCalendar.GuildLib.Roster.Players[playerInfo.Name]
	local vOfflineGuildMember = vEventIsRunning and vRosterInfo and vRosterInfo.Offline
	
	self.ClassColorCode = (not vOfflineGuildMember and playerInfo.ClassID and GroupCalendar.RAID_CLASS_COLOR_CODES[playerInfo.ClassID]) or "|cff888888"
	
	local attendance = pEvent:GetAttendance()
	local attendanceInfo = attendance and attendance[playerInfo.Name]
	
	local vClassID = (attendanceInfo and attendanceInfo.ClassID) or playerInfo.ClassID
	self.PlayerRoleCode = (attendanceInfo and attendanceInfo.RoleCode) or GroupCalendar:GetPlayerDefaultRoleCode(playerInfo.Name, vClassID)
	local vRoleInfo = GroupCalendar.RoleInfoByID[self.PlayerRoleCode]
	
	local inviteStatus = playerInfo:GetInviteStatus()
	
	local vTitleNote
	
	if inviteStatus == CALENDAR_INVITESTATUS_INVITED
	or inviteStatus == CALENDAR_INVITESTATUS_ACCEPTED
	or inviteStatus == CALENDAR_INVITESTATUS_TENTATIVE
	or inviteStatus == CALENDAR_INVITESTATUS_DECLINED
	or inviteStatus == CALENDAR_INVITESTATUS_SIGNEDUP
	or inviteStatus == CALENDAR_INVITESTATUS_OUT then
		vTitleNote = tostring(vRoleInfo and (vRoleInfo.ColorCode..vRoleInfo.Name))
	elseif inviteStatus == CALENDAR_INVITESTATUS_CONFIRMED then
		vTitleNote = GroupCalendar.cInviteStatusText.CONFIRMED
	elseif inviteStatus == CALENDAR_INVITESTATUS_STANDBY then
		vTitleNote = GroupCalendar.cInviteStatusText.STANDBY
	else
		vTitleNote = GroupCalendar.cInviteStatusText[inviteStatus]
		
		if not vTitleNote then vTitleNote = tostring(inviteStatus).."?" end
	end
	
	vTitleNote = string.format("%s%s, %s %s", vTitleNote, self.ClassColorCode, playerInfo.Level or "", GroupCalendar.cClassName[vClassID] and GroupCalendar.cClassName[vClassID].Male or "")
	
	--
	
	self.Title:SetText((self.ClassColorCode or "")..playerInfo.Name)
	self.TitleNote:SetText(vTitleNote and (" "..vTitleNote) or "")
	
	self.MenuFunc = pMenuFunc
	
	if self.MenuFunc then
		self.Menu:Show()
	else
		self.Menu:Hide()
	end
	
	local vActualInviteStatus = pEvent:GetAttendance()[playerInfo.Name] and pEvent:GetAttendance()[playerInfo.Name].InviteStatus
	
	self.NeedsConfirm = pEvent:CanEdit()
	                  and (vActualInviteStatus == CALENDAR_INVITESTATUS_ACCEPTED
	                    or vActualInviteStatus == CALENDAR_INVITESTATUS_TENTATIVE
	                    or vActualInviteStatus == CALENDAR_INVITESTATUS_SIGNEDUP)
	
	local vIsConfirmedOrStandby = vActualInviteStatus == CALENDAR_INVITESTATUS_CONFIRMED
	                           or vActualInviteStatus == CALENDAR_INVITESTATUS_STANDBY
	
	if self.NeedsConfirm then
		self.InviteButton:Hide()
		self.ConfirmButton:Show()
		self.StandbyButton:Show()
		self.InfoText:SetPoint("RIGHT", self.ConfirmButton, "LEFT")
		self.InfoText:SetText("")
	else
		local selfPlayerInfo = GroupCalendar.RaidLib.PlayersByName[GroupCalendar.PlayerName]
		
		if vIsConfirmedOrStandby
		and GroupCalendar.RunningEvent == pEvent
		and not GroupCalendar.RaidLib.PlayersByName[playerInfo.Name]
		and selfPlayerInfo.Rank > 0 then
			self.InviteButton:Show()
			self.InfoText:SetPoint("RIGHT", self.InviteButton, "LEFT")
		else
			self.InviteButton:Hide()
			self.InfoText:SetPoint("RIGHT", self.Menu, "LEFT")
		end
		
		self.ConfirmButton:Hide()
		self.StandbyButton:Hide()
		
		self.InfoText:SetText((self.ClassColorCode or "")..(self.PlayerInfoText or ""))
	end
	
	self.SelectionFunc = pSelectionFunc
end

----------------------------------------
GroupCalendar._PlayerGroup = {}
----------------------------------------

function GroupCalendar._PlayerGroup:Construct(pTitle, pEvent, pExpanded)
	self.Title = pTitle
	self.Event = pEvent
	self.Expanded = pExpanded
	
	self.Members = {}
end

function GroupCalendar._PlayerGroup:BeginRebuild()
	for vKey, _ in pairs(self.Members) do
		self.Members[vKey] = nil
	end
end

function GroupCalendar._PlayerGroup:AddPlayerInfo(playerInfo)
	table.insert(self.Members, playerInfo)
end

function GroupCalendar._PlayerGroup:EndRebuild()
	table.sort(self.Members, GroupCalendar._GroupPlayerMethods.LessThanByStatus)
end

function GroupCalendar._PlayerGroup:GetColorCode()
	return nil
end

function GroupCalendar._PlayerGroup:GetInfoText()
	if #self.Members == 0 then
		return GroupCalendar.cNone
	else
		return string.format(GroupCalendar.cPartySizeFormat, #self.Members)
	end
end

function GroupCalendar._PlayerGroup:GetNumMembers()
	return #self.Members
end

function GroupCalendar._PlayerGroup:GetIndexedMember(pIndex)
	return nil, self.Members[pIndex]
end

----------------------------------------
GroupCalendar._StatusGroup = {}
----------------------------------------

function GroupCalendar._StatusGroup:Construct(pTitle, pEvent, pStatus, pExpanded)
	self.Title = pTitle
	self.Event = pEvent
	self.Status = pStatus
	self.Expanded = pExpanded
	
	if self.Status == CALENDAR_INVITESTATUS_ACCEPTED then
		self.Status2 = CALENDAR_INVITESTATUS_SIGNEDUP
	end
	
	self.Members = {}
end

function GroupCalendar._StatusGroup:Rebuild()
	for vKey, _ in pairs(self.Members) do
		self.Members[vKey] = nil
	end
	
	local attendance = self.Event:GetAttendance()
	
	if not attendance then
		return
	end
	
	for _, vInfo in pairs(attendance) do
		local inviteStatus, vInviteStatus2 = vInfo.InviteStatus, vInfo:GetInviteStatus()
		
		if (inviteStatus == self.Status
		or vInviteStatus2 == self.Status
		or inviteStatus == self.Status2
		or vInviteStatus2 == self.Status2)
		and not vInfo:IsGroupMember() then
			table.insert(self.Members, vInfo)
		end
	end
	
	if GroupCalendar.RunningEvent == self.Event then
		for name, playerInfo in pairs(self.Event.Group) do
			local inviteStatus, vInviteStatus2 = playerInfo.InviteStatus, playerInfo:GetInviteStatus()
			
			if not attendance[name]
			and (inviteStatus == self.Status
			or vInviteStatus2 == self.Status
			or inviteStatus == self.Status2
			or vInviteStatus2 == self.Status2)
			and not playerInfo:IsGroupMember() then
				table.insert(self.Members, playerInfo)
			end
		end
	end
	
	table.sort(self.Members, GroupCalendar._GroupPlayerMethods.LessThanByStatus)
end

function GroupCalendar._StatusGroup:GetColorCode()
	return nil
end

function GroupCalendar._StatusGroup:GetInfoText()
	if #self.Members == 0 then
		return "none"
	else
		return string.format("%s players", #self.Members)
	end
end

function GroupCalendar._StatusGroup:GetNumMembers()
	return #self.Members
end

function GroupCalendar._StatusGroup:GetIndexedMember(pIndex)
	return nil, self.Members[pIndex]
end

----------------------------------------
GroupCalendar._ClassGroup = {}
----------------------------------------

function GroupCalendar._ClassGroup:Construct(pTitle, pEvent, pClassID)
	self.Title = pTitle
	self.Event = pEvent
	self.ClassID = pClassID
	
	self.Members = {}
	
	self.Expanded = true

	self.ClassColor = RAID_CLASS_COLORS[self.ClassID]
	self.ColorCode = GroupCalendar.RAID_CLASS_COLOR_CODES[self.ClassID]
end

function GroupCalendar._ClassGroup:Rebuild()
	for vKey, _ in pairs(self.Members) do
		self.Members[vKey] = nil
	end
	
	self.NumConfirmed = 0
	self.NumStandby = 0
	self.NumJoined = 0
	
	local attendance = self.Event:GetAttendance()
	
	if not attendance then
		return
	end
	
	for _, vInfo in pairs(attendance) do
		local inviteStatus = vInfo:GetInviteStatus()
		
		if vInfo.ClassID == self.ClassID
		and vInfo:IsGroupMember() then
			if inviteStatus == CALENDAR_INVITESTATUS_CONFIRMED
			or inviteStatus == "INVITED"
			or inviteStatus == "JOINED" then
				self.NumConfirmed = self.NumConfirmed + 1
			else
				self.NumStandby = self.NumStandby + 1
			end
			
			table.insert(self.Members, vInfo)
		end
	end
	
	if GroupCalendar.RunningEvent == self.Event then
		for name, playerInfo in pairs(self.Event.Group) do
			if playerInfo.ClassID == self.ClassID then
				if GroupCalendar.RaidLib.PlayersByName[name] then
					self.NumJoined = self.NumJoined + 1
				end
				
				if not attendance[name] then
					self.NumConfirmed = self.NumConfirmed + 1
					
					table.insert(self.Members, playerInfo)
				end
			end
		end
	end
	
	table.sort(self.Members, GroupCalendar._GroupPlayerMethods.LessThanByStatus)
end

function GroupCalendar._ClassGroup:GetColorCode()
	return self.ColorCode
end

function GroupCalendar._ClassGroup:GetInfoText()
	if self.NumJoined > 0 then
		return string.format("%s joined", self.NumJoined)
	elseif self.NumConfirmed == 0 and self.NumStandby == 0 then
		return "none"
	elseif self.NumStandby == 0 then
		return string.format("%s confirmed", self.NumConfirmed)
	else
		return string.format("%s confirmed, %s standby", self.NumConfirmed, self.NumStandby)
	end
end

function GroupCalendar._ClassGroup:GetNumMembers()
	return #self.Members
end

function GroupCalendar._ClassGroup:GetIndexedMember(pIndex)
	return nil, self.Members[pIndex]
end

----------------------------------------
GroupCalendar._RoleGroup = {}
----------------------------------------

function GroupCalendar._RoleGroup:Construct(pTitle, pEvent, pRoleCode)
	self.Title = pTitle
	self.Event = pEvent
	self.RoleCode = pRoleCode
	
	self.Members = {}

	self.Expanded = true
end

function GroupCalendar._RoleGroup:Rebuild()
	while self.Members[1] do
		table.remove(self.Members)
	end
	
	self.NumConfirmed = 0
	self.NumStandby = 0
	self.NumJoined = 0
	
	local attendance = self.Event:GetAttendance()
	
	if not attendance then
		return
	end
	
	for _, vInfo in pairs(attendance) do
		local inviteStatus = vInfo:GetInviteStatus()
		
		if vInfo.RoleCode == self.RoleCode
		and vInfo:IsGroupMember() then
			if vInfo:IsConfirmedMember() then
				self.NumConfirmed = self.NumConfirmed + 1
			else
				self.NumStandby = self.NumStandby + 1
			end
			
			table.insert(self.Members, vInfo)
		end
	end
	
	if GroupCalendar.RunningEvent == self.Event then
		for name, playerInfo in pairs(self.Event.Group) do
			local roleCode = GroupCalendar:GetPlayerDefaultRoleCode(name, playerInfo.ClassID)
			
			if roleCode == self.RoleCode then
				if GroupCalendar.RaidLib.PlayersByName[name] then
					self.NumJoined = self.NumJoined + 1
				end
				
				if not attendance[name]
				and playerInfo:IsGroupMember() then
					self.NumConfirmed = self.NumConfirmed + 1
					
					table.insert(self.Members, playerInfo)
				end
			end
		end
	end
	
	table.sort(self.Members, GroupCalendar._GroupPlayerMethods.LessThanByStatus)
end

function GroupCalendar._RoleGroup:GetColorCode()
	return nil
end

function GroupCalendar._RoleGroup:GetInfoText()
	if self.NumJoined > 0 then
		return string.format("%s joined", self.NumJoined)
	elseif self.NumConfirmed == 0 and self.NumStandby == 0 then
		return "none"
	elseif self.NumStandby == 0 then
		return string.format("%s confirmed", self.NumConfirmed)
	else
		return string.format("%s confirmed, %s standby", self.NumConfirmed, self.NumStandby)
	end
end

function GroupCalendar._RoleGroup:GetNumMembers()
	return #self.Members
end

function GroupCalendar._RoleGroup:GetIndexedMember(pIndex)
	return nil, self.Members[pIndex]
end

----------------------------------------
GroupCalendar._GroupPlayerMethods = {}
----------------------------------------

function GroupCalendar._GroupPlayerMethods:IsGroupMember()
	local inviteStatus = self:GetInviteStatus()
	
	return self.InviteStatus == CALENDAR_INVITESTATUS_CONFIRMED
	    or self.InviteStatus == CALENDAR_INVITESTATUS_STANDBY
	    or inviteStatus == "INVITED"
	    or inviteStatus == "JOINED"
end

function GroupCalendar._GroupPlayerMethods:IsConfirmedMember()
	local inviteStatus = self:GetInviteStatus()
	
	return inviteStatus == CALENDAR_INVITESTATUS_CONFIRMED
	    or inviteStatus == "INVITED"
	    or inviteStatus == "JOINED"
	    or inviteStatus == "OFFLINE"
end

function GroupCalendar._GroupPlayerMethods:GetInviteStatus()
	-- The status is generated based on several items: the invitation (attendance), the raid record,
	-- and the invite engine data.
	
	if GroupCalendar.RunningEvent == self.EventGroup.Event then
		-- If the player is currently in the group then the status is always "JOINED"
		
		local playerGroupInfo = self.EventGroup.Event.Group and self.EventGroup.Event.Group[self.Name]
		
		if playerGroupInfo then
			if playerGroupInfo.LeftGroup then
				return "LEFT"
			else
				return "JOINED"
			end
		end
		
		if self.LeftGroup then
			return "LEFT"
		end
		
		-- If they are invited, then determine the status from the invitation data
		
		local attendanceInfo = self.EventGroup.Event:GetAttendance()[self.Name]
		
		if attendanceInfo then
			return attendanceInfo.RaidInviteStatus or attendanceInfo.InviteStatus
		end
		
		-- Otherwise they were never invited but joined and then left the group, so use "LEFT" for their status
		
		return "LEFT"
	else
		-- If they are invited, then determine the status from the invitation data
		
		local attendanceInfo = self.EventGroup.Event:GetAttendance()[self.Name]
		
		if attendanceInfo then
			return attendanceInfo.InviteStatus or attendanceInfo.RaidInviteStatus
		end
		
		-- If the player is currently in the group then the status is always "JOINED"
		
		local playerGroupInfo = self.EventGroup.Event.Group and self.EventGroup.Event.Group[self.Name]
		
		if playerGroupInfo then
			if playerGroupInfo.LeftGroup then
				return "LEFT"
			else
				return "JOINED"
			end
		end
		
		-- Otherwise they were never invited but joined and then left the group, so use "LEFT" for their status
		
		return "LEFT"
	end
end

GroupCalendar._GroupPlayerMethods.InviteStatusSortOrder =
{
	[CALENDAR_INVITESTATUS_INVITED] = 1,
	[CALENDAR_INVITESTATUS_ACCEPTED] = 2,
	[CALENDAR_INVITESTATUS_SIGNEDUP] = 3,
	[CALENDAR_INVITESTATUS_TENTATIVE] = 4,
	JOINED = 5,
	INVITED = 6,
	[CALENDAR_INVITESTATUS_CONFIRMED] = 7,
	[CALENDAR_INVITESTATUS_STANDBY] = 8,
	BUSY = 9,
	DECLINED = 10,
	OFFLINE = 11,
	LEFT = 12,
	[CALENDAR_INVITESTATUS_OUT] = 13,
	[CALENDAR_INVITESTATUS_DECLINED] = 14,
}

function GroupCalendar._GroupPlayerMethods:LessThanByStatus(playerInfo)
	local priority1 = self.InviteStatusSortOrder[self:GetInviteStatus()]
	local priority2 = self.InviteStatusSortOrder[playerInfo:GetInviteStatus()]
	
	if priority1 ~= priority2 then
		if not priority1 then
			return false
		elseif not priority2 then
			return true
		elseif priority1 < priority2 then
			return true
		else
			return false
		end
	end -- if
	
	return self:LessThanByDate(playerInfo)
end

function GroupCalendar._GroupPlayerMethods:LessThanByDate(playerInfo)
	local result, vEqual = GroupCalendar.DateLib:CompareDateTime(self.ResponseDate, self.ResponseTime, playerInfo.ResponseDate, playerInfo.ResponseTime)
	
	if not vEqual then
		return result
	else
		return self.Name < playerInfo.Name
	end
end

GroupCalendar.GroupPlayerMetaTable = {__index = GroupCalendar._GroupPlayerMethods}
