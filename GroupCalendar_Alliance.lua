----------------------------------------
-- Group Calendar 5 Copyright (c) 2018 John Stephen
-- This software is licensed under the MIT license.
-- See the included LICENSE.txt file for more information.
----------------------------------------

local _

----------------------------------------
----------------------------------------

-- NOTE: If any regexp characters need to be escaped remember to code them properly
--       Currently those characters are ^$()%.[]*+-?

GroupCalendar.cEscapeNetworkCharsRegExp = "([~,/:|\n])"

GroupCalendar.cUnescapeNetworkCharMap =
{
	d = "~",
	c = ",",
	s = "/",
	o = ":",
	b = "|",
	n = "\n",
}

GroupCalendar.cEscapeNetworkCharMap = {} -- Generate the reverse map

for vEscapeCode, vChar in pairs(GroupCalendar.cUnescapeNetworkCharMap) do
	GroupCalendar.cEscapeNetworkCharMap[vChar] = "~"..vEscapeCode
end

function GroupCalendar:EscapeNetworkParam(pString)
	return pString:gsub(GroupCalendar.cEscapeNetworkCharsRegExp, GroupCalendar.cEscapeNetworkCharMap)
end

function GroupCalendar:UnescapeNetworkParam(pString)
	return pString:gsub("~(.)", GroupCalendar.cUnescapeNetworkCharMap)
end

----------------------------------------
-- Chat message escaping (for drunk filtering)
----------------------------------------

GroupCalendar.cEscapedChatCharRegExp = "([`sS|])"

GroupCalendar.cUnescapeChatCharMap =
{
	n = "`",
	["l"] = "s",
	["u"] = "S",
}

GroupCalendar.cEscapeChatCharMap = {}

for vEscapeCode, vChar in pairs(GroupCalendar.cUnescapeChatCharMap) do
	GroupCalendar.cEscapeChatCharMap[vChar] = "`"..vEscapeCode
end

function GroupCalendar:EscapeChatString(pString)
	return pString:gsub(GroupCalendar.cEscapedChatCharRegExp, GroupCalendar.cEscapeChatCharMap)
end

function GroupCalendar:UnescapeChatString(pString)
	return pString:gsub("`(.)", GroupCalendar.cUnescapeChatCharMap)
end

----------------------------------------
GroupCalendar.Partnerships = {}
----------------------------------------

function GroupCalendar.Partnerships:Initialize()
	if not GroupCalendar.WhisperSockets then
		GroupCalendar.WhisperSockets = GroupCalendar:New(GroupCalendar._WhisperSockets)
	end
	
	if not GroupCalendar.PlayerData.PartnerConfigs then
		GroupCalendar.PlayerData.PartnerConfigs = {}
	end
	
	self.PartnerGuilds = {}
	
	self:PartnerConfigChanged()
	
	GroupCalendar.WhisperSockets:Listen(self, "SYNC_ROSTER")
	
	GroupCalendar.SchedulerLib:ScheduleTask(10, self.StartAutoSync, self)
end

function GroupCalendar.Partnerships:PartnerConfigChanged()
	-- Mark the existing PartnerGuilds as unused
	
	for _, vPartnerGuild in ipairs(self.PartnerGuilds) do
		vPartnerGuild.Unused = true
	end
	
	-- Unmark or create partner guilds
	
	for _, vPartnerConfig in ipairs(GroupCalendar.PlayerData.PartnerConfigs) do
		local vFound
		
		for _, vPartnerGuild in ipairs(self.PartnerGuilds) do
			if vPartnerGuild.Config == vPartnerConfig then
				vPartnerGuild.Unused = nil
				vFound = true
				break
			end
		end
		
		if not vFound then
			table.insert(self.PartnerGuilds, GroupCalendar:New(GroupCalendar._PartnerGuild, vPartnerConfig))
		end
	end
	
	-- Delete old guilds
	
	local vDidDelete
	
	for _, vPartnerGuild in ipairs(self.PartnerGuilds) do
		if vPartnerGuild.Unused then
			vPartnerGuild.Proxies = {}
			vDidDelete = true
		end
	end
	
	if vDidDelete then
		self:CleanUpPartners()
	else
		GroupCalendar.EventLib:DispatchEvent("GC5_PARTNERS_CHANGED")
	end
end

function GroupCalendar.Partnerships:StartAutoSync()
	-- Don't start sync if the player is in combat
	
	GroupCalendar.EventLib:UnregisterEvent("PLAYER_REGEN_ENABLED", self.StartAutoSync, self)
	
	if not self.NewPartnershipsEnabled and UnitAffectingCombat("player") then
		GroupCalendar.EventLib:RegisterEvent("PLAYER_REGEN_ENABLED", self.StartAutoSync, self)
		return
	end
	
	--
	
	for _, vPartnerGuild in ipairs(self.PartnerGuilds) do
		vPartnerGuild:StartPartnerSync()
	end
end

function GroupCalendar.Partnerships:ConnectionRequest(pSender, pSourceSocketID, pConnectionType, pMessage)
	if GroupCalendar.Debug.partners then
		GroupCalendar:DebugMessage("Partnerships:ConnectionRequest: %s %s %s", tostring(pSender), tostring(pSourceSocketID), tostring(pConnectionType), tostring(pMessage))
	end
	
	-- Don't accept requests to sync if we're in combat
	
	if not self.NewPartnershipsEnabled and UnitAffectingCombat("player") then
		if GroupCalendar.Debug.partners then
			GroupCalendar:DebugMessage("Partnerships:ConnectionRequest: Ignoring because player is in combat")
		end
		return
	end
	
	--
	
	local vPartnerGuild = self:FindPartnerGuildByPlayer(pSender)
	
	if vPartnerGuild and vPartnerGuild:IsSyncing() then
		if GroupCalendar.Debug.partners then
			GroupCalendar:DebugMessage("Partnerships:ConnectionRequest: Ignoring because sync is in progress")
		end
		return
	end
	
	if vPartnerGuild then
		vPartnerGuild:ConnectionRequest(pSender, pSourceSocketID, pConnectionType, pMessage)
		return
	end
	
	-- New partnership request
	
	if not self.NewPartnershipsEnabled then
		if GroupCalendar.Debug.partners then
			GroupCalendar:DebugMessage("Partnerships:ConnectionRequest: Ignoring because new partnerships aren't enabled")
		end
		return
	end
	
	-- Ask the sender to wait
	
	local _, _, vSenderGuild, vSenderChecksum = pMessage:find("GUILD:([^,]+),([^/]+)/?")
	
	if not vSenderGuild then
		return
	end
	
	vSenderGuild = GroupCalendar:UnescapeNetworkParam(vSenderGuild)
	
	if not StaticPopupDialogs.GC5_CONFIRM_PARTNER_REQUEST then
		StaticPopupDialogs.GC5_CONFIRM_PARTNER_REQUEST =
		{
			preferredIndex = 3,
			text = GroupCalendar.cConfirmPartnerRequest,
			button1 = ACCEPT,
			button2 = CANCEL,
			OnAccept = nil,
			timeout = 0,
			whileDead = 1,
			hideOnEscape = 1,
		}
	end

	StaticPopupDialogs.GC5_CONFIRM_PARTNER_REQUEST.OnAccept = function ()
		local vPartnerGuild = self:FindPartnerGuildByGuild(vSenderGuild)
		
		if not vPartnerGuild then
			table.insert(GroupCalendar.PlayerData.PartnerConfigs, {GuildName = vSenderGuild, Proxies = {pSender}})
			self:PartnerConfigChanged()
			
			vPartnerGuild = self:FindPartnerGuildByGuild(vSenderGuild)
			
			if not vPartnerGuild then
				error("Creating partner guild unexpectedly failed")
			end
		else
			table.insert(vPartnerGuild.Config.Proxies, pSender)
		end
		
		if vPartnerGuild and not vPartnerGuild:IsSyncing() then
			vPartnerGuild:ConnectionRequest(pSender, pSourceSocketID, pConnectionType, pMessage)
			return
		end
	end
	
	StaticPopup_Show("GC5_CONFIRM_PARTNER_REQUEST", pSender)
end

function GroupCalendar.Partnerships:FindPartnerGuildByPlayer(pPlayerName)
	local vLowerName = pPlayerName:lower()
	
	for vPartnerIndex, vPartnerGuild in ipairs(self.PartnerGuilds) do
		for vProxyIndex, vName in ipairs(vPartnerGuild.Config.Proxies) do
			if vName:lower() == vLowerName then
				return vPartnerGuild, vPartnerIndex, vProxyIndex
			end
		end
	end
end

function GroupCalendar.Partnerships:FindPartnerGuildByGuild(pGuildName)
	for vPartnerIndex, vPartnerGuild in ipairs(self.PartnerGuilds) do
		if vPartnerGuild.Config.GuildName == pGuildName then
			return vPartnerGuild, vPartnerIndex
		end
	end
end

function GroupCalendar.Partnerships:FindPartnerConfigByGuild(pGuildName)
	for vPartnerIndex, vPartnerConfig in ipairs(GroupCalendar.PlayerData.PartnerConfigs) do
		if vPartnerConfig.GuildName == pGuildName then
			return vPartnerConfig, vPartnerIndex
		end
	end
end

function GroupCalendar.Partnerships:AddPartnerPlayer(pPlayerName)
	local vPartnerGuild = self:FindPartnerGuildByPlayer(pPlayerName)
	
	if vPartnerGuild then
		return false, "EXISTS"
	end
	
	-- Initiate a partnership
	
	local vPartnerGuild = GroupCalendar:New(GroupCalendar._PartnerGuild, {GuildName = nil, Proxies = {pPlayerName}})
	
	vPartnerGuild:StartPartnerSync()
	
	return vPartnerGuild
end

function GroupCalendar.Partnerships:RemovePartnerPlayer(pPlayerName)
	local vPartnerGuild, vPartnerIndex, vProxyIndex = self:FindPartnerGuildByPlayer(pPlayerName)
	
	if not vPartnerGuild then
		return false, "NOT_FOUND"
	end
	
	table.remove(vPartnerGuild.Config.Proxies, vProxyIndex)
	
	self:CleanUpPartners()
end

function GroupCalendar.Partnerships:RemovePartnerGuild(pGuildName)
	local vPartnerConfig, vPartnerIndex = self:FindPartnerConfigByGuild(pGuildName)
	
	if not vPartnerConfig then
		return
	end
	
	vPartnerConfig.Proxies = {}
	self:CleanUpPartners()
end

function GroupCalendar.Partnerships:CleanUpPartners()
	local vDidDelete
	
	for vPartnerIndex, vPartnerConfig in pairs(GroupCalendar.PlayerData.PartnerConfigs) do
		if #vPartnerConfig.Proxies == 0 then
			vDidDelete = true
			
			GroupCalendar.PlayerData.PartnerConfigs[vPartnerIndex] = nil
			
			for vPartnerIndex, vPartnerGuild in ipairs(self.PartnerGuilds) do
				if vPartnerGuild.Config == vPartnerConfig then
					vPartnerGuild:Terminate()
					table.remove(self.PartnerGuilds, vPartnerIndex)
				end
			end
		end
	end
	
	if vDidDelete then
		GroupCalendar:CleanUpRosters()
		GroupCalendar.EventLib:DispatchEvent("GC5_PARTNERS_CHANGED")
	end
end

----------------------------------------

GroupCalendar.PartnerSyncPrefix = "GC5:"
GroupCalendar.PartnerSyncPrefixLen = GroupCalendar.PartnerSyncPrefix:len()

--[[
Rough ideas of how this will work:

- Users enter one or more proxies (players) from each guild alliance.  Those proxies will exchange guild rosters with the player
- The proxies must be in the player's Friends list so that their online status can be determined
- Upon login, the player will see which proxies are online and will send them an intro whisper
- The whisper will be partially human-readable so they aren't astonished to see it if they don't have GC5 running
- Something like "GC5:BEGIN_UPDATE/NOTE: This message is being sent by Group Calendar 5 to synch rosters.  If you're seeing this then you may not have GC5 installed or enabled."
- Rosters will be identified by an MD5 checksum of their contents.  If the checksum is different, a new roster is sent.
]]

GroupCalendar._PartnerGuild = {}

function GroupCalendar._PartnerGuild:Construct(pConfig)
	self.Config = pConfig
	
	if not self.Config then
		self.Config =
		{
			GuildName = "",
			Proxies = {},
		}
	end
	
	self.Roster = GroupCalendar.RealmData.Guilds[self.Config.GuildName]
end

function GroupCalendar._PartnerGuild:Terminate()
	if self.Socket then
		self.Socket:Close()
	end
end

function GroupCalendar._PartnerGuild:UpdateCompiledData()
	self.CompiledRoster, self.Checksum = self:CompileRoster(GroupCalendar.GuildLib.Roster)
	
	if self.Roster then
		_, self.RemoteChecksum = self:CompileRoster(self.Roster)
	end
end

function GroupCalendar._PartnerGuild:IsSyncing()
	return self.ProxyIndex ~= nil
end

function GroupCalendar._PartnerGuild:SetSyncStatus(pStatus, pMessage)
	self.Status = pStatus
	self.StatusMessage = pMessage
	
	GroupCalendar.BroadcastLib:Broadcast(self, pStatus, pMessage)
end

function GroupCalendar._PartnerGuild:StartPartnerSync()
	if self:IsSyncing() then
		return
	end
	
	self:UpdateCompiledData()
	
	self.ProxyIndex = 0
	self:StartNextPartnerSync()
end

function GroupCalendar._PartnerGuild:PartnerSyncComplete()
	self.Config.LastUpdateDate, self.Config.LastUpdateTime = GroupCalendar.DateLib:GetServerDateTime()
	self:SetSyncStatus("PARTNER_SYNC_COMPLETE")
end

function GroupCalendar._PartnerGuild:StartNextPartnerSync()
	self.ProxyIndex = self.ProxyIndex + 1
	
	if self.ProxyIndex > #self.Config.Proxies then
		self.ProxyIndex = nil
		self:PartnerSyncComplete()
		return
	end
	
	local vPlayerName = self.Config.Proxies[self.ProxyIndex]
	
	self.State = "CONNECTING"
	GroupCalendar.WhisperSockets:Connect(vPlayerName, self, "SYNC_ROSTER", string.format("GUILD:%s,%s", GroupCalendar:EscapeNetworkParam(GroupCalendar.GuildLib.Roster.GuildName), self.Checksum))

	self:SetSyncStatus("PARTNER_SYNC_CONNECTING", vPlayerName)
end

function GroupCalendar._PartnerGuild:PartnerSyncSucceeded()
	if self:IsSyncing() then
		self:StartNextPartnerSync()
	else
		self:PartnerSyncComplete()
	end
end

function GroupCalendar._PartnerGuild:PartnerSyncFailed(pReason)
	if self:IsSyncing() then
		self:StartNextPartnerSync()
	end
end

--

function GroupCalendar._PartnerGuild:StartGuildSynch()
	-- Notify the guild of our copy
end

function GroupCalendar._PartnerGuild:InitializeNewConnection(pSocket)
	self.ReceivingRoster = nil
	self.SendingRoster = nil
	self.CloseWhenDone = nil
	
	self.Socket = pSocket
end

--

function GroupCalendar._PartnerGuild:ConnectionRequest(pSender, pSourceSocketID, pConnectionType, pMessage)
	if GroupCalendar.Debug.partners then
		GroupCalendar:DebugMessage("PartnerGuild:ConnectionRequest(%s, %s, %s)", tostring(pSender), tostring(pSourceSocketID), tostring(pConnectionType), tostring(pMessage))
	end
	
	local _, _, vSenderGuild, vSenderChecksum = pMessage:find("GUILD:([^,]+),([^/]+)/?")
	
	vSenderGuild = GroupCalendar:UnescapeNetworkParam(vSenderGuild)
	
	if vSenderGuild ~= self.Config.GuildName then
		if GroupCalendar.Debug.partners then
			GroupCalendar:DebugMessage("PartnerGuild:ConnectionRequest: Guild names don't match (expected %s, got %s)", tostring(self.Config.GuildName), tostring(vSenderGuild))
		end
		return
	end
	
	--
	
	self:UpdateCompiledData()
	
	local vMessage = string.format("GUILD:%s,%s", GroupCalendar:EscapeNetworkParam(GroupCalendar.GuildLib.Roster.GuildName), self.Checksum)
	
	-- Check their roster checksum and request an update
	
	if not self.Roster or self.RemoteChecksum ~= vSenderChecksum then
		vMessage = vMessage.."/SEND"
	end
	
	local vSocket = GroupCalendar.WhisperSockets:CompleteConnection(pSender, self, pSourceSocketID, pConnectionType, vMessage)
	
	self:InitializeNewConnection(vSocket)

	self:SetSyncStatus("PARTNER_SYNC_CONNECTED", pSender)
end

function GroupCalendar._PartnerGuild:Connected(pSocket, pMessage)
	if GroupCalendar.Debug.partners then
		GroupCalendar:DebugMessage("PartnerGuild:Connected(%s)", tostring(pMessage))
	end

	local vStartIndex, vEndIndex, vSenderGuild, vSenderChecksum = pMessage:find("GUILD:([^,]+),([^/]+)/?")
	local vSend = pMessage:sub(vEndIndex + 1) == "SEND"
	
	vSenderGuild = GroupCalendar:UnescapeNetworkParam(vSenderGuild)
	
	self:InitializeNewConnection(pSocket)
	
	self.CloseWhenDone = true
	
	-- Update the guild name in case it changes or is new
	
	if self.Config.GuildName ~= vSenderGuild then
		self.Config.GuildName = vSenderGuild
		self.Roster = GroupCalendar.RealmData.Guilds[self.Config.GuildName]
		self:UpdateCompiledData()
	end
	
	-- If the roster has changed request an update
	
	if not self.Roster or self.RemoteChecksum ~= vSenderChecksum then
		self.ReceivingRoster = true
		self.Socket:Send("SEND")
	end
	
	-- If the sender wants an update, send it
	
	if vSend then
		self:SendRoster()
	end
	
	-- Otherwise close the connection
	
	self:CheckCompletion()

	self:SetSyncStatus("PARTNER_SYNC_CONNECTED", pSocket.PlayerName)
end

function GroupCalendar._PartnerGuild:ConnectFailed(pSocket, pReason, pPlayerName)
	if GroupCalendar.Debug.partners then
		GroupCalendar:DebugMessage("PartnerGuild:ConnectFailed(%s)", tostring(pReason))
	end
	
	GroupCalendar.BroadcastLib:Broadcast(self, "GC5_CONNECT_FAILED", pReason, pPlayerName)
	
	self.Socket = nil
	
	self:PartnerSyncFailed(pReason)
end

function GroupCalendar._PartnerGuild:ConnectionClosed(pSocket)
	if GroupCalendar.Debug.partners then
		GroupCalendar:DebugMessage("PartnerGuild:ConnectionClosed()")
	end

	self.Socket = nil
	
	self:PartnerSyncSucceeded()
end

function GroupCalendar._PartnerGuild:SendSucceeded(pSocket)
	if GroupCalendar.Debug.partners then
		GroupCalendar:DebugMessage("PartnerGuild:SendSucceeded()")
	end
	
	self.SendingRoster = nil
	
	self.TotalLinesSent = nil
	GroupCalendar.BroadcastLib:Broadcast(self, "GC5_SEND_PROGRESS", nil)
	
	self:CheckCompletion()
end

function GroupCalendar._PartnerGuild:SendFailed(pSocket, pResult)
	if GroupCalendar.Debug.partners then
		GroupCalendar:DebugMessage("PartnerGuild:SendFailed(%s)", tostring(pResult))
	end
	
	self.Socket:Close()
	self.Socket = nil
	
	GroupCalendar.BroadcastLib:Broadcast(self, "GC5_SEND_FAILED", pResult)
	
	self:PartnerSyncFailed(pResult)
end

function GroupCalendar._PartnerGuild:Receive(pSocket, pMessage)
	if GroupCalendar.Debug.partners then
		GroupCalendar:DebugMessage("PartnerGuild:Receive(%s)", tostring(pMessage))
	end
	
	local vStartIndex, vEndIndex, vOp, vParams = pMessage:find("([^:]+):?([^/]*)/?")
	local vMessage = pMessage
	
	while vStartIndex do
		vMessage = vMessage:sub(vEndIndex + 1)
		
		if vOp == "ROSTER" then
			self.CollectedPlayers = {}
			self.CollectedRanks = {}
			
			self.LineIndex = 0
			self.NumLines = tonumber(vParams)
		elseif vOp == "END_ROSTER" then
			self.LineIndex = nil
			self.NumLines = nil
			GroupCalendar.BroadcastLib:Broadcast(self, "GC5_RECEIVE_PROGRESS", nil)
			
			self.ReceivingRoster = nil
			self:ProcessCollectedRoster()
			self:CheckCompletion()
		elseif vOp == "PLAYER" then
			table.insert(self.CollectedPlayers, vParams)
			self.LineIndex = self.LineIndex + 1
		elseif vOp == "RANK" then
			table.insert(self.CollectedRanks, vParams)
			self.LineIndex = self.LineIndex + 1
		elseif vOp == "TABARD_BG_U" then
			self.BackgroundTop = GroupCalendar:UnescapeNetworkParam(vParams)
			self.LineIndex = self.LineIndex + 1
		elseif vOp == "TABARD_BG_L" then
			self.BackgroundBottom = GroupCalendar:UnescapeNetworkParam(vParams)
			self.LineIndex = self.LineIndex + 1
		elseif vOp == "TABARD_EM_U" then
			self.EmblemTop = GroupCalendar:UnescapeNetworkParam(vParams)
			self.LineIndex = self.LineIndex + 1
		elseif vOp == "TABARD_EM_L" then
			self.EmblemBottom = GroupCalendar:UnescapeNetworkParam(vParams)
			self.LineIndex = self.LineIndex + 1
		elseif vOp == "TABARD_BD_U" then
			self.BorderTop = GroupCalendar:UnescapeNetworkParam(vParams)
			self.LineIndex = self.LineIndex + 1
		elseif vOp == "TABARD_BD_L" then
			self.BorderBottom = GroupCalendar:UnescapeNetworkParam(vParams)
			self.LineIndex = self.LineIndex + 1
		elseif vOp == "SEND" then
			self:SendRoster()
		end
		
		if self.NumLines and self.NumLines ~= 0 then
			GroupCalendar.BroadcastLib:Broadcast(self, "GC5_RECEIVE_PROGRESS", self.LineIndex / self.NumLines)
		end
		
		vStartIndex, vEndIndex, vOp, vParams = vMessage:find("([^:]+):?([^/]*)/?")
	end
end

function GroupCalendar._PartnerGuild:CheckCompletion()
	if self.Socket
	and self.CloseWhenDone
	and not self.SendingRoster
	and not self.ReceivingRoster then
		self.CloseWhenDone = nil
		
		self.Socket:Close()
	end
end

function GroupCalendar._PartnerGuild:SendRoster()
	self.SendingRoster = true
	
	self.TotalLinesSent = 2 + #self.CompiledRoster
	
	self.Socket:Send("ROSTER:"..#self.CompiledRoster)
	
	for _, vEntry in ipairs(self.CompiledRoster) do
		self.Socket:Send(vEntry)
	end
	
	self.Socket:Send("END_ROSTER")
end

function GroupCalendar._PartnerGuild:SendProgress(pLinesRemaining)
	if not self.TotalLinesSent then
		return
	end
	
	local vLinesSent = self.TotalLinesSent - pLinesRemaining
	local vPercent = vLinesSent / self.TotalLinesSent
	
	GroupCalendar.BroadcastLib:Broadcast(self, "GC5_SEND_PROGRESS", vPercent)
end

function GroupCalendar._PartnerGuild:ProcessCollectedRoster()
	if GroupCalendar.Debug.partners then
		GroupCalendar:DebugMessage("ProcessCollectedRoster")
	end
	
	-- Empty or create the roster
	
	if self.Roster then
		for _, vPlayerInfo in pairs(self.Roster.Players) do
			vPlayerInfo.Unused = true
		end
		
		for vKey in pairs(self.Roster.Ranks) do
			self.Roster.Ranks[vKey] = nil
		end
	else
		self.Roster = GroupCalendar.GuildLib:NewRosterData(self.Config.GuildName)
		
		GroupCalendar.RealmData.Guilds[self.Config.GuildName] = self.Roster
	end
	
	-- Parse out the players
	
	for _, vData in ipairs(self.CollectedPlayers) do
		local _, _, vName, vGuildRank, vClassID, vLevel = vData:find("([^,]+),([^,]+),([^,]+),([^,]+)")
		
		if not vName then
			error("Couldn't parse roster data: "..tostring(vData))
			return
		end
		
		local vPlayerInfo = self.Roster:AddPlayer(GroupCalendar:UnescapeNetworkParam(vName), vClassID)
		
		vPlayerInfo.GuildRank = tonumber(vGuildRank)
		vPlayerInfo.Level = tonumber(vLevel)
	end
	
	-- Parse the ranks
	
	for _, vData in ipairs(self.CollectedRanks) do
		local _, _, vRankIndex, vRankName = vData:find("([^,]+),([^,]+)")
		
		if not vRankIndex then	
			error("Couldn't parse rank data: "..tostring(vData))
			return
		end
		
		vRankIndex = tonumber(vRankIndex)
		
		self.Roster.Ranks[vRankIndex] = GroupCalendar:UnescapeNetworkParam(vRankName)
	end
	
	-- Update the tabard
	
	self.Roster.BackgroundTop = self.BackgroundTop
	self.Roster.BackgroundBottom = self.BackgroundBottom
	self.Roster.EmblemTop = self.EmblemTop
	self.Roster.EmblemBottom = self.EmblemBottom
	self.Roster.BorderTop = self.BorderTop
	self.Roster.BorderBottom = self.BorderBottom
end

function GroupCalendar._PartnerGuild:CompileRoster(pRoster)
	local vCompiledRoster = {}
	
	-- Create the data string for each member, which is name, rank, class, level, public note (not currently included)
	
	for vPlayerName, vPlayerInfo in pairs(pRoster.Players) do
		table.insert(vCompiledRoster,
				string.format("PLAYER:%s,%s,%s,%s",
				GroupCalendar:EscapeNetworkParam(vPlayerInfo.Name),
				tostring(vPlayerInfo.GuildRank),
				tostring(vPlayerInfo.ClassID),
				tostring(vPlayerInfo.Level)))
	end
	
	-- Sort the players to make the MD5 hash predictable
	
	table.sort(vCompiledRoster)
	
	-- Append the rank info
	
	for vRankIndex, vRankName in ipairs(pRoster.Ranks) do
		table.insert(vCompiledRoster, string.format("RANK:%s,%s", tostring(vRankIndex), GroupCalendar:EscapeNetworkParam(vRankName)))
	end
	
	-- Append the tabard info
	
	table.insert(vCompiledRoster, "TABARD_BG_U:"..GroupCalendar:EscapeNetworkParam(pRoster.BackgroundTop or ""))
	table.insert(vCompiledRoster, "TABARD_BG_L:"..GroupCalendar:EscapeNetworkParam(pRoster.BackgroundBottom or ""))
	table.insert(vCompiledRoster, "TABARD_EM_U:"..GroupCalendar:EscapeNetworkParam(pRoster.EmblemTop or ""))
	table.insert(vCompiledRoster, "TABARD_EM_L:"..GroupCalendar:EscapeNetworkParam(pRoster.EmblemBottom or ""))
	table.insert(vCompiledRoster, "TABARD_BD_U:"..GroupCalendar:EscapeNetworkParam(pRoster.BorderTop or ""))
	table.insert(vCompiledRoster, "TABARD_BD_L:"..GroupCalendar:EscapeNetworkParam(pRoster.BorderBottom or ""))
	
	-- Calculate the hash
	
	local vMD5 = GroupCalendar:New(GroupCalendar._MD5)
	
	vMD5:BeginDigest()
	
	for _, vEntry in ipairs(vCompiledRoster) do
		vMD5:DigestString(vEntry)
	end
	
	local vChecksum = vMD5:EndDigest()
	
	-- Done
	
	return vCompiledRoster, vChecksum
end

----------------------------------------
GroupCalendar._WhisperSocket = {}
----------------------------------------

function GroupCalendar._WhisperSocket:Construct(pPlayerName, pClient, pConnectionType, pWhisperSockets)
	self.PlayerName = pPlayerName
	self.Client = pClient
	self.ConnectionType = pConnectionType
	self.State = "CLOSED"
	self.WhisperSockets = pWhisperSockets
	
	self.WhisperSockets.LastSocketID = self.WhisperSockets.LastSocketID + 1
	self.SocketID = self.WhisperSockets.LastSocketID
	self.DestSocketID = 0
	
	self.SendQueue = {}
end

function GroupCalendar._WhisperSocket:Connect(pMessage)
	local vMessage = self.ConnectionType
	
	if pMessage then
		vMessage = vMessage.."/"..pMessage
	end
	
	self.State = "CONNECTING"
	self:Send(vMessage)
	GroupCalendar.SchedulerLib:ScheduleTask(15, self.ConnectFailed, self)
end

function GroupCalendar._WhisperSocket:CompleteConnection(pPlayerName, pSocketID, pResponse, pMessage)
	if GroupCalendar.Debug.partners then
		GroupCalendar:DebugMessage("WhisperSocket:CompleteConnection(%s, %s, %s, %s)", tostring(pPlayerName), tostring(pSocketID), tostring(pResponse), tostring(pMessage))
	end
	
	local vMessage = pResponse
	
	if pMessage then
		vMessage = vMessage.."/"..pMessage
	end
	
	self.PlayerName = pPlayerName
	self.State = "CONNECTED"
	self.DestSocketID = pSocketID
	self:Send(vMessage)
end

function GroupCalendar._WhisperSocket:ConnectFailed(pReason)
	if GroupCalendar.Debug.partners then
		GroupCalendar:DebugMessage("WhisperSocket:ConnectFailed(%s)", tostring(pReason))
	end
	
	GroupCalendar.SchedulerLib:UnscheduleTask(self.ConnectFailed, self)
	
	self.State = "CLOSED"
	self.Client:ConnectFailed(self, pReason or "TIMEOUT", self.PlayerName)
end

function GroupCalendar._WhisperSocket:Close()
	self.State = "CLOSING"
	self:CancelSend()
	self:Send("CLOSE")
end

function GroupCalendar._WhisperSocket:Closed()
	self.State = "CLOSED"
	
	if self.Client then
		self.Client:ConnectionClosed()
	end
end

function GroupCalendar._WhisperSocket:Send(pMessage)
	if GroupCalendar.Debug.partners then
		--GroupCalendar:DebugMessage("WhisperSocket:Send(%s, %s)", tostring(pMessage), tostring(pTimeout))
	end
	
	self.Timeout = 10
	
	table.insert(self.SendQueue, pMessage)
	
	if #self.SendQueue == 1 then
		self.WhisperSockets:QueueSend(self)
	end
end

function GroupCalendar._WhisperSocket:CancelSend()
	for vKey, _ in pairs(self.SendQueue) do
		self.SendQueue[vKey] = nil
	end
	
	GroupCalendar.WhisperSockets:CancelSend(self)
end

function GroupCalendar._WhisperSocket:SendSucceeded()
	if GroupCalendar.Debug.partners then
		-- too noisy GroupCalendar:DebugMessage("WhisperSocket:SendSucceeded()")
	end
	
	table.remove(self.SendQueue, 1)
	
	if self.Client.SendProgress then
		self.Client:SendProgress(#self.SendQueue)
	end
	
	if #self.SendQueue > 0 then
		self.WhisperSockets:QueueSend(self)
	elseif self.State == "CONNECTED" then
		self.Client:SendSucceeded(self)
	end
end

function GroupCalendar._WhisperSocket:SendFailed(pResult)
	if GroupCalendar.Debug.partners then
		GroupCalendar:DebugMessage("WhisperSocket:SendFailed(%s)", tostring(pResult))
	end
	
	if self.State == "CONNECTING" then
		self:ConnectFailed(pResult)
	elseif self.State == "CONNECTED" then
		self:CancelSend()
		self.Client:SendFailed(self, pResult)
	end
end

function GroupCalendar._WhisperSocket:Receive(pSourceSocketID, pMessage)
	if GroupCalendar.Debug.partners then
		GroupCalendar:DebugMessage("WhisperSocket:Receive(%s, %s) State=%s", tostring(pSourceSocketID), tostring(pMessage), tostring(self.State))
	end
	
	if self.State == "CONNECTING" then
		local vStartIndex, vEndIndex, vConnectionType = pMessage:find("([^/]+)/?")
		
		if not vStartIndex then
			if GroupCalendar.Debug.partners then
				GroupCalendar:DebugMessage("Receive: Couldn't find connection type in %s", tostring(pMessage))
			end
			
			return
		end
		
		local vMessage = pMessage:sub(vEndIndex + 1)
		
		if vConnectionType == self.ConnectionType then
			GroupCalendar.SchedulerLib:UnscheduleTask(self.ConnectFailed, self)
			
			self.DestSocketID = pSourceSocketID
			
			self.State = "CONNECTED"
			self.Client:Connected(self, vMessage)
		else
			if GroupCalendar.Debug.partners then
				GroupCalendar:DebugMessage("Receive: Connection failed, ConnectionType mismatch %s should be %s", tostring(vConnectionType), tostring(self.ConnectionType))
			end
			
			self:ConnectFailed("CONNECTION_TYPE_MISMATCH")
		end
	elseif self.State == "CONNECTED" then
		self.Client:Receive(self, pMessage)
	end
end

----------------------------------------
GroupCalendar._WhisperSockets = {}
----------------------------------------

function GroupCalendar._WhisperSockets:Construct()
	-- Install the chat filter
	
	if not GroupCalendar.ChatFilter then
		GroupCalendar.ChatFilter = GroupCalendar:New(GroupCalendar._ChatFilter)
	end
	
	GroupCalendar.EventLib:RegisterEvent("CHAT_MSG_WHISPER", self.ChatMsgWhisper, self)
	GroupCalendar.EventLib:RegisterEvent("CHAT_MSG_WHISPER_INFORM", self.ChatMsgWhisperInform, self)
	
	-- Initialize the sockets
	
	self.LastSocketID = 0
	self.Sockets = {}
	self.Listeners = {}
	
	self.SendQueue = {}
end

function GroupCalendar._WhisperSockets:Connect(pPlayerName, pClient, pConnectionType, pMessage)
	local vSocket = GroupCalendar:New(GroupCalendar._WhisperSocket, pPlayerName, pClient, pConnectionType, self)
	
	self.Sockets[vSocket.SocketID] = vSocket
	
	vSocket:Connect(pMessage)
	
	return vSocket
end

function GroupCalendar._WhisperSockets:Listen(pClient, pConnectionType)
	self.Listeners[pConnectionType] = pClient
end

function GroupCalendar._WhisperSockets:ConnectionRequest(pSender, pSourceSocketID, pConnectionType, pMessage)
	local vClient = self.Listeners[pConnectionType]
	
	if not vClient then
		return
	end
	
	vClient:ConnectionRequest(pSender, pSourceSocketID, pConnectionType, pMessage)
end

function GroupCalendar._WhisperSockets:CompleteConnection(pPlayerName, pClient, pSocketID, pConnectionType, pResponse)
	local vSocket = GroupCalendar:New(GroupCalendar._WhisperSocket, pPlayerName, pClient, pConnectionType, self)
	
	self.Sockets[vSocket.SocketID] = vSocket
	
	vSocket:CompleteConnection(pPlayerName, pSocketID, pConnectionType, pResponse)
	
	return vSocket
end

function GroupCalendar._WhisperSockets:QueueSend(pSocket)
	table.insert(self.SendQueue, pSocket)
	
	if not self.LastMessage then
		self:SendNextWhisper()
	end
end

function GroupCalendar._WhisperSockets:SendNextWhisper()	
	-- Just return if a message is already in-flight
	
	if self.LastMessage then
		return
	end
	
	-- Send the next message
	
	local vSocket = self.SendQueue[1]
	
	if not vSocket then
		return -- No messages waiting
	end
	
	self.LastMessage = GroupCalendar:EscapeChatString(GroupCalendar.PartnerSyncPrefix..vSocket.DestSocketID..","..(vSocket.State == "CLOSING" and 0 or vSocket.SocketID).."/"..vSocket.SendQueue[1])
	
	GroupCalendar.ChatFilter:SetFilterNotFoundPlayer(vSocket.PlayerName, self)
	
	local vSavedAutoClearAFK = GetCVar("autoClearAFK")
	SetCVar("autoClearAFK", 0)
	
	SendChatMessage(self.LastMessage, "WHISPER", nil, vSocket.PlayerName)
	
	SetCVar("autoClearAFK", vSavedAutoClearAFK)
	
	GroupCalendar.SchedulerLib:ScheduleTask(vSocket.Timeout, self.SendTimeout, self)
end

function GroupCalendar._WhisperSockets:SendFailed(pReason)
	GroupCalendar.SchedulerLib:UnscheduleTask(self.SendTimeout, self)
	
	local vSocket = table.remove(self.SendQueue, 1)
	
	self.LastMessage = nil
	
	vSocket:SendFailed(pReason)
	
	self:SendNextWhisper()
end

function GroupCalendar._WhisperSockets:PlayerNotFound(pPlayerName)
	self:SendFailed("NOT_FOUND")
end

function GroupCalendar._WhisperSockets:SendTimeout()
	self:SendFailed("TIMEOUT")
end

function GroupCalendar._WhisperSockets:CancelSend(pSocket)
	for vSendIndex, vSendSocket in ipairs(self.SendQueue) do
		if vSendSocket == pSocket then
			table.remove(self.SendQueue, vSendIndex)
			break
		end
	end
end

function GroupCalendar._WhisperSockets:ClosedSocket(pSocket)
	self:CancelSend(pSocket)
	
	self.Sockets[pSocket.SocketID] = nil

	pSocket:Closed()
end

function GroupCalendar._WhisperSockets:GetMessageEnvelope(pMessage)
	local vMessage = GroupCalendar:UnescapeChatString(pMessage)
	
	-- Verify the prefix and remove it
	
	if vMessage:sub(1, GroupCalendar.PartnerSyncPrefixLen) ~= GroupCalendar.PartnerSyncPrefix then
		return
	end
	
	vMessage = vMessage:sub(GroupCalendar.PartnerSyncPrefixLen)
	
	-- Extract and validate the socket ID
	
	local vStartIndex, vEndIndex, vSocketID, vSourceSocketID = vMessage:find("(%d+),(%d+)/")
	
	if not vStartIndex then
		return
	end
	
	return tonumber(vSocketID), tonumber(vSourceSocketID), vMessage:sub(vEndIndex + 1)
end

function GroupCalendar._WhisperSockets:ChatMsgWhisper(pEvent, ...)
	local vSocketID, vSourceSocketID, vMessage = self:GetMessageEnvelope(select(1, ...))
	local vSender = select(2, ...)
	
	if not vSocketID then
		return
	end
	
	-- Check for a connection request
	
	if vSocketID == 0 then
		local vStartIndex, vEndIndex, vConnectionType = vMessage:find("([^/]+)/?")
		
		if not vStartIndex then
			if GroupCalendar.Debug.partners then
				GroupCalendar:DebugMessage("ChatMsgWhisper: Connection request from %s %s couldn't find connection type", tostring(vSender), tostring(vMessage))
			end
			
			return
		end
		
		local vMessage = vMessage:sub(vEndIndex + 1)
		
		if GroupCalendar.Debug.partners then
			GroupCalendar:DebugMessage("ChatMsgWhisper: ConnectionRequest(%s, %s, %s, %s)", tostring(vSender), tostring(vSourceSocketID), tostring(vConnectionType), tostring(vMessage))
		end
		
		self:ConnectionRequest(vSender, vSourceSocketID, vConnectionType, vMessage)
		return
	end
	
	local vSocket = self.Sockets[vSocketID]
	
	if not vSocket then
		return
	end
	
	-- Closing connection
	
	if vSourceSocketID == 0 then
		self:ClosedSocket(vSocket)
		return
	end
	
	if vSocket.DestSocketID ~= 0
	and vSocket.DestSocketID ~= vSourceSocketID then
		return
	end
	
	-- Validate the sender
	
	if vSender ~= vSocket.PlayerName then
		return
	end
	
	-- Deliver the message
	
	vSocket:Receive(vSourceSocketID, vMessage)
end

function GroupCalendar._WhisperSockets:ChatMsgWhisperInform(pEvent, ...)
	local vMessage = select(1, ...)
	
	if vMessage ~= self.LastMessage then
		return
	end
	
	self.LastMessage = nil
	GroupCalendar.ChatFilter:SetFilterNotFoundPlayer(nil)
	
	GroupCalendar.SchedulerLib:UnscheduleTask(self.SendTimeout, self)
	
	local vSocket = table.remove(self.SendQueue, 1)
	
	if vSocket.State == "CLOSING" then
		self:ClosedSocket(vSocket)
	else
		vSocket:SendSucceeded()
	end
	
	self:SendNextWhisper()
end

----------------------------------------
GroupCalendar._ChatFilter = {}
----------------------------------------

GroupCalendar._ChatFilter.cPlayerNotFoundPattern = GroupCalendar:ConvertFormatStringToSearchPattern(ERR_CHAT_PLAYER_NOT_FOUND_S)

function GroupCalendar._ChatFilter:Construct()
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", function (...) return self:WhisperEventFilter(...) end)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", function (...) return self:WhisperEventFilter(...) end)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function (...) return self:SystemEventFilter(...) end)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_AFK", function (...) return self:AFKEventFilter(...) end)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_DND", function (...) return self:AFKEventFilter(...) end)
end

function GroupCalendar._ChatFilter:WhisperEventFilter(pChatFrame, pEvent, pMessage, ...)
	if GroupCalendar.Debug.partners then
		return false
	end
	
	return pMessage:sub(1, GroupCalendar.PartnerSyncPrefixLen) == GroupCalendar.PartnerSyncPrefix
end

function GroupCalendar._ChatFilter:SetFilterNotFoundPlayer(pPlayerName, pClient)
	self.FilterNotFoundPlayer = pPlayerName
	self.FilterNotFoundClient = pClient
	self.DidFilterNotFoundPlayer = false
	
	if pPlayerName then -- Don't clear the AFK filter with the NotFound filter since AFK replies come after the confirmation whisper
		self.FilterAFKPlayer = pPlayerName
		GroupCalendar.SchedulerLib:RescheduleTask(5, self.ClearAFKPlayer, self)
	end
end

function GroupCalendar._ChatFilter:ClearAFKPlayer()
	self.FilterAFKPlayer = nil
end

function GroupCalendar._ChatFilter:SystemEventFilter(pChatFrame, pEvent, pMessage, ...)
	if not self.FilterNotFoundPlayer then
		return false
	end
	
	local _, _, vPlayerName = pMessage:find(self.cPlayerNotFoundPattern)
	
	if vPlayerName ~= self.FilterNotFoundPlayer then
		if vPlayerName then
			self.FilterNotFoundPlayer = nil
			self.FilterNotFoundClient = nil
			self.DidFilterNotFoundPlayer = nil
		end
		
		return false
	end
	
	if self.DidFilterNotFoundPlayer then
		return true
	end
	
	self.DidFilterNotFoundPlayer = true
	
	self.FilterNotFoundClient:PlayerNotFound(vPlayerName)
	
	return true
end

function GroupCalendar._ChatFilter:AFKEventFilter(pChatFrame, pEvent, pMessage, pPlayerName, ...)
	return pPlayerName == self.FilterAFKPlayer
end

----------------------------------------
--
----------------------------------------

GroupCalendar.EventLib:RegisterCustomEvent("GC5_INIT", GroupCalendar.Partnerships.Initialize, GroupCalendar.Partnerships)
