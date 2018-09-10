----------------------------------------
-- _Clock
----------------------------------------

local _, Addon = ...

Addon._Clock = {}

function Addon._Clock:New(pSize, pFrame)
	return CreateFrame("Frame", nil, pFrame or UIParent)
end

function Addon._Clock:Construct(pSize, pFrame, pOffsetX, pOffsetY, pShowDate, pMinimap)
	if not pSize then
		pSize = 32
	end
	
	if not pFrame then
		self:SetWidth(pSize)
		self:SetHeight(pSize)
	else
		self:SetAllPoints()
	end
	
	self.IsMinimapClock = pMinimap
	
	self.ClockBackground = self:CreateTexture(nil, "BORDER")
	self.ClockBackground:SetTexture(Addon.AddonPath.."Textures\\ClockBackground")
	if self.IsMinimapClock then
		self.ClockBackground:SetTexCoord(0.0, 0.78125, 0.0, 0.78125)
	else
		self.ClockBackground:SetTexCoord(0.125, 0.625, 0.125, 0.625)
	end
	--self.ClockBackground:SetPoint("CENTER", self, "CENTER", pOffsetX, pOffsetY)
	self.ClockBackground:SetPoint("TOPLEFT", self, "TOPLEFT")
	self.ClockBackground:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT")
	
	local vMinuteHandInset = self.IsMinimapClock and 10 or 0
	
	self.MinuteHand = self:CreateTexture(nil, "ARTWORK")
	self.MinuteHand:SetTexture(Addon.AddonPath.."Textures\\ClockHand")
	self.MinuteHand:SetPoint("TOPLEFT", self, "TOPLEFT", (pOffsetX or 0)  + vMinuteHandInset, (pOffsetY or 0)  - vMinuteHandInset)
	self.MinuteHand:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", (pOffsetX or 0) - vMinuteHandInset, (pOffsetY or 0) + vMinuteHandInset)
	
	local vHourHandInset = self.IsMinimapClock and 10 or 5
	
	self.HourHand = self:CreateTexture(nil, "ARTWORK")
	self.HourHand:SetTexture(Addon.AddonPath.."Textures\\ClockHourHand")
	self.HourHand:SetPoint("CENTER", self, "CENTER", pOffsetX, pOffsetY)
	self.HourHand:SetPoint("TOPLEFT", self, "TOPLEFT", (pOffsetX or 0)  + vHourHandInset, (pOffsetY or 0)  - vHourHandInset)
	self.HourHand:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", (pOffsetX or 0) - vHourHandInset, (pOffsetY or 0) + vHourHandInset)
	
	self.ClockGloss = self:CreateTexture(nil, "OVERLAY")
	self.ClockGloss:SetTexture(Addon.AddonPath.."Textures\\ClockGloss")
	if self.IsMinimapClock then
		self.ClockGloss:SetTexCoord(0.0, 0.78125, 0.0, 0.78125)
	else
		self.ClockGloss:SetTexCoord(0.125, 0.625, 0.125, 0.625)
	end
	self.ClockGloss:SetPoint("CENTER", self, "CENTER", pOffsetX, pOffsetY)
	self.ClockGloss:SetPoint("TOPLEFT", self, "TOPLEFT")
	self.ClockGloss:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT")
	
	if pShowDate then
		self.DateFontString = self:CreateFontString(nil, "ARTWORK", "SystemFont_Tiny")
		self.DateFontString:SetTextColor(77 / 255, 56 / 255, 0 / 255, 0.75)
		self.DateFontString:SetPoint("TOP", self, "CENTER", -1, 0)
		
		hooksecurefunc(pFrame, "SetText", function (pFrame, pText) self.DateFontString:SetText(pText) end)
	end
	
	self.NextUpdateDelay = 0
	
	self:HookScript("OnShow", function () self:OnShow() end)
	self:HookScript("OnHide", function () self:OnHide() end)
	self:HookScript("OnUpdate", function (pFrame, pElapsed) self:OnUpdate(pElapsed) end)
	
	if self:IsVisible() then
		self:OnShow()
	end
end

function Addon._Clock:OnShow()
	self.NextUpdateDelay = 0 -- Force an update
	self:OnUpdate(0)
	
	if Addon.EventLib then
		Addon.EventLib:RegisterCustomEvent("GC5_CLOCKS_CHANGED", self.Update, self)
		Addon.EventLib:RegisterCustomEvent("GC5_PREFS_CHANGED", function () self.NextUpdateDelay = 0 end)
	end
end

function Addon._Clock:OnHide()
	if Addon.EventLib then
		Addon.EventLib:UnregisterEvent("GC5_CLOCKS_CHANGED", self.Update, self)
		Addon.EventLib:UnregisterEvent("GC5_PREFS_CHANGED", nil, self)
	end
end

function Addon._Clock:SetShowLocalTime(pShowLocalTime)
	Addon.Clock.Data.ShowLocalTime = pShowLocalTime
	
	if Addon.EventLib then
		Addon.EventLib:DispatchEvent("GC5_PREFS_CHANGED")
	end
end

function Addon._Clock:OnUpdate(pElapsed)
	self.NextUpdateDelay = self.NextUpdateDelay - pElapsed
	
	if self.NextUpdateDelay > 0 then
		return
	end
	
	self.NextUpdateDelay = 30
	
	self:Update()
end

function Addon._Clock:Update()
	local vHour, vMinute = GetGameTime()
	local vHourAngle
	
	if Addon.Clock.Data.ShowLocalTime then
		vHour, vMinute = Addon.DateLib:ConvertTimeToHM(Addon.DateLib:GetLocalTimeFromServerTime(Addon.DateLib:ConvertHMToTime(vHour, vMinute)))
	end
	
	vHourAngle = (vHour + vMinute / 60) * 3.1415926535 / 6
	
	self:SetTextureAngle(self.HourHand, vHourAngle)
	self:SetTextureAngle(self.MinuteHand, vMinute * 3.1415926535 / 30)
	
	if vHour ~= self.PreviousHour then
		self.PreviousHour = vHour
		GameTimeFrame_SetDate() -- Refresh the date each hour
	end
end

function Addon._Clock:MatrixDotVector(pMatrix, pVector)
	local vResult = {}
	
	for vRow, vRowValues in ipairs(pMatrix) do
		local vTotal = 0
		
		for vColumn, vMatrixValue in ipairs(vRowValues) do
			vTotal = vTotal + vMatrixValue * (pVector[vColumn] or 1)
		end
		
		vResult[vRow] = vTotal
	end
	
	return vResult
end

function Addon._Clock:SetTextureAngle(pTexture, pAngle, pScaleX, pScaleY)
	-- Calculate the rotation transform
	
	local vCosAngle = math.cos(-pAngle)
	local vSinAngle = math.sin(-pAngle)
	
	local vTransform =
	{
		{vCosAngle, vSinAngle, 0.5}, -- Offset by 0.5 to make the coordinates 0.0 to 1.0 instead of -0.5 to 0.5
		{vSinAngle, -vCosAngle, 0.5},-- Same for the Y axis
	}
	
	-- Rotate the texture
	
	local vTopLeft = self:MatrixDotVector(vTransform, {-0.5, 0.5})
	local vTopRight = self:MatrixDotVector(vTransform, {0.5, 0.5})
	local vBottomLeft = self:MatrixDotVector(vTransform, {-0.5, -0.5})
	local vBottomRight = self:MatrixDotVector(vTransform, {0.5, -0.5})
	
	-- Set the texture
	
	pTexture:SetTexCoord(
			vTopLeft[1], vTopLeft[2],
			vBottomLeft[1], vBottomLeft[2],
			vTopRight[1], vTopRight[2],
			vBottomRight[1], vBottomRight[2])
end

function Addon._Clock:SetBackground(pTexture, pTexCoords)
	if not pTexture then
		self.ClockBackground:SetTexture(Addon.AddonPath.."Textures\\ClockBackground")
		
		if self.IsMinimapClock then
			self.ClockBackground:SetTexCoord(0.0, 0.78125, 0.0, 0.78125)
		else
			self.ClockBackground:SetTexCoord(0.125, 0.625, 0.125, 0.625)
		end
	else
		SetPortraitToTexture(self.ClockBackground, pTexture)
		
		if pTexCoords then
			local vCoordWidth = pTexCoords.right - pTexCoords.left
			local vCoordHeight = pTexCoords.bottom - pTexCoords.top
			
			self.ClockBackground:SetTexCoord(
					pTexCoords.left - 0.25 * vCoordWidth,
					pTexCoords.right + 0.3125 * vCoordWidth,
					pTexCoords.top - 0.25 * vCoordHeight,
					pTexCoords.bottom + 0.3125 * vCoordHeight)
		else
			self.ClockBackground:SetTexCoord(0.0, 0.78125, 0.0, 0.78125)
		end
	end
end
