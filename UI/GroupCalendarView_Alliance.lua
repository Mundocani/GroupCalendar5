----------------------------------------
-- Group Calendar 5 Copyright (c) 2018 John Stephen
-- This software is licensed under the MIT license.
-- See the included LICENSE.txt file for more information.
----------------------------------------

----------------------------------------
GroupCalendar.UI._PartnersView = {}
----------------------------------------

function GroupCalendar.UI._PartnersView:New(pParent)
	return CreateFrame("Frame", nil, pParent)
end

function GroupCalendar.UI._PartnersView:Construct(pParent)
	self.Title = self:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	self.Title:SetPoint("TOP", self, "TOP", 17, -7)
	self.Title:SetText(GroupCalendar.cPartnersTitle)
	
	self.HelpText = CreateFrame("SimpleHTML", nil, self)
	self.HelpText:SetPoint("TOP", self, "TOP", 0, -50)
	self.HelpText:SetPoint("BOTTOM", self, "BOTTOM", 0, 50)
	self.HelpText:SetWidth(470)
	self.HelpText:SetFontObject(GameFontNormalSmall)
	self.HelpText:SetFontObject("h1", GameFontNormal)
	self.HelpText:SetFontObject("h2", GameFontHighlight)
	self.HelpText:SetFontObject("h3", GameFontNormalSmall)
	self.HelpText:SetFontObject("p", GameFontHighlight)
	self.HelpText:SetSpacing("p", 5)
	self.HelpText:SetText(GroupCalendar.cPartnersHelp)
	
	self.RemovePlayerButton = GroupCalendar:New(GroupCalendar.UIElementsLib._PushButton, self, REMOVE, 100)
	self.RemovePlayerButton:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -15, 17)
	self.RemovePlayerButton:SetScript("OnClick", function ()
		local vPlayerName = strtrim(self.CharacterName:GetText())
		
		GroupCalendar:ConfirmDelete(GroupCalendar.cConfirmDeletePartner, vPlayerName, function ()
			GroupCalendar.Partnerships:RemovePartnerPlayer(vPlayerName)
		end)
		
		self.CharacterName:HighlightText()
	end)
	
	self.AddPlayerButton = GroupCalendar:New(GroupCalendar.UIElementsLib._PushButton, self, ADD, 100)
	self.AddPlayerButton:SetPoint("RIGHT", self.RemovePlayerButton, "LEFT", -10, 0)
	self.AddPlayerButton:SetScript("OnClick", function ()
		self:AddPartnerPlayer(strtrim(self.CharacterName:GetText()))
		self.CharacterName:HighlightText()
	end)
	
	self.CharacterName = GroupCalendar:New(GroupCalendar.UIElementsLib._EditBox, self, nil, 40, 140)
	self.CharacterName:SetPoint("RIGHT", self.AddPlayerButton, "LEFT", -10, 0)
	self.CharacterName:SetEmptyText(CALENDAR_PLAYER_NAME)
	self.CharacterName:SetAutoCompleteFunc(GroupCalendar.PlayerNameAutocomplete)
	self.CharacterName:SetScript("OnEnterPressed", function ()
		self:AddPartnerPlayer(strtrim(self.CharacterName:GetText()))
		self.CharacterName:HighlightText()
	end)
	
	self.ProgressBar = GroupCalendar:New(GroupCalendar._PartnerProgressBar, self)
	self.ProgressBar:SetPoint("TOP", self.RemovePlayerButton, "TOP")
	self.ProgressBar:SetPoint("BOTTOM", self.RemovePlayerButton, "BOTTOM")
	self.ProgressBar:SetPoint("LEFT", self, "LEFT", 35, 0)
	self.ProgressBar:SetPoint("RIGHT", self.RemovePlayerButton, "RIGHT")
	self.ProgressBar:Hide()
	
	self.PartnerItems = {}
	self.FreePartnerItems = {}
	
	self:SetScript("OnShow", self.OnShow)
	self:SetScript("OnHide", self.OnHide)
	
	GroupCalendar.EventLib:RegisterCustomEvent("GC5_PARTNERS_CHANGED", self.Refresh, self)
end

function GroupCalendar.UI._PartnersView:OnShow()
	GroupCalendar.Partnerships.NewPartnershipsEnabled = true
	self:Refresh()
end

function GroupCalendar.UI._PartnersView:OnHide()
	GroupCalendar.Partnerships.NewPartnershipsEnabled = false
end

function GroupCalendar.UI._PartnersView:Refresh()
	-- Move existing items to the free list
	
	for vIndex, vPartnerItem in pairs(self.PartnerItems) do
		vPartnerItem:Hide()
		table.insert(self.FreePartnerItems, vPartnerItem)
		self.PartnerItems[vIndex] = nil
	end
	
	-- Add all the data
	
	for vIndex, vPartnerGuild in ipairs(GroupCalendar.Partnerships.PartnerGuilds) do
		self:AddPartnerGuild(vPartnerGuild)
	end
	
	-- Stack the result
	
	self:StackPartners()
end

function GroupCalendar.UI._PartnersView:SetStatusText(pStatus, pText)
	if not pStatus or pStatus == "PARTNER_SYNC_COMPLETE" then
		self.ProgressBar:Hide()
		self.RemovePlayerButton:Show()
		self.AddPlayerButton:Show()
		self.CharacterName:Show()
		
		return
	end
	
	if pStatus == "GC5_SEND_PROGRESS" then
		self.SendProgress = pText
		self.ProgressBar:SetProgress(self.SendProgress, self.ReceiveProgress)
	elseif pStatus == "GC5_RECEIVE_PROGRESS" then
		self.ReceiveProgress = pText
		self.ProgressBar:SetProgress(self.SendProgress, self.ReceiveProgress)
	else
		local vStatus = GroupCalendar.cPartnerStatus[pStatus]
		
		if not vStatus then
			self.ProgressBar:SetText(pStatus)
		else
			self.ProgressBar:SetText(vStatus:format(pText))
		end
		
		self.ProgressBar:Show()
		
		self.RemovePlayerButton:Hide()
		self.AddPlayerButton:Hide()
		self.CharacterName:Hide()
	end
end

function GroupCalendar.UI._PartnersView:AddPartnerPlayer(pPlayerName)
	self.CreatingGuild = GroupCalendar.Partnerships:AddPartnerPlayer(pPlayerName)
	
	GroupCalendar.BroadcastLib:Listen(self.CreatingGuild, self.CreatingGuildStatus, self)
	
	self:CreatingGuildStatus(self.CreatingGuild, self.CreatingGuild.Status, self.CreatingGuild.StatusMessage)
end

function GroupCalendar.UI._PartnersView:CreatingGuildStatus(pPartnerGuild, pStatus, pMessage, pPlayerName)
	if GroupCalendar.Debug.partners then
		GroupCalendar:DebugMessage("PartnersView:CreatingGuildStatus(%s, %s, %s): GuildName=%s", tostring(pStatus), tostring(pMessage), tostring(pPlayerName), tostring(pPartnerGuild.Config.GuildName))
	end
	
	if pStatus == "GC5_CONNECT_FAILED" and pMessage == "NOT_FOUND" then
		GroupCalendar.UI:CalendarUpdateError(ERR_CHAT_PLAYER_NOT_FOUND_S:format(pPlayerName))
		return
	end
	
	if pStatus == "PARTNER_SYNC_COMPLETE"
	and pPartnerGuild.Config.GuildName then
		-- Save the new info
		
		local vPartnerConfig = GroupCalendar.Partnerships:FindPartnerConfigByGuild(pPartnerGuild.Config.GuildName)
		
		if vPartnerConfig then
			GroupCalendar:DebugTable(vPartnerConfig, "ExistingConfig")
			table.insert(vPartnerConfig.Proxies, pPartnerGuild.Config.Proxies[1])
		else
			GroupCalendar:DebugTable(pPartnerGuild.Config, "NewConfig")
			table.insert(GroupCalendar.PlayerData.PartnerConfigs, pPartnerGuild.Config)
		end
		
		GroupCalendar.Partnerships:PartnerConfigChanged()
	end
	
	self:SetStatusText(pStatus, pMessage)
end

function GroupCalendar.UI._PartnersView:AddPartnerGuild(pPartnerGuild)
	local vPartnerItem = table.remove(self.FreePartnerItems)
	
	if not vPartnerItem then
		vPartnerItem = GroupCalendar:New(GroupCalendar.UI._PartnerItem, self)
	end
		
	table.insert(self.PartnerItems, vPartnerItem)
	
	vPartnerItem:SetPartnerGuild(pPartnerGuild)
	vPartnerItem:Show()
end

function GroupCalendar.UI._PartnersView:StackPartners()
	local vPreviousItem
	
	for vIndex, vPartnerItem in ipairs(self.PartnerItems) do
		vPartnerItem:ClearAllPoints()
		
		if vIndex == 1 then
			vPartnerItem:SetPoint("TOP", self, "TOP", 0, -40)
		else
			vPartnerItem:SetPoint("TOPLEFT", vPreviousItem, "BOTTOMLEFT", 0, -10)
		end
		
		vPreviousItem = vPartnerItem
	end
	
	if not vPreviousItem then
		self.HelpText:Show()
	else
		self.HelpText:Hide()
	end
end

----------------------------------------
GroupCalendar.UI._PartnerItem = {}
----------------------------------------

function GroupCalendar.UI._PartnerItem:New(pParent)
	return GroupCalendar:New(GroupCalendar.UIElementsLib._PlainBorderedFrame, pParent)
end

function GroupCalendar.UI._PartnerItem:Construct(pParent)
	self:SetWidth(490)
	self:SetHeight(75)
	
	self.TabardSize = 60
	self.HalfTabardSize = 0.5 * self.TabardSize
	
	self.EmblemBrightness = 0.7
	
	self.EmblemBgTL = self:CreateTexture(nil, "BORDER")
	self.EmblemBgTL:SetWidth(self.HalfTabardSize)
	self.EmblemBgTL:SetHeight(self.HalfTabardSize)
	self.EmblemBgTL:SetTexCoord(0.5, 1, 0, 1)
	self.EmblemBgTL:SetVertexColor(self.EmblemBrightness, self.EmblemBrightness, self.EmblemBrightness, 1)
	self.EmblemBgTL:SetPoint("TOPLEFT", self, "TOPLEFT", 15, -7)
	
	self.EmblemBgTR = self:CreateTexture(nil, "BORDER")
	self.EmblemBgTR:SetWidth(self.HalfTabardSize)
	self.EmblemBgTR:SetHeight(self.HalfTabardSize)
	self.EmblemBgTR:SetTexCoord(1, 0.5, 0, 1)
	self.EmblemBgTR:SetVertexColor(self.EmblemBrightness, self.EmblemBrightness, self.EmblemBrightness, 1)
	self.EmblemBgTR:SetPoint("TOPLEFT", self.EmblemBgTL, "TOPRIGHT")
	
	self.EmblemBgBL = self:CreateTexture(nil, "BORDER")
	self.EmblemBgBL:SetWidth(self.HalfTabardSize)
	self.EmblemBgBL:SetHeight(self.HalfTabardSize)
	self.EmblemBgBL:SetTexCoord(0.5, 1, 0, 1)
	self.EmblemBgBL:SetVertexColor(self.EmblemBrightness, self.EmblemBrightness, self.EmblemBrightness, 1)
	self.EmblemBgBL:SetPoint("TOP", self.EmblemBgTL, "BOTTOM")
	
	self.EmblemBgBR = self:CreateTexture(nil, "BORDER")
	self.EmblemBgBR:SetWidth(self.HalfTabardSize)
	self.EmblemBgBR:SetHeight(self.HalfTabardSize)
	self.EmblemBgBR:SetTexCoord(1, 0.5, 0, 1)
	self.EmblemBgBR:SetVertexColor(self.EmblemBrightness, self.EmblemBrightness, self.EmblemBrightness, 1)
	self.EmblemBgBR:SetPoint("TOP", self.EmblemBgTR, "BOTTOM")
	
	self.EmblemBorderTL = self:CreateTexture(nil, "ARTWORK")
	self.EmblemBorderTL:SetWidth(self.HalfTabardSize)
	self.EmblemBorderTL:SetHeight(self.HalfTabardSize)
	self.EmblemBorderTL:SetTexCoord(0.5, 1, 0, 1)
	self.EmblemBorderTL:SetVertexColor(self.EmblemBrightness, self.EmblemBrightness, self.EmblemBrightness, 1)
	self.EmblemBorderTL:SetPoint("TOP", self.EmblemBgTL, "TOP")
	
	self.EmblemBorderTR = self:CreateTexture(nil, "ARTWORK")
	self.EmblemBorderTR:SetWidth(self.HalfTabardSize)
	self.EmblemBorderTR:SetHeight(self.HalfTabardSize)
	self.EmblemBorderTR:SetTexCoord(1, 0.5, 0, 1)
	self.EmblemBorderTR:SetVertexColor(self.EmblemBrightness, self.EmblemBrightness, self.EmblemBrightness, 1)
	self.EmblemBorderTR:SetPoint("TOPLEFT", self.EmblemBorderTL, "TOPRIGHT")
	
	self.EmblemBorderBL = self:CreateTexture(nil, "ARTWORK")
	self.EmblemBorderBL:SetWidth(self.HalfTabardSize)
	self.EmblemBorderBL:SetHeight(self.HalfTabardSize)
	self.EmblemBorderBL:SetTexCoord(0.5, 1, 0, 1)
	self.EmblemBorderBL:SetVertexColor(self.EmblemBrightness, self.EmblemBrightness, self.EmblemBrightness, 1)
	self.EmblemBorderBL:SetPoint("TOP", self.EmblemBorderTL, "BOTTOM")
	
	self.EmblemBorderBR = self:CreateTexture(nil, "ARTWORK")
	self.EmblemBorderBR:SetWidth(self.HalfTabardSize)
	self.EmblemBorderBR:SetHeight(self.HalfTabardSize)
	self.EmblemBorderBR:SetTexCoord(1, 0.5, 0, 1)
	self.EmblemBorderBR:SetVertexColor(self.EmblemBrightness, self.EmblemBrightness, self.EmblemBrightness, 1)
	self.EmblemBorderBR:SetPoint("TOP", self.EmblemBorderTR, "BOTTOM")

	self.EmblemTL = self:CreateTexture(nil, "ARTWORK")
	self.EmblemTL:SetWidth(self.HalfTabardSize)
	self.EmblemTL:SetHeight(self.HalfTabardSize)
	self.EmblemTL:SetTexCoord(0.5, 1, 0, 1)
	self.EmblemTL:SetVertexColor(self.EmblemBrightness, self.EmblemBrightness, self.EmblemBrightness, 1)
	self.EmblemTL:SetPoint("TOP", self.EmblemBgTL, "TOP")
	
	self.EmblemTR = self:CreateTexture(nil, "ARTWORK")
	self.EmblemTR:SetWidth(self.HalfTabardSize)
	self.EmblemTR:SetHeight(self.HalfTabardSize)
	self.EmblemTR:SetTexCoord(1, 0.5, 0, 1)
	self.EmblemTR:SetVertexColor(self.EmblemBrightness, self.EmblemBrightness, self.EmblemBrightness, 1)
	self.EmblemTR:SetPoint("TOPLEFT", self.EmblemTL, "TOPRIGHT")
	
	self.EmblemBL = self:CreateTexture(nil, "ARTWORK")
	self.EmblemBL:SetWidth(self.HalfTabardSize)
	self.EmblemBL:SetHeight(self.HalfTabardSize)
	self.EmblemBL:SetTexCoord(0.5, 1, 0, 1)
	self.EmblemBL:SetVertexColor(self.EmblemBrightness, self.EmblemBrightness, self.EmblemBrightness, 1)
	self.EmblemBL:SetPoint("TOP", self.EmblemTL, "BOTTOM")
	
	self.EmblemBR = self:CreateTexture(nil, "ARTWORK")
	self.EmblemBR:SetWidth(self.HalfTabardSize)
	self.EmblemBR:SetHeight(self.HalfTabardSize)
	self.EmblemBR:SetTexCoord(1, 0.5, 0, 1)
	self.EmblemBR:SetVertexColor(self.EmblemBrightness, self.EmblemBrightness, self.EmblemBrightness, 1)
	self.EmblemBR:SetPoint("TOP", self.EmblemTR, "BOTTOM")
	
	self.GuildNameBackground = self:CreateTexture(nil, "ARTWORK")
	self.GuildNameBackground:SetHeight(55)
	self.GuildNameBackground:SetPoint("TOP", self, "TOP", 0, -5)
	self.GuildNameBackground:SetPoint("RIGHT", self, "RIGHT", -5, 0)
	self.GuildNameBackground:SetPoint("LEFT", self.EmblemBR, "RIGHT", 0, 0)
	self.GuildNameBackground:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Title")
	self.GuildNameBackground:SetTexCoord(1, 0, 0.5, 1)
	self.GuildNameBackground:SetVertexColor(1, 1, 1, 0.6)
	
	self.GuildNameText = self:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	self.GuildNameText:SetPoint("TOP", self, "TOP", 0, -7)
	self.GuildNameText:SetWidth(340)
	self.GuildNameText:SetJustifyH("CENTER")
	
	self.Players = self:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	self.Players:SetPoint("TOP", self.GuildNameText, "BOTTOM", 0, -4)
	self.Players:SetWidth(480)
	self.Players:SetJustifyH("CENTER")
	
	self.DeleteButton = GroupCalendar:New(GroupCalendar.UIElementsLib._PushButton, self, DELETE, 80)
	self.DeleteButton:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -10, 7)
	self.DeleteButton:SetHeight(18)
	self.DeleteButton.Text:SetFontObject(GameFontNormalSmall)
	self.DeleteButton:SetScript("OnClick", function ()
		GroupCalendar:ConfirmDelete(GroupCalendar.cConfirmDeletePartnerGuild, self.PartnerGuild.Config.GuildName, function ()
			GroupCalendar.Partnerships:RemovePartnerGuild(self.PartnerGuild.Config.GuildName)
		end)
	end)
	
	self.SyncButton = GroupCalendar:New(GroupCalendar.UIElementsLib._PushButton, self, GroupCalendar.cSync, 80)
	self.SyncButton:SetPoint("RIGHT", self.DeleteButton, "LEFT", -10, 0)
	self.SyncButton:SetHeight(18)
	self.SyncButton.Text:SetFontObject(GameFontNormalSmall)
	self.SyncButton:SetScript("OnClick", function ()
		self.PartnerGuild:StartPartnerSync()
	end)
	
	self.ProgressBar = GroupCalendar:New(GroupCalendar._PartnerProgressBar, self)
	
	self.ProgressBar:SetPoint("TOP", self.SyncButton, "TOP")
	self.ProgressBar:SetPoint("BOTTOM", self.SyncButton, "BOTTOM")
	self.ProgressBar:SetPoint("RIGHT", self.SyncButton, "LEFT", -10, 0)
	self.ProgressBar:SetPoint("LEFT", self.EmblemTL, "LEFT", 0, 0)
end

function GroupCalendar.UI._PartnerItem:SetPartnerGuild(pPartnerGuild)
	if self.PartnerGuild then
		GroupCalendar.BroadcastLib:StopListening(self.PartnerGuild, self.PartnerGuildMessage, self)
	end
	
	self.PartnerGuild = pPartnerGuild
	
	if not self.PartnerGuild then
		return
	end
	
	GroupCalendar.BroadcastLib:Listen(self.PartnerGuild, self.PartnerGuildMessage, self)
	
	self:Refresh()
	
	self:PartnerGuildMessage(self.PartnerGuild, self.PartnerGuild.Status, self.PartnerGuild.StatusMessage)
end

function GroupCalendar.UI._PartnerItem:Refresh()
	self.GuildNameText:SetText("<"..self.PartnerGuild.Config.GuildName..">")
	self.Players:SetText(GroupCalendar:FormatItemList(self.PartnerGuild.Config.Proxies))
	
	local vRoster = GroupCalendar.RealmData.Guilds[self.PartnerGuild.Config.GuildName]
	
	if vRoster then
		self.EmblemBgTL:SetTexture(vRoster.BackgroundTop)
		self.EmblemBgTR:SetTexture(vRoster.BackgroundTop)
		self.EmblemBgBL:SetTexture(vRoster.BackgroundBottom)
		self.EmblemBgBR:SetTexture(vRoster.BackgroundBottom)
		self.EmblemBorderTL:SetTexture(vRoster.BorderTop)
		self.EmblemBorderTR:SetTexture(vRoster.BorderTop)
		self.EmblemBorderBL:SetTexture(vRoster.BorderBottom)
		self.EmblemBorderBR:SetTexture(vRoster.BorderBottom)
		self.EmblemTL:SetTexture(vRoster.EmblemTop)
		self.EmblemTR:SetTexture(vRoster.EmblemTop)
		self.EmblemBL:SetTexture(vRoster.EmblemBottom)
		self.EmblemBR:SetTexture(vRoster.EmblemBottom)
	else
		self.EmblemBgTL:SetTexture("")
		self.EmblemBgTR:SetTexture("")
		self.EmblemBgBL:SetTexture("")
		self.EmblemBgBR:SetTexture("")
		self.EmblemBorderTL:SetTexture("")
		self.EmblemBorderTR:SetTexture("")
		self.EmblemBorderBL:SetTexture("")
		self.EmblemBorderBR:SetTexture("")
		self.EmblemTL:SetTexture("")
		self.EmblemTR:SetTexture("")
		self.EmblemBL:SetTexture("")
		self.EmblemBR:SetTexture("")
	end
end

function GroupCalendar.UI._PartnerItem:PartnerGuildMessage(pPartnerGuild, pMessageID, pDescription)
	if not pMessageID or pMessageID == "PARTNER_SYNC_COMPLETE" then
		self.ProgressBar:SetValue(0)
		
		if self.PartnerGuild.Config.LastUpdateDate then
			self.ProgressBar:SetText(string.format(GroupCalendar.cLastPartnerUpdate,
					GroupCalendar.DateLib:GetLongDateString(self.PartnerGuild.Config.LastUpdateDate),
					GroupCalendar.DateLib:GetShortTimeString(self.PartnerGuild.Config.LastUpdateTime)))
		else
			self.ProgressBar:SetText(GroupCalendar.cNoPartnerUpdate)
		end
		
		self:Refresh()
	elseif pMessageID == "GC5_SEND_PROGRESS"
	or pMessageID == "GC5_RECEIVE_PROGRESS" then
		if pMessageID == "GC5_SEND_PROGRESS" then
			self.SendProgress = pDescription
		else
			self.ReceiveProgress = pDescription
		end
		
		self.ProgressBar:SetProgress(self.SendProgress, self.ReceiveProgress)
	else
		local vStatus = GroupCalendar.cPartnerStatus[pMessageID]
		
		if not vStatus then
			self.ProgressBar:SetText(pMessageID)
		else
			self.ProgressBar:SetText(vStatus:format(pDescription))
		end
	end
end

----------------------------------------
GroupCalendar._PartnerProgressBar = {}
----------------------------------------

function GroupCalendar._PartnerProgressBar:New(pParent)
	return CreateFrame("StatusBar", nil, pParent)
end

function GroupCalendar._PartnerProgressBar:Construct()
	self:SetHeight(20)
	
	self.LabelText = self:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	self.LabelText:SetPoint("TOPLEFT", self, "TOPLEFT")
	self.LabelText:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT")
	self.LabelText:SetJustifyH("LEFT")
	self.LabelText:SetJustifyV("MIDDLE")
	
	self:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
	self:SetStatusBarColor(1, 0.7, 0)
	
	self:SetMinMaxValues(0, 1)
	self:SetValue(0)
end

function GroupCalendar._PartnerProgressBar:SetText(pText)
	self.LabelText:SetText(pText)
end

function GroupCalendar._PartnerProgressBar:SetProgress(pProgress1, pProgress2)
	local vProgress
	
	if not pProgress2 then
		vProgress = pProgress1
	elseif not pProgress1 then
		vProgress = pProgress2
	elseif pProgress2 < pProgress1 then
		vProgress = pProgress1
	else
		vProgress = pProgress2
	end
	
	if vProgress then
		self:SetValue(vProgress)
	else
		self:SetValue(0)
	end
end
