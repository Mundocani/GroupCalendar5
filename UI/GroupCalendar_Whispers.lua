----------------------------------------
-- Group Calendar 5 Copyright (c) 2018 John Stephen
-- This software is licensed under the MIT license.
-- See the included LICENSE.txt file for more information.
----------------------------------------

----------------------------------------
GroupCalendar._WhisperLog = {}
----------------------------------------

function GroupCalendar._WhisperLog:Construct()
	self.Players = {}

	GroupCalendar.EventLib:RegisterEvent("CHAT_MSG_WHISPER", function (pMessage, pPlayerName) self:AddWhisper(pPlayerName, pMessage) end)
end

function GroupCalendar._WhisperLog:AddWhisper(pPlayerName, pMessage)
	-- If no event is active then just ignore all whispers
	
	if not GroupCalendar.RunningEvent then
		return
	end
	
	-- Ignore whispers which appear to be data from other addons
	
	local vFirstChar = string.sub(pMessage, 1, 1)
	
	if vFirstChar == "<"
	or vFirstChar == "["
	or vFirstChar == "{"
	or vFirstChar == "!" then
		return
	end
	
	-- Filter if requested
	
	if self.WhisperFilterFunc
	and not self.WhisperFilterFunc(self.WhisperFilterParam, pPlayerName) then
		return
	end
	
	-- Create a new entry for the player if necessary
	
	local vPlayerLog = self.Players[pPlayerName]
	
	if not vPlayerLog then
		vPlayerLog = {}
		
		vPlayerLog.Name = pPlayerName
		vPlayerLog.Date, vPlayerLog.Time = GroupCalendar.DateLib:GetServerDateTime60()
		vPlayerLog.Whispers = {}
		
		self.Players[pPlayerName] = vPlayerLog
	end
	
	-- Keep only the most recent 3 whispers from any one player
	
	if #vPlayerLog.Whispers > 3 then
		table.remove(vPlayerLog.Whispers, 1)
	end
	
	-- Add the new message
	
	table.insert(vPlayerLog.Whispers, pMessage)

	-- Notify
	
	if self.NotificationFunc then
		self.NotificationFunc(self.NotifcationParam)
	end
end

function GroupCalendar._WhisperLog:AskClear()
	StaticPopup_Show("CONFIRM_CALENDAR_CLEAR_WHISPERS")
end

function GroupCalendar._WhisperLog:Clear()
	self.Players = {}
	
	if self.NotificationFunc then
		self.NotificationFunc(self.NotifcationParam)
	end
end

function GroupCalendar._WhisperLog:GetPlayerWhispers(pEvent)
	if GroupCalendar.RunningEvent ~= pEvent then
		return
	end
	
	return self.Players
end

function GroupCalendar._WhisperLog:SetNotificationFunc(pFunc, pParam)
	self.NotificationFunc = pFunc
	self.NotifcationParam = pParam
end

function GroupCalendar._WhisperLog:SetWhisperFilterFunc(pFunc, pParam)
	self.WhisperFilterFunc = pFunc
	self.WhisperFilterParam = pParam
end

function GroupCalendar._WhisperLog:RemovePlayer(pPlayerName)
	self.Players[pPlayerName] = nil

	-- Notify
	
	if self.NotificationFunc then
		self.NotificationFunc(self.NotifcationParam)
	end
end

function GroupCalendar._WhisperLog:GetNextWhisper(pPlayerName)
	-- Make an indexed list of the whispers
	
	local vWhispers = {}
	
	for vName, vWhisper in pairs(self.Players) do
		table.insert(vWhispers, vWhisper)
	end
	
	-- Sort by time
	
	table.sort(vWhispers, function (pWhisper1, pWhisper2)
		if pWhisper1.Date < pWhisper2.Date then
			return true
		elseif pWhisper1.Date > pWhisper2.Date then
			return false
		elseif pWhisper1.Time < pWhisper2.Time then
			return true
		elseif pWhisper1.Time > pWhisper2.Time then
			return false
		else
			return pWhisper1.Name < pWhisper2.Name
		end
	end)
	
	--
	
	local vLowerName = strlower(pPlayerName)
	local vUseNext = false
	
	for vIndex, vWhisper in ipairs(vWhispers) do
		if vUseNext then
			return vWhisper
		end
		
		if vLowerName == strlower(vWhisper.Name) then
			vUseNext = true
		end
	end
	
	return nil
end
