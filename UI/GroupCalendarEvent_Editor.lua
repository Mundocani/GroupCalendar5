----------------------------------------
-- Group Calendar 5 Copyright (c) 2018 John Stephen
-- This software is licensed under the MIT license.
-- See the included LICENSE.txt file for more information.
----------------------------------------

----------------------------------------
GroupCalendar.UI._EventEditor = {}
----------------------------------------

function GroupCalendar.UI._EventEditor:New(pParentFrame)
	return CreateFrame("Frame", nil, pParentFrame)
end

GroupCalendar.UI._EventEditor.ItemSpacing = 5

function GroupCalendar.UI._EventEditor:Construct(pParentFrame)
	self:SetAllPoints()
	
	self.EventTypeNames = C_Calendar.EventGetTypes()
	self.EventTextures = {}
	
	self:SetScript("OnShow", self.OnShow)
	self:SetScript("OnHide", self.OnHide)
end

function GroupCalendar.UI._EventEditor:Initialize()
	if self.Initialized then return end
	self.Background = self:CreateTexture(nil, "BACKGROUND")
	self.Background:SetPoint("TOPLEFT", self, "TOPLEFT", 5, -63)
	self.Background:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -9, 32)
	self.Background:SetVertexColor(0.3, 0.3, 0.3, 0.5)
	
	self.EventTypeMenu = GroupCalendar:New(GroupCalendar.UIElementsLib._TitledDropDownMenuButton, self, function (...) self:EventTypeMenuFunc(...) end, 150)
	self.EventTypeMenu:SetPoint("TOPLEFT", self, "TOPLEFT", 100, -78)
	self.EventTypeMenu:SetTitle(GroupCalendar.cEventLabel)

	self.DifficultyMenu = GroupCalendar:New(GroupCalendar.UIElementsLib._TitledDropDownMenuButton, self,
		function (menu)
			-- Return an empty menu if no event is set
			if not self.Event then
				return
			end

			-- Iterate the difficulties for the current event type
			local eventType = self.Event.EventType
			local textureIndex = self.Event.TextureIndex
			local eventTex = GroupCalendar:GetEventTexture(textureIndex, eventType)
			if eventTex then
				local alreadyAddedDifficulties = {}
				for i, difficultyInfo in ipairs(eventTex.difficulties) do
					if not alreadyAddedDifficulties[difficultyInfo.difficultyName] then
						local item = menu:AddToggleWithIcon(difficultyInfo.difficultyName, difficultyInfo.textureIndex, nil,
							function ()
								local checked = textureIndex == difficultyInfo.textureIndex or nil
								return checked
							end,
							function ()
								self:ClearFocus()
								self:SetEventType(self.Event.EventType, difficultyInfo.textureIndex)
							end
						)
						item.value = difficultyInfo.textureIndex
						alreadyAddedDifficulties[difficultyInfo.difficultyName] = true
					end
				end
			end
		end, 65)
	self.DifficultyMenu:SetPoint("TOPLEFT", self.EventTypeMenu, "TOPRIGHT", 5, 0)

	self.EventTitle = GroupCalendar:New(GroupCalendar.UIElementsLib._EditBox, self, GroupCalendar.cTitleLabel, 100, 220)
	self.EventTitle:SetPoint("TOPLEFT", self.EventTypeMenu, "BOTTOMLEFT", 0, -self.ItemSpacing)
	GroupCalendar:HookScript(self.EventTitle, "OnChar", function (pEditBox)
		pEditBox.EventType, pEditBox.TextureIndex, pEditBox.EventTemplate = GroupCalendar:AutoCompleteEventTitle(pEditBox)
		pEditBox.GotChar = true
	end)
	GroupCalendar:HookScript(self.EventTitle, "OnTextChanged", function (pEditBox)
		if not pEditBox.GotChar then
			pEditBox.EventTemplate = nil
		end
		
		pEditBox.GotChar = false
	end)
	GroupCalendar:HookScript(self.EventTitle, "OnEditFocusGained", function (pEditBox)
		pEditBox.GotChar = false
		pEditBox:HighlightText()
	end)
	GroupCalendar:HookScript(self.EventTitle, "OnEditFocusLost", function (pEditBox)
		if not self.Event then
			return
		end
		
		if self.IsNewEvent
		and not self.DidLoadDefaultsFromType
		and pEditBox:GetText() ~= self.Event.Title
		and (pEditBox.EventType or pEditBox.EventTemplate) then
			if pEditBox.EventTemplate then
				self:SetEventType(pEditBox.EventTemplate.EventType, pEditBox.EventTemplate.TextureIndex)
				self:LoadEventDefaults(pEditBox.EventTemplate)
			else
				self:SetEventType(pEditBox.EventType, pEditBox.TextureIndex)
				self:LoadEventDefaults()
			end
			
			self.DidLoadDefaultsFromTitle = true
		end
		
		pEditBox.EventType, pEditBox.TextureIndex, pEditBox.EventTemplate = nil, nil, nil
		pEditBox:HighlightText(0, 0)
		
		local newTitle = pEditBox:GetText()
		self.Event:SetTitle(pEditBox:GetText())
	end)
	
	self.EventModeMenu = GroupCalendar:New(GroupCalendar.UIElementsLib._TitledDropDownMenuButton, self, function (...) self:EventModeMenuFunc(...) end, 220)
	self.EventModeMenu:SetPoint("TOPLEFT", self.EventTitle, "BOTTOMLEFT", 0, -self.ItemSpacing)
	self.EventModeMenu:SetTitle(GroupCalendar.cEventModeLabel)
	function self.EventModeMenu.DidSelectItemWithValue(menu, value)
		DEFAULT_CHAT_FRAME:AddMessage("Item clicked")
		self:ClearFocus()
		self.Event:SetEventMode(value)
	end

	self.LevelRangePicker = GroupCalendar:New(GroupCalendar.UIElementsLib._LevelRangePicker, self, GroupCalendar.cLevelsLabel)
	self.LevelRangePicker:SetPoint("TOPLEFT", self.EventModeMenu, "BOTTOMLEFT", 0, -self.ItemSpacing)
	GroupCalendar:HookScript(self.LevelRangePicker.MinLevel, "OnEditFocusLost", function (pEditBox)
		if not self.Event then
			return
		end
		
		local vMinLevel, vMaxLevel = self.LevelRangePicker:GetLevelRange()
		
		self.Event:SetLevelRange(vMinLevel, vMaxLevel)
	end)
	GroupCalendar:HookScript(self.LevelRangePicker.MaxLevel, "OnEditFocusLost", function (pEditBox)
		if not self.Event then
			return
		end
		
		local vMinLevel, vMaxLevel = self.LevelRangePicker:GetLevelRange()
		
		self.Event:SetLevelRange(vMinLevel, vMaxLevel)
	end)
	
	--self.Description = GroupCalendar:New(GroupCalendar.UIElementsLib._ScrollingEditBox, self, GroupCalendar.cDescriptionLabel, 200, 220, 80)
	self.Description = GroupCalendar:New(GroupCalendar.UIElementsLib._ScrollingEditBox, self, GroupCalendar.cDescriptionLabel, 200, 220, 155)
	self.Description:ShowLimitText()
	self.Description:SetPoint("TOPLEFT", self.LevelRangePicker, "BOTTOMLEFT", 0, -self.ItemSpacing)
	GroupCalendar:HookScript(self.Description.EditBox, "OnEditFocusLost", function (pEditBox)
		if not self.Event then
			return
		end
		
		self.Event:SetDescription(pEditBox:GetText())
	end)
	
	self.DatePicker = GroupCalendar:New(GroupCalendar.UIElementsLib._DatePicker, self)
	self.DatePicker:SetPoint("TOP", self, "TOP", 0, -30)
	self.DatePicker.ValueChangedFunc = function ()
		local vHour, vMinute = self.TimePicker:GetTime()
		local vMonth, vDay, vYear = self.DatePicker:GetDate()
		
		if GroupCalendar.Clock.Data.ShowLocalTime then
			local vLocalDate = GroupCalendar.DateLib:ConvertMDYToDate(vMonth, vDay, vYear)
			local vLocalTime = GroupCalendar.DateLib:ConvertHMToTime(vHour, vMinute)
			
			local vServerDate, vServerTime = GroupCalendar.DateLib:GetServerDateTimeFromLocalDateTime(vLocalDate, vLocalTime)
			
			vMonth, vDay, vYear = GroupCalendar.DateLib:ConvertDateToMDY(vServerDate)
			vHour, vMinute = GroupCalendar.DateLib:ConvertTimeToHM(vServerTime)
		end
		
		if self.Event.Hour ~= vHour
		or self.Event.Minute ~= vMinute
		or self.Event.Month ~= vMonth
		or self.Event.Day ~= vDay
		or self.Event.Year ~= vYear then
			self.Event:SetDate(vMonth, vDay, vYear)
			self.Event:SetTime(vHour, vMinute)
			
			self:ClearFocus()
		end
	end
	
	self.TimePicker = GroupCalendar:New(GroupCalendar.UIElementsLib._TimePicker, self, GroupCalendar.cTimeLabel)
	self.TimePicker:SetPoint("TOPLEFT", self.Description, "BOTTOMLEFT", 0, -2 * self.ItemSpacing)
	self.TimePicker.ValueChangedFunc = self.DatePicker.ValueChangedFunc
	
	self.DurationMenu = GroupCalendar:New(GroupCalendar.UIElementsLib._TitledDropDownMenuButton, self, function (...) self:DurationMenuFunc(...) end)
	self.DurationMenu:SetPoint("TOPLEFT", self.TimePicker, "BOTTOMLEFT", 0, -self.ItemSpacing)
	self.DurationMenu:SetTitle(GroupCalendar.cDurationLabel)
	function self.DurationMenu.DidSelectItemWithValue(menu, value)
		self:ClearFocus()
		self.DurationMenu:SetSelectedValue(value)
		self.Event:SetDuration(value)
	end
	
	self.RepeatMenu = GroupCalendar:New(GroupCalendar.UIElementsLib._TitledDropDownMenuButton, self, function (...) self:RepeatMenuFunc(...) end)
	self.RepeatMenu:SetPoint("TOPLEFT", self.DurationMenu, "BOTTOMLEFT", 0, -self.ItemSpacing)
	self.RepeatMenu:SetTitle(GroupCalendar.cRepeatLabel)
	function self.RepeatMenu.ItemClicked(pMenu, pItemID)
		self:ClearFocus()
		self.Event:SetRepeatOption(pItemID)
	end
	self.RepeatMenu:SetEnabled(false)
	self.RepeatMenu:Hide()
	
	--
	
	self.AutoConfirmButton = GroupCalendar:New(GroupCalendar.UIElementsLib._CheckButton, self)
	self.AutoConfirmButton:SetTitle(GroupCalendar.cAutoConfirmLabel)
	self.AutoConfirmButton:SetPoint("LEFT", self.RepeatMenu, "LEFT", -5, 0)
	self.AutoConfirmButton:SetPoint("TOP", self.RepeatMenu, "BOTTOM", 0, -2 * self.ItemSpacing)
	self.AutoConfirmButton:SetScript("OnClick", function ()
		self:ClearFocus()
		if self.Event.Limits then
			self.SavedLimits = GroupCalendar:DuplicateTable(self.Event.Limits, true)
			self.Event:SetLimits(nil)
		elseif self.SavedLimits then
			self.Event:SetLimits(self.SavedLimits)
		else
			local vPartySize, vMinLevel = self.Event:GetDefaultPartySize()
			
			if vPartySize then
				self.Event:SetLimits(GroupCalendar.DefaultLimits[vPartySize])
			end
		end
	end)
	self.AutoConfirmButton:Hide()
	
	self.AutoConfirmSettings = GroupCalendar:New(GroupCalendar.UIElementsLib._PushButton, self, GroupCalendar.cAutoConfirmLimitsLabel, 80)
	self.AutoConfirmSettings:SetHeight(20)
	self.AutoConfirmSettings.Text:SetFontObject(GameFontNormalSmall)
	self.AutoConfirmSettings:SetPoint("LEFT", self.AutoConfirmButton.Title, "RIGHT", 5, 0)
	self.AutoConfirmSettings:SetScript("OnClick", function (pFrame, pButton)
		self:ClearFocus()
		GroupCalendar.UI.RoleLimitsDialog:SetParent(self)
		GroupCalendar.UI.RoleLimitsDialog:SetFrameLevel(self:GetFrameLevel() + 30)
		GroupCalendar.UI.RoleLimitsDialog:ClearAllPoints()
		GroupCalendar.UI.RoleLimitsDialog:SetPoint("CENTER", self, "CENTER")
		GroupCalendar.UI.RoleLimitsDialog:Open(self.Event.Limits, GroupCalendar.cAutoConfirmRoleLimitsTitle, nil, function (pLimits)
			self.Event:SetLimits(pLimits)
		end)
	end)
	self.AutoConfirmSettings:Hide()
	
	--
	
	self.EventClosedButton = GroupCalendar:New(GroupCalendar.UIElementsLib._CheckButton, self)
	self.EventClosedButton:SetTitle(GroupCalendar.cEventClosedLabel)
	self.EventClosedButton:SetPoint("LEFT", self.AutoConfirmButton, "LEFT")
	self.EventClosedButton:SetPoint("TOP", self.AutoConfirmSettings, "BOTTOM", 0, -2 * self.ItemSpacing + 50)
	self.EventClosedButton:SetScript("OnClick", function (pFrame, pButton)
		self:ClearFocus()
		self.Event:SetLocked(pFrame:GetChecked())
	end)
	
	self.LockoutMenu = GroupCalendar:New(GroupCalendar.UIElementsLib._TitledDropDownMenuButton, self, function (...) self:LockoutMenuFunc(...) end)
	self.LockoutMenu:SetPoint("TOP", self.EventClosedButton, "BOTTOM", 0, -self.ItemSpacing)
	self.LockoutMenu:SetPoint("LEFT", self.RepeatMenu, "LEFT")
	self.LockoutMenu:SetTitle(GroupCalendar.cLockoutLabel)
	function self.LockoutMenu.ItemClicked(pMenu, pItemID)
		self:ClearFocus()
		if pItemID == "OFF" then
			--self.Event:SetLockoutDate(nil, nil, nil)
			--self.Event:SetLockoutTime(nil, nil)
		else
			local vEventDate = GroupCalendar.DateLib:ConvertMDYToDate(self.Event.Month, self.Event.Day, self.Event.Year)
			local vEventTime = GroupCalendar.DateLib:ConvertHMToTime(self.Event.Hour, self.Event.Minute)
			
			local vLockoutDate, vLockoutTime = GroupCalendar.DateLib:AddOffsetToDateTime(vEventDate, vEventTime, -pItemID)
			
			self.Event:SetLockoutDate(GroupCalendar.DateLib:ConvertDateToMDY(vLockoutDate))
			self.Event:SetLockoutTime(GroupCalendar.DateLib:ConvertTimeToHM(vLockoutTime))
		end
	end
	self.LockoutMenu:SetEnabled(false)
	self.LockoutMenu:Hide()
	
	self.Initialized = true
end

function GroupCalendar.UI._EventEditor:HasChangedEditFields()
	if not self:IsVisible() then
		return false
	end
	
	return self.EventTitle.TextHasChanged
	    or self.LevelRangePicker.MinLevel.TextHasChanged
	    or self.LevelRangePicker.MaxLevel.TextHasChanged
	    or self.Description.EditBox.TextHasChanged
end

function GroupCalendar.UI._EventEditor:SetEvent(pEvent, pIsNewEvent)
	self:Initialize()
	GroupCalendar.BroadcastLib:StopListening(nil, self.EventMessage, self)
	
	if pEvent and not pEvent:CanEdit() then
		self.Event = nil
	else
		self.Event = pEvent
	end
	
	if not self.Event then
		return
	end
	
	self.IsNewEvent = pIsNewEvent
	
	self:UpdateControlsFromEvent()
	
	GroupCalendar.BroadcastLib:Listen(self.Event, self.EventMessage, self)
end

function GroupCalendar.UI._EventEditor:EventMessage(pEvent, pMessageID)
	if pMessageID == "CHANGED" then
		self:UpdateControlsFromEvent()
	end
end

function GroupCalendar.UI._EventEditor:OnShow()
	self:Initialize()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN)

	GroupCalendar.EventLib:RegisterCustomEvent("GC5_PREFS_CHANGED", self.UpdateControlsFromEvent, self)
	
	if not self.Event then
		return
	end
	
	if self.EventTitle.Enabled then
		self.EventTitle:SetFocus()
	end
end

function GroupCalendar.UI._EventEditor:OnHide()
	GroupCalendar.EventLib:UnregisterEvent("GC5_PREFS_CHANGED", self.UpdateControlsFromEvent, self)
	
	if not self.Event then
		return
	end
end

function GroupCalendar.UI._EventEditor:UpdateControlsFromEvent()
	local vCanEdit = not self.Event.Index -- new event
	              or not self.Event:IsExpired() -- not past event
	
	-- Set the mode
	
	if self.Event:IsAnnouncementEvent() then
		self.EventModeMenu:SetSelectedValue("ANNOUNCE")
	elseif self.Event.CalendarType == "GUILD_EVENT" then
		self.EventModeMenu:SetSelectedValue("SIGNUP")
	else
		self.EventModeMenu:SetSelectedValue("NORMAL")
	end
	
	self.EventModeMenu:SetEnabled(self.IsNewEvent and vCanEdit)
	
	-- Set title and description
	
	self.EventTitle:SetText(self.Event.Title or "")
	self.EventTitle:SetEnabled(vCanEdit)
	
	self.Description:SetText(self.Event.Description or "")
	self.Description:SetEnabled(vCanEdit)
	
	self.EventTypeMenu:SetSelectedValue(self:GetEventTypeID())
	self.EventTypeMenu:SetEnabled(vCanEdit)
	
	self.DifficultyMenu:SetSelectedValue(self.Event.TextureIndex)
	self.DifficultyMenu:SetEnabled(vCanEdit)

	if self.Event:IsAllDayEvent() then
		self.TimePicker:Hide()
		self.DurationMenu:Hide()
	else
		self.TimePicker:Show()
		self.TimePicker:SetEnabled(vCanEdit)

		self.DurationMenu:Show()
		self.DurationMenu:SetSelectedValue(self.Event.Duration)
		self.DurationMenu:SetEnabled(vCanEdit)
	end
	
	local vEventDate = GroupCalendar.DateLib:ConvertMDYToDate(self.Event.Month, self.Event.Day, self.Event.Year)
	local vEventTime = GroupCalendar.DateLib:ConvertHMToTime(self.Event.Hour, self.Event.Minute)
	
	if GroupCalendar.Clock.Data.ShowLocalTime then
		local vLocalDate, vLocalTime = GroupCalendar.DateLib:GetLocalDateTimeFromServerDateTime(vEventDate, vEventTime)
		local vLocalMonth, vLocalDay, vLocalYear = GroupCalendar.DateLib:ConvertDateToMDY(vLocalDate)
		local vLocalHour, vLocalMinute = GroupCalendar.DateLib:ConvertTimeToHM(vLocalTime)
		
		self.TimePicker:SetTime(vLocalHour, vLocalMinute)
		self.DatePicker:SetDate(vLocalMonth, vLocalDay, vLocalYear)
	else
		self.TimePicker:SetTime(self.Event.Hour, self.Event.Minute)
		self.DatePicker:SetDate(self.Event.Month, self.Event.Day, self.Event.Year)
	end
	
	self.DatePicker:SetEnabled(vCanEdit)
	
	if self.Event:UsesLevelLimits() then
		self.LevelRangePicker:SetLevelRange(self.Event.MinLevel, self.Event.MaxLevel)
		self.LevelRangePicker:SetEnabled(vCanEdit)
		self.LevelRangePicker:Show()
	else
		self.LevelRangePicker:Hide()
	end
	
	if self.Event:UsesAttendance() then
		self.EventClosedButton:SetChecked(self.Event.Locked)
		self.EventClosedButton:SetEnabled(vCanEdit)
		
		if not self.Event:IsAllDayEvent() then
			local vLockoutDate = GroupCalendar.DateLib:ConvertMDYToDate(self.Event.LockoutMonth, self.Event.LockoutDay, self.Event.LockoutYear)
			local vLockoutTime = GroupCalendar.DateLib:ConvertHMToTime(self.Event.LockoutHour, self.Event.LockoutMinute)
			
			local vLockoutMinutes
			
			if vLockoutDate then
				vLockoutMinutes = (vEventDate * 1440 + vEventTime) - (vLockoutDate * 1440 + vLockoutTime)
			else
				vLockoutMinutes = "OFF"
			end
			
--			self.LockoutMenu:SetSelectedValue(vLockoutMinutes)
			self.LockoutMenu:SetEnabled(vCanEdit)
		end
		
		self.AutoConfirmButton:SetChecked(self.Event.Limits ~= nil)
		self.AutoConfirmButton:SetEnabled(vCanEdit)
		
		--self.AutoConfirmButton:Show()
		--self.AutoConfirmSettings:Show()
		self.EventClosedButton:Show()
		--self.LockoutMenu:Show()
	else
		--self.AutoConfirmButton:Hide()
		--self.AutoConfirmSettings:Hide()
		self.EventClosedButton:Hide()
		--self.LockoutMenu:Hide()
	end
	
	GroupCalendar:SetEventBackground(self.Event, self.Background, self:GetWidth(), self:GetHeight())
end

function GroupCalendar.UI._EventEditor:ClearFocus()
	self.EventTitle:ClearFocus()
	self.LevelRangePicker:ClearFocus()
	self.Description:ClearFocus()
end

function GroupCalendar.UI._EventEditor:LoadEventDefaults(pTemplate)
	-- Start with the defaults
	
	self.Event:LoadDefaults()
	
	-- Overlay any templated values
	
	if pTemplate then
		for vField, _ in pairs(GroupCalendar.EventTemplateFields) do
			if type(pTemplate[vField]) == "table" then
				if vField ~= "Attendance"
				and vField ~= "Limits" then -- Limits should be allowed once they're actually supported, but for now ignore them
					self.Event[vField] = GroupCalendar:DuplicateTable(pTemplate[vField], true)
				end
			else
				if vField ~= "CalendarType"
				and vField ~= "TitleTag" then
					self.Event[vField] = pTemplate[vField]
				end
			end
		end
		
		self.Event:InitializeNewEvent() -- Copy the new values to the APIs
		
		-- Change the event mode
		
		if pTemplate.CalendarType == "GUILD" or pTemplate.CalendarType == "GUILD_ANNOUNCEMENT" then
			self.Event:SetEventMode("ANNOUNCE")
		elseif pTemplate.CalendarType == "GUILD_EVENT" then
			self.Event:SetEventMode("SIGNUP")
		else
			self.Event:SetEventMode("NORMAL")
		end
	end
	
	-- Process invites
	
	if not GroupCalendar.Data.Prefs.DisableInviteMemory then
		self.Event:BeginBatchInvites()
		
		if pTemplate and pTemplate.Attendance then
			for _, vInfo in pairs(pTemplate.Attendance) do
				self.Event:InvitePlayer(vInfo.Name)
			end
		end
		
		for vName, vInfo in pairs(self.Event.Attendance) do
			if (not pTemplate or not pTemplate.Attendance or not pTemplate.Attendance[vName])
			and vName ~= GroupCalendar.PlayerName then
				self.Event:UninvitePlayer(vInfo.Name)
			end
		end
			
		self.Event:EndBatchInvites()
	end
	
	--
	
	GroupCalendar.BroadcastLib:Broadcast(self.Event, "CHANGED")
end

function GroupCalendar.UI._EventEditor:GetDefaultTitle()
	local eventTypeTextures = GroupCalendar:GetEventTypeTextures(self.Event.EventType)
	local textureInfo = eventTypeTextures[self.Event.TextureIndex]
	
	if not textureInfo then
		return
	end
	
	if not textureInfo.difficultyId then
		return textureInfo.title
	else
		local difficultyName, instanceType, isHeroic, isChallengeMode, displayHeroic, displayMythic, toggleDifficultyID = GetDifficultyInfo(textureInfo.difficultyId)
		if not difficultyName then
			return textureInfo.title
		end
		return DUNGEON_NAME_WITH_DIFFICULTY:format(textureInfo.title, difficultyName)
	end
end

function GroupCalendar.UI._EventEditor:GetEventTypeID()
	if self.Event.TitleTag then
		return self.Event.TitleTag.."_"
	else
		local vEventType = self.Event.EventType
		local vTextureIndex = self.Event.TextureIndex

		-- Get the event's base textureIndex
		local vEventTextureInfo, vDifficultyInfo = GroupCalendar:GetEventTexture(vTextureIndex, vEventType)

		-- Replace the textureIndex with the base textureIndex
		if vEventTextureInfo then
			vTextureIndex = vEventTextureInfo.textureIndex
		end

		return vEventType.."_"..(vTextureIndex or "")
	end
end

function GroupCalendar.UI._EventEditor:SetEventType(eventType, textureIndex)
	local useDefaultTitle = not self.DidLoadDefaultsFromTitle and (self.Event.Title == "" or self:GetDefaultTitle() == self.Event.Title)
	
	local eventType2, textureIndex2, titleTag
	
	if GroupCalendar.TitleTagInfo[eventType] then
		eventType2 = CALENDAR_EVENTTYPE_OTHER
		titleTag = eventType
	else
		eventType2 = eventType
		textureIndex2 = textureIndex
	end
	
	self.Event:SetType(eventType2, textureIndex2)
	self.Event:SetTitleTag(titleTag)
	
	if useDefaultTitle then
		local defaultTitle = self:GetDefaultTitle()
		self.Event:SetTitle(defaultTitle)
		self.EventTitle:SetText(defaultTitle)
	end
	
	-- Update the UI
	self.EventTypeMenu:SetSelectedValue(self:GetEventTypeID())
	self.DifficultyMenu:SetSelectedValue(textureIndex)
	
	-- Broadcast the change
	GroupCalendar.BroadcastLib:Broadcast(self.Event, "CHANGED")
end

function GroupCalendar.UI._EventEditor:AddEventGroupSubMenu(pMenu, pEventGroupID)
	pMenu:AddChildMenu(GroupCalendar.EventTypes[pEventGroupID].Title or "nil", pEventGroupID or 0)
end

function GroupCalendar.UI._EventEditor:AddEventGroupItems(pMenu, pEventGroupID)
	local vEventTypes = GroupCalendar.EventTypes[pEventGroupID]
	
	for vIndex, vEventItem in ipairs(vEventTypes.Events) do
		pMenu:AddItemWithValue(vEventItem.name or "nil", vEventItem.id or 0)
	end
end


function GroupCalendar.UI._EventEditor:EventModeMenuFunc(menu)
	menu:AddItemWithValue(GroupCalendar.cSignupMode, "SIGNUP")
	menu:AddItemWithValue(GroupCalendar.cAnnounceMode, "ANNOUNCE")
	menu:AddItemWithValue(GroupCalendar.cNormalMode, "NORMAL")
end
	
function GroupCalendar.UI._EventEditor:EventTypeMenuFunc(menu)
	local orderedEventTypes = C_Calendar.EventGetTypesDisplayOrdered()

	for index, info in ipairs(orderedEventTypes) do
		local name = _G[info.displayString] or info.displayString

		if info.eventType == CALENDAR_EVENTTYPE_DUNGEON or info.eventType == CALENDAR_EVENTTYPE_PVP then
			menu:AddDivider()
		end

		if info.eventType == CALENDAR_EVENTTYPE_RAID or info.eventType == CALENDAR_EVENTTYPE_DUNGEON then
			local maxExpansion = 7
			local minExpansion = 0 -- Classic didn't have heroics

			local textureCache = GroupCalendar:GetTextureCache()
			local textureCacheForType = textureCache[info.eventType]

			for expansion = maxExpansion, minExpansion, -1 do
				menu:AddChildMenu(
					name.." (".._G["EXPANSION_NAME"..expansion]..")",
					function (menu)
						for cacheIndex, textureInfo in ipairs(textureCacheForType) do
							if textureInfo.expansionLevel == expansion then
								local item = menu:AddToggleWithIcon(
									textureInfo.title,
									GroupCalendar:GetTextureFile(textureInfo.texture, "PLAYER", nil, info.eventType),
									nil,
									function ()
										return self.Event and self.Event.EventType == info.eventType and self.Event.TextureIndex == textureInfo.textureIndex
									end,
									function (menu, value)
										self:SetEventTypeWithDefaults(info.eventType, textureInfo.textureIndex)
									end
								)
								item.value = info.eventType.."_"..textureInfo.textureIndex
							end
						end
					end)
			end
		else
			local item = menu:AddToggleWithIcon(
				name,
				GroupCalendar:GetTextureFile(nil, "PLAYER", nil, info.eventType),
				nil,
				function ()
					return self.Event and self.Event.EventType == info.eventType
				end,
				function (menu, value)
					self:SetEventTypeWithDefaults(info.eventType)
				end
			)
			item.value = info.eventType.."_"..0
		end
	end

	local item = menu:AddToggleWithIcon(
		GroupCalendar.cRoleplayEventName,
		GroupCalendar.TitleTagInfo.RP.Texture,
		nil,
		function ()
			return self.Event and self.Event.TitleTag == "RP"
		end,
		function (menu, value)
			self:SetEventTypeWithDefaults("RP")
		end
	)
	item.value = "RP_"

	item = menu:AddToggleWithIcon(
		GroupCalendar.cBirthdayEventName,
		GroupCalendar.TitleTagInfo.BRTH.Texture,
		nil,
		function ()
			return self.Event and self.Event.TitleTag == "BRTH"
		end,
		function (menu, value)
			self:SetEventTypeWithDefaults("BRTH")
		end
	)
	item.value = "BRTH_"

	item = menu:AddToggleWithIcon(
		GroupCalendar.cVacationEventName,
		GroupCalendar.TitleTagInfo.VAC.Texture,
		nil,
		function ()
			return self.Event and self.Event.TitleTag == "VAC"
		end,
		function (menu, value)
			self:SetEventTypeWithDefaults("VAC")
		end
	)
	item.value = "VAC_"

	item = menu:AddToggleWithIcon(
		GroupCalendar.cDoctorEventName,
		GroupCalendar.TitleTagInfo.MD.Texture,
		nil,
		function ()
			return self.Event and self.Event.TitleTag == "MD"
		end,
		function (menu, value)
			self:SetEventTypeWithDefaults("MD")
		end
	)
	item.value = "MD_"

	item = menu:AddToggleWithIcon(
		GroupCalendar.cDentistEventName,
		GroupCalendar.TitleTagInfo.DDS.Texture,
		nil,
		function ()
			return self.Event and self.Event.TitleTag == "DDS"
		end,
		function (menu, value)
			self:SetEventTypeWithDefaults("DDS")
		end
	)
	item.value = "DDS_"
	
	function self.EventTypeMenu.DidSelectItemWithValue(menu, value)
		self:ClearFocus()

		local _, _, vEventType, vTextureIndex = value:find("(.*)_(.*)")

		vEventType = tonumber(vEventType) or vEventType
		vTextureIndex = tonumber(vTextureIndex)

		self:SetEventTypeWithDefaults(vEventType, vTextureIndex)

		CloseDropDownMenus()
	end
end

function GroupCalendar.UI._EventEditor:SetEventTypeWithDefaults(eventType, textureIndex)
	GroupCalendar:DebugMessage("_EventEditor:SetEventTypeWithDefaults %s", tostring(textureIndex))

	self.EventTypeMenu:SetSelectedValue(textureIndex)

	self:SetEventType(eventType, textureIndex)

	if not self.Event.Index and not self.DidLoadDefaultsFromTitle then
		self:LoadEventDefaults(GroupCalendar:FindEventTemplateByEvent(self.Event))
		self.DidLoadDefaultsFromType = true
	end
end

function GroupCalendar.UI._EventEditor:DurationMenuFunc(menu)
	local durations = {15, 30, 60, 90, 120, 150, 180, 210, 240, 300, 360}

	for _, duration in ipairs(durations) do
		local text

		local minutes = math.fmod(duration, 60)
		local hours = (duration - minutes) / 60

		if hours == 0 then
			text = format(GroupCalendar.cPluralMinutesFormat, minutes)
		else
			if minutes ~= 0 then
				if hours == 1 then
					text = format(GroupCalendar.cSingularHourPluralMinutes, hours, minutes)
				else
					text = format(GroupCalendar.cPluralHourPluralMinutes, hours, minutes)
				end
			else
				if hours == 1 then
					text = format(GroupCalendar.cSingularHourFormat, hours)
				elseif hours > 0 then
					text = format(GroupCalendar.cPluralHourFormat, hours)
				end
			end
		end
		
		menu:AddItemWithValue(text, duration)
	end
end

function GroupCalendar.UI._EventEditor:RepeatMenuFunc(pMenu, pMenuID, pLevel)
	local vOptions = {C_Calendar.EventGetRepeatOptions()}
	
	for vOptionID, vOptionTitle in ipairs(vOptions) do
		pMenu:AddItemWithValue(vOptionTitle, vOptionID)
	end
end

function GroupCalendar.UI._EventEditor:LockoutMenuFunc(pMenu, pMenuID, pLevel)
	pMenu:AddItemWithValue(OFF, "OFF")
	pMenu:AddItemWithValue(GroupCalendar.cLockout0, 0)
	pMenu:AddItemWithValue(GroupCalendar.cLockout15, 15)
	pMenu:AddItemWithValue(GroupCalendar.cLockout30, 30)
	pMenu:AddItemWithValue(GroupCalendar.cLockout60, 60)
	pMenu:AddItemWithValue(GroupCalendar.cLockout120, 120)
	pMenu:AddItemWithValue(GroupCalendar.cLockout180, 180)
	pMenu:AddItemWithValue(GroupCalendar.cLockout1440, 1440)
end
