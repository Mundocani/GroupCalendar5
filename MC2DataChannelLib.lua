local _, Addon = ...

Addon.DataChannelLib =
{
	Version = 1,
	
	ChannelInfo = {},
	EventIDs = {},
	ChatChannelsReady = false,
	
	SpecialChannelIDs =
	{
		["#GUILD"] = "GUILD",
		["#PARTY"] = "PARTY",
		["#RAID"] = "RAID",
		["#BATTLEGROUND"] = "BATTLEGROUND",
	},
	
	MaxSendBytesPerSecond = 800,
	NextSendTime = 0,
	RetransmitInterval = 15,
	
	PlayerName = UnitName("player"),
}

function Addon.DataChannelLib:NewChannel(pPrefix, pMessageFunction, pClientRef)
	local vChannelClient =
	{
		Prefix = pPrefix,
		MessageFunction = pMessageFunction,
		ClientRef = pClientRef,
		
		Open = false,
		Name = nil,
		Password = nil,
		
		Delete = self.Delete,
		
		OpenChannel = self.OpenChannel,
		CloseChannel = self.CloseChannel,
		
		SendMessage = self.SendMessageToChannel,
		SendMessageToClient = self.SendMessageToClient,
		ResendLastMessage = self.ResendLastMessage,
		SendFailed = self.SendFailed,
		
		ReadyToSend = self.ReadyToSend,
		
		SentMessageQueue = {},
	}
	
	return vChannelClient
end

function Addon.DataChannelLib:OpenChannelClient(pChannelClient, pChannelName, pPassword)
	if not pChannelName then
		self:DebugMessage("OpenChannelClient called with no channel name")
		self:DebugStack()
		return false
	end
	
	-- Create the channel info if necessary
	
	local vUpperChannelName = strupper(pChannelName)
	local vChannelInfo = self.ChannelInfo[vUpperChannelName]
	local vNewChannel = false
	
	if not vChannelInfo then
		vChannelInfo =
		{
			Name = pChannelName,
			UpperName = vUpperChannelName,
			Password = pPassword,
			GotTooManyChannelsMessage = false,
			
			Clients = {},
			WildcardClients = {},
		}
		
		self.ChannelInfo[vUpperChannelName] = vChannelInfo
		
		vChannelInfo.Permanent = self.SpecialChannelIDs[vUpperChannelName] ~= nil
		
		if self.ChatChannelsReady
		or vChannelInfo.Permanent then
			self:JoinChannel(vChannelInfo)
		else
			self:SetChannelStatus(vChannelInfo, "INIT", "Initializing")
		end
	end
	
	-- Add the client
	
	pChannelClient.Name = pChannelName
	pChannelClient.Password = pPassword
	
	if not pChannelClient.Prefix then
		table.insert(vChannelInfo.WildcardClients, pChannelClient)
	else
		vChannelInfo.Clients[pChannelClient.Prefix] = pChannelClient
	end
	
	-- Notify the client of the current status
	
	pChannelClient.Status = vChannelInfo.Status
	pChannelClient.StatusMessage = vChannelInfo.StatusMessage
	
	if vChannelInfo.ID then
		pChannelClient.Connected = true
		pChannelClient:SendMessageToClient("#STATUS", "CONNECTED")
	end
	
	if vChannelInfo.Status ~= "CONNECTED" then
		pChannelClient:SendMessageToClient("#STATUS", vChannelInfo.Status, vChannelInfo.StatusMessage)
	end
	
	return true
end

function Addon.DataChannelLib:CloseChannelClient(pChannelClient)
	local vChannelInfo = self.ChannelInfo[strupper(pChannelClient.Name)]
	
	if not vChannelInfo then
		return false
	end
	
	if not pChannelClient.Prefix then
		local vFoundClient = false
		
		for vIndex, vChannelClient in ipairs(vChannelInfo.WildcardClients) do
			if vChannelClient == pChannelClient then
				table.remove(vChannelInfo.WildcardClients, vIndex)
				vFoundClient = true
				break
			end
		end
		
		if not vFoundClient then
			return false
		end
	else
		if vChannelInfo.Clients[pChannelClient.Prefix] ~= pChannelClient then
			return false
		end
		
		vChannelInfo.Clients[pChannelClient.Prefix] = nil
	end
	
	Addon.SchedulerLib:UnscheduleTask(pChannelClient.ResendLastMessage, pChannelClient) -- Make sure a resend isn't pending
	pChannelClient.SentMessageQueue = {}
	
	pChannelClient.Name = nil
	pChannelClient.Password = nil
	
	pChannelClient.Connected = false
	pChannelClient.Status = "DISCONNECTED"
	pChannelClient.StatusMessage = nil
	pChannelClient:SendMessageToClient("#STATUS", "DISCONNECTED")
	
	-- Just return if there are still more clients
	
	if #vChannelInfo.WildcardClients > 0 then
		return true
	end
	
	for vClientPrefix, vChannelClient in pairs(vChannelInfo.Clients) do
		return true
	end
	
	-- Otherwise shut down the channel
	
	self:LeaveChannel(vChannelInfo)
	self.ChannelInfo[vChannelInfo.UpperName] = nil
	
	return true
end

function Addon.DataChannelLib:JoinChannel(pChannelInfo)
	if pChannelInfo.Permanent then
		if not pChannelInfo.ID then
			-- Addon.DebugLib:TestMessage("JoinChannel: Joining permanent channel "..pChannelInfo.Name)
			
			pChannelInfo.ID = self.SpecialChannelIDs[pChannelInfo.UpperName]
			
			if pChannelInfo.ID == "GUILD" and not IsInGuild() then
				pChannelInfo.ID = nil
				pChannelInfo.Open = false
				self:SetChannelStatus(pChannelInfo, "ERROR", "Not in a guild")
				return false
			end
			
			pChannelInfo.Open = true
			
			self:SetChannelStatus(pChannelInfo, "CONNECTED")
			self:SetChannelStatus(pChannelInfo, "READY_TO_SEND")
		end
	else
		local vChannelID = GetChannelName(pChannelInfo.Name)
		
		-- If the channel isn't already present attempt to join it
		
		if not vChannelID
		or vChannelID == 0 then
			if not JoinTemporaryChannel(pChannelInfo.Name, pChannelInfo.Password) then
				pChannelInfo.ID = nil
				pChannelInfo.Open = false
				self:SetChannelStatus(pChannelInfo, "ERROR", "Joining channel failed")
				return false
			end
			
			vChannelID = GetChannelName(pChannelInfo.Name)
			
			if not vChannelID then
				pChannelInfo.ID = nil
				pChannelInfo.Open = false
				self:SetChannelStatus(pChannelInfo, "ERROR", "Joining channel failed")
				return false
			end
			
			self:SetChannelStatus(pChannelInfo, "CONNECTING")
		
		-- Otherwise note the ID and set it as connected
		
		elseif not pChannelInfo.ID then
			-- Addon.DebugLib:TestMessage("JoinChannel: Joining existing channel "..pChannelInfo.Name)
			
			pChannelInfo.ID = vChannelID
			pChannelInfo.Open = true
			
			self:SetChannelStatus(pChannelInfo, "CONNECTED")
			self:SetChannelStatus(pChannelInfo, "READY_TO_SEND")
			
			ChatFrame_RemoveChannel(DEFAULT_CHAT_FRAME, pChannelInfo.Name)
		end
	end
end

function Addon.DataChannelLib:LeaveChannel(pChannelInfo)
	if not pChannelInfo.ID then
		return
	end
	
	if not pChannelInfo.Permanent then
		LeaveChannelByName(pChannelInfo.Name)
	end
	
	pChannelInfo.ID = nil
	pChannelInfo.Open = false
	
	self:SetChannelStatus(pChannelInfo, "DISCONNECTED")
end

function Addon.DataChannelLib:RegisterEvents()
	-- For suspending/resuming the chat channels during logout
	
	-- Addon.EventLib:RegisterEvent("PLAYER_CAMPING", MCDataChannelLib.SuspendChannels, MCDataChannelLib)
	-- Addon.EventLib:RegisterEvent("PLAYER_QUITING", MCDataChannelLib.SuspendChannels, MCDataChannelLib)
	-- Addon.EventLib:RegisterEvent("LOGOUT_CANCEL", MCDataChannelLib.ResumeChannels, MCDataChannelLib)

	Addon.EventLib:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE", MCDataChannelLib.ChatMsgChannelNotice, MCDataChannelLib)

	Addon.EventLib:RegisterEvent("CHAT_MSG_ADDON", MCDataChannelLib.ChatMsgAddon, MCDataChannelLib)
	Addon.EventLib:RegisterEvent("CHAT_MSG_CHANNEL", MCDataChannelLib.ChatMsgChannel, MCDataChannelLib)
	Addon.EventLib:RegisterEvent("CHAT_MSG_SYSTEM", MCDataChannelLib.ChatMsgSystem, MCDataChannelLib)
end

function Addon.DataChannelLib:UnregisterEvents()
	-- Addon.EventLib:UnregisterEvent("PLAYER_CAMPING", MCDataChannelLib.SuspendChannels, MCDataChannelLib)
	-- Addon.EventLib:UnregisterEvent("PLAYER_QUITING", MCDataChannelLib.SuspendChannels, MCDataChannelLib)
	-- Addon.EventLib:UnregisterEvent("LOGOUT_CANCEL", MCDataChannelLib.ResumeChannels, MCDataChannelLib)

	Addon.EventLib:UnregisterEvent("CHAT_MSG_CHANNEL_NOTICE", MCDataChannelLib.ChatMsgChannelNotice, MCDataChannelLib)

	Addon.EventLib:UnregisterEvent("CHAT_MSG_ADDON", MCDataChannelLib.ChatMsgAddon, MCDataChannelLib)
	Addon.EventLib:UnregisterEvent("CHAT_MSG_CHANNEL", MCDataChannelLib.ChatMsgChannel, MCDataChannelLib)
	Addon.EventLib:UnregisterEvent("CHAT_MSG_SYSTEM", MCDataChannelLib.ChatMsgSystem, MCDataChannelLib)
end

function Addon.DataChannelLib:SuspendChannels()
	for _, vChannelInfo in pairs(self.ChannelInfo) do
		if not vChannelInfo.Suspended
		and vChannelInfo.Open then
			vChannelInfo.Suspended = true
			self:LeaveChannel(vChannelInfo)
		end
	end -- for
end

function Addon.DataChannelLib:ResumeChannels()
	for _, vChannelInfo in pairs(self.ChannelInfo) do
		if vChannelInfo.Suspended then
			vChannelInfo.Suspended = false
			self:JoinChannel(vChannelInfo)
		end
	end -- for
end

function Addon.DataChannelLib:SetChannelStatus(pChannelInfo, pStatus, pMessage)
	-- Addon.DebugLib:TestMessage("SetChannelStatus("..pChannelInfo.Name..", "..pStatus..")")
	
	pChannelInfo.Status = pStatus
	pChannelInfo.StatusMessage = pMessage
	
	local vConnected = pChannelInfo.ID ~= nil
	
	for vClientPrefix, vChannelClient in pairs(pChannelInfo.Clients) do
		vChannelClient.Connected = vConnected
		vChannelClient.Status = pStatus
		vChannelClient.StatusMessage = pMessage
		vChannelClient:SendMessageToClient("#STATUS", pStatus, pMessage)
	end

	for _, vChannelClient in pairs(pChannelInfo.WildcardClients) do
		vChannelClient.Connected = vConnected
		vChannelClient.Status = pStatus
		vChannelClient.StatusMessage = pMessage
		vChannelClient:SendMessageToClient("#STATUS", pStatus, pMessage)
	end
end

function Addon.DataChannelLib:SendMessageToClient(pSender, pMessageID, pMessage)
	-- If the message is an echo of our previous transmission, then remove
	-- the message from the top of the queue and send the next one
	
	if pSender == MCDataChannelLib.PlayerName
	and pMessageID == "DATA"
	and self.SentMessageQueue[1] == pMessage then
		table.remove(self.SentMessageQueue, 1)
		Addon.SchedulerLib:UnscheduleTask(self.ResendLastMessage, self)
		
		if #self.SentMessageQueue > 0 then
			Addon.DataChannelLib:SendChannelMessage(self, self.SentMessageQueue[1])				
			Addon.SchedulerLib:ScheduleTask(MCDataChannelLib.RetransmitInterval, self.ResendLastMessage, self, "MCDataChannelLib.ResendLastMessage")
		else
			self:SendMessageToClient("#STATUS", "READY_TO_SEND")
		end
	end
	
	-- Pass the message on to the client
	
	if self.ClientRef then
		self.MessageFunction(self.ClientRef, pSender, pMessageID, pMessage)
	else
		self.MessageFunction(pSender, pMessageID, pMessage)
	end
end

function Addon.DataChannelLib:ReadyToSend()
	return #self.SentMessageQueue == 0
end

Addon.DataChannelLib.cEscapedChatCharRegExp = "([`sS|])"

Addon.DataChannelLib.cUnescapeChatCharMap =
{
	a = "`",
	l = "s",
	u = "S",
	b = "|",
}

Addon.DataChannelLib.cEscapeChatCharMap = {}

for vEscapeCode, vChar in pairs(Addon.DataChannelLib.cUnescapeChatCharMap) do
	Addon.DataChannelLib.cEscapeChatCharMap[vChar] = "`"..vEscapeCode
end

function Addon.DataChannelLib.EscapeChatString(pString)
	return string.gsub(pString, Addon.DataChannelLib.cEscapedChatCharRegExp, Addon.DataChannelLib.cEscapeChatCharMap)
end

function Addon.DataChannelLib.UnescapeChatString(pString)
	return string.gsub(pString, "`(.)", Addon.DataChannelLib.cUnescapeChatCharMap)
end

-- These functions are similar to the chat string functions above except that they're for
-- implementing a GroupCalendar-style syntax for message packets

Addon.DataChannelLib.cEscapedCharRegExp = "([~,/:;&|\n])"

Addon.DataChannelLib.cUnescapeCharMap =
{
	t = "~",
	c = ",",
	s = "/",
	n = ":",
	m = ";",
	a = "&",
	b = "|",
	n = "\n",
}

Addon.DataChannelLib.cEscapeCharMap = {} -- Generate the reverse map

for vEscapeCode, vChar in pairs(Addon.DataChannelLib.cUnescapeCharMap) do
	Addon.DataChannelLib.cEscapeCharMap[vChar] = "~"..vEscapeCode
end

function Addon.DataChannelLib:EscapeString(pString)
	return string.gsub(pString, self.cEscapedCharRegExp, Addon.DataChannelLib.cEscapeCharMap)
end

function Addon.DataChannelLib:UnescapeString(pString)
	return string.gsub(pString, "~(.)", self.cUnescapeCharMap)
end

function Addon.DataChannelLib:SendChannelMessage(pChannelClient, pMessage)
	local vChannelInfo = self.ChannelInfo[pChannelClient.UpperName]
	
	if not vChannelInfo
	or not vChannelInfo.ID then
		return
	end
	
	if vChannelInfo.Permanent then
		if vChannelInfo.ID == "GUILD" and not IsInGuild() then
			self:LeaveChannel(vChannelInfo)
			self:SetChannelStatus(vChannelInfo, "ERROR", "Not in a guild")
			return
		end
		
		local vTotalMessageLength = string.len(pChannelClient.Prefix) + 1 + string.len(pMessage)
		
		if vTotalMessageLength > 254 then
			self:ErrorMessage("Error: Attempted to send addon data of %d bytes", vTotalMessageLength)
			self:ErrorMessage("Data: %s: %s", pChannelClient.Prefix, pMessage)
			self:CloseChannel()
			return
		end
		
		-- Addon.DebugLib:TestMessage("To ["..vChannelInfo.Name.."/"..pChannelClient.Prefix.."]:"..pMessage)
		SendAddonMessage(pChannelClient.Prefix, pMessage, vChannelInfo.ID)
		return
	end
	
	--
	
	local vMessage
	
	if pChannelClient.Prefix then
		vMessage = pChannelClient.Prefix..":"..pMessage
	else
		vMessage = pMessage
	end
	
	local vEscapedMessage = self.EscapeChatString(vMessage)
	
	if string.len(vEscapedMessage) > 254 then
		self:ErrorMessage("Error: Attempted to send chat data of "..string.len(vEscapedMessage).." bytes")
		self:ErrorMessage("Data: "..vEscapedMessage)
		self:CloseChannel()
		return
	end
	
	-- Send the message
	
	local vSavedAutoClearAFK = GetCVar("autoClearAFK")
	SetCVar("autoClearAFK", 0)
	
	SendChatMessage(vEscapedMessage, "CHANNEL", nil, vChannelInfo.ID)
	
	SetCVar("autoClearAFK", vSavedAutoClearAFK)
end

function Addon.DataChannelLib:LibraryReady()
	if self.ChatChannelsReady then
		return
	end
	
	self.ChatChannelsReady = true
	
	-- Open any waiting channels
	
	for _, vChannelInfo in pairs(self.ChannelInfo) do
		if not vChannelInfo.Permanent then
			self:JoinChannel(vChannelInfo)
		end
	end
end

function Addon.DataChannelLib:ChatMsgChannel(pEventID, pMessage, pSender, pLanguage, pChannelNameAndNum, pTargetName, pFlags, pZoneID, pChannelNumber, pChannelName)
	-- See if it's a channel we're interested in
	
	if not pChannelName then
		return
	end
	
	local vUpperChannelName = strupper(pChannelName)
	local vChannelInfo = self.ChannelInfo[vUpperChannelName]
	
	if not vChannelInfo then
		return
	end
	
	-- Decode the message
	
	local vMessage
	
	if strsub(pMessage, -8) == " ...hic!" then
		vMessage = self.UnescapeChatString(strsub(pMessage, 1, -9))
	else
		vMessage = self.UnescapeChatString(pMessage)
	end
	
	--
	
	local vStartIndex, vEndIndex, vPrefix, vMessageData = string.find(vMessage, "(%w+):(.*)")
	
	if not vStartIndex then
		for _, vChannelClient in pairs(vChannelInfo.WildcardClients) do
			vChannelClient:SendMessageToClient(pSender, "DATA", vMessage)
		end
		
		return
	end
	
	local vChannelClient = vChannelInfo.Clients[vPrefix]
	
	if vChannelClient then
		-- Addon.DebugLib:TestMessage("["..pChannelName.."/"..vPrefix.."]["..pSender.."]: "..vMessageData)
		
		vChannelClient:SendMessageToClient(pSender, "DATA", vMessageData)
	end
end

function Addon.DataChannelLib:ChatMsgAddon(pEventID, pPrefix, pMessage, pChannelName, pSender)
	local vChannelInfo = self.ChannelInfo["#"..pChannelName]
	
	if vChannelInfo then
		local vChannelClient = vChannelInfo.Clients[pPrefix]
		
		if not vChannelClient then
			return
		end
		
		Addon.DebugLib:AddDebugMessage(NORMAL_FONT_COLOR_CODE.."["..pChannelName.."/"..pPrefix.."]"..GREEN_FONT_COLOR_CODE.."["..pSender.."]: "..HIGHLIGHT_FONT_COLOR_CODE..pMessage..FONT_COLOR_CODE_CLOSE)
		
		vChannelClient:SendMessageToClient(pSender, "DATA", pMessage)
	end
	
	if pChannelName == "PARTY" then
		vChannelInfo = self.ChannelInfo["#RAID"]
		
		if vChannelInfo then
			local vChannelClient = vChannelInfo.Clients[pPrefix]
			
			if not vChannelClient then
				return
			end
			
			Addon.DebugLib:AddDebugMessage(NORMAL_FONT_COLOR_CODE.."["..pChannelName.."/"..pPrefix.."]"..GREEN_FONT_COLOR_CODE.."["..pSender.."]: "..HIGHLIGHT_FONT_COLOR_CODE..pMessage..FONT_COLOR_CODE_CLOSE)
			
			vChannelClient:SendMessageToClient(pSender, "DATA", pMessage)
		end
	end
end

function Addon.DataChannelLib:ChatMsgSystem(pEventID, pMessage)
	if pMessage == ERR_TOO_MANY_CHAT_CHANNELS then
		for _, vChannelInfo in pairs(self.ChannelInfo) do
			if vChannelInfo.Status == "CONNECTING"
			or vChannelInfo.Status == "ERROR" then
				vChannelInfo.GotTooManyChannelsMessage = true
				
				if vChannelInfo.Status == "ERROR" then
					self:SetChannelStatus(vChannelInfo, "ERROR", "Can't join more channels")
				end
			end
		end -- for
	end -- if
end

function Addon.DataChannelLib:ChatMsgChannelNotice(pEventID, pNoticeID, pArg2, pArg3, pChannelNameWithNum, pArg5, pArg6, pChannelType, pChannelNumber, pChannelName)
	if not pChannelName then
		return
	end
	
	-- Just leave if it's not a channel we're interested in
	
	local vUpperChannelName = strupper(pChannelName)
	local vChannelInfo = self.ChannelInfo[vUpperChannelName]
	
	--
	
	if pNoticeID == "YOU_JOINED" then
		-- Once channels start showing up shorten the initialization delay
		
		if not self.ChatChannelsReady then
			Addon.SchedulerLib:SetTaskDelay(1, self.LibraryReady, self)
		end
		
		if not vChannelInfo then
			return
		end
		
		local vChannelID = GetChannelName(vChannelInfo.Name)
		
		if not vChannelID
		or vChannelID == 0 then
			vChannelInfo.ID = nil
			vChannelInfo.Open = false
			self:SetChannelStatus(vChannelInfo, "ERROR", "Internal Error (Channel ID not found)")
		
		elseif not vChannelInfo.ID then
			vChannelInfo.ID = vChannelID
			vChannelInfo.Open = true
			
			self:SetChannelStatus(vChannelInfo, "CONNECTED")
			self:SetChannelStatus(vChannelInfo, "READY_TO_SEND")
			
			ChatFrame_RemoveChannel(DEFAULT_CHAT_FRAME, vChannelInfo.Name)
		
		else
			vChannelInfo.ID = vChannelID -- Update it in case it changed for some reason
		end
		
	elseif pNoticeID == "YOU_LEFT" then
		if not vChannelInfo then
			return
		end
		
		if vChannelInfo.ID then
			vChannelInfo.ID = nil
			vChannelInfo.Open = false
			self:SetChannelStatus(vChannelInfo, "DISCONNECTED")
		end
	
	elseif pNoticeID == "WRONG_PASSWORD" then
		if not vChannelInfo then
			return
		end
		
		vChannelInfo.ID = nil
		vChannelInfo.Open = false
		self:SetChannelStatus(vChannelInfo, "ERROR", "Wrong password")
	end
end

-- Channel methods

function Addon.DataChannelLib:Delete()
	if self.Open then
		self:CloseChannel()
	end
end

function Addon.DataChannelLib:OpenChannel(pChannelName, pPassword)
	if self.Open then
		self:CloseChannel()
	end
	
	if Addon.DataChannelLib:OpenChannelClient(self, pChannelName, pPassword) then
		self.Name = pChannelName
		self.UpperName = strupper(pChannelName)
		self.Open = true
	end
end

function Addon.DataChannelLib:CloseChannel()
	if not self.Open then
		return
	end
	
	Addon.DataChannelLib:CloseChannelClient(self)
	self.Open = false
end

function Addon.DataChannelLib:SendMessageToChannel(pMessage)
	if self.DisableSend then
		return
	end
	
	table.insert(self.SentMessageQueue, pMessage)
	
	if #self.SentMessageQueue > 1 then
		return
	end
	
	Addon.DataChannelLib:SendChannelMessage(self, pMessage)
	Addon.SchedulerLib:ScheduleTask(self.RetransmitInterval, self.ResendLastMessage, self, "MCDataChannelLib.ResendLastMessage")
end

function Addon.DataChannelLib:ResendLastMessage()
	Addon.DataChannelLib:SendChannelMessage(self, self.SentMessageQueue[1])
	Addon.SchedulerLib:ScheduleTask(self.RetransmitInterval, self.ResendLastMessage, self, "MCDataChannelLib.ResendLastMessage")
end

function Addon.DataChannelLib:SendFailed()
end

-- Utilities

function Addon.DataChannelLib:ParseCommandString(pCommandString)
	-- Break the command into parts
	
	local vCommand = {}
	
	for vOpcode, vOperands in string.gmatch(pCommandString, "(%w+):?([^/]*)") do
		local vOperation = {}
		
		vOperation.opcode = vOpcode
		vOperation.operandString = vOperands
		vOperation.operands = self.ParseParameterString(vOperands)
		
		table.insert(vCommand, vOperation)
	end
	
	return vCommand
end

function Addon.DataChannelLib.ParseParameterString(pParameterString)
	local vParameters = {}
	local vIndex = 0
	local vFound = true
	local vStartIndex = 1
	
	while vFound do
		local vEndIndex
		
		vFound, vEndIndex, vParameter = string.find(pParameterString, "([^,]*),", vStartIndex)
		
		vIndex = vIndex + 1
		
		if not vFound then
			vParameters[vIndex] = string.sub(pParameterString, vStartIndex)
			break
		end
		
		vParameters[vIndex] = vParameter
		vStartIndex = vEndIndex + 1
	end
	
	return vParameters
end

--[[ New mechanism of message verification is self-throttling

function Addon.DataChannelLib.SendAddonMessage(pPrefix, pMessage, pChannel)
	if not pMessage or type(pMessage) ~= "string" then
		return
	end
	
	local vNumBytes = string.len(pMessage)
	local vTime = GetTime()
	
	MCDataChannelLib.NextSendTime = MCDataChannelLib.NextSendTime + vNumBytes / MCDataChannelLib.MaxSendBytesPerSecond
	
	if MCDataChannelLib.NextSendTime < vTime then
		MCDataChannelLib.NextSendTime = vTime
	elseif MCDataChannelLib.NextSendTime > vTime + 0.75 then
		MCDataChannelLib.NextSendTime = vTime + 0.75
	end
end

if not Addon.DataChannelLib.DidHookSendAddonMessage then
	Addon.DataChannelLib.DidHookSendAddonMessage = true
	hooksecurefunc("SendAddonMessage", MCDataChannelLib.SendAddonMessage)
end

function MCDataChannelLib.SendChatMessage(pMessage, pType, pLanguage, pChannel)
	if not pMessage or type(pMessage) ~= "string" then
		return
	end
	
	local vNumBytes = string.len(pMessage)
	local vTime = GetTime()
	
	MCDataChannelLib.NextSendTime = MCDataChannelLib.NextSendTime + vNumBytes / MCDataChannelLib.MaxSendBytesPerSecond
	
	if MCDataChannelLib.NextSendTime < vTime then
		MCDataChannelLib.NextSendTime = vTime
	elseif MCDataChannelLib.NextSendTime > vTime + 0.75 then
		MCDataChannelLib.NextSendTime = vTime + 0.75
	end
end

if not MCDataChannelLib.DidHookSendChatMessage then
	MCDataChannelLib.DidHookSendChatMessage = true
	hooksecurefunc("SendChatMessage", MCDataChannelLib.SendChatMessage)
end
]]--

--

Addon.DataChannelLib:RegisterEvents()

if not Addon.DataChannelLib.ChatChannelsReady then
	local vID1, vName1 = GetChannelList()
	
	-- If there are already channels then just signal that we're ready
	
	if vID1 then
		Addon.DataChannelLib:LibraryReady()
	
	-- Otherwise schedule a task to signal later after the world channels
	-- are joined
	
	else
		Addon.SchedulerLib:ScheduleTask(60, MCDataChannelLib.LibraryReady, MCDataChannelLib, "MCDataChannelLib.LibraryReady")
	end
end
