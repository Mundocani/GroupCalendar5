local _, Addon = ...

----------------------------------------
Addon.RaidLib =
----------------------------------------
{
	Version = 1,
	NumPlayers = 0,
	Players = {},
	PlayersByName = {},
	PlayersByUnitID = {},
	PlayerInCombat = false,
	PlayerInRaid = false,
}

function Addon.RaidLib:Initialize()
	-- Listen for changes to the raid
	Addon.EventLib:RegisterEvent("PLAYER_LOGIN", self.Synchronize, self, true)
	Addon.EventLib:RegisterEvent("GROUP_ROSTER_UPDATE", self.Synchronize, self, true)
	Addon.EventLib:RegisterEvent("PARTY_LEADER_CHANGED", self.Synchronize, self, true)
	Addon.EventLib:RegisterEvent("UNIT_NAME_UPDATE", self.Synchronize, self, true)

	-- Combat
	Addon.EventLib:RegisterEvent("PLAYER_ENTERING_WORLD", self.PlayerCombatStop, self, true)
	Addon.EventLib:RegisterEvent("PLAYER_REGEN_ENABLED", self.PlayerCombatStop, self, true)
	Addon.EventLib:RegisterEvent("PLAYER_REGEN_DISABLED", self.PlayerCombatStart, self, true)
	
	self:Synchronize()
end	

function Addon.RaidLib:Synchronize()
	-- Mark all existing players as unused
	
	for vPlayerName, vPlayerInfo in pairs(self.PlayersByName) do
		vPlayerInfo.Unused = true
	end
	
	-- Update/add members
	
	local vNumGroupMembers = GetNumGroupMembers()
	local vRaidLeaderZoneChanged = false
	local vRaidChanged
	
	self.NumPlayers = 0
	
	-- Update raid status
	if IsInRaid() and not self.PlayerInRaid then
		self.PlayerInRaid = true
		Addon.EventLib:DispatchEvent("JOINED_RAID")
	elseif not IsInRaid() and self.PlayerInRaid then
		self.PlayerInRaid = false
		Addon.EventLib:DispatchEvent("LEFT_RAID")
		vRaidChanged = true
	end
	
	if vNumGroupMembers > 0 then
		for vIndex = 1, vNumGroupMembers do
			local vName,
			      vRank,
			      vSubgroup,
			      vLevel,
			      vClassName,
			      vClassID,
			      vZone,
			      vOnline,
			      vIsDead,
			      vRole,
			      vMasterLooter = GetRaidRosterInfo(vIndex)
			
			local vOffline = not vOnline
			
			if vName and vClassID then
				local vUnitID = IsInRaid() and "raid"..vIndex or "party"..vIndex
				local vPlayerInfo, vNewPlayer = self:AddPlayer(vName, vClassName, vClassID, vUnitID)
		
				self.NumPlayers = self.NumPlayers + 1
				
				if vPlayerInfo.Rank ~= vRank then
					vPlayerInfo.Rank = vRank
					vPlayerInfo.StatusChanged = true
				end
				
				if vPlayerInfo.Offline ~= not vOnline then
					vPlayerInfo.Offline = not vOnline
					vPlayerInfo.StatusChanged = true
				end
				
				if vPlayerInfo.Level ~= vLevel then
					vPlayerInfo.Level = vLevel
					vPlayerInfo.StatusChanged = true
				end
				
				if vNewPlayer then
					vPlayerInfo.Constructing = nil
					Addon.EventLib:DispatchEvent("PLAYER_JOINED", vPlayerInfo)
					vRaidChanged = true
				end
			end
		end
	else
		-- Add the player
		local vUnitID = "player"
		local vName = UnitName(vUnitID)
		local vClassName, vClassID = UnitClass(vUnitID)
		
		if vName and vClassID then
			local vPlayerInfo, vNewPlayer = self:AddPlayer(vName, vClassName, vClassID, vUnitID)
			local vRank = 2
			local vLevel = UnitLevel(vUnitID)
			
			if vPlayerInfo.Rank ~= vRank then
				vPlayerInfo.Rank = vRank
				vPlayerInfo.StatusChanged = true
			end
			
			if vPlayerInfo.Party ~= 1 then
				vPlayerInfo.Party = 1
				vPlayerInfo.StatusChanged = true
			end
			
			if vPlayerInfo.Level ~= vLevel then
				vPlayerInfo.Level = vLevel
				vPlayerInfo.StatusChanged = true
			end
			
			if vPlayerInfo.Offline ~= not UnitIsConnected(vUnitID) then
				vPlayerInfo.Offline = not UnitIsConnected(vUnitID)
				vPlayerInfo.StatusChanged = true
			end
			
			self.NumPlayers = self.NumPlayers + 1

			if vNewPlayer then
				vPlayerInfo.Constructing = nil
				Addon.EventLib:DispatchEvent("PLAYER_JOINED", vPlayerInfo)
			end
		end -- if vName and vClassID
	end -- else
	
	-- Clear any unused players from the ID map
	
	for vUnitID, vPlayerInfo in pairs(self.PlayersByUnitID) do
		if vPlayerInfo.Unused or vPlayerInfo.UnitID ~= vUnitID then
			self.PlayersByUnitID[vUnitID] = nil
			vRaidChanged = true
		end
	end
	
	-- Free any players who've left the raid
	
	for vPlayerName, vPlayerInfo in pairs(self.PlayersByName) do
		if vPlayerInfo.Unused then
			self.PlayersByName[vPlayerName] = nil
			self:NotifyUnit(vPlayerInfo, "UNIT_DELETED")
			vRaidChanged = true
		else
			if vPlayerInfo.StatusChanged then
				self:NotifyUnit(vPlayerInfo, "STATUS_CHANGED")
				vPlayerInfo.StatusChanged = nil
				vRaidChanged = true
			end
		end
	end
	
	-- Rebuild the alphabetical list of players
	
	for vKey, _ in pairs(self.Players) do
		self.Players[vKey] = nil
	end
	
	if vRaidChanged then
		Addon.EventLib:DispatchEvent("MC2RAIDLIB_RAID_CHANGED", self)
	end
end

function Addon.RaidLib:GetSortedPlayers()
	if #self.Players ~= self.NumPlayers then
		for vKey, _ in pairs(self.Players) do
			self.Players[vKey] = nil
		end
		
		for vPlayerName, vPlayerInfo in pairs(self.PlayersByName) do
			table.insert(self.Players, vPlayerInfo)
		end
		
		table.sort(self.Players, function (pPlayer1, pPlayer2) return pPlayer1.Name < pPlayer2.Name end)
	end
	
	return self.Players
end

function Addon.RaidLib:AddPlayer(pPlayerName, pClassName, pClassID, pUnitID)
	local vPlayerInfo = self.PlayersByName[pPlayerName]

	if vPlayerInfo then
		vPlayerInfo.Unused = nil
		
		if vPlayerInfo.UnitID ~= pUnitID then
			vPlayerInfo.UnitID = pUnitID
			self.PlayersByUnitID[pUnitID] = vPlayerInfo
			vPlayerInfo.StatusChanged = true
		end
		
		return vPlayerInfo, false
	else
		vPlayerInfo =
		{
			Name = pPlayerName,
			ClassName = pClassName,
			ClassID = pClassID,
			UnitID = pUnitID,
			Constructing = true,
		}
		
		self.PlayersByName[pPlayerName] = vPlayerInfo
		self.PlayersByUnitID[pUnitID] = vPlayerInfo
		
		return vPlayerInfo, true
	end
end

function Addon.RaidLib:Subscribe(pPlayerInfo, pFunction, pParam)
	if not pPlayerInfo.Subscribers then
		pPlayerInfo.Subscribers = {}
	end
	
	table.insert(pPlayerInfo.Subscribers, {Function = pFunction, Param = pParam})
end

function Addon.RaidLib:Unsubscribe(pPlayerInfo, pFunction, pParam)
	if not pPlayerInfo.Subscribers then
		pPlayerInfo.Subscribers = {}
	end
	
	for vIndex, vSubscriber in ipairs(pPlayerInfo.Subscribers) do
		if (pFunction == nil or pFunction == vSubscriber.Function)
		and (pParam == nil or pParam == vSubscriber.Param) then
			table.remove(pPlayerInfo.Subscribers, vIndex)
			return
		end
	end
end

function Addon.RaidLib:NotifyUnit(pPlayerInfo, ...)
	if not pPlayerInfo.Subscribers then
		return
	end
	
	for vIndex, vSubscriber in ipairs(pPlayerInfo.Subscribers) do
		vSubscriber.Function(vSubscriber.Param, pPlayerInfo, ...)
	end
end

function Addon.RaidLib:PlayerCombatStart()
	self.PlayerInCombat = true
	Addon.SchedulerLib:SetTaskInterval(1.5, self.Synchronize, self)
end

function Addon.RaidLib:PlayerCombatStop()
	self.PlayerInCombat = false
	Addon.SchedulerLib:SetTaskInterval(0.5, self.Synchronize, self)
end

function Addon.RaidLib:RaidInCombat()
	if self.PlayerInCombat then
		return true
	end
	
	for vPlayerName, vPlayerInfo in pairs(self.PlayersByName) do
		if UnitAffectingCombat(vPlayerInfo.UnitID) then
			return true
		end
	end
	
	return false
end

function Addon.RaidLib:FindUnitWithTarget(pTargetName)
	for vPlayerName, vPlayerInfo in pairs(self.PlayersByName) do
		if UnitExists(vPlayerInfo.UnitID)
		and UnitExists(vPlayerInfo.UnitID.."target")
		and UnitName(vPlayerInfo.UnitID.."target") == pTargetName then
			return vPlayerInfo.UnitID
		end
	end
	
	return nil
end

function Addon.RaidLib:PlayerIsLeader(pPlayerName)
	vPlayerInfo = self.PlayersByName[pPlayerName]
	
	return vPlayerInfo ~= nil and vPlayerInfo.Rank == 2
end

function Addon.RaidLib:PlayerIsAssistant(pPlayerName)
	vPlayerInfo = self.PlayersByName[pPlayerName]
	
	return vPlayerInfo ~= nil and vPlayerInfo.Rank == 1
end

Addon.RaidLib:Initialize()
