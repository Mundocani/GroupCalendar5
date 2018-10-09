----------------------------------------
-- Group Calendar 5 Copyright (c) 2018 John Stephen
-- This software is licensed under the MIT license.
-- See the included LICENSE.txt file for more information.
----------------------------------------

----------------------------------------
GroupCalendar.UI._EventInvite = {}
----------------------------------------

function GroupCalendar.UI._EventInvite:New(pParentFrame)
	return CreateFrame("Frame", nil, pParentFrame)
end

function GroupCalendar.UI._EventInvite:Construct(pParentFrame)
	self:SetAllPoints()
	
	--
	
	self.ItemFrames = {}
	
	--
	
	self.CharacterName = GroupCalendar:New(GroupCalendar.UIElementsLib._EditBox, self, nil, 40, 140)
	self.CharacterName:SetPoint("TOPLEFT", self, "TOPLEFT", 100, -30)
	self.CharacterName:SetEmptyText(CALENDAR_PLAYER_NAME)
	self.CharacterName:SetAutoCompleteFunc(function () self:AutoCompleteName() end)
	self.CharacterName:SetScript("OnEnterPressed", function ()
		self.Event:InvitePlayer(strtrim(self.CharacterName:GetText()))
		self.CharacterName:HighlightText()
	end)
	
	self.InviteButton = GroupCalendar:New(GroupCalendar.UIElementsLib._PushButton, self, INVITE)
	self.InviteButton:SetPoint("LEFT", self.CharacterName, "RIGHT")
	self.InviteButton:SetScript("OnClick", function ()
		self.Event:InvitePlayer(strtrim(self.CharacterName:GetText()))
		self.CharacterName:HighlightText()
	end)
	
	-- Status section
	
	self.StatusSection = CreateFrame("Frame", nil, self)
	self.StatusSection:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -9, 32)
	self.StatusSection:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, 32)
	self.StatusSection:SetHeight(30)
	self.StatusSection.Background = GroupCalendar:New(GroupCalendar.UIElementsLib._StretchTextures, GroupCalendar.UIElementsLib._PanelSectionBackgroundInfo, self.StatusSection, "BACKGROUND")
	
	self.AbortButton = GroupCalendar:New(GroupCalendar.UIElementsLib._PushButton, self.StatusSection, "Abort")
	self.AbortButton:SetPoint("RIGHT", self.StatusSection, "RIGHT", -8, 0)
	self.AbortButton:SetScript("OnClick", function ()
		self.Event:CancelPendingInvites()
	end)
	self.AbortButton:Hide()
	
	self.InviteProgress = self.StatusSection:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	self.InviteProgress:SetPoint("LEFT", self.StatusSection, "LEFT", 6, 0)
	self.InviteProgress:SetPoint("RIGHT", self.AbortButton, "LEFT", -5, 0)
	self.InviteProgress:SetWidth(250)
	self.InviteProgress:Hide()
	
	-- Scrolling list
	
	self.ScrollingList = GroupCalendar:New(GroupCalendar.UIElementsLib._ScrollingItemList, self, self._ListItem, self._ListItem.cItemHeight)
	self.ScrollingList.DrawingFunc = function () self:Refresh() end
	
	self.ScrollingList:SetPoint("TOPLEFT", self, "TOPLEFT", 10, -62)
	self.ScrollingList:SetPoint("BOTTOMRIGHT", self.StatusSection, "TOPRIGHT", 0, 0)
	
	--
	
	self.FriendsInviteGroup = GroupCalendar:New(GroupCalendar._FriendsInviteGroup)
	self.CurrentPartyInviteGroup = GroupCalendar:New(GroupCalendar._CurrentPartyGroup)
	
	self.ExpandAll = GroupCalendar:New(GroupCalendar.UIElementsLib._ExpandAllButton, self)
	self.ExpandAll:SetPoint("TOPLEFT", self.ScrollingList, "TOPLEFT", 5, 25)
	self.ExpandAll:SetScript("OnClick", function (pButton)
		self:SetExpandAll(not not pButton:GetChecked()) -- I don't like using 'not not', but it's the easiest way to force a boolean value :/
	end)
	
	self:SetScript("OnShow", self.OnShow)
	self:SetScript("OnHide", self.OnHide)
end

function GroupCalendar.UI._EventInvite:AutoCompleteName()
	local vText = self.CharacterName:GetText()
	local vPosition = self.CharacterName:GetUTF8CursorPosition()
	
	local vName = GetAutoCompleteResults(
	                       vText, 
	                       bit.bor(AUTOCOMPLETE_FLAG_FRIEND, AUTOCOMPLETE_FLAG_IN_GUILD, AUTOCOMPLETE_FLAG_IN_GROUP),
	                       AUTOCOMPLETE_FLAG_NONE,
	                       1, vPosition)
	
	if not vName then
		return
	end
	
	GroupCalendar:SetEditBoxAutoCompleteText(self.CharacterName, vName)
end

function GroupCalendar.UI._EventInvite:SetEvent(pEvent, pIsNewEvent)
	GroupCalendar.BroadcastLib:StopListening(nil, self.EventMessage, self)
	
	self.Event = pEvent
	self.IsNewEvent = pIsNewEvent
	
	if not self.Event then
		return
	end
	
	GroupCalendar.BroadcastLib:Listen(self.Event, self.EventMessage, self)
end

function GroupCalendar.UI._EventInvite:EventMessage(pEvent, pMessageID, ...)
	if pMessageID == "INVITES_CHANGED" then
		self:Rebuild()
	elseif pMessageID == "INVITE_QUEUE_BEGIN" then
		self.AbortButton:Show()
		self.InviteProgress:Show()
		self.InviteProgress:SetText("")
	elseif pMessageID == "INVITE_QUEUE_UPDATE" then
		local vMessage = select(1, ...)
		local vRemaining = self.Event:GetDesiredAttendanceCount()
		
		self.InviteProgress:SetText(string.format("%s (%s remaining)", vMessage, vRemaining))
		
	elseif pMessageID == "INVITE_QUEUE_END" then
		self.AbortButton:Hide()
		self.InviteProgress:Hide()
		
		self:Rebuild()
	end
end

function GroupCalendar.UI._EventInvite:OnShow()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN)
	
	self.InviteButton:Show()
	self.CharacterName:Show()
	self.AbortButton:Hide()
	self.InviteProgress:Hide()
	
	self:Rebuild(true)
	
	self.CharacterName:SetFocus()
end

function GroupCalendar.UI._EventInvite:OnHide()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE)
end

function GroupCalendar.UI._EventInvite:SaveEventFields()
	-- Nothing to do, event is updated as the user manipulates it
end

function GroupCalendar.UI._EventInvite:Rebuild(pRebuildInviteGroups)
	if not self.InviteGroups or pRebuildInviteGroups then
		self.InviteGroups = {}
		table.insert(self.InviteGroups, self.CurrentPartyInviteGroup)
		
		-- Add the player's guild if they're in a guild and this isn't a guild-wide event
		
		if IsInGuild() then
			table.insert(self.InviteGroups, GroupCalendar:New(GroupCalendar._GuildInviteGroup, GroupCalendar.GuildLib.Roster, true))
		end
		
		for vGuildName, vGuildRoster in pairs(GroupCalendar.RealmData.Guilds) do
			if vGuildName ~= GroupCalendar.PlayerGuild then
				table.insert(self.InviteGroups, GroupCalendar:New(GroupCalendar._GuildInviteGroup, vGuildRoster, false))
			end
		end
		
		table.insert(self.InviteGroups, self.FriendsInviteGroup)
--		for vTeamIndex = 1, 3 do
--			if GetArenaTeam(vTeamIndex) then
--				table.insert(self.InviteGroups, GroupCalendar:New(GroupCalendar._ArenaInviteGroup, vTeamIndex))
--			end
--		end
		
		table.insert(self.InviteGroups, GroupCalendar:New(GroupCalendar._OthersInviteGroup, self.Event, self.InviteGroups))
	else
		for _, vGroup in ipairs(self.InviteGroups) do
			vGroup:Rebuild()
		end
	end
	
	self:Refresh()
end

function GroupCalendar.UI._EventInvite:SetExpandAll(pExpandAll)
	assert(type(pExpandAll) == "boolean")
	
	for vIndex, vGroup in ipairs(self.InviteGroups) do
		if vGroup:GetNumMembers() > 0 then
			vGroup.Expanded = pExpandAll
		end
	end
	
	self:Refresh()
end

function GroupCalendar.UI._EventInvite:GroupIsSelected(pGroup)
	if self.Event.CalendarType == "GUILD_EVENT"
	and pGroup.Roster == GroupCalendar.GuildLib.Roster then
		return true, true, pGroup:GetNumMembers(), false, false, false
	end
	
	if not self.Event.Attendance
	and not self.Event.DesiredAttendance then
		return false
	end
	
	local vNumMembers = pGroup:GetNumMembers()
	local vSelected, vAllSelected, vPending, vHasModerators, vAllModerators = false, true, false, false, true
	local vNumSelected = 0
	
	for vIndex = 1, vNumMembers do
		local vMemberGroup, vMemberInfo = pGroup:GetIndexedMember(vIndex)
		
		if vMemberGroup then
			local vGroupSelected, vGroupAllSelected, vGroupNumSelected, vGroupPending, vGroupHasModerators, vGroupAllModerators = self:GroupIsSelected(vMemberGroup)
			
			if vGroupSelected then
				vSelected = true
			end
			
			if not vGroupAllSelected then
				vAllSelected = false
			end
			
			if vGroupPending then
				vPending = true
			end
			
			if vGroupHasModerators then
				vHasModerators = true
			end
			
			if not vGroupAllModerators then
				vAllModerators = false
			end
			
			vNumSelected = vNumSelected + vGroupNumSelected
		else
			local vPlayerInvite = self.Event:GetPlayerInvite(vMemberInfo.Name)
			
			if vPlayerInvite then
				vSelected = true
				
				if self.Event:PlayerInviteIsPending(vMemberInfo.Name) then
					vPending = true
				end
				
				if vPlayerInvite.ModStatus == "MODERATOR" then
					vHasModerators = true
				elseif vPlayerInvite.ModStatus ~= "CREATOR" then
					vAllModerators = false
				end
				
				vNumSelected = vNumSelected + 1
			elseif self:LevelIsOK(vMemberInfo.Level) then
				vAllSelected = false
			end
		end
	end
	
	return vSelected, vAllSelected, vNumSelected, vPending, vHasModerators, vAllModerators
end

function GroupCalendar.UI._EventInvite:AddGroupItem(pGroup, pFirstItemIndex, pNumVisibleItems, pIndent)
	local vNumMembers = pGroup:GetNumMembers()
	local vItemIndex = pFirstItemIndex
	
	if vItemIndex > 0 then
		local vItemFrame = self.ScrollingList.ItemFrames[vItemIndex]
		local vSelected, vAllSelected, vNumSelected, vPending, vHasModerators, vAllModerators = self:GroupIsSelected(pGroup)
		local vInfoText
		
		if vNumSelected and vNumSelected > 0 then
			vInfoText = string.format("%s selected", vNumSelected)
		else
			vInfoText = ""
		end
		
		vItemFrame:SetInvite(
				vSelected, vAllSelected, vPending,
				nil, pGroup.Title, vInfoText,
				vHasModerators and ((vAllModerators and "MODERATOR") or "MODERATOR_MULTI"),
				pGroup.Expanded, pIndent,
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
	
	local vMemberIndent = pIndent + 23
	
	for vIndex = 1, vNumMembers do
		local vMemberGroup, vMemberInfo = pGroup:GetIndexedMember(vIndex)
		
		if vMemberGroup then
			if vMemberGroup:GetNumMembers() > 0 then
				vItemIndex = self:AddGroupItem(vMemberGroup, vItemIndex, pNumVisibleItems, vMemberIndent)
				
				if vItemIndex > pNumVisibleItems then
					return vItemIndex
				end
			end
		else
			if vItemIndex > 0 then
				local vItemFrame = self.ScrollingList.ItemFrames[vItemIndex]
				local vClassID = vMemberInfo.ClassID
				local vLevel = vMemberInfo.Level
				
				local vAttendance = self.Event:GetAttendance()
				local vPlayerInfo = vAttendance and vAttendance[vMemberInfo.Name]
				
				if vPlayerInfo and vPlayerInfo ~= vMemberInfo then
					vClassID = vPlayerInfo.ClassID
					vLevel = vPlayerInfo.Level
				end
				
				local vColorCode = GroupCalendar.RAID_CLASS_COLOR_CODES[vClassID] or "|cff888888"
				local vRoleCode = vMemberInfo.RoleCode or (vClassID and GroupCalendar:GetPlayerDefaultRoleCode(vMemberInfo.Name, vClassID))
				local vInfoText
				
				if vLevel and vRoleCode then
					local vRoleName = tostring(GroupCalendar["c"..tostring(vRoleCode).."Role"])
					
					if self:LevelIsOK(vLevel) then
						vInfoText = string.format("%s %s", tostring(vLevel), vRoleName)
					else
						vInfoText = string.format("%s%s %s", RED_FONT_COLOR_CODE, tostring(vLevel), vRoleName)
					end
				elseif vMemberInfo.Offline then
					vInfoText = PLAYER_OFFLINE
				else
					vInfoText = ""
				end
				
				local vPlayerInvite = self.Event:GetPlayerInvite(vMemberInfo.Name)
				
				local vSelected = vPlayerInvite
				               or (self.Event.CalendarType == "GUILD_EVENT" and pGroup.Roster == GroupCalendar.GuildLib.Roster)
				
				vItemFrame:SetInvite(
						vSelected, true, self.Event:PlayerInviteIsPending(vMemberInfo.Name),
						vColorCode, vMemberInfo.Name, vInfoText,
						vPlayerInvite and vPlayerInvite.ModStatus,
						nil,
						vMemberIndent,
						function (...) self:ListItemFunc(...) end)
				
				vItemFrame.Group = pGroup
				vItemFrame.MemberIndex = vIndex
			end
			
			vItemIndex = vItemIndex + 1
			
			if vItemIndex > pNumVisibleItems then
				return vItemIndex
			end
		end
	end
	
	return vItemIndex
end

function GroupCalendar.UI._EventInvite:ListItemFunc(pItem, pButton, pPartID)
	if pPartID == "EXPAND" then
		pItem.Group.Expanded = not pItem.Group.Expanded
		
		if pItem.Group == self.FriendsInviteGroup then
			GroupCalendar.PlayerData.ExpandFriendsGroup = pItem.Group.Expanded
		end
		
		self:Refresh()
	elseif pPartID == "CHECKBOX" then
		if pItem.MemberIndex then
			local _, vMemberInfo = pItem.Group:GetIndexedMember(pItem.MemberIndex)
			
			if self.Event:GetPlayerInvite(vMemberInfo.Name) then
				self.Event:UninvitePlayer(vMemberInfo.Name)
			else
				self.Event:InvitePlayer(vMemberInfo.Name)
			end
		else
			local vSelected, vAllSelected, vNumSelected, vPending, vHasModerators, vAllModerators = self:GroupIsSelected(pItem.Group)
			
			self.Event:BeginBatchInvites()
			
			if not vAllSelected then
				self:InviteGroup(pItem.Group)
			else
				self:UninviteGroup(pItem.Group)
			end

			self.Event:EndBatchInvites()
		end
	elseif pPartID == "MODERATOR" then
		if pItem.MemberIndex then
			local _, vMemberInfo = pItem.Group:GetIndexedMember(pItem.MemberIndex)
			
			local vPlayerInvite = self.Event:GetPlayerInvite(vMemberInfo.Name)
			
			if vPlayerInvite then
				self.Event:SetModerator(vMemberInfo.Name, vPlayerInvite.ModStatus ~= "MODERATOR")
			end
		else
			local vSelected, vAllSelected, vNumSelected, vPending, vHasModerators, vAllModerators = self:GroupIsSelected(pItem.Group)
			
			self.Event:BeginBatchInvites()
			self:SetGroupModerator(pItem.Group, not vAllModerators)
			self.Event:EndBatchInvites()
		end
		
		self:Refresh()
	end
end

function GroupCalendar.UI._EventInvite:LevelIsOK(pLevel)
	if not pLevel then
		return true
	end
	
	if self.Event.MinLevel and pLevel < self.Event.MinLevel then
		return false
	end
	
	if self.Event.MaxLevel and pLevel > self.Event.MaxLevel then
		return false
	end
	
	return true
end

function GroupCalendar.UI._EventInvite:InviteGroup(pGroup)
	local vNumMembers = pGroup:GetNumMembers()
	
	for vIndex = 1, vNumMembers do
		local vMemberGroup, vMemberInfo = pGroup:GetIndexedMember(vIndex)
		
		if vMemberGroup then
			self:InviteGroup(vMemberGroup)
		elseif self:LevelIsOK(vMemberInfo.Level) then
			self.Event:InvitePlayer(vMemberInfo.Name)
		end
	end
end

function GroupCalendar.UI._EventInvite:UninviteGroup(pGroup)
	local vNumMembers = pGroup:GetNumMembers()
	
	for vIndex = 1, vNumMembers do
		local vMemberGroup, vMemberInfo = pGroup:GetIndexedMember(vIndex)
		
		if vMemberGroup then
			self:UninviteGroup(vMemberGroup)
		else
			self.Event:UninvitePlayer(vMemberInfo.Name)
		end
	end
end

function GroupCalendar.UI._EventInvite:SetGroupModerator(pGroup, pModerator)
	local vNumMembers = pGroup:GetNumMembers()
	
	for vIndex = 1, vNumMembers do
		local vMemberGroup, vMemberInfo = pGroup:GetIndexedMember(vIndex)
		
		if vMemberGroup then
			self:SetGroupModerator(vMemberGroup, pModerator)
		elseif self.Event:GetAttendance()[vMemberInfo.Name] then
			self.Event:SetModerator(vMemberInfo.Name, pModerator)
		end
	end
end

function GroupCalendar.UI._EventInvite:GetGroupVisibleItems(pGroup)
	local vNumItems = 1
	
	if pGroup.Expanded then
		local vNumMembers = pGroup:GetNumMembers()
		
		for vIndex = 1, vNumMembers do
			local vMemberGroup, vMemberInfo = pGroup:GetIndexedMember(vIndex)
			
			if vMemberGroup then
				if vMemberGroup:GetNumMembers() > 0 then
					vNumItems = vNumItems + self:GetGroupVisibleItems(vMemberGroup)
				end
			else
				vNumItems = vNumItems + 1
			end
		end
	end
	
	return vNumItems
end

function GroupCalendar.UI._EventInvite:Refresh()
	local vNumItems = 0
	local vAllExpanded = true
	
	for vIndex, vInviteGroup in ipairs(self.InviteGroups) do
		if vInviteGroup:GetNumMembers() > 0 then
			vNumItems = vNumItems + self:GetGroupVisibleItems(vInviteGroup)
			
			if not vInviteGroup.Expanded then
				vAllExpanded = false
			end
		end
	end
	
	self.ScrollingList:SetNumItems(vNumItems)
	
	self.ExpandAll:SetChecked(vAllExpanded)
	
	--
	
	local vNumVisibleItems = self.ScrollingList:GetNumVisibleItems()
	local vItemIndex = 1 - self.ScrollingList:GetOffset()
	
	for vIndex, vInviteGroup in ipairs(self.InviteGroups) do
		if vInviteGroup:GetNumMembers() > 0 then
			vItemIndex = self:AddGroupItem(vInviteGroup, vItemIndex, vNumVisibleItems, 0)
			
			if vItemIndex > vNumVisibleItems then
				break
			end
		end
	end
end

----------------------------------------
GroupCalendar._GuildRankInviteGroup = {}
----------------------------------------

function GroupCalendar._GuildRankInviteGroup:Construct(pRoster, pRankIndex)
	self.Roster = pRoster
	self.RankIndex = pRankIndex
	self.Title = pRoster.Ranks[pRankIndex]
	self.Expanded = false
	
	self.Members = {}
end

function GroupCalendar._GuildRankInviteGroup:Rebuild()
	for vKey, _ in pairs(self.Members) do
		self.Members[vKey] = nil
	end
end

function GroupCalendar._GuildRankInviteGroup:Sort()
	table.sort(self.Members, function (pMember1, pMember2)
		if not pMember1.ClassID
		or (pMember2.ClassID and pMember1.ClassID < pMember2.ClassID) then
			return true
		elseif not pMember2.ClassID
		or pMember1.ClassID > pMember2.ClassID then
			return false
		end
		
		if pMember1.Level > pMember2.Level then
			return true
		elseif pMember1.Level < pMember2.Level then
			return false
		end
		
		return pMember1.Name < pMember2.Name
	end)
end

function GroupCalendar._GuildRankInviteGroup:GetInfoText()
	local vNumSelected = 0
	
	return string.format("%s selected", vNumSelected)
end

function GroupCalendar._GuildRankInviteGroup:AddMember(pName, pLevel, pClassID, pRoleCode)
	table.insert(self.Members, {Name = pName, Level = pLevel, ClassID = pClassID, RoleCode = pRoleCode})
end

function GroupCalendar._GuildRankInviteGroup:GetNumMembers()
	return #self.Members
end

function GroupCalendar._GuildRankInviteGroup:GetIndexedMember(pIndex)
	return nil, self.Members[pIndex]
end

----------------------------------------
GroupCalendar._GuildInviteGroup = {}
----------------------------------------

function GroupCalendar._GuildInviteGroup:Construct(pRoster, pExpanded)
	self.Roster = pRoster
	self.Ranks = {}
	
	self.Title = string.format(HIGHLIGHT_FONT_COLOR_CODE.."<%s>", pRoster.GuildName or "name_missing")
	self.Expanded = pExpanded

	self:Rebuild()
end

function GroupCalendar._GuildInviteGroup:Rebuild()
	local vNumRanks = #self.Roster.Ranks
	
	while #self.Ranks < vNumRanks do
		local vRankIndex = #self.Ranks + 1
		
		self.Ranks[vRankIndex] = GroupCalendar:New(GroupCalendar._GuildRankInviteGroup, self.Roster, vRankIndex)
	end
	
	while #self.Ranks > vNumRanks do
		self.Ranks[#self.Ranks] = nil
	end
	
	for _, vRankGroup in ipairs(self.Ranks) do
		vRankGroup:Rebuild()
	end
	
	for vName, vPlayerInfo in pairs(self.Roster.Players) do
		local vRoleCode = GroupCalendar:GetPlayerDefaultRoleCode(vName, vPlayerInfo.ClassID)
		if vPlayerInfo.GuildRank then -- sometimes seems to happen with lag or something /shrug
			self.Ranks[vPlayerInfo.GuildRank + 1]:AddMember(vPlayerInfo.Name, vPlayerInfo.Level, vPlayerInfo.ClassID, vPlayerInfo.RoleCode)
		end
	end

	for _, vRankGroup in ipairs(self.Ranks) do
		vRankGroup:Sort()
	end
end

function GroupCalendar._GuildInviteGroup:GetInfoText()
	local vNumSelected = 0
	
	return string.format("%s selected", vNumSelected)
end

function GroupCalendar._GuildInviteGroup:GetNumMembers()
	return #self.Ranks
end

function GroupCalendar._GuildInviteGroup:GetIndexedMember(pIndex)
	return self.Ranks[pIndex]
end

----------------------------------------
GroupCalendar._ArenaInviteGroup = {}
----------------------------------------

function GroupCalendar._ArenaInviteGroup:Construct(pTeamIndex)
	local vTeamName, vTeamSize, vTeamRating,
	      vWeekPlayed, vWeekWins, vSeasonPlayed, vSeasonWins,
	      vPlayerPlayed, vSeasonPlayerPlayed,
	      vTeamRank, vPlayerRating = GetArenaTeam(pTeamIndex)
	
	self.TeamIndex = pTeamIndex
	self.Title = vTeamName
end

function GroupCalendar._ArenaInviteGroup:Rebuild()
end

function GroupCalendar._ArenaInviteGroup:GetInfoText()
	local vNumSelected = 0
	
	return string.format("%s selected", vNumSelected)
end

function GroupCalendar._ArenaInviteGroup:GetNumMembers()
	return GetNumArenaTeamMembers(self.TeamIndex, true)
end

function GroupCalendar._ArenaInviteGroup:GetIndexedMember(pIndex)
	local vName, vRank, vLevel, vClass, vOnline,
	      vPlayed, vWin, vSeasonPlayed, vSeasonWin, vPersonalRating = GetArenaTeamRosterInfo(self.TeamIndex, pIndex)

	local vClassID = GroupCalendar.GuildLib.ClassNameToClassID[vClass]
	
	return nil, {Name = vName, Level = vLevel, Class = vClass, ClassID = vClassID, Offline = not vOnline}
end

----------------------------------------
GroupCalendar._FriendsInviteGroup = {}
----------------------------------------

function GroupCalendar._FriendsInviteGroup:Construct()
	self.Title = HIGHLIGHT_FONT_COLOR_CODE..FRIENDS
	
	if GroupCalendar.PlayerData.ExpandFriendsGroup == nil then
		self.Expanded = true
	else
		self.Expanded = GroupCalendar.PlayerData.ExpandFriendsGroup
	end
end

function GroupCalendar._FriendsInviteGroup:Rebuild()
end

function GroupCalendar._FriendsInviteGroup:GetInfoText()
	local vNumSelected = 0
	
	return string.format("%s selected", vNumSelected)
end

function GroupCalendar._FriendsInviteGroup:GetNumMembers()
	return GetNumFriends()
end

function GroupCalendar._FriendsInviteGroup:GetIndexedMember(pIndex)
	local vName, vLevel, vClass, vLocation, vConnected, vStatus, vNote = GetFriendInfo(pIndex)
	local vClassID = GroupCalendar.GuildLib.ClassNameToClassID[vClass]
	
	if vLevel == 0 then
		vLevel = nil
	end
	
	return nil, {Name = vName, Level = vLevel, Class = vClass, ClassID = vClassID, Offline = not vConnected}
end

----------------------------------------
GroupCalendar._CurrentPartyGroup = {}
----------------------------------------

function GroupCalendar._CurrentPartyGroup:Construct()
	self.Title = HIGHLIGHT_FONT_COLOR_CODE..GroupCalendar.cCurrentPartyOrRaid
	
	self.Expanded = false
end

function GroupCalendar._CurrentPartyGroup:Rebuild()
end

function GroupCalendar._CurrentPartyGroup:GetInfoText()
	local vNumSelected = 0
	
	return string.format("%s selected", vNumSelected)
end

function GroupCalendar._CurrentPartyGroup:GetNumMembers()
	return GroupCalendar.RaidLib.NumPlayers
end

function GroupCalendar._CurrentPartyGroup:GetIndexedMember(pIndex)
	local vPlayers = GroupCalendar.RaidLib:GetSortedPlayers()
	
	return nil, vPlayers[pIndex]
end

----------------------------------------
GroupCalendar._OthersInviteGroup = {}
----------------------------------------

function GroupCalendar._OthersInviteGroup:Construct(pEvent, pInviteGroups)
	self.Title = GroupCalendar.cOthers
	self.Expanded = true
	self.Event = pEvent
	self.InviteGroups = pInviteGroups
	self.Members = {}
	self.MembersByName = {}
	
	self:Rebuild()
end

function GroupCalendar._OthersInviteGroup:Rebuild()
	-- Collect the current members
	
	for vKey, _ in pairs(self.Members) do
		self.MembersByName[vKey] = nil
	end
	
	if self.Event.Attendance then
		for vName, vInfo in pairs(self.Event.Attendance) do
			self.MembersByName[vName] = vInfo
		end
	end
	
	-- Subtract out the other groups
	
	for _, vInviteGroup in ipairs(self.InviteGroups) do
		if vInviteGroup ~= self then
			self:RemoveInviteGroup(vInviteGroup, self.MembersByName)
		end
	end
	
	-- Build the list of "others"
	
	for vKey, _ in pairs(self.Members) do
		self.Members[vKey] = nil
	end
	
	for vName, vInfo in pairs(self.MembersByName) do
		table.insert(self.Members, vInfo)
	end
end

function GroupCalendar._OthersInviteGroup:RemoveInviteGroup(pInviteGroup, pMembers)
	local vNumMembers = pInviteGroup:GetNumMembers()

	for vIndex = 1, vNumMembers do
		local vMemberGroup, vMemberInfo = pInviteGroup:GetIndexedMember(vIndex)
		
		if vMemberGroup then
			self:RemoveInviteGroup(vMemberGroup, pMembers)
		elseif vMemberInfo.Name then
			pMembers[vMemberInfo.Name] = nil
		end
	end
end

function GroupCalendar._OthersInviteGroup:GetInfoText()
	local vNumSelected = 0
	
	return string.format("%s selected", vNumSelected)
end

function GroupCalendar._OthersInviteGroup:GetNumMembers()
	return #self.Members
end

function GroupCalendar._OthersInviteGroup:GetIndexedMember(pIndex)
	return nil, self.Members[pIndex]
end

----------------------------------------
GroupCalendar.UI._EventInvite._ListItem = {}
----------------------------------------

function GroupCalendar.UI._EventInvite._ListItem:New(pParent)
	return CreateFrame("Button", nil, pParent)
end

GroupCalendar.UI._EventInvite._ListItem.cItemHeight = 15

function GroupCalendar.UI._EventInvite._ListItem:Construct(pParent)
	self:SetHeight(self.cItemHeight)
	
	self.ExpandButton = GroupCalendar:New(GroupCalendar.UIElementsLib._ExpandButton, self)
	self.ExpandButton:SetPoint("LEFT", self, "LEFT")
	self.ExpandButton:SetScript("OnClick", function (pFrame, pButton)
		self.SelectionFunc(self, pButton, "EXPAND")
	end)
	
	self.ModeratorButton = GroupCalendar:New(GroupCalendar.UIElementsLib._CheckButton, self)
	self.ModeratorButton:SetDisplayMode("ASSIST")
	self.ModeratorButton:SetWidth(self.cItemHeight)
	self.ModeratorButton:SetHeight(self.cItemHeight)
	self.ModeratorButton:SetPoint("RIGHT", self, "RIGHT")
	self.ModeratorButton:SetScript("OnClick", function (pFrame, pButton)
		self.SelectionFunc(self, pButton, "MODERATOR")
	end)
	self.ModeratorButton:SetScript("OnEnter", function ()
		GroupCalendar:ShowTooltip(
			self,
			GroupCalendar.cModeratorTooltipTitle, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b,
			GroupCalendar.cModeratorTooltipDescription, 1)
	end)
	self.ModeratorButton:SetScript("OnLeave", function ()
		GroupCalendar:HideTooltip()
	end)

	self.InfoText = self:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	self.InfoText:SetPoint("RIGHT", self.ModeratorButton, "LEFT", -3, 0)
	self.InfoText:SetWidth(100)
	self.InfoText:SetJustifyH("RIGHT")
	
	self.CheckButton = GroupCalendar:New(GroupCalendar.UIElementsLib._CheckButton, self)
	self.CheckButton:SetWidth(self.cItemHeight)
	self.CheckButton:SetHeight(self.cItemHeight)
	self.CheckButton:SetPoint("LEFT", self.ExpandButton, "RIGHT")
	self.CheckButton.Title:SetPoint("RIGHT", self.InfoText, "LEFT")
	self.CheckButton.Title:SetJustifyH("LEFT")
	self.CheckButton:SetScript("OnClick", function (pFrame, pButton)
		self.SelectionFunc(self, pButton, "CHECKBOX")
	end)
end

function GroupCalendar.UI._EventInvite._ListItem:SetInvite(
			pSelected, pAllSelected, pPending,
			pColorCode, pTitle, pInfoText,
			pModStatus,
			pExpanded, pIndent, pSelectionFunc)
	if pExpanded == nil then
		self.ExpandButton:Hide()
		
		self.CheckButton:ClearAllPoints()
		self.CheckButton:SetPoint("LEFT", self, "LEFT", (pIndent or 0) + 16, 0)
	else
		self.ExpandButton:SetExpanded(pExpanded)
		self.ExpandButton:Show()
		
		self.ExpandButton:ClearAllPoints()
		self.ExpandButton:SetPoint("LEFT", self, "LEFT", pIndent or 0, 0)
		
		self.CheckButton:ClearAllPoints()
		self.CheckButton:SetPoint("LEFT", self.ExpandButton, "RIGHT")
	end
	
	self.CheckButton:SetChecked(pSelected)
	self.CheckButton:SetTitle((pColorCode or "")..pTitle)
	
	self.CheckButton:SetMultiSelect(not pAllSelected)
	
	if pPending then
		self.CheckButton:SetDisplayMode("BUSY")
	else
		self.CheckButton:SetDisplayMode("CHECKBOX")
	end
	
	self.InfoText:SetText((pColorCode or "")..(pInfoText or ""))
	
	self.SelectionFunc = pSelectionFunc
	
	if pModStatus then
		if pModStatus == "CREATOR" then
			self.ModeratorButton:SetDisplayMode("LEADER")
			self.ModeratorButton:SetChecked(true)
			self.ModeratorButton:SetMultiSelect(false)
		elseif pModStatus == "MODERATOR" then
			self.ModeratorButton:SetDisplayMode("ASSIST")
			self.ModeratorButton:SetChecked(true)
			self.ModeratorButton:SetMultiSelect(false)
		elseif pModStatus == "MODERATOR_MULTI" then
			self.ModeratorButton:SetDisplayMode("ASSIST")
			self.ModeratorButton:SetChecked(true)
			self.ModeratorButton:SetMultiSelect(true)
		else
			self.ModeratorButton:SetDisplayMode("ASSIST")
			self.ModeratorButton:SetChecked(false)
			self.ModeratorButton:SetMultiSelect(false)
		end
		
		self.ModeratorButton:Show()
	else
		self.ModeratorButton:Hide()
	end
end

----------------------------------------
GroupCalendar._ProgressBar = {}
----------------------------------------

function GroupCalendar._ProgressBar:New(pParent)
	return CreateFrame("StatusBar", nil, pParent)
end

function GroupCalendar._ProgressBar:Construct()
	self:SetHeight(20)
	
	self.LabelText = self:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	self.LabelText:SetPoint("CENTER", self, "CENTER")
	
	self:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
	self:SetStatusBarColor(1, 0.7, 0)
end

function GroupCalendar._ProgressBar:SetText(pText)
	self.LabelText:SetText(pText)
end
