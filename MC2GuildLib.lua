local _, Addon = ...

Addon.GuildLib = {}

Addon.GuildLib.ClassNameToClassID = {}

for _, vClassID in ipairs(CLASS_SORT_ORDER) do
	Addon.GuildLib.ClassNameToClassID[LOCALIZED_CLASS_NAMES_MALE[vClassID]] = vClassID
	Addon.GuildLib.ClassNameToClassID[LOCALIZED_CLASS_NAMES_FEMALE[vClassID]] = vClassID
end

function Addon.GuildLib:Initialize()
	self.Roster = {}
	self:ActivateRosterData(self.Roster)
	
	Addon.EventLib:RegisterEvent("GUILD_ROSTER_UPDATE", self.OnEvent, self)
	Addon.EventLib:RegisterEvent("PLAYER_GUILD_UPDATE", self.OnEvent, self)
	Addon.EventLib:RegisterEvent("GROUP_ROSTER_UPDATE", self.OnEvent, self)
	
	-- Force the guild roster to update periodically

	Addon.SchedulerLib:ScheduleRepeatingTask(60, self.RequestGuildRosterUpdate, self, 10)
	
	self.Roster:Synchronize()
end

function Addon.GuildLib:RequestGuildRosterUpdate()
	if IsInGuild() then
		GuildRoster()
	end
end

function Addon.GuildLib:OnEvent(pEventID)
	if pEventID == "GUILD_ROSTER_UPDATE"
	or pEventID == "PLAYER_GUILD_UPDATE"
	or pEventID == "GROUP_ROSTER_UPDATE" then
		if Addon.SchedulerLib:FindTask(self.Roster.Synchronize, self.Roster) then
			return
		end
		
		Addon.SchedulerLib:ScheduleTask(2, self.Roster.Synchronize, self.Roster)
	end
end

function Addon.GuildLib:NewRosterData(pGuildName)
	local vRoster = {}
	
	self:ActivateRosterData(vRoster)
	
	vRoster.GuildName = pGuildName
	
	return vRoster
end

function Addon.GuildLib:ActivateRosterData(pRosterData)
	setmetatable(pRosterData, self._RosterMetaTable)
	
	if pRosterData.Players then
		for _, vPlayerInfo in pairs(pRosterData.Players) do
			vPlayerInfo.Offline = nil
			vPlayerInfo.DaysOffline = nil
			vPlayerInfo.IsAFK = nil
			vPlayerInfo.Zone = nil
			vPlayerInfo.Party = nil
		end
	else
		pRosterData:Construct()
	end
end

function Addon.GuildLib:GetPlayer(pPlayerName)
	return self.Roster.Players[pPlayerName]
end

----------------------------------------
Addon.GuildLib._RosterMethods = {}
Addon.GuildLib._RosterMetaTable = {__index = Addon.GuildLib._RosterMethods}
----------------------------------------

function Addon.GuildLib._RosterMethods:Construct()
	self.GuildName = nil
	self.Players = {}
	self.Ranks = {}
	self.Mains = {}
end

function Addon.GuildLib._RosterMethods:AddPlayer(pPlayerName, pClassID)
	local vPlayerInfo = self.Players[pPlayerName]
	
	if vPlayerInfo then
		vPlayerInfo.Unused = nil
		
		return vPlayerInfo, false
	else
		vPlayerInfo = self:NewPlayerInfo(pPlayerName, pClassID)
		
		self.Players[pPlayerName] = vPlayerInfo
		
		vPlayerInfo.Constructing = true
		
		return vPlayerInfo, true
	end
end

function Addon.GuildLib._RosterMethods:Synchronize()
	self.GuildName = GetGuildInfo("player")
	self.BackgroundTop, self.BackgroundBottom, self.EmblemTop, self.EmblemBottom, self.BorderTop, self.BorderBottom = GetGuildTabardFileNames()
	
	-- Mark existing members as unused
	
	for vPlayerName, vPlayerInfo in pairs(self.Players) do
		vPlayerInfo.Unused = true
	end
	
	-- Update/add members
	
	local vMembersAddedOrRemoved
	
	for k, _ in pairs(self.Ranks) do
		self.Ranks[k] = nil
	end
	
	local vNumGuildMembers
	
	if IsInGuild() then
		vNumGuildMembers = GetNumGuildMembers(true)
		
		local vNumRanks = GuildControlGetNumRanks()
		
		for vIndex = 1, vNumRanks do
			self.Ranks[vIndex] = GuildControlGetRankName(vIndex)
		end
	else
		vNumGuildMembers = 0
	end

	for vIndex = 1, vNumGuildMembers do
		local vName, vRank, vRankIndex, vLevel, vClass, vZone, vNote, vOfficerNote, vOnline, vStatus = GetGuildRosterInfo(vIndex)
		local vYearsOffline, vMonthsOffline, vDaysOffline, vHoursOffline = GetGuildRosterLastOnline(vIndex)
		
		local vOffline = not vOnline
		local vClassID = Addon.GuildLib.ClassNameToClassID[vClass]
		
		if vName then
			vName = Ambiguate(vName, "none")
			local vPlayerInfo, vNewPlayer = self:AddPlayer(vName, vClassID)
			local vStatusChanged = vNewPlayer
			local vIsAFK = vStatus == "<AFK>"
			
			--
			
			vPlayerInfo.IsDead = nil -- Don't know
			
			if vPlayerInfo.GuildRank ~= vRankIndex then
				vPlayerInfo.GuildRank = vRankIndex
				vStatusChanged = true
			end
			
			if vPlayerInfo.Offline ~= vOffline then
				vPlayerInfo.Offline = vOffline
				vStatusChanged = true
			end
			
			if not vDaysOffline or not vPlayerInfo.Offline then
				vDaysOffline = 0
			end
			
			if vPlayerInfo.DaysOffline ~= vDaysOffline then
				vPlayerInfo.DaysOffline = vDaysOffline
				vStatusChanged = true
			end
			
			if vPlayerInfo.Zone ~= vZone then
				vPlayerInfo.Zone = vZone
				vStatusChanged = true
			end
			
			if vPlayerInfo.Level ~= vLevel then
				vPlayerInfo.Level = vLevel
				vStatusChanged = true
			end
			
			if vPlayerInfo.IsAFK ~= vIsAFK then
				vPlayerInfo.IsAFK = vIsAFK
				vStatusChanged = true
			end
			
			if vPlayerInfo.Note ~= vNote then
				vStatusChanged = true
				vPlayerInfo.Note = vNote
				vPlayerInfo.CheckMain = true
			end
			
			if vPlayerInfo.OfficerNote ~= vOfficerNote then
				vStatusChanged = true
				vPlayerInfo.OfficerNote = vOfficerNote
				vPlayerInfo.CheckMain = true
			end
			
			vPlayerInfo.Party = nil -- Not in the raid
			
			if vStatusChanged then
				self:UnitStatusChanged(vPlayerInfo)
			end

			if vNewPlayer then
				vMembersAddedOrRemoved = true
				vPlayerInfo.Constructing = nil
				Addon.EventLib:DispatchEvent("GUILD_MEMBER_ADDED", vPlayerInfo)
			end
		end
	end
	
	-- Free any members who've left the guild
	
	for vPlayerName, vPlayerInfo in pairs(self.Players) do
		if vPlayerInfo.Unused then
			vMembersAddedOrRemoved = true
			self.Players[vPlayerName] = nil
			self.Mains[vPlayerName] = nil
			
			Addon.EventLib:DispatchEvent("GUILD_MEMBER_DELETED", vPlayerInfo)
		end
	end
	
	self:UpdateMains(vMembersAddedOrRemoved)
end

function Addon.GuildLib._RosterMethods:SetMainsPattern(pPattern, pSkipOfficerNote)
	self.SkipOfficerNote = pSkipOfficerNote
	
	if pPattern then
		-- Escape magic characters
		
		local vPattern = pPattern:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", function (c) return "%"..c end)
		
		-- Change the 'playername' token
		
		local vStartIndex, vEndIndex = vPattern:lower():find("playername")
		
		if not vStartIndex then
			return false, "Missing playername token"
		end
		
		self.MainsPattern = vPattern:sub(1, vStartIndex - 1).."([^%c%p%s]+)"..vPattern:sub(vEndIndex + 1)
	else
		self.MainsPattern = nil
	end
	
	self:UpdateMains(true)
end

function Addon.GuildLib._RosterMethods:UpdateMains(pForceUpdate)
	if pForceUpdate then
		for vKey, _ in pairs(self.Mains) do
			self.Mains[vKey] = nil
		end
	end
	
	for vPlayerName, vPlayerInfo in pairs(self.Players) do
		if vPlayerInfo.CheckMain or pForceUpdate then
			local vMain = self:FindMainCharacter(vPlayerName)
			
			vPlayerInfo.CheckMain = nil
			
			self.Mains[vPlayerName] = vMain
			
			if vMain ~= vPlayerInfo.MainName then
				vPlayerInfo.MainName = vMain
				
				self:UnitStatusChanged(vPlayerInfo)
			end
		end
	end
end

function Addon.GuildLib._RosterMethods:AllUnitStatusChanged()
	for vPlayerName, vPlayerInfo in pairs(self.Players) do
		if not vPlayerInfo.Offline then
			self:UnitStatusChanged(vPlayerInfo)
		end
	end
end

function Addon.GuildLib._RosterMethods:UnitStatusChanged(pPlayerInfo)
	if pPlayerInfo.Constructing then
		return
	end
	
	Addon.EventLib:DispatchEvent("GUILD_MEMBER_STATUS_CHANGED", pPlayerInfo)
end

function Addon.GuildLib._RosterMethods:FindMainCharacter(pPlayerName)
	local vPlayerName = Ambiguate(pPlayerName, "guild")
	local vPlayerInfo = self.Players[vPlayerName]
	
	if not vPlayerInfo
	or not vPlayerInfo.Note then
		return
	end
	
	-- Search the player note for a guild member's name
	local vName = self:FindCharacterInNote(vPlayerName, vPlayerInfo.Note)
	
	-- If one wasn't found, try the officer note instead if it's available
	if not vName and vPlayerInfo.OfficerNote and not self.SkipOfficerNote then
		vName = self:FindCharacterInNote(vPlayerName, vPlayerInfo.OfficerNote)
	end
	
	return vName
end

function Addon.GuildLib._RosterMethods:FindCharacterInNote(pPlayerName, pNote)
	local vPlayerName = Ambiguate(pPlayerName, "guild")
	if self.MainsPattern then
		local _, _, vName = pNote:find(self.MainsPattern)
		
		return vName
	else
		for vName in pNote:gmatch("([^%c%p%s]+)") do
			local vMainPlayerInfo = self.Players[vName]
			
			if vMainPlayerInfo and vName ~= vPlayerName then
				return vName
			end
		end
	end
end

function Addon.GuildLib._RosterMethods:FindOnlineCharacter(pPlayerName)
	local vPlayerName = Ambiguate(pPlayerName, "guild")
	local vPlayerInfo = self.Players[vPlayerName]
	local vLowerPlayerName = vPlayerName:lower()
	
	if not vPlayerInfo then
		for vName, vPlayerInfo2 in pairs(self.Players) do
			if vName:lower() == vLowerPlayerName then
				vPlayerName = vName
				vPlayerInfo = vPlayerInfo2
				break
			end
		end
	end
	
	if not vPlayerInfo then
		return
	end
	
	if not vPlayerInfo.Offline then
		return vPlayerName, vPlayerName
	end
	
	for vAltName, vMainName in pairs(self.Mains) do
		if vMainName:lower() == vLowerPlayerName then
			vPlayerInfo = self.Players[vAltName]
			
			if vPlayerInfo and not vPlayerInfo.Offline then
				return vAltName, vPlayerName
			end
		end
		
		if vAltName:lower() == vLowerPlayerName then
			vPlayerInfo = self.Players[vMainName]
			
			if vPlayerInfo and not vPlayerInfo.Offline then
				return vMainName, vPlayerName
			end
		end
	end
end

function Addon.GuildLib._RosterMethods:NewPlayerInfo(pPlayerName, pClassID)
	return
	{
		Name = pPlayerName,
		ClassID = pClassID,
	}
end

Addon.GuildLib:Initialize()
