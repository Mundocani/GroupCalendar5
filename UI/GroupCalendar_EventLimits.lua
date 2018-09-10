----------------------------------------
-- Group Calendar 5 Copyright 2005 - 2016 John Stephen, wobbleworks.com
-- All rights reserved, unauthorized redistribution is prohibited
----------------------------------------

----------------------------------------
-- _RoleLimitsDialog
----------------------------------------

GroupCalendar.UI._RoleLimitsDialog = {}

function GroupCalendar.UI._RoleLimitsDialog:New(pParent)
	return CreateFrame("Frame", nil, pParent)
end

function GroupCalendar.UI._RoleLimitsDialog:Construct(pParent)
	self.FullHeight = 350
	
	self:Inherit(GroupCalendar.UIElementsLib._ModalDialogFrame, pParent, GroupCalendar.cRoleConfirmationTitle, 680, self.FullHeight)
	
	self:SetFrameStrata("DIALOG")
	self:EnableMouse(true)
	
	self:SetScript("OnShow", self.OnShow)
end

function GroupCalendar.UI._RoleLimitsDialog:Open(pLimits, pTitle, pShowPriority, pSaveFunction)
	if not self.Initialized then
		self.Initialized = true
		self.Description = self:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
		self.Description:SetText(GroupCalendar.cRoleLimitDescription)
		
		self.Description:SetPoint("TOP", self, "TOP", 0, -30)
		self.Description:SetWidth(600)
		
		-- Priority
		
		self.PriorityFrame = CreateFrame("Frame", nil, self)
		self.PriorityFrame:SetPoint("TOP", self.Description, "BOTTOM", -20, -20)
		self.PriorityFrame:SetWidth(230)
		self.PriorityFrame:SetHeight(1)
		self.PriorityFrame.FullHeight = 24
		self.PriorityFrame:SetScript("OnHide", function (pFrame)
			pFrame:SetHeight(1)
			self:SetHeight(self.FullHeight - pFrame.FullHeight)
		end)
		self.PriorityFrame:SetScript("OnShow", function (pFrame)
			pFrame:SetHeight(pFrame.FullHeight)
			self:SetHeight(self.FullHeight)
		end)
		
		self:SetHeight(self.FullHeight - self.PriorityFrame.FullHeight)
		
		self.PriorityMenu = GroupCalendar:New(GroupCalendar.UIElementsLib._TitledDropDownMenuButton, self.PriorityFrame, function (pMenu, pValue, pLevel)
			pMenu:AddNormalItem(GroupCalendar.cPriorityDate, "DATE")
			pMenu:AddNormalItem(GroupCalendar.cPriorityRank, "RANK")
		end, 130)
		self.PriorityMenu:SetTitle(GroupCalendar.cPriorityLabel)
		self.PriorityMenu:SetPoint("TOPLEFT", self.PriorityFrame, "TOPLEFT", 100, 0)
		
		-- Limit items
		
		self.H = GroupCalendar:New(GroupCalendar._RoleLimitItem, self)
		self.H:SetPoint("LEFT", self, "LEFT", 30, 0)
		self.H:SetPoint("TOP", self.PriorityFrame, "BOTTOM", 0, -30)
		self.H:SetRoleCode("H")
		
		self.T = GroupCalendar:New(GroupCalendar._RoleLimitItem, self)
		self.T:SetPoint("TOPLEFT", self.H, "TOPLEFT", 0, -30)
		self.T:SetRoleCode("T")
		
		self.R = GroupCalendar:New(GroupCalendar._RoleLimitItem, self)
		self.R:SetPoint("TOPLEFT", self.T, "TOPLEFT", 0, -30)
		self.R:SetRoleCode("R")
		
		self.M = GroupCalendar:New(GroupCalendar._RoleLimitItem, self)
		self.M:SetPoint("TOPLEFT", self.R, "TOPLEFT", 0, -30)
		self.M:SetRoleCode("M")
		
		-- Class labels
		
		self.ClassLabels = {}
		
		for vClassID, vClassInfo in pairs(GroupCalendar.ClassInfoByClassID) do
			local vColor = RAID_CLASS_COLORS[vClassID]
			
			local vFontString = self:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
			vFontString:SetWidth(35)
			vFontString:SetHeight(20)
			vFontString:SetTextColor(vColor.r, vColor.g, vColor.b)
			vFontString:SetPoint("BOTTOM", self.H[vClassID], "TOP", 0, 5)
			vFontString:SetText(GroupCalendar.cClassName[vClassID].Male)
			
			self.ClassLabels[vClassID] = vFontString
		end
		
		-- Party size
		
		self.MaxPartySizeMenu = GroupCalendar:New(GroupCalendar.UIElementsLib._TitledDropDownMenuButton, self, function (pMenu, pValue, pLevel)
			pMenu:AddNormalItem(GroupCalendar.cNoMaximum, 0)
			pMenu:AddNormalItem(GroupCalendar.cPartySizeFormat:format("5"), 5)
			pMenu:AddNormalItem(GroupCalendar.cPartySizeFormat:format("10"), 10)
			pMenu:AddNormalItem(GroupCalendar.cPartySizeFormat:format("15"), 15)
			pMenu:AddNormalItem(GroupCalendar.cPartySizeFormat:format("20"), 20)
			pMenu:AddNormalItem(GroupCalendar.cPartySizeFormat:format("25"), 25)
			pMenu:AddNormalItem(GroupCalendar.cPartySizeFormat:format("40"), 40)
		end, 130)
		self.MaxPartySizeMenu:SetTitle(GroupCalendar.cMaxPartySizeLabel)
		self.MaxPartySizeMenu:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 170, 20)
		self.MaxPartySizeMenu.ItemClickedFunc = function (pMenu, pValue)
			if pValue > 0 then
				self:UpdateFields(GroupCalendar.DefaultLimits[pValue])
			end
		end
		
		self.MinLabel = self:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
		self.MinLabel:SetText(GroupCalendar.cMinPartySizeLabel)
		self.MinLabel:SetJustifyH("RIGHT")
		self.MinLabel:SetPoint("BOTTOMRIGHT", self.MaxPartySizeMenu.Title, "BOTTOMRIGHT", 0, 30)
		
		self.MinPartySize = self:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
		self.MinPartySize:SetText("0")
		self.MinPartySize:SetJustifyH("LEFT")
		self.MinPartySize:SetPoint("LEFT", self.MinLabel, "RIGHT", 4, 0)
		
		-- Hide/Show reservations
		
		self.ToggleClassReservations = GroupCalendar:New(GroupCalendar.UIElementsLib._PushButton, self, GroupCalendar.cShowClassReservations, 150)
		self.ToggleClassReservations:SetPoint("RIGHT", self.CancelButton, "RIGHT", 0, 0)
		self.ToggleClassReservations:SetPoint("TOP", self.MinPartySize, "TOP", 0, 8)
		self.ToggleClassReservations:SetScript("OnClick", function (pFrame, pButton)
			self:ShowClassReservations(not self.ReservationsVisible)
		end)
	end
	
	self.ShowPriority = pShowPriority
	self.SaveFunction = pSaveFunction
	
	self.Title:SetText(pTitle)
	self:UpdateFields(pLimits)

	if pShowPriority then
		self.PriorityFrame:Show()
	else
		self.PriorityFrame:Hide()
	end
	
	self:Show()
end

function GroupCalendar.UI._RoleLimitsDialog:Done()
	if self.SaveFunction then
		self.SaveFunction(self:GetLimits())
	end
	
	self:Hide()
end

function GroupCalendar.UI._RoleLimitsDialog:Cancel()
	self:Hide()
end

function GroupCalendar.UI._RoleLimitsDialog:ShowClassReservations(pShow)
	self.ReservationsVisible = pShow
	
	self.H:ShowClassReservations(pShow)
	self.T:ShowClassReservations(pShow)
	self.R:ShowClassReservations(pShow)
	self.M:ShowClassReservations(pShow)
	
	if pShow then
		self.H:SetPoint("LEFT", self, "LEFT", 25, 0)
		
		for vClassID, _ in pairs(GroupCalendar.ClassInfoByClassID) do
			self.ClassLabels[vClassID]:Show()
		end
		
		self:SetWidth(self.H.ExpandedWidth + 20 + 40)
		self.Description:SetWidth(self.H.ExpandedWidth + 20)
		self.ToggleClassReservations:SetTitle(GroupCalendar.cHideClassReservations)
	else
		self.H:SetPoint("LEFT", self, "LEFT", 165, 0)
		
		for vClassID, _ in pairs(GroupCalendar.ClassInfoByClassID) do
			self.ClassLabels[vClassID]:Hide()
		end
		
		self:SetWidth(self.H.CompactWidth + 290 + 40)
		self.Description:SetWidth(self.H.CompactWidth + 290)

		self.ToggleClassReservations:SetTitle(GroupCalendar.cShowClassReservations)
	end
end

function GroupCalendar.UI._RoleLimitsDialog:OnShow()
	self:MinTotalChanged()
	self:ShowClassReservations(false)
end

function GroupCalendar.UI._RoleLimitsDialog:MinTotalChanged()
	local vMinTotal = nil
	
	for vRoleCode, vRoleInfo in pairs(GroupCalendar.RoleInfoByID) do
		local vRoleMin = tonumber(self[vRoleCode].Min:GetText())
		
		if vRoleMin then
			vMinTotal = (vMinTotal or 0) + vRoleMin
		end
	end
	
	self.MinPartySize:SetText(vMinTotal or GroupCalendar.cNoMinimum)
end

function GroupCalendar.UI._RoleLimitsDialog:UpdateFields(pLimits)
	for vRoleCode, vRoleInfo in pairs(GroupCalendar.RoleInfoByID) do
		local vRoleLimits = nil
		
		if pLimits and pLimits.RoleLimits then
			vRoleLimits = pLimits.RoleLimits[vRoleCode]
		end
		
		local vMinValue, vMaxValue
		
		if vRoleLimits and vRoleLimits.Min then
			vMinValue = vRoleLimits.Min
		else
			vMinValue = ""
		end
		
		if vRoleLimits and vRoleLimits.Max then
			vMaxValue = vRoleLimits.Max
		else
			vMaxValue = ""
		end
		
		--
		
		local vRoleFrame = self[vRoleCode]
		
		vRoleFrame.Min:SetText(vMinValue)
		vRoleFrame.Max:SetText(vMaxValue)
		
		for vClassID, vClassInfo in pairs(GroupCalendar.ClassInfoByClassID) do
			local vValue
			
			if vRoleLimits and vRoleLimits.Class and vRoleLimits.Class[vClassID] then
				vValue = vRoleLimits.Class[vClassID]
			else
				vValue = ""
			end
			
			vRoleFrame[vClassID]:SetText(vValue)
		end
	end
	
	if pLimits and pLimits.MaxAttendance then
		self.MaxPartySizeMenu:SetSelectedValue(pLimits.MaxAttendance)
	else
		self.MaxPartySizeMenu:SetSelectedValue(0)
	end

	if pLimits and pLimits.PriorityOrder then
		self.PriorityMenu:SetSelectedValue(pLimits.PriorityOrder)
	else
		self.PriorityMenu:SetSelectedValue("DATE")
	end
end

function GroupCalendar.UI._RoleLimitsDialog:GetLimits()
	local vLimits = {}
	
	for vRoleCode, vRoleInfo in pairs(GroupCalendar.RoleInfoByID) do
		local vRoleFrame = self[vRoleCode]
		
		local vRoleMin = tonumber(vRoleFrame.Min:GetText())
		local vRoleMax = tonumber(vRoleFrame.Max:GetText())
		
		if vRoleMin or vRoleMax then
			local vRoleLimits = {}
			
			vRoleLimits.Min = vRoleMin
			vRoleLimits.Max = vRoleMax
			
			for vClassID, vClassInfo in pairs(GroupCalendar.ClassInfoByClassID) do
				local vClassMin = tonumber(vRoleFrame[vClassID]:GetText())
				
				if vClassMin then
					if not vRoleLimits.Class then
						vRoleLimits.Class = {}
					end
					
					vRoleLimits.Class[vClassID] = vClassMin
				end
			end
			
			if not vLimits.RoleLimits then
				vLimits.RoleLimits = {}
			end
			
			vLimits.RoleLimits[vRoleCode] = vRoleLimits
		end
	end
	
	vLimits.MaxAttendance = self.MaxPartySizeMenu:GetSelectedValue()
	
	if vLimits.MaxAttendance == 0 then
		vLimits.MaxAttendance = nil
	end
	
	vLimits.PriorityOrder = self.PriorityMenu:GetSelectedValue()
	
	if vLimits.PriorityOrder == "DATE" then
		vLimits.PriorityOrder = nil
	end
	
	-- See if the Limits field should just be removed altogether
	
	if not next(vLimits) then
		vLimits = nil
	end
	
	-- Done
	
	return vLimits
end

----------------------------------------
-- _AvailableSlots
----------------------------------------

GroupCalendar._AvailableSlots = {}

function GroupCalendar._AvailableSlots:Construct(pLimits, pLimitMode)
	self.Limits = pLimits
	self.LimitMode = pLimitMode
	
	if pLimits then
		self.SlotLimits = tern(pLimitMode == "ROLE", pLimits.RoleLimits, pLimits.ClassLimits)
	end
	
	self.SlotTotals = {}
	
	local vMinTotal = 0
	
	if self.SlotLimits then
		for vSlotID, vSlotLimit in pairs(self.SlotLimits) do
			local vSlotTotal = {}
			
			-- Set the class minimums and total them up
			
			local vTotalClassMin = 0
			
			if vSlotLimit.Class then
				vSlotTotal.ClassMin = {}
				
				for vClassID, vClassMin in pairs(vSlotLimit.Class) do
					vSlotTotal.ClassMin[vClassID] = vClassMin
					vTotalClassMin = vTotalClassMin + vClassMin
				end
			end
			
			-- The number of "general" slots for the category can't
			-- include the sub-category slots (class), so subtract
			-- those out
			
			if vSlotLimit.Min then
				vSlotTotal.Available = vSlotLimit.Min - vTotalClassMin -- Subtract the specialized mins from the general min
			else
				vSlotTotal.Available = 0
			end
			
			if vSlotTotal.Available < 0 then
				vSlotTotal.Available = 0
			end
			
			local vSlotMinTotal = vTotalClassMin + vSlotTotal.Available
			
			-- Make sure the max is at least the min
			
			if vSlotLimit.Max and vSlotLimit.Max < vSlotMinTotal then
				vSlotLimit.Max = vSlotMinTotal
			end
			
			-- Calculate the available extra slots as max - min
			
			vSlotTotal.Extras = (vSlotLimit.Max or pLimits.MaxAttendance) - vSlotMinTotal
			
			if vSlotTotal.Extras < 0 then
				vSlotTotal.Extras = 0
			end
			
			-- Done with this slot
			
			vMinTotal = vMinTotal + vSlotMinTotal
			
			self.SlotTotals[vSlotID] = vSlotTotal
		end -- for vSlotID
	end
	
	if pLimits and pLimits.MaxAttendance then
		self.TotalExtras = pLimits.MaxAttendance - vMinTotal
		
		if self.TotalExtras < 0 then
			self.TotalExtras = 0
		end
	else
		self.TotalExtras = nil
	end
end

function GroupCalendar._AvailableSlots:AddEventAttendance(pEvent, pIgnorePlayerName)
	local vAttendance = pEvent:GetAttendance()
	
	for vName, vPlayerInfo in pairs(vAttendance) do
		if vPlayerInfo.InviteStatus == CALENDAR_INVITESTATUS_STANDBY
		or vPlayerInfo.InviteStatus == CALENDAR_INVITESTATUS_CONFIRMED
		or vPlayerInfo.InviteStatus == CALENDAR_INVITESTATUS_TENTATIVE then
			if vName ~= pIgnorePlayerName then
				self:AddPlayer(vPlayerInfo)
			end
		end
	end
end

function GroupCalendar._AvailableSlots:AddEventGroup(pEvent, pIgnorePlayerName)
	if not pEvent.Group then
		return
	end
	
	for vName, vPlayerInfo in pairs(pEvent.Group) do
		if vName ~= pIgnorePlayerName
		and not vPlayerInfo.LeftGroup then
			self:AddPlayer(vPlayerInfo)
		end
	end
end

function GroupCalendar._AvailableSlots:AddPlayer(pPlayerInfo)
	local vRoleCode = (vAttendanceInfo and vAttendanceInfo.RoleCode) or GroupCalendar:GetPlayerDefaultRoleCode(pPlayerInfo.Name, pPlayerInfo.ClassID)
	local vSlotCode = tern(self.LimitMode == "ROLE", vRoleCode, pPlayerInfo.ClassID)
	local vSlotTotal = self.SlotTotals[vSlotCode]
	
	if not vSlotTotal then
		return false
	end
	
	-- Try to fill a class-specific slot first
	
	if vSlotTotal.ClassMin then
		local vClassMin = vSlotTotal.ClassMin[pPlayerInfo.ClassID]
		
		if vClassMin and vClassMin > 0 then
			vSlotTotal.ClassMin[pPlayerInfo.ClassID] = vClassMin - 1
			return true
		end
	end
	
	-- Try to fill general slot
	
	if vSlotTotal.Available > 0 then
		vSlotTotal.Available = vSlotTotal.Available - 1
		return true
	end
	
	-- If there are no extra (floating) slots then they can't get in
	
	if self.TotalExtras and self.TotalExtras <= 0 then
		return false
	end
	
	-- Make sure there's space in their category
	
	if vSlotTotal.Extras and vSlotTotal.Extras <= 0 then
		return false
	end
	
	if self.TotalExtras then
		self.TotalExtras = self.TotalExtras - 1
	end
	
	if vSlotTotal.Extras then
		vSlotTotal.Extras = vSlotTotal.Extras - 1
	end
	
	return true
end

----------------------------------------
GroupCalendar._ClassLimitItem = {}
----------------------------------------

function GroupCalendar._ClassLimitItem:New(pParent)
	return CreateFrame("Frame", nil, pParent)
end

function GroupCalendar._ClassLimitItem:Construct(pParent)
	self:SetWidth(113)
	self:SetHeight(20)
	
	self.Background = self:CreateTexture(nil, "BACKGROUND")
	self.Background:SetPoint("TOPLEFT", self, "TOPLEFT", -74, 2)
	self.Background:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, -3)
	
	self.Min = GroupCalendar:New(GroupCalendar.UIElementsLib._EditBox, self, "Class name:", 2, 40)
	self.Min:SetPoint("LEFT", self, "LEFT")
	self.Min:SetScript("OnTextChanged", function (pEditBox)
		self:GetParent():MinTotalChanged()
	end)
	
	self.Max = GroupCalendar:New(GroupCalendar.UIElementsLib._EditBox, self, GroupCalendar.cLevelRangeSeparator, 2, 40)
	self.Max:SetPoint("LEFT", self.Min, "RIGHT", 25, 0)
end

function GroupCalendar._ClassLimitItem:SetClassID(pClassID)
	local vColor = RAID_CLASS_COLORS[pClassID]
	
	self.Min.Title:SetText(GroupCalendar.cClassName[pClassID].Plural..":")
	
	self.Min.Title:SetTextColor(vColor.r, vColor.g, vColor.b)
	self.Background:SetColorTexture(vColor.r, vColor.g, vColor.b, 0.05)
	self.Max.Title:SetTextColor(vColor.r, vColor.g, vColor.b)
end

----------------------------------------
GroupCalendar._RoleLimitItem = {}
----------------------------------------

function GroupCalendar._RoleLimitItem:New(pParent)
	return CreateFrame("Frame", nil, pParent)
end

function GroupCalendar._RoleLimitItem:Construct(pParent)
	self.CompactWidth = 185
	self.ReservationsWidth = 500
	self.ExpandedWidth = self.CompactWidth + self.ReservationsWidth
	
	self:SetWidth(self.ExpandedWidth)
	self:SetHeight(20)
	
	self.Min = GroupCalendar:New(GroupCalendar.UIElementsLib._EditBox, self, "", 2, 40)
	self.Min:SetPoint("LEFT", self, "LEFT", 90, 0)
	self.Min:SetScript("OnTextChanged", function (pEditBox)
		self:GetParent():MinTotalChanged()
	end)
	
	self.Max = GroupCalendar:New(GroupCalendar.UIElementsLib._EditBox, self, GroupCalendar.cLevelRangeSeparator, 2, 40)
	self.Max:SetPoint("LEFT", self.Min, "RIGHT", 30, 0)
	
	self.PRIEST = GroupCalendar:New(GroupCalendar.UIElementsLib._EditBox, self, nil, 2, 25)
	self.PRIEST:SetPoint("LEFT", self.Max, "RIGHT", 25, 0)
	
	self.DRUID = GroupCalendar:New(GroupCalendar.UIElementsLib._EditBox, self, nil, 2, 25)
	self.DRUID:SetPoint("LEFT", self.PRIEST, "LEFT", 40, 0)
	
	self.PALADIN = GroupCalendar:New(GroupCalendar.UIElementsLib._EditBox, self, nil, 2, 25)
	self.PALADIN:SetPoint("LEFT", self.DRUID, "LEFT", 40, 0)
	
	self.SHAMAN = GroupCalendar:New(GroupCalendar.UIElementsLib._EditBox, self, nil, 2, 25)
	self.SHAMAN:SetPoint("LEFT", self.PALADIN, "LEFT", 40, 0)
	
	self.WARRIOR = GroupCalendar:New(GroupCalendar.UIElementsLib._EditBox, self, nil, 2, 25)
	self.WARRIOR:SetPoint("LEFT", self.SHAMAN, "LEFT", 40, 0)
	
	self.ROGUE = GroupCalendar:New(GroupCalendar.UIElementsLib._EditBox, self, nil, 2, 25)
	self.ROGUE:SetPoint("LEFT", self.WARRIOR, "LEFT", 40, 0)
	
	self.HUNTER = GroupCalendar:New(GroupCalendar.UIElementsLib._EditBox, self, nil, 2, 25)
	self.HUNTER:SetPoint("LEFT", self.ROGUE, "LEFT", 40, 0)
	
	self.MAGE = GroupCalendar:New(GroupCalendar.UIElementsLib._EditBox, self, nil, 2, 25)
	self.MAGE:SetPoint("LEFT", self.HUNTER, "LEFT", 40, 0)
	
	self.WARLOCK = GroupCalendar:New(GroupCalendar.UIElementsLib._EditBox, self, nil, 2, 25)
	self.WARLOCK:SetPoint("LEFT", self.MAGE, "LEFT", 40, 0)
	
	self.DEATHKNIGHT = GroupCalendar:New(GroupCalendar.UIElementsLib._EditBox, self, nil, 2, 25)
	self.DEATHKNIGHT:SetPoint("LEFT", self.WARLOCK, "LEFT", 40, 0)
	
	self.MONK = GroupCalendar:New(GroupCalendar.UIElementsLib._EditBox, self, nil, 2, 25)
	self.MONK:SetPoint("LEFT", self.DEATHKNIGHT, "LEFT", 40, 0)
	
	self.DEMONHUNTER = GroupCalendar:New(GroupCalendar.UIElementsLib._EditBox, self, nil, 2, 25)
	self.DEMONHUNTER:SetPoint("LEFT", self.MONK, "LEFT", 40, 0)
	
	-- Adjust the colors
	
	for vClassID, vClassInfo in pairs(GroupCalendar.ClassInfoByClassID) do
		local vColor = RAID_CLASS_COLORS[vClassID]
		
		self[vClassID]:SetTextColor(vColor.r, vColor.g, vColor.b)
	end

	self.Background = self:CreateTexture(nil, "BACKGROUND")
	self.Background:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 2)
	self.Background:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, -2)
	self.Background:SetPoint("RIGHT", self.Max, "RIGHT", 8, 0)
	
	self.Background2 = self:CreateTexture(nil, "BACKGROUND")
	self.Background2:SetPoint("TOP", self, "TOP", 0, 2)
	self.Background2:SetPoint("BOTTOM", self, "BOTTOM", 0, -2)
	self.Background2:SetPoint("LEFT", self.PRIEST, "LEFT", -10, 0)
	self.Background2:SetPoint("RIGHT", self.DEMONHUNTER, "RIGHT", 10, 0)
end

function GroupCalendar._RoleLimitItem:ShowClassReservations(pShow)
	if pShow then
		self:SetRoleCode(self.RoleCode)
		
		self.Background2:Show()
		self:SetWidth(self.ExpandedWidth)
	else
		for vClassID, _ in pairs(GroupCalendar.ClassInfoByClassID) do
			self[vClassID]:Hide()
		end
		
		self.Background2:Hide()
		self:SetWidth(self.CompactWidth)
	end
end

function GroupCalendar._RoleLimitItem:SetRoleCode(pRoleCode)
	self.RoleCode = pRoleCode
	
	local vColor = GroupCalendar.RoleInfoByID[pRoleCode].Color
	
	self.Min.Title:SetText(GroupCalendar["c"..pRoleCode.."PluralLabel"])
	
	self.Min.Title:SetTextColor(vColor.r, vColor.g, vColor.b)
	self.Max.Title:SetTextColor(vColor.r, vColor.g, vColor.b)
	self.Background:SetColorTexture(vColor.r, vColor.g, vColor.b, 0.07)
	self.Background2:SetColorTexture(vColor.r, vColor.g, vColor.b, 0.05)

	local vRoleInfo = GroupCalendar.RoleInfoByID[pRoleCode]
	
	for vClassID, vClassInfo in pairs(GroupCalendar.ClassInfoByClassID) do
		local vClassItem = self[vClassID]
		local vColor = RAID_CLASS_COLORS[vClassID]
		
		if vRoleInfo.Classes[vClassID] then
			vClassItem:SetVertexColor(vColor.r, vColor.g, vColor.b)
			vClassItem:Show()
		else
			vClassItem:Hide()
		end
	end
end

----------------------------------------
-- _ClassLimitsDialog
----------------------------------------

GroupCalendar.UI._ClassLimitsDialog = {}

function GroupCalendar.UI._ClassLimitsDialog:New(pParent)
	return CreateFrame("Frame", nil, pParent)
end

function GroupCalendar.UI._ClassLimitsDialog:Construct(pParent)
	self.FullHeight = 320
	
	self:Inherit(GroupCalendar.UIElementsLib._ModalDialogFrame, pParent, GroupCalendar.cAutoConfirmationTitle, 700, self.FullHeight)
	
	self:SetScript("OnShow", self.OnShow)
end

function GroupCalendar.UI._ClassLimitsDialog:Initialize()
	if self.Initialized then return end
	self.Initialized = true
	
	self.Description = self:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	self.Description:SetText(GroupCalendar.cClassLimitDescription)
	self.Description:SetHeight(80)
	self.Description:SetPoint("TOPLEFT", self, "TOPLEFT", 35, -15)
	self.Description:SetPoint("TOPRIGHT", self, "TOPRIGHT", -35, -15)
	
	-- Priority
	
	self.PriorityFrame = CreateFrame("Frame", nil, self)
	self.PriorityFrame:SetPoint("TOPLEFT", self.Description, "BOTTOM", -65, 0)
	self.PriorityFrame:SetWidth(350)
	self.PriorityFrame:SetHeight(1)
	self.PriorityFrame.FullHeight = 30
	self.PriorityFrame:SetScript("OnHide", function (pFrame)
		pFrame:SetHeight(1)
		self:SetHeight(self.FullHeight - pFrame.FullHeight)
	end)
	self.PriorityFrame:SetScript("OnShow", function (pFrame)
		pFrame:SetHeight(pFrame.FullHeight)
		self:SetHeight(self.FullHeight)
	end)
	
	self.PriorityMenu = GroupCalendar:New(GroupCalendar.UIElementsLib._TitledDropDownMenuButton, self, function (pMenu, pValue, pLevel)
		pMenu:AddNormalItem(GroupCalendar.cPriorityDate, "DATE")
		pMenu:AddNormalItem(GroupCalendar.cPriorityRank, "RANK")
	end, 130)
	self.PriorityMenu:SetTitle(GroupCalendar.cPriorityLabel)
	self.PriorityMenu:SetPoint("TOPLEFT", self.PriorityFrame, "TOPLEFT", 100, 20)
	
	-- Limit items
	
	self.DRUID = GroupCalendar:New(GroupCalendar._ClassLimitItem, self)
	self.DRUID:SetPoint("TOPLEFT", self.PriorityFrame, "BOTTOMLEFT", -46, -25)
	self.DRUID:SetClassID("DRUID")

	self.PRIEST = GroupCalendar:New(GroupCalendar._ClassLimitItem, self)
	self.PRIEST:SetPoint("TOPLEFT", self.DRUID, "TOPLEFT", 200, 0)
	self.PRIEST:SetClassID("PRIEST")

	self.PALADIN = GroupCalendar:New(GroupCalendar._ClassLimitItem, self)
	self.PALADIN:SetPoint("TOPLEFT", self.PRIEST, "TOPLEFT", 200, 0)
	self.PALADIN:SetClassID("PALADIN")

	self.HUNTER = GroupCalendar:New(GroupCalendar._ClassLimitItem, self)
	self.HUNTER:SetPoint("TOPLEFT", self.DRUID, "TOPLEFT", 0, -30)
	self.HUNTER:SetClassID("HUNTER")

	self.ROGUE = GroupCalendar:New(GroupCalendar._ClassLimitItem, self)
	self.ROGUE:SetPoint("TOPLEFT", self.PRIEST, "TOPLEFT", 0, -30)
	self.ROGUE:SetClassID("ROGUE")

	self.SHAMAN = GroupCalendar:New(GroupCalendar._ClassLimitItem, self)
	self.SHAMAN:SetPoint("TOPLEFT", self.PALADIN, "TOPLEFT", 0, -30)
	self.SHAMAN:SetClassID("SHAMAN")

	self.MAGE = GroupCalendar:New(GroupCalendar._ClassLimitItem, self)
	self.MAGE:SetPoint("TOPLEFT", self.HUNTER, "TOPLEFT", 0, -30)
	self.MAGE:SetClassID("MAGE")

	self.WARLOCK = GroupCalendar:New(GroupCalendar._ClassLimitItem, self)
	self.WARLOCK:SetPoint("TOPLEFT", self.ROGUE, "TOPLEFT", 0, -30)
	self.WARLOCK:SetClassID("WARLOCK")

	self.WARRIOR = GroupCalendar:New(GroupCalendar._ClassLimitItem, self)
	self.WARRIOR:SetPoint("TOPLEFT", self.SHAMAN, "TOPLEFT", 0, -30)
	self.WARRIOR:SetClassID("WARRIOR")

	self.DEATHKNIGHT = GroupCalendar:New(GroupCalendar._ClassLimitItem, self)
	self.DEATHKNIGHT:SetPoint("TOPLEFT", self.MAGE, "TOPLEFT", 0, -30)
	self.DEATHKNIGHT:SetClassID("DEATHKNIGHT")
	
	self.MONK = GroupCalendar:New(GroupCalendar._ClassLimitItem, self)
	self.MONK:SetPoint("TOPLEFT", self.DEATHKNIGHT, "TOPLEFT", 0, -30)
	self.MONK:SetClassID("MONK")
	
	self.DEMONHUNTER = GroupCalendar:New(GroupCalendar._ClassLimitItem, self)
	self.DEMONHUNTER:SetPoint("TOPLEFT", self.MONK, "TOPLEFT", 0, -30)
	self.DEMONHUNTER:SetClassID("DEMONHUNTER")
	
	-- Party size
	
	self.MaxPartySizeMenu = GroupCalendar:New(GroupCalendar.UIElementsLib._TitledDropDownMenuButton, self, function (pMenu, pValue, pLevel)
		pMenu:AddNormalItem(GroupCalendar.cNoMaximum, 0)
		pMenu:AddNormalItem(GroupCalendar.cPartySizeFormat:format("5"), 5)
		pMenu:AddNormalItem(GroupCalendar.cPartySizeFormat:format("10"), 10)
		pMenu:AddNormalItem(GroupCalendar.cPartySizeFormat:format("15"), 15)
		pMenu:AddNormalItem(GroupCalendar.cPartySizeFormat:format("20"), 20)
		pMenu:AddNormalItem(GroupCalendar.cPartySizeFormat:format("25"), 25)
		pMenu:AddNormalItem(GroupCalendar.cPartySizeFormat:format("40"), 40)
	end, 130)
	self.MaxPartySizeMenu:SetTitle(GroupCalendar.cMaxPartySizeLabel)
	self.MaxPartySizeMenu:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 150, 20)
	
	self.MinLabel = self:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	self.MinLabel:SetText(GroupCalendar.cMinPartySizeLabel)
	self.MinLabel:SetJustifyH("RIGHT")
	self.MinLabel:SetPoint("BOTTOMRIGHT", self.MaxPartySizeMenu.Title, "BOTTOMRIGHT", 0, 30)
	
	self.MinPartySize = self:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	self.MinPartySize:SetText("0")
	self.MinPartySize:SetJustifyH("LEFT")
	self.MinPartySize:SetPoint("LEFT", self.MinLabel, "RIGHT", 4, 0)
end

function GroupCalendar.UI._ClassLimitsDialog:Open(pLimits, pTitle, pShowPriority, pSaveFunction)
	self:Initialize()
	
	self.ShowPriority = pShowPriority
	self.SaveFunction = pSaveFunction
	self.Title:SetText(pTitle)
	
	self:UpdateFields(pLimits)
	
	if pShowPriority then
		self.PriorityFrame:Show()
	else
		self.PriorityFrame:Hide()
	end
	
	self:Show()
end

function GroupCalendar.UI._ClassLimitsDialog:Done()
	if self.SaveFunction then
		self.SaveFunction(self:GetLimits())
	end
	
	self:Hide()
end

function GroupCalendar.UI._ClassLimitsDialog:Cancel()
	self:Hide()
end

function GroupCalendar.UI._ClassLimitsDialog:OnShow()
	self:MinTotalChanged()
end

function GroupCalendar.UI._ClassLimitsDialog:MinTotalChanged(pAutoConfirmFrame)
	local vMinTotal = nil
	
	for vClassID, vClassInfo in pairs(GroupCalendar.ClassInfoByClassID) do
		local vClassMin = tonumber(self[vClassID].Min:GetText())
		
		if vClassMin then
			vMinTotal = (vMinTotal or 0) + vClassMin
		end
	end
	
	self.MinPartySize:SetText(vMinTotal or GroupCalendar.cNoMinimum)
end

function GroupCalendar.UI._ClassLimitsDialog:UpdateFields(pLimits)
	for vClassID, vClassInfo in pairs(GroupCalendar.ClassInfoByClassID) do
		local vClassLimit = nil
		
		if pLimits and pLimits.ClassLimits then
			vClassLimit = pLimits.ClassLimits[vClassID]
		end
		
		local vMinValue, vMaxValue
		
		if vClassLimit and vClassLimit.Min then
			vMinValue = vClassLimit.Min
		else
			vMinValue = ""
		end
		
		if vClassLimit and vClassLimit.Max then
			vMaxValue = vClassLimit.Max
		else
			vMaxValue = ""
		end
		
		local vClassFrame = self[vClassID]
		
		vClassFrame.Min:SetText(vMinValue)
		vClassFrame.Max:SetText(vMaxValue)
	end
	
	if pLimits and pLimits.MaxAttendance then
		self.MaxPartySizeMenu:SetSelectedValue(pLimits.MaxAttendance)
	else
		self.MaxPartySizeMenu:SetSelectedValue(0)
	end

	if pLimits and pLimits.PriorityOrder then
		pLimits.PriorityMenu:SetSelectedValue(pLimits.PriorityOrder)
	else
		pLimits.PriorityMenu:SetSelectedValue("DATE")
	end
end

function GroupCalendar.UI._ClassLimitsDialog:GetLimits()
	local vLimits = {}
	
	for vClassID, vClassInfo in pairs(GroupCalendar.ClassInfoByClassID) do
		local vClassMin = tonumber(self[vClassID].Min:GetText())
		local vClassMax = tonumber(self[vClassID].Max:GetText())
		
		if vClassMin or vClassMax then
			if not vLimits.ClassLimits then
				vLimits.ClassLimits = {}
			end
			
			vLimits.ClassLimits[vClassID] = {Min = vClassMin, Max = vClassMax}
		end
	end
	
	vLimits.MaxAttendance = self.MaxPartySizeMenu:GetSelectedValue()
	
	if vLimits.MaxAttendance == 0 then
		vLimits.MaxAttendance = nil
	end
	
	vLimits.PriorityOrder = self.PriorityMenu:GetSelectedValue()
	
	if vLimits.PriorityOrder == "DATE" then
		vLimits.PriorityOrder = nil
	end
	
	-- See if the Limits field should just be removed altogether
	
	if not next(vLimits) then
		vLimits = nil
	end
	
	-- Done
	
	return vLimits
end

