local _, Addon = ...

Addon.UIElementsLib =
{
	Version = 1,
	Addon = Addon,
}

if not MC2UIElementsLib then
	MC2UIElementsLib = {}
end

if not Addon.UIElementsLibTexturePath then
	Addon.UIElementsLibTexturePath = Addon.AddonPath
end

----------------------------------------
-- Escape key handling for dialogs
----------------------------------------

function Addon.UIElementsLib:BeginDialog(pDialog)
	if not self.OpenDialogs then
		self.OpenDialogs = {}
		
		self.OrigStaticPopup_EscapePressed = StaticPopup_EscapePressed
		StaticPopup_EscapePressed = function (...) return self:StaticPopup_EscapePressed(...) end
	end
	
	table.insert(self.OpenDialogs, pDialog)
end

function Addon.UIElementsLib:EndDialog(pDialog)
	for vIndex, vDialog in ipairs(self.OpenDialogs) do
		if vDialog == pDialog then
			table.remove(self.OpenDialogs, vIndex)
			return
		end
	end
	
	Addon:ErrorMessage("DialogClosed called on an unknown dialog: %s", tostring(pDialog:GetName()))
end

function Addon.UIElementsLib:StaticPopup_EscapePressed(...)
	local vClosed = self.OrigStaticPopup_EscapePressed(...)
	local vNumDialogs = #self.OpenDialogs
	
	for vIndex = 1, vNumDialogs do
		local vDialog = self.OpenDialogs[1]
		vDialog:Cancel()
		vClosed = 1
	end
	
	return vClosed
end


----------------------------------------
Addon.UIElementsLib._StretchTextures = {}
----------------------------------------

function Addon.UIElementsLib._StretchTextures:Construct(pTextureInfo, pFrame, pLayer)
	for vName, vInfo in pairs(pTextureInfo) do
		local vTexture = pFrame:CreateTexture(nil, pLayer)
		
		if vInfo.Width then
			vTexture:SetWidth(vInfo.Width)
		end
		
		if vInfo.Height then
			vTexture:SetHeight(vInfo.Height)
		end
		
		vTexture:SetTexture(vInfo.Path)
		vTexture:SetTexCoord(vInfo.Coords.Left, vInfo.Coords.Right, vInfo.Coords.Top, vInfo.Coords.Bottom)
		
		self[vName] = vTexture
	end
	
	self.TopLeft:SetPoint("TOPLEFT", pFrame, "TOPLEFT")
	self.TopRight:SetPoint("TOPRIGHT", pFrame, "TOPRIGHT")
	self.BottomLeft:SetPoint("BOTTOMLEFT", pFrame, "BOTTOMLEFT")
	self.BottomRight:SetPoint("BOTTOMRIGHT", pFrame, "BOTTOMRIGHT")
	
	self.TopCenter:SetPoint("TOPLEFT", self.TopLeft, "TOPRIGHT")
	self.TopCenter:SetPoint("TOPRIGHT", self.TopRight, "TOPLEFT")
	
	self.MiddleLeft:SetPoint("TOPLEFT", self.TopLeft, "BOTTOMLEFT")
	self.MiddleLeft:SetPoint("BOTTOMLEFT", self.BottomLeft, "TOPLEFT")
	
	self.MiddleRight:SetPoint("TOPRIGHT", self.TopRight, "BOTTOMRIGHT")
	self.MiddleRight:SetPoint("BOTTOMRIGHT", self.BottomRight, "TOPRIGHT")
	
	self.BottomCenter:SetPoint("BOTTOMLEFT", self.BottomLeft, "BOTTOMRIGHT")
	self.BottomCenter:SetPoint("BOTTOMRIGHT", self.BottomRight, "BOTTOMLEFT")
	
	self.MiddleCenter:SetPoint("TOPLEFT", self.TopLeft, "BOTTOMRIGHT")
	self.MiddleCenter:SetPoint("BOTTOMLEFT", self.BottomLeft, "TOPRIGHT")
	self.MiddleCenter:SetPoint("TOPRIGHT", self.TopRight, "BOTTOMLEFT")
	self.MiddleCenter:SetPoint("BOTTOMRIGHT", self.BottomRight, "TOPLEFT")
end

----------------------------------------
if Addon.UIElementsLibTexturePath then
Addon.UIElementsLib._PortaitWindow = {}
----------------------------------------

Addon.UIElementsLib._PortaitWindow.BackgroundTextureInfo =
{
	TopLeft      = {Width = 100, Height = 100, Path = "Interface\\PaperDollInfoFrame\\UI-Character-General-TopLeft", Coords = {Left = 0, Right = 0.390625, Top = 0, Bottom = 0.390625}},
	TopCenter    = {Width = 156, Height = 100, Path = "Interface\\PaperDollInfoFrame\\UI-Character-General-TopLeft", Coords = {Left = 0.390625, Right = 1, Top = 0, Bottom = 0.390625}},
	TopRight     = {Width =  93, Height = 100, Path = "Interface\\PaperDollInfoFrame\\UI-Character-General-TopRight", Coords = {Left = 0, Right = 0.7265625, Top = 0, Bottom = 0.390625}},
	MiddleLeft   = {Width = 100, Height = 156, Path = "Interface\\PaperDollInfoFrame\\UI-Character-General-TopLeft", Coords = {Left = 0, Right = 0.390625, Top = 0.390625, Bottom = 1}},
	MiddleCenter = {Width = 156, Height = 156, Path = "Interface\\PaperDollInfoFrame\\UI-Character-General-TopLeft", Coords = {Left = 0.390625, Right = 1, Top = 0.390625, Bottom = 1}},
	MiddleRight  = {Width =  93, Height = 156, Path = "Interface\\PaperDollInfoFrame\\UI-Character-General-TopRight", Coords = {Left = 0, Right = 0.7265625, Top = 0.390625, Bottom = 1}},
	BottomLeft   = {Width = 100, Height = 120, Path = Addon.UIElementsLibTexturePath.."Textures\\CalendarFrame-BottomLeft", Coords = {Left = 0, Right = 0.390625, Top = 0, Bottom = 0.9375}},
	BottomCenter = {Width = 156, Height = 120, Path = Addon.UIElementsLibTexturePath.."Textures\\CalendarFrame-BottomLeft", Coords = {Left = 0.390625, Right = 1, Top = 0, Bottom = 0.9375}},
	BottomRight  = {Width =  93, Height = 120, Path = Addon.UIElementsLibTexturePath.."Textures\\CalendarFrame-BottomRight", Coords = {Left = 0, Right = 0.7265625, Top = 0, Bottom = 0.9375}},
}

function Addon.UIElementsLib._PortaitWindow:New(pTitle, pWidth, pHeight, pName)
	return CreateFrame("Frame", pName, UIParent)
end

function Addon.UIElementsLib._PortaitWindow:Construct(pTitle, pWidth, pHeight, pName)
	self:EnableMouse(true)
	self:SetMovable(true)
	self:SetWidth(pWidth)
	self:SetHeight(pHeight)
	
	self:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, -104)
	
	self.BackgroundTextures = Addon:New(Addon.UIElementsLib._StretchTextures, self.BackgroundTextureInfo, self, "BORDER")
	
	self:SetScript("OnDragStart", function (self, pButton) self:StartMoving() end)
	self:SetScript("OnDragStop", function (self) self:StopMovingOrSizing() end)

	self.TitleText = self:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	self.TitleText:SetPoint("TOP", self, "TOP", 17, -18)
	self.TitleText:SetText(pTitle)
	
	self.CloseButton = CreateFrame("Button", nil, self, "UIPanelCloseButton")
	self.CloseButton:SetPoint("TOPRIGHT", self, "TOPRIGHT", 5, -8)
end

----------------------------------------
Addon.UIElementsLib._PanelSectionBackgroundInfo =
----------------------------------------
{
	TopLeft      = {Width = 4, Height = 4, Path = Addon.UIElementsLibTexturePath.."Textures\\PanelSectionBackground", Coords = {Left = 0, Right = 0.015625, Top = 0, Bottom = 0.0625}},
	TopCenter    = {Width = 248, Height = 4, Path = Addon.UIElementsLibTexturePath.."Textures\\PanelSectionBackground", Coords = {Left = 0.015625, Right = 0.984375, Top = 0, Bottom = 0.0625}},
	TopRight     = {Width =  4, Height = 4, Path = Addon.UIElementsLibTexturePath.."Textures\\PanelSectionBackground", Coords = {Left = 0.984375, Right = 1, Top = 0, Bottom = 0.0625}},
	MiddleLeft   = {Width = 4, Height = 56, Path = Addon.UIElementsLibTexturePath.."Textures\\PanelSectionBackground", Coords = {Left = 0, Right = 0.015625, Top = 0.0625, Bottom = 0.9375}},
	MiddleCenter = {Width = 248, Height = 56, Path = Addon.UIElementsLibTexturePath.."Textures\\PanelSectionBackground", Coords = {Left = 0.015625, Right = 0.984375, Top = 0.0625, Bottom = 0.9375}},
	MiddleRight  = {Width =  4, Height = 56, Path = Addon.UIElementsLibTexturePath.."Textures\\PanelSectionBackground", Coords = {Left = 0.984375, Right = 1, Top = 0.0625, Bottom = 0.9375}},
	BottomLeft   = {Width = 4, Height = 4, Path = Addon.UIElementsLibTexturePath.."Textures\\PanelSectionBackground", Coords = {Left = 0, Right = 0.015625, Top = 0.9375, Bottom = 1}},
	BottomCenter = {Width = 248, Height = 4, Path = Addon.UIElementsLibTexturePath.."Textures\\PanelSectionBackground", Coords = {Left = 0.015625, Right = 0.984375, Top = 0.9375, Bottom = 1}},
	BottomRight  = {Width =  4, Height = 4, Path = Addon.UIElementsLibTexturePath.."Textures\\PanelSectionBackground", Coords = {Left = 0.984375, Right = 1, Top = 0.9375, Bottom = 1}},
}

end -- if UIElementsLibTexturePath

----------------------------------------
function Addon.UIElementsLib:SetDialogBackdrop(pFrame)
----------------------------------------
	pFrame:SetBackdrop(
	{
		bgFile = "Interface\\RAIDFRAME\\UI-RaidFrame-GroupBg",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = true,
		tileSize = 512,
		edgeSize = 32,
		insets = {left = 11, right = 11, top = 11, bottom = 10}
	})
	
	pFrame:SetBackdropBorderColor(1, 1, 1)
	pFrame:SetBackdropColor(0.8, 0.8, 0.8, 1)
end

----------------------------------------
Addon.UIElementsLib._ModalDialogFrame = {}
----------------------------------------

function Addon.UIElementsLib._ModalDialogFrame:New(pParent, pTitle, pWidth, pHeight)
	return CreateFrame("Frame", nil, pParent)
end

function Addon.UIElementsLib._ModalDialogFrame:Construct(pParent, pTitle, pWidth, pHeight)
	Addon.UIElementsLib:SetDialogBackdrop(self)
	
	self:SetWidth(pWidth)
	self:SetHeight(pHeight)

	self.Title = self:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	self.Title:SetPoint("TOP", self, "TOP", 0, 0)
	self.Title:SetText(pTitle)
	
	self.TitleBackground = self:CreateTexture(nil, "ARTWORK")
	self.TitleBackground:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
	self.TitleBackground:SetTexCoord(0.234375, 0.7578125, 0, 0.625)
	self.TitleBackground:SetHeight(40)
	self.TitleBackground:SetPoint("LEFT", self.Title, "LEFT", -20, 0)
	self.TitleBackground:SetPoint("RIGHT", self.Title, "RIGHT", 20, 0)
	
	self.CancelButton = Addon:New(Addon.UIElementsLib._PushButton, self, CANCEL, 80)
	self.CancelButton:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -15, 20)
	self.CancelButton:SetScript("OnClick", function ()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		self:Cancel()
	end)
	
	self.DoneButton = Addon:New(Addon.UIElementsLib._PushButton, self, OKAY, 80)
	self.DoneButton:SetPoint("RIGHT", self.CancelButton, "LEFT", -7, 0)
	self.DoneButton:SetScript("OnClick", function ()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		self:Done()
	end)
end

----------------------------------------
Addon.UIElementsLib._SidebarWindowFrame = {}
----------------------------------------

function Addon.UIElementsLib._SidebarWindowFrame:New(pParent)
	return CreateFrame("Frame", nil, pParent or UIParent)
end

function Addon.UIElementsLib._SidebarWindowFrame:Construct()
	self:EnableMouse(true)
	
	self.CloseButton = CreateFrame("Button", nil, self, "UIPanelCloseButton")
	self.CloseButton:SetPoint("TOPRIGHT", self, "TOPRIGHT", 5, 5)
	
	self.Title = self:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	self.Title:SetPoint("CENTER", self, "TOP", 0, -10)
	
	-- Create the textures
	
	self.TopHeight = 80
	self.LeftWidth = 80
	self.BottomHeight = 183
	self.RightWidth = 94
	
	self.TopMargin = 13
	self.LeftMargin = 0
	self.BottomMargin = 3
	self.RightMargin = 1
	
	self.TextureWidth1 = 256
	self.TextureWidth2 = 128
	self.TextureUsedWidth2 = 94
	
	self.TextureHeight1 = 256
	self.TextureHeight2 = 256
	self.TextureUsedHeight2 = 183
	
	self.MiddleWidth1 = self.TextureWidth1 - self.LeftWidth
	self.MiddleWidth2 = 60
	
	self.TexCoordX1 = self.LeftWidth / self.TextureWidth1
	self.TexCoordX2 = (self.TextureUsedWidth2 - self.RightWidth) / self.TextureWidth2
	self.TexCoordX3 = self.TextureUsedWidth2 / self.TextureWidth2
	
	self.TexCoordY1 = self.TopHeight / self.TextureHeight1
	self.TexCoordY2 = (self.TextureUsedHeight2 - self.BottomHeight) / self.TextureHeight2
	self.TexCoordY3 = self.TextureUsedHeight2 / self.TextureHeight2
	
	self.Background = {}
	
	self.Background.TopRight = self:CreateTexture(nil, "BORDER")
	self.Background.TopRight:SetWidth(self.RightWidth)
	self.Background.TopRight:SetHeight(self.TopHeight)
	self.Background.TopRight:SetPoint("TOPRIGHT", self, "TOPRIGHT", self.RightMargin, self.TopMargin)
	self.Background.TopRight:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopRight")
	self.Background.TopRight:SetTexCoord(self.TexCoordX2, self.TexCoordX3, 0, self.TexCoordY1)
	
	self.Background.TopLeft = self:CreateTexture(nil, "BORDER")
	self.Background.TopLeft:SetHeight(self.TopHeight)
	self.Background.TopLeft:SetPoint("TOPLEFT", self, "TOPLEFT", -self.LeftMargin, self.TopMargin)
	self.Background.TopLeft:SetPoint("TOPRIGHT", self.Background.TopRight, "TOPLEFT")
	self.Background.TopLeft:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopLeft")
	self.Background.TopLeft:SetTexCoord(self.TexCoordX1, 1, 0, self.TexCoordY1)
	
	self.Background.BottomRight = self:CreateTexture(nil, "BORDER")
	self.Background.BottomRight:SetWidth(self.RightWidth)
	self.Background.BottomRight:SetHeight(self.BottomHeight)
	self.Background.BottomRight:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", self.RightMargin, -self.BottomMargin)
	self.Background.BottomRight:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-BottomRight")
	self.Background.BottomRight:SetTexCoord(self.TexCoordX2, self.TexCoordX3, self.TexCoordY2, self.TexCoordY3)
	
	self.Background.BottomLeft = self:CreateTexture(nil, "BORDER")
	self.Background.BottomLeft:SetHeight(self.BottomHeight)
	self.Background.BottomLeft:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", -self.LeftMargin, -self.BottomMargin)
	self.Background.BottomLeft:SetPoint("BOTTOMRIGHT", self.Background.BottomRight, "BOTTOMLEFT")
	self.Background.BottomLeft:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-BottomLeft")
	self.Background.BottomLeft:SetTexCoord(self.TexCoordX1, 1, self.TexCoordY2, self.TexCoordY3)
	
	self.Background.RightMiddle = self:CreateTexture(nil, "BORDER")
	self.Background.RightMiddle:SetWidth(self.RightWidth)
	self.Background.RightMiddle:SetPoint("TOPRIGHT", self.Background.TopRight, "BOTTOMRIGHT")
	self.Background.RightMiddle:SetPoint("BOTTOMRIGHT", self.Background.BottomRight, "TOPRIGHT")
	self.Background.RightMiddle:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopRight")
	self.Background.RightMiddle:SetTexCoord(self.TexCoordX2, self.TexCoordX3, self.TexCoordY1, 1)
	
	self.Background.LeftMiddle = self:CreateTexture(nil, "BORDER")
	self.Background.LeftMiddle:SetPoint("TOPLEFT", self.Background.TopLeft, "BOTTOMLEFT")
	self.Background.LeftMiddle:SetPoint("BOTTOMLEFT", self.Background.BottomLeft, "TOPLEFT")
	self.Background.LeftMiddle:SetPoint("TOPRIGHT", self.Background.TopRight, "BOTTOMLEFT")
	self.Background.LeftMiddle:SetPoint("BOTTOMRIGHT", self.Background.BottomRight, "TOPLEFT")
	self.Background.LeftMiddle:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopLeft")
	self.Background.LeftMiddle:SetTexCoord(self.TexCoordX1, 1, self.TexCoordY1, 1)
	
	self.Foreground = CreateFrame("Frame", nil, self)
	self.Foreground:SetAllPoints()
	self.Foreground:SetFrameLevel(self:GetFrameLevel() + 20)
	
	self.Foreground.Shadow = self.Foreground:CreateTexture(nil, "OVERLAY")
	self.Foreground.Shadow:SetWidth(18)
	self.Foreground.Shadow:SetPoint("TOPLEFT", self.Foreground, "TOPLEFT")
	self.Foreground.Shadow:SetPoint("BOTTOMLEFT", self.Foreground, "BOTTOMLEFT")
	self.Foreground.Shadow:SetTexture("Interface\\AchievementFrame\\UI-Achievement-HorizontalShadow")
	self.Foreground.Shadow:SetVertexColor(0, 0, 0)
end

----------------------------------------
Addon.UIElementsLib._Tabs = {}
----------------------------------------

if not MC2UIElementsLib.TabNameIndex then
	MC2UIElementsLib.TabNameIndex = 1
end

function Addon.UIElementsLib._Tabs:Construct(pFrame, pXOffset, pYOffset)
	self.ParentFrame = pFrame
	self.Tabs = {}
	self.SelectedTab = nil
	
	self.XOffset = (pXOffset or 0) + 18
	self.YOffset = (pYOffset or 0) + 3
end

function Addon.UIElementsLib._Tabs:NewTab(title, value)
	local name = "MC2UIElementsLibTab"..MC2UIElementsLib.TabNameIndex

	MC2UIElementsLib.TabNameIndex = MC2UIElementsLib.TabNameIndex + 1
	
	local tab = CreateFrame("Button", name, self.ParentFrame, "CharacterFrameTabButtonTemplate")
	
	tab:SetText(title)
	tab.Value = value
	tab:SetScript("OnClick", function(...) self:Tab_OnClick(...) end)
	
	PanelTemplates_DeselectTab(tab)
	
	table.insert(self.Tabs, tab)
	
	self:UpdateTabs()
end

function Addon.UIElementsLib._Tabs:UpdateTabs()
	local previousTab
	
	for _, tab in ipairs(self.Tabs) do
		-- Remove existing anchors
		tab:ClearAllPoints()

		-- Anchor to the previous tab if shown, or the parent if this is the first visible tab
		if not tab.Hidden then
			if not previousTab then
				tab:SetPoint("TOPLEFT", self.ParentFrame, "TOPLEFT", self.XOffset, self.YOffset)
			else
				tab:SetPoint("TOPLEFT", previousTab, "TOPRIGHT", -14, 0)
			end
			
			previousTab = tab
		end
	end
end

function Addon.UIElementsLib._Tabs:SelectTabByValue(pValue)
	self:SelectTab(self:GetTabByValue(pValue))
end

function Addon.UIElementsLib._Tabs:ShowTabByValue(pValue)
	self:ShowTab(self:GetTabByValue(pValue))
end

function Addon.UIElementsLib._Tabs:HideTabByValue(pValue)
	self:HideTab(self:GetTabByValue(pValue))
end

function Addon.UIElementsLib._Tabs:SelectTab(pTab)
	if pTab == self.SelectedTab then
		return
	end
	
	if self.SelectedTab then
		PanelTemplates_DeselectTab(self.SelectedTab)
		
		if self.OnDeselect then
			self:OnSelect(self.SelectedTab)
		end
	end
	
	self.SelectedTab = pTab
	
	if self.SelectedTab then
		PanelTemplates_SelectTab(self.SelectedTab)
		
		if self.OnSelect then
			self:OnSelect(self.SelectedTab)
		end
	end
end

function Addon.UIElementsLib._Tabs:ShowTab(pTab)
	if not pTab.Hidden then
		return
	end
	
	pTab.Hidden = false
	pTab:Show()
	self:UpdateTabs()
end

function Addon.UIElementsLib._Tabs:HideTab(pTab)
	if pTab.Hidden then
		return
	end
	
	pTab.Hidden = true
	pTab:Hide()
	self:UpdateTabs()
end

function Addon.UIElementsLib._Tabs:GetTabByValue(pValue)
	for vIndex, vTab in ipairs(self.Tabs) do
		if vTab.Value == pValue then
			return vTab, vIndex
		end
	end
end

function Addon.UIElementsLib._Tabs:Tab_OnClick(pTab, pButton)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
	self:SelectTabByValue(pTab.Value)
end

----------------------------------------
Addon.UIElementsLib._TabbedView = {}
----------------------------------------

function Addon.UIElementsLib._TabbedView:New(parent, horizOffset, vertOffset)
	return CreateFrame("Frame", nil, parent or UIParent)
end

function Addon.UIElementsLib._TabbedView:Construct(parent, horizOffset, vertOffset)
	self.Views = {}
	self.CurrentFrame = nil
	
	self:SetWidth(1)
	self:SetHeight(1)
	
	self:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", horizOffset, vertOffset)
	
	self.Tabs = Addon:New(Addon.UIElementsLib._Tabs, self)
	self.Tabs.OnSelect = function (tabs, tab)
		self:SelectView(tab.Value)
	end
end

function Addon.UIElementsLib._TabbedView:AddView(frame, title)
	-- Add the tab
	local tab = self.Tabs:NewTab(title, frame)

	-- Create the view
	local view = {
		Title = title,
		Frame = frame,
		Tab = tab,
	}
	table.insert(self.Views, view)

	-- Initially hidden
	frame:Hide()

	-- Done
	return view
end

function Addon.UIElementsLib._TabbedView:SelectView(pFrame)
	if self.CurrentFrame == pFrame then
		return
	end
	
	if self.CurrentFrame then
		self:DeactivateView(self.CurrentFrame)
		self.CurrentFrame:Hide()
	end
	
	self.CurrentFrame = pFrame
	
	if self.CurrentFrame then
		self.CurrentFrame:Show()
		self:ActivateView(self.CurrentFrame)
	end
	
	self.Tabs:SelectTabByValue(self.CurrentFrame)
end

function Addon.UIElementsLib._TabbedView:GetViewByFrame(pFrame)
	for _, vView in ipairs(self.Views) do
		if vView.Frame == pFrame then
			return vView
		end
	end
end

function Addon.UIElementsLib._TabbedView:ShowView(pFrame)
	self.Tabs:ShowTabByValue(pFrame)
end

function Addon.UIElementsLib._TabbedView:HideView(pFrame)
	self.Tabs:HideTabByValue(pFrame)
end

function Addon.UIElementsLib._TabbedView:ActivateView(pView)
	if pView.ViewActivated then
		pView:ViewActivated()
	end
end

function Addon.UIElementsLib._TabbedView:DeactivateView(pView)
	if pView.ViewDeactivated then
		pView:ViewDeactivated()
	end
end

----------------------------------------
if Addon.UIElementsLibTexturePath then
Addon.UIElementsLib._ScrollbarTrench = {}
----------------------------------------

function Addon.UIElementsLib._ScrollbarTrench:New(pParent)
	return CreateFrame("Frame", nil, pParent)
end

function Addon.UIElementsLib._ScrollbarTrench:Construct(pParent)
	self:SetWidth(27)
	
	self.TopTexture = self:CreateTexture(nil, "OVERLAY")
	self.TopTexture:SetHeight(26)
	self.TopTexture:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 2)
	self.TopTexture:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 2)
	self.TopTexture:SetTexture(Addon.UIElementsLibTexturePath.."Textures\\ScrollbarTrench")
	self.TopTexture:SetTexCoord(0, 0.84375, 0, 0.1015625)
	
	self.BottomTexture = self:CreateTexture(nil, "OVERLAY")
	self.BottomTexture:SetHeight(26)
	self.BottomTexture:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, -1)
	self.BottomTexture:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, -1)
	self.BottomTexture:SetTexture(Addon.UIElementsLibTexturePath.."Textures\\ScrollbarTrench")
	self.BottomTexture:SetTexCoord(0, 0.84375, 0.90234375, 1)
	
	self.MiddleTexture = self:CreateTexture(nil, "OVERLAY")
	self.MiddleTexture:SetPoint("TOPLEFT", self.TopTexture, "BOTTOMLEFT")
	self.MiddleTexture:SetPoint("BOTTOMRIGHT", self.BottomTexture, "TOPRIGHT")
	self.MiddleTexture:SetTexture(Addon.UIElementsLibTexturePath.."Textures\\ScrollbarTrench")
	self.MiddleTexture:SetTexCoord(0, 0.84375, 0.1015625, 0.90234375)
end

----------------------------------------
Addon.UIElementsLib._Scrollbar = {}
----------------------------------------

function Addon.UIElementsLib._Scrollbar:New(pParent)
	return CreateFrame("Slider", nil, pParent)
end

function Addon.UIElementsLib._Scrollbar:Construct(pParent)
	self:SetWidth(16)
	
	self.UpButton = CreateFrame("Button", nil, self)
	self.UpButton:SetWidth(16)
	self.UpButton:SetHeight(16)
	self.UpButton:SetNormalTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Up")
	self.UpButton:GetNormalTexture():SetTexCoord(0.25, 0.75, 0.25, 0.75)
	self.UpButton:SetPushedTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Down")
	self.UpButton:GetPushedTexture():SetTexCoord(0.25, 0.75, 0.25, 0.75)
	self.UpButton:SetDisabledTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Disabled")
	self.UpButton:GetDisabledTexture():SetTexCoord(0.25, 0.75, 0.25, 0.75)
	self.UpButton:SetHighlightTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Highlight")
	self.UpButton:GetHighlightTexture():SetTexCoord(0.25, 0.75, 0.25, 0.75)
	self.UpButton:GetHighlightTexture():SetBlendMode("ADD")
	self.UpButton:SetPoint("BOTTOM", self, "TOP")
	self.UpButton:SetScript("OnClick", function (pButtonFrame, pButton)
		self:SetValue(self:GetValue() - self:GetHeight() * 0.5)
		PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
	end)
	
	self.DownButton = CreateFrame("Button", nil, self)
	self.DownButton:SetWidth(16)
	self.DownButton:SetHeight(16)
	self.DownButton:SetNormalTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Up")
	self.DownButton:GetNormalTexture():SetTexCoord(0.25, 0.75, 0.25, 0.75)
	self.DownButton:SetPushedTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Down")
	self.DownButton:GetPushedTexture():SetTexCoord(0.25, 0.75, 0.25, 0.75)
	self.DownButton:SetDisabledTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Disabled")
	self.DownButton:GetDisabledTexture():SetTexCoord(0.25, 0.75, 0.25, 0.75)
	self.DownButton:SetHighlightTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Highlight")
	self.DownButton:GetHighlightTexture():SetTexCoord(0.25, 0.75, 0.25, 0.75)
	self.DownButton:GetHighlightTexture():SetBlendMode("ADD")
	self.DownButton:SetPoint("TOP", self, "BOTTOM")
	self.DownButton:SetScript("OnClick", function (pButtonFrame, pButton)
		self:SetValue(self:GetValue() + self:GetHeight() * 0.5)
		PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
	end)
	
	local vThumbTexture = self:CreateTexture(nil, "OVERLAY")
	
	vThumbTexture:SetTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
	vThumbTexture:SetWidth(16)
	vThumbTexture:SetHeight(24)
	vThumbTexture:SetTexCoord(0.25, 0.75, 0.125, 0.875)
	
	self:SetThumbTexture(vThumbTexture)
end

function Addon.UIElementsLib._Scrollbar:SetValue(...)
	self.Inherited.SetValue(self, ...)
	self:AdjustButtons()
end
	
function Addon.UIElementsLib._Scrollbar:SetMinMaxValues(...)
	self.Inherited.SetMinMaxValues(self, ...)
	self:AdjustButtons()
end

function Addon.UIElementsLib._Scrollbar:AdjustButtons()
	local vMin, vMax = self:GetMinMaxValues()
	local vValue = self:GetValue()
	
	if math.floor(vValue) <= vMin then
		self.UpButton:Disable()
	else
		self.UpButton:Enable()
	end
	
	if math.ceil(vValue) >= vMax then
		self.DownButton:Disable()
	else
		self.DownButton:Enable()
	end
end

----------------------------------------
Addon.UIElementsLib._ScrollingList = {}
----------------------------------------

if not MC2UIElementsLib.ScrollFrameIndex then
	MC2UIElementsLib.ScrollFrameIndex = 1
end

function Addon.UIElementsLib._ScrollingList:New(pParent, pItemHeight)
	return CreateFrame("Frame", nil, pParent)
end

function Addon.UIElementsLib._ScrollingList:Construct(pParent, pItemHeight)
	self.ItemHeight = pItemHeight or 27
	
	self.ScrollbarTrench = Addon:New(Addon.UIElementsLib._ScrollbarTrench, self)
	self.ScrollbarTrench:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)
	self.ScrollbarTrench:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
	
	local vScrollFrameName = "MC2UIElementsLibScrollFrame"..MC2UIElementsLib.ScrollFrameIndex
	MC2UIElementsLib.ScrollFrameIndex = MC2UIElementsLib.ScrollFrameIndex + 1
	
	self.ScrollFrame = CreateFrame("ScrollFrame", vScrollFrameName, self, "FauxScrollFrameTemplate")
	self.ScrollFrame:SetPoint("TOPLEFT", self, "TOPLEFT")
	self.ScrollFrame:SetPoint("BOTTOMRIGHT", self.ScrollbarTrench, "BOTTOMLEFT", 0, 0)
	self.ScrollFrame:SetScript("OnVerticalScroll", function (frame, offset)
		FauxScrollFrame_OnVerticalScroll(frame, offset, self.ItemHeight, function ()
			if self.DrawingFunc then
				self:DrawingFunc()
			end
		end)
	end)
	
	self.ScrollFrame:SetFrameLevel(self:GetFrameLevel() + 1) -- Ensure it's above the parent
	self.ScrollFrame:Show() -- Ensure it's visible
end

function Addon.UIElementsLib._ScrollingList:GetOffset()
	return FauxScrollFrame_GetOffset(self.ScrollFrame)
end

function Addon.UIElementsLib._ScrollingList:GetNumVisibleItems()
	local vHeight = self:GetHeight() or 0
	return math.floor(vHeight / self.ItemHeight)
end

function Addon.UIElementsLib._ScrollingList:SetNumItems(pNumItems)
	local vWidth, vHeight = self:GetWidth(), self:GetHeight()
	local vNumVisibleItems = self:GetNumVisibleItems()
	
	FauxScrollFrame_Update(
			self.ScrollFrame,
			pNumItems,
			vNumVisibleItems,
			self.ItemHeight,
			nil,
			nil,
			nil,
			nil,
			vWidth, vHeight)
end

----------------------------------------
Addon.UIElementsLib._ScrollingItemList = {}
----------------------------------------

function Addon.UIElementsLib._ScrollingItemList:New(pParent, pItemMethods, pItemHeight)
	return Addon:New(Addon.UIElementsLib._ScrollingList, pParent, pItemHeight)
end

function Addon.UIElementsLib._ScrollingItemList:Construct(pParent, pItemMethods, pItemHeight)
	self.ItemMethods = pItemMethods
	self.ItemFrames = {}
end

function Addon.UIElementsLib._ScrollingItemList:GetNumVisibleItems()
	local vNumVisibleItems = self.Inherited.GetNumVisibleItems(self)
	
	while #self.ItemFrames < vNumVisibleItems do
		local vListItem = Addon:New(self.ItemMethods, self)
		
		if #self.ItemFrames == 0 then
			vListItem:SetPoint("TOPLEFT", self.ScrollFrame, "TOPLEFT")
			vListItem:SetPoint("TOPRIGHT", self.ScrollFrame, "TOPRIGHT")
		else
			local vPreviousListItem = self.ItemFrames[#self.ItemFrames]
			
			vListItem:SetPoint("TOPLEFT", vPreviousListItem, "BOTTOMLEFT")
			vListItem:SetPoint("TOPRIGHT", vPreviousListItem, "BOTTOMRIGHT")
		end
		
		table.insert(self.ItemFrames, vListItem)
	end
	
	return vNumVisibleItems
end

function Addon.UIElementsLib._ScrollingItemList:SetNumItems(pNumItems)
	self.Inherited.SetNumItems(self, pNumItems)
	
	-- Adjust visibility
	
	local vNumVisibleItems = self:GetNumVisibleItems() -- This will allocate the item frames
	
	if pNumItems < vNumVisibleItems then
		vNumVisibleItems = pNumItems
	end
	
	for vItemIndex = 1, vNumVisibleItems do
		self.ItemFrames[vItemIndex]:Show()
	end
	
	for vItemIndex = vNumVisibleItems + 1, #self.ItemFrames do
		self.ItemFrames[vItemIndex]:Hide()
	end
end

end -- if Addon.UIElementsLibTexturePath then

----------------------------------------
Addon.UIElementsLib._CheckButton = {}
----------------------------------------

function Addon.UIElementsLib._CheckButton:New(pParent, pTitle, pSmall)
	return CreateFrame("CheckButton", nil, pParent)
end

function Addon.UIElementsLib._CheckButton:Construct(pParent, pTitle, pSmall)
	self.Enabled = true
	
	self.Small = pSmall
	
	self:SetWidth(self.Small and 18 or 23)
	self:SetHeight(self.Small and 16 or 21)
	
	self.Title = self:CreateFontString(nil, "ARTWORK", self.Small and "GameFontNormalSmall" or "GameFontNormal")
	self.Title:SetPoint("LEFT", self, "RIGHT", 2, 0)
	self.Title:SetJustifyH("LEFT")
	self.Title:SetText(pTitle or "")
	
	--self:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
	--self:GetDisabledCheckedTexture():SetTexCoord(0.125, 0.84375, 0.15625, 0.8125)
	
	self:SetDisplayMode("CHECKBOX")
end

function Addon.UIElementsLib._CheckButton:SetEnabled(pEnabled)
	self.Enabled = pEnabled
	
	if pEnabled then
		self:Enable()
	else
		self:Disable()
	end
	
	self:SetAlpha(pEnabled and 1 or 0.5)
end

function Addon.UIElementsLib._CheckButton:SetAnchorMode(pMode)
	self.Title:ClearAllPoints()
	self:ClearAllPoints()
	
	if pMode == "TITLE" then
		self:SetPoint("RIGHT", self.Title, "LEFT", -2, 0)
	else
		self.Title:SetPoint("LEFT", self, "RIGHT", 2, 0)
	end
end

function Addon.UIElementsLib._CheckButton:SetDisplayMode(pMode)
	self.DisplayMode = pMode
	
	if pMode == "LEADER"
	or pMode == "ASSIST" then
		self:UpdateLeaderModeTexture()
		
		self:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight")
		self:GetHighlightTexture():SetTexCoord(0, 1, 0, 1)
		self:GetHighlightTexture():SetBlendMode("ADD")
		
		if self.DisplayMode == "ASSIST" then
			self:SetNormalTexture("Interface\\GroupFrame\\UI-Group-AssistantIcon")
			self:SetPushedTexture("Interface\\GroupFrame\\UI-Group-AssistantIcon")
			self:SetCheckedTexture("Interface\\GroupFrame\\UI-Group-AssistantIcon")
		else
			self:SetNormalTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")
			self:SetCheckedTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")
			self:SetPushedTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")
		end
		
		if self.MultiSelect then
			self:GetCheckedTexture():SetDesaturated(true)
			self:GetCheckedTexture():SetVertexColor(1, 1, 1, 0.6)
		else
			self:GetCheckedTexture():SetDesaturated(false)
			self:GetCheckedTexture():SetVertexColor(1, 1, 1, 1)
		end
		
		local vNormalTexture = self:GetNormalTexture()
		
		vNormalTexture:SetDesaturated(true)
		vNormalTexture:SetVertexColor(1, 1, 1, 0.33)
		
	elseif pMode == "EXPAND" then
		self:UpdateExpandModeTexture()
		
		self:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight")
		self:GetHighlightTexture():SetTexCoord(0, 1, 0, 1)
		self:GetHighlightTexture():SetBlendMode("ADD")
		
		self:SetCheckedTexture("")
	else
		if pMode == "BUSY" then
			self:SetNormalTexture(Addon.UIElementsLibTexturePath.."Textures\\Gear")
			self:GetNormalTexture():SetTexCoord(0, 1, 0, 1)
			self:SetCheckedTexture("")
		else -- CHECKBOX
			self:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
			self:GetNormalTexture():SetTexCoord(0.125, 0.84375, 0.15625, 0.8125)
			
			if self.MultiSelect then
				self:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
			else
				self:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
			end
			
			self:GetCheckedTexture():SetTexCoord(0.125, 0.84375, 0.15625, 0.8125)
		end
		
		self:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
		self:GetPushedTexture():SetTexCoord(0.125, 0.84375, 0.15625, 0.8125)
		
		self:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
		self:GetHighlightTexture():SetTexCoord(0.125, 0.84375, 0.15625, 0.8125)
		self:GetHighlightTexture():SetBlendMode("ADD")
	end
end

function Addon.UIElementsLib._CheckButton:SetChecked(pChecked)
	self.Inherited.SetChecked(self, pChecked)
	
	if self.DisplayMode == "LEADER"
	or self.DisplayMode == "ASSIST" then
		self:UpdateLeaderModeTexture()
	elseif self.DisplayMode == "EXPAND" then
		self:UpdateExpandModeTexture()
	end
end

function Addon.UIElementsLib._CheckButton:UpdateExpandModeTexture()
	if self:GetChecked() then
		self:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up")
		self:GetNormalTexture():SetTexCoord(0, 1, 0, 1)
		
		self:SetPushedTexture("Interface\\Buttons\\UI-MinusButton-Down")
		self:GetPushedTexture():SetTexCoord(0, 1, 0, 1)
	else
		self:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up")
		self:GetNormalTexture():SetTexCoord(0, 1, 0, 1)
		
		self:SetPushedTexture("Interface\\Buttons\\UI-PlusButton-Down")
		self:GetPushedTexture():SetTexCoord(0, 1, 0, 1)
	end
end

function Addon.UIElementsLib._CheckButton:UpdateLeaderModeTexture()
end

function Addon.UIElementsLib._CheckButton:SetTitle(pTitle)
	self.Title:SetText(pTitle)
end

function Addon.UIElementsLib._CheckButton:SetMultiSelect(pMultiSelect)
	self.MultiSelect = pMultiSelect
	self:SetDisplayMode(self.DisplayMode)
end

----------------------------------------
Addon.UIElementsLib._ExpandAllButton = {}
----------------------------------------

function Addon.UIElementsLib._ExpandAllButton:New(pParent)
	return Addon:New(Addon.UIElementsLib._CheckButton, pParent, ALL)
end

function Addon.UIElementsLib._ExpandAllButton:Construct(pParent)
	self:SetWidth(20)
	self:SetHeight(20)
	
	self.TabLeft = self:CreateTexture(nil, "BACKGROUND")
	self.TabLeft:SetWidth(8)
	self.TabLeft:SetHeight(32)
	self.TabLeft:SetPoint("RIGHT", self, "LEFT", 3, 3)
	self.TabLeft:SetTexture("Interface\\QuestFrame\\UI-QuestLogSortTab-Left")
	
	self.TabMiddle = self:CreateTexture(nil, "BACKGROUND")
	self.TabMiddle:SetHeight(32)
	self.TabMiddle:SetPoint("LEFT", self.TabLeft, "RIGHT")
	self.TabMiddle:SetPoint("RIGHT", self.Title, "RIGHT", 5, 0)
	self.TabMiddle:SetTexture("Interface\\QuestFrame\\UI-QuestLogSortTab-Middle")
	
	self.TabRight = self:CreateTexture(nil, "BACKGROUND")
	self.TabRight:SetWidth(8)
	self.TabRight:SetHeight(32)
	self.TabRight:SetPoint("LEFT", self.TabMiddle, "RIGHT")
	self.TabRight:SetTexture("Interface\\QuestFrame\\UI-QuestLogSortTab-Right")
	
	self:SetDisplayMode("EXPAND")
end

----------------------------------------
Addon.UIElementsLib._Window = {}
----------------------------------------

function Addon.UIElementsLib._Window:New()
	return CreateFrame("Frame", nil, UIParent)
end

function Addon.UIElementsLib._Window:Construct()
	self:SetMovable(true)
	self:SetScript("OnDragStart", self.OnDragStart)
	self:SetScript("OnDragStop", self.OnDragStop)
end

function Addon.UIElementsLib._Window:OnDragStart()
	self:StartMoving()
end

function Addon.UIElementsLib._Window:OnDragStop()
	self:StopMovingOrSizing()
end

function Addon.UIElementsLib._Window:Close()
	self:Hide()
end

----------------------------------------
Addon.UIElementsLib._FloatingWindow = {}
----------------------------------------

function Addon.UIElementsLib._FloatingWindow:New()
	return Addon:New(Addon.UIElementsLib._Window)
end

function Addon.UIElementsLib._FloatingWindow:Construct()
	self.ContentFrame = Addon:New(Addon.UIElementsLib._PlainBorderedFrame, self)
	self.ContentFrame:SetAllPoints()
	
	self.TitleBar = Addon:New(Addon.UIElementsLib._FadingTitleBar, self)
end

function Addon.UIElementsLib._FloatingWindow:SetTitle(pTitle)
	self.TitleBar:SetTitle(pTitle)
end

function Addon.UIElementsLib._FloatingWindow:OnDragStart()
	self.Inherited.OnDragStart(self)
	self.TitleBar:SetForceFullBar(true)
end

function Addon.UIElementsLib._FloatingWindow:OnDragStop()
	self.Inherited.OnDragStop(self)
	self.TitleBar:SetForceFullBar(false)
end

----------------------------------------
Addon.UIElementsLib._PlainBorderedFrame = {}
----------------------------------------

function Addon.UIElementsLib._PlainBorderedFrame:New(pParent)
	return CreateFrame("Frame", nil, pParent)
end

function Addon.UIElementsLib._PlainBorderedFrame:Construct(pParent)
	self:SetBackdrop(
	{
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = {left = 3, right = 3, top = 3, bottom = 3}
	})
	
	self:SetBackdropBorderColor(0.75, 0.75, 0.75)
	self:SetBackdropColor(0.15, 0.15, 0.15)
	self:SetAlpha(1.0)
end

----------------------------------------
Addon.UIElementsLib._CloseButton = {}
----------------------------------------

function Addon.UIElementsLib._CloseButton:New(pParent)
	return CreateFrame("Button", nil, pParent)
end

function Addon.UIElementsLib._CloseButton:Construct(pParent)
	local vTexture
	
	self:SetWidth(16)
	self:SetHeight(15)
	
	local vTexture = self:CreateTexture(nil, "ARTWORK")
	
	self:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
	vTexture = self:GetNormalTexture()
	vTexture:SetTexCoord(0.1875, 0.78125, 0.21875, 0.78125)
	
	self:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
	vTexture = self:GetPushedTexture()
	vTexture:SetTexCoord(0.1875, 0.78125, 0.21875, 0.78125)
	
	self:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
	vTexture = self:GetHighlightTexture()
	vTexture:SetTexCoord(0.1875, 0.78125, 0.21875, 0.78125)
	vTexture:SetBlendMode("ADD")
end

----------------------------------------
Addon.UIElementsLib._FadingTitleBar = {}
----------------------------------------

function Addon.UIElementsLib._FadingTitleBar:New(pParent)
	return CreateFrame("Button", nil, pParent)
end

function Addon.UIElementsLib._FadingTitleBar:Construct(pParent)
	self:SetHeight(15)
	self:SetPoint("BOTTOMLEFT", self:GetParent(), "TOPLEFT", 0, 0)
	self:SetPoint("BOTTOMRIGHT", self:GetParent(), "TOPRIGHT", 0, 0)
	
	self.FullBar = CreateFrame("Frame", nil, self)
	self.FullBar:SetAllPoints()
	
	self.FullBar.BarLeft = self.FullBar:CreateTexture(nil, "BACKGROUND")
	self.FullBar.BarLeft:SetWidth(12)
	self.FullBar.BarLeft:SetHeight(22)
	self.FullBar.BarLeft:SetPoint("TOPLEFT", self, "TOPLEFT")
	self.FullBar.BarLeft:SetTexture("Interface\\Addons\\ForgeWay\\Textures\\GroupTitleBar")
	self.FullBar.BarLeft:SetTexCoord(0, 0.09375, 0.3125, 1)

	self.FullBar.BarRight = self.FullBar:CreateTexture(nil, "BACKGROUND")
	self.FullBar.BarRight:SetWidth(32)
	self.FullBar.BarRight:SetHeight(22)
	self.FullBar.BarRight:SetPoint("TOPRIGHT", self, "TOPRIGHT", 1, 0)
	self.FullBar.BarRight:SetTexture("Interface\\Addons\\ForgeWay\\Textures\\GroupTitleBar")
	self.FullBar.BarRight:SetTexCoord(0.75, 1, 0.3125, 1)

	self.FullBar.BarMiddle = self.FullBar:CreateTexture(nil, "BACKGROUND")
	self.FullBar.BarMiddle:SetHeight(22)
	self.FullBar.BarMiddle:SetPoint("TOPLEFT", self.FullBar.BarLeft, "TOPRIGHT")
	self.FullBar.BarMiddle:SetPoint("TOPRIGHT", self.FullBar.BarRight, "TOPLEFT")
	self.FullBar.BarMiddle:SetTexture("Interface\\Addons\\ForgeWay\\Textures\\GroupTitleBar")
	self.FullBar.BarMiddle:SetTexCoord(0.09375, 0.75, 0.3125, 1)
	
	self.FullBar.Title = self.FullBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	self.FullBar.Title:SetPoint("LEFT", self.FullBar.BarLeft, "RIGHT", -4, 2)
	self.FullBar.Title:SetPoint("RIGHT", self.FullBar.BarRight, "LEFT", 0, 2)
	
	self.FullBar.CloseButton = Addon:New(Addon.UIElementsLib._CloseButton, self.FullBar)
	self.FullBar.CloseButton:SetPoint("RIGHT", self.FullBar.BarRight, "RIGHT", -5, 1)
	self.FullBar.CloseButton:SetScript("OnEnter", function (self) self:GetParent():GetParent():ShowFullBar(true) end)
	self.FullBar.CloseButton:SetScript("OnLeave", function (self) self:GetParent():GetParent():ShowFullBar(false) end)
	self.FullBar.CloseButton:Hide()
	
	-- Create the compact version (shown when the mouse isn't over the bar)
	
	self.CompactBar = CreateFrame("Frame", nil, self)
	self.CompactBar:SetAllPoints()
	
	self.CompactBar.Title = self.CompactBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	self.CompactBar.Title:SetPoint("LEFT", self.CompactBar, "LEFT", 0, -1)
	self.CompactBar.Title:SetPoint("RIGHT", self.CompactBar, "RIGHT", 0, -1)
	
	self:SetScript("OnEnter", function (self) self:ShowFullBar(true) end)
	self:SetScript("OnLeave", function (self) self:ShowFullBar(false) end)
	self:SetScript("OnMouseDown", function (self) self:GetParent():OnDragStart() end)
	self:SetScript("OnMouseUp", function (self) self:GetParent():OnDragStop() end)
	
	-- Start out with the full bar hidden
	
	self.FullBar:SetAlpha(0)
	self.CompactBar:SetAlpha(1)
	
	self.FullBarShown = false
	self.FullBarForced = false
	
	--
	
	self:RegisterForDrag("LeftButton")
	self:RegisterForClicks("RightButtonUp")
end

function Addon.UIElementsLib._FadingTitleBar:SetForceFullBar(pForce)
	if self.FullBarForced == pForce then
		return
	end
	
	self.FullBarForced = pForce
	self:UpdateFullBarVisibility()
end

function Addon.UIElementsLib._FadingTitleBar:ShowFullBar(pShow)
	if self.FullBarShown == pShow then
		return
	end
	
	self.FullBarShown = pShow
	self:UpdateFullBarVisibility()
end

function Addon.UIElementsLib._FadingTitleBar:UpdateFullBarVisibility()
	if self.FullBarShown or self.FullBarForced then
		UIFrameFadeRemoveFrame(self.FullBar)
		UIFrameFadeRemoveFrame(self.CompactBar)
		
		self.FullBar:SetAlpha(1)
		self.CompactBar:SetAlpha(0)
	else
		if pForceState then
			UIFrameFadeRemoveFrame(self.FullBar)
			UIFrameFadeRemoveFrame(self.CompactBar)
			self.FullBar:SetAlpha(0)
			self.CompactBar:SetAlpha(1)
		else
			UIFrameFadeOut(self.FullBar, 0.5, 1, 0)
			UIFrameFadeIn(self.CompactBar, 0.5, 0, 1)
		end
	end
end

function Addon.UIElementsLib._FadingTitleBar:SetTitle(pTitle)
	self.FullBar.Title:SetText(pTitle)
	self.CompactBar.Title:SetText(pTitle)
end

function Addon.UIElementsLib._FadingTitleBar:SetCloseFunc(pCloseFunc)
	self.FullBar.CloseButton:SetScript("OnClick", pCloseFunc)
	self.FullBar.CloseButton:Show()
end

----------------------------------------
Addon.UIElementsLib._ExpandButton = {}
----------------------------------------

function Addon.UIElementsLib._ExpandButton:New(pParent)
	return CreateFrame("Button", nil, pParent)
end

function Addon.UIElementsLib._ExpandButton:Construct(pParent)
	self:SetWidth(16)
	self:SetHeight(16)
	
	self:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-UP")
	
	local vHighlight = self:CreateTexture(nil, "HIGHLIGHT")
	vHighlight:SetTexture("Interface\\Buttons\\UI-PlusButton-Hilight")
	vHighlight:SetBlendMode("ADD")
	vHighlight:SetAllPoints()
	
	self:SetHighlightTexture(vHighlight)
end

function Addon.UIElementsLib._ExpandButton:SetExpanded(pExpanded)
	if pExpanded then
		self:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-UP")
	else
		self:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-UP")
	end
end

----------------------------------------
Addon.UIElementsLib._DropDownMenuItems = {}
----------------------------------------

function Addon.UIElementsLib._DropDownMenuItems:Construct(closeFunc)
	self.type = "group"
	self.args = {}
	self.closeFunc = closeFunc
end

function Addon.UIElementsLib._DropDownMenuItems:AddItem(item, options)
	-- Convert to a table if the item is just a string
	if type(item) ~= "table" then
		item = {name = tostring(item)}
	end

	-- Copy the options table over if it's provided
	if options then
		assert(type(options) == "table", "AddItem second parameter must be a table")

		for k, v in pairs(options) do
			item[k] = v
		end
	end

	item.order = #self.args + 1
	table.insert(self.args, item)
end

function Addon.UIElementsLib._DropDownMenuItems:AddFunction(title, func, disabled, options)
	self:AddItem({
		name = title,
		type = "execute",
		func = function (...)
			func(...)
			if self.closeFunc then
				self.closeFunc()
			end
		end,
		disabled = disabled,
	}, options)
end

function Addon.UIElementsLib._DropDownMenuItems:AddCategoryTitle(title)
	if not title then
		Addon:ErrorMessage("Category must have title")
		return
	end

	self:AddItem({
		name = title,
		type = "header",
	})
end

function Addon.UIElementsLib._DropDownMenuItems:AddSelect(title, values, get, set)
	assert(title, "Category must have title")

	if type(values) == "function" then
		values = values()
	end

	self:AddItem({
		name = title,
		type = "select",
		values = values,
		get = get,
		set = function (...)
			set(...)
			if self.closeFunc then
				self.closeFunc()
			end
		end,
	})
end

function Addon.UIElementsLib._DropDownMenuItems:AddChildMenu(title, func)
	assert(type(title) == "string", "AddChildMenu: First parameter must be a string")
	assert(type(func) == "function", "AddChildMenu: Second parameter must be a function")

	local items = Addon:New(Addon.UIElementsLib._DropDownMenuItems, self.closeFunc)
	items.name = title
	items.type = "group"
	func(items)
	
	self:AddItem(items)
end

function Addon.UIElementsLib._DropDownMenuItems:AddDivider()
	self:AddCategoryTitle(" ")
end

function Addon.UIElementsLib._DropDownMenuItems:AddToggle(title, get, set, disabled, options)
	local item = {
		name = title,
		type = "toggle",
		get = get,
		set = function (item, ...)
			if set then
				set(item, ...)
			end
			if self.closeFunc then
				self.closeFunc()
			end
		end,
		disabled = disabled,
	}
	self:AddItem(item, options)
	return item
end

function Addon.UIElementsLib._DropDownMenuItems:AddToggleWithIcon(title, icon, color, get, set, disabled, options)
	local item = self:AddToggle(title, get, set, disabled, options)
	item.icon = icon
	item.color = color
	return item
end

function Addon.UIElementsLib._DropDownMenuItems:AddItemWithValue(title, value, options)
	local item = self:AddToggle(
		title,

		-- get
		function (item)
			return self.selectedValue == value
		end,

		-- set
		function (item)
			self:DidSelectItemWithValue(value)
		end,

		nil, -- disabled
		options
	)

	item.value = value
	return item
end

function Addon.UIElementsLib._DropDownMenuItems:GetItemWithValue(value)
	for index, item in ipairs(self.args) do
		if item.value == value then
			return item, index
		elseif item.type == "group" then
			local item, index2 = item:GetItemWithValue(value)
			if item then
				return item, index, index2
			end
		end
	end
end

function Addon.UIElementsLib._DropDownMenuItems:GetTitleForValue(value)
	local item = self:GetItemWithValue(value)
	if item then
		return item.name
	end
end

function Addon.UIElementsLib._DropDownMenuItems:AddSingleChoiceGroup(title, items, get, set, disable)
	if title then
		self:AddCategoryTitle(title)
	end
	for index, item in ipairs(items) do
		local menuItem = self:AddToggle(
			item.title,
			-- get
			function ()
				return get() == item.value
			end,
			-- set
			function (menu, value)
				set(item.value)
			end,
			disable)
		menuItem.value = item.value
	end
end

----------------------------------------
Addon.UIElementsLib._DropDownMenu = {}
----------------------------------------

function Addon.UIElementsLib._DropDownMenu:Show(items, point, relativeTo, relativePoint, xOffset, yOffset)
	-- Fail if it's already up
	assert(not self.menuFrame, "DropDownMenu can't call Show if already shown")
	assert(items and items.args, "DropDownMenu items must be DropDownMenuItems")

	-- Play a sound
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	
	-- Show the menu
	self.menuFrame = LibStub("LibDropdownMC-1.0"):OpenAce3Menu(items)
	self.menuFrame:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset)
	self.menuFrame.cleanup = function ()
		if self.cleanup then
			self.cleanup()
		end
	end
end

function Addon.UIElementsLib._DropDownMenu:Hide()
	-- Fail if it's not  up
	assert(self.menuFrame, "DropDownMenu can't call Hide if not shown")

	-- Play a sound
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	
	-- Hide the menu and leave if it's currently up
	self.menuFrame:Hide()
	self.menuFrame = nil
end

function Addon.UIElementsLib._DropDownMenu:Toggle()
	if self.menuFrame then
		self:Hide()
	else
		self:Show()
	end
end

----------------------------------------
Addon.UIElementsLib._DropDownMenuButton = {}
----------------------------------------

if not MC2UIElementsLib_Globals then
	MC2UIElementsLib_Globals =
	{
		NumDropDownMenuButtons = 0,
	}
end

function Addon.UIElementsLib._DropDownMenuButton:New(parent, menuFunc, width)
	MC2UIElementsLib_Globals.NumDropDownMenuButtons = MC2UIElementsLib_Globals.NumDropDownMenuButtons + 1
	local name = "MC2UIElementsLib_DropDownMenuButton"..MC2UIElementsLib_Globals.NumDropDownMenuButtons
	
	return CreateFrame("Frame", name, parent)
end

function Addon.UIElementsLib._DropDownMenuButton:Construct(pParent, pMenuFunc, pWidth)
	local buttonSize = 24
	
	if not pWidth then
		pWidth = buttonSize
	end
	
	if pWidth < buttonSize then
		buttonSize = pWidth
	end
	
	self.AutoSelectValue = true -- calls SetSelectedValue on item selection automatically
	
	self:SetWidth(pWidth)
	self:SetHeight(buttonSize)
	
	self.Button = CreateFrame("Button", nil, self)
	self.Button:SetWidth(buttonSize)
	self.Button:SetHeight(buttonSize)
	self.Button:SetPoint("RIGHT", self, "RIGHT", 1, 0)

	self.Button:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
	self.Button:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down")
	self.Button:SetDisabledTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Disabled")
	
	self.Button.HighlightTexture = self.Button:CreateTexture(nil, "HIGHLIGHT")
	self.Button.HighlightTexture:SetTexture("Interface\\Buttons\\UI-Common-MouseHilight")
	self.Button.HighlightTexture:SetBlendMode("ADD")
	self.Button.HighlightTexture:SetAllPoints()

	self.Icon = self:CreateTexture(self:GetName().."Icon", "ARTWORK")
	self.Icon:SetWidth(1)
	self.Icon:SetHeight(1)
	self.Icon:SetPoint("TOPLEFT", self.LeftTexture, "TOPLEFT", 0, 0)
	
	self.Button:SetScript("OnClick", function (frame, button)
		self:ToggleMenu()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	end)

	self.MenuFunc = pMenuFunc
	
	self.initialize = self.WoWMenuInitFunction
	self.currentLevelItems = self.items
	
	self:SetScript("OnHide", function ()
		if self.dropDownMenu then
			self.dropDownMenu:Hide()
			self.dropDownMenu = nil
		end
	end)
end

function Addon.UIElementsLib._DropDownMenuButton:SetMenuFunc(menuFunc)
	self.menuFunc = menuFunc
end

function Addon.UIElementsLib._DropDownMenuButton:RefreshItems()
	self.items = Addon:New(Addon.UIElementsLib._DropDownMenuItems, function ()
		Addon.SchedulerLib:ScheduleTask(0.1, function ()
			self.dropDownMenu:Hide()
			self.dropDownMenu = nil
		end)
	end)
	self.MenuFunc(self.items)
end

function Addon.UIElementsLib._DropDownMenuButton:ToggleMenu()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	
	-- Hide the menu and leave if it's currently up
	if self.dropDownMenu then
		self.dropDownMenu:Hide()
		self.dropDownMenu = nil
		return
	end

	-- Position the menu
	self.relativeTo = self
	self.point = self.AnchorPoint or "TOPRIGHT"
	self.relativePoint = self.AnchorRelativePoint or "BOTTOMRIGHT"
	self.xOffset = self.AnchorXOffset or 0
	self.yOffset = self.AnchorYOffset or 3
	
	-- Get the items
	self:RefreshItems()

	-- Show the menu
	self.dropDownMenu = Addon:New(Addon.UIElementsLib._DropDownMenu)
	self.items.selectedValue = self.selectedValue
	self.dropDownMenu:Show(self.items, self.point, self.relativeTo, self.relativePoint, self.xOffset, self.yOffset)

	-- Propagate value change messages for those menus using the stateful idiom
	self.items.DidSelectItemWithValue = function (menu, value)
		self:DidSelectItemWithValue(value)
	end
end

function Addon.UIElementsLib._DropDownMenuButton:ItemClicked(value)
	if self.AutoSelectValue then
		self:SetSelectedValue(value)
	end
	
	if self.ItemClickedFunc then
		self:ItemClickedFunc(value)
	end
	
	CloseDropDownMenus()
end

function Addon.UIElementsLib._DropDownMenuButton:SetSelectedValue(value)
	self.selectedValue = value

	if self.items then
		self.items.selectedValue = value
	end
end

function Addon.UIElementsLib._DropDownMenuButton:GetSelectedValue()
	return self.selectedValue
end

function Addon.UIElementsLib._DropDownMenuButton:SetCurrentValueText(pText)
	-- Not applicable for a menu button
end

function Addon.UIElementsLib._DropDownMenuButton:SetEnabled(pEnabled)
	if pEnabled then
		self.Button:Enable()
		self:SetAlpha(1)
	else
		self.Button:Disable()
		self:SetAlpha(0.5)
	end
end

----------------------------------------
Addon.UIElementsLib._TitledDropDownMenuButton = {}
----------------------------------------

Addon.UIElementsLib._TitledDropDownMenuButton.New = Addon.UIElementsLib._DropDownMenuButton.New

function Addon.UIElementsLib._TitledDropDownMenuButton:Construct(pParent, pMenuFunc, pWidth)
	self:Inherit(Addon.UIElementsLib._DropDownMenuButton, pParent, pMenuFunc, pWidth or 150)
	
	self.LeftTexture = self:CreateTexture(nil, "ARTWORK")
	self.LeftTexture:SetWidth(25)
	self.LeftTexture:SetHeight(64)
	self.LeftTexture:SetPoint("TOPRIGHT", self, "TOPLEFT", 1, 19)
	self.LeftTexture:SetTexture("Interface\\Glues\\CharacterCreate\\CharacterCreate-LabelFrame")
	self.LeftTexture:SetTexCoord(0, 0.1953125, 0, 1)
	
	self.RightTexture = self:CreateTexture(nil, "ARTWORK")
	self.RightTexture:SetWidth(25)
	self.RightTexture:SetHeight(64)
	self.RightTexture:SetPoint("TOP", self.LeftTexture, "TOP")
	self.RightTexture:SetPoint("LEFT", self, "RIGHT", -9, 0)
	self.RightTexture:SetTexture("Interface\\Glues\\CharacterCreate\\CharacterCreate-LabelFrame")
	self.RightTexture:SetTexCoord(0.8046875, 1, 0, 1)
	
	self.MiddleTexture = self:CreateTexture(nil, "ARTWORK")
	self.MiddleTexture:SetPoint("TOPLEFT", self.LeftTexture, "TOPRIGHT")
	self.MiddleTexture:SetPoint("BOTTOMRIGHT", self.RightTexture, "BOTTOMLEFT")
	self.MiddleTexture:SetTexture("Interface\\Glues\\CharacterCreate\\CharacterCreate-LabelFrame")
	self.MiddleTexture:SetTexCoord(0.1953125, 0.8046875, 0, 1)
	
	self.Text = self:CreateFontString(self:GetName().."Text", "ARTWORK", "GameFontHighlightSmall")
	self.Text:SetJustifyH("RIGHT")
	self.Text:SetHeight(18)
	self.Text:SetPoint("RIGHT", self.MiddleTexture, "RIGHT", -18, 1)
	self.Text:SetPoint("LEFT", self.MiddleTexture, "LEFT", 0, 1)
	
	self.Title = self:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	self.Title:SetPoint("RIGHT", self.MiddleTexture, "LEFT", -11, 1)
end

function Addon.UIElementsLib._TitledDropDownMenuButton:SetTitle(pTitle)
	self.Title:SetText(pTitle)
end

function Addon.UIElementsLib._TitledDropDownMenuButton:SetCurrentValueText(pText)
	self.Text:SetText(pText)
end

function Addon.UIElementsLib._TitledDropDownMenuButton:SetSelectedValue(value)
	if self.selectedValue == value then
		return
	end
	
	self.Inherited.SetSelectedValue(self, value)
	
	self:RefreshItems()

	local text = self.items:GetTitleForValue(value) or ""
	self:SetCurrentValueText(text)
end

----------------------------------------
Addon.UIElementsLib._Section = {}
----------------------------------------

function Addon.UIElementsLib._Section:New(pParent, pTitle)
	return CreateFrame("Frame", nil, pParent)
end

function Addon.UIElementsLib._Section:Construct(pParent, pTitle)
	self:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 16, edgeSize = 16,
		insets = {left = 3, right = 3, top = 3, bottom = 3}})
	
	self:SetBackdropColor(1, 1, 1, 0.2)
	
	self.Title = self:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	self.Title:SetPoint("TOPLEFT", self, "TOPLEFT", 10, -7)
	self.Title:SetText(pTitle)
end

----------------------------------------
Addon.UIElementsLib._ContextMenu = {}
----------------------------------------

function Addon.UIElementsLib._ContextMenu:ToggleMenu(frame)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)

	-- Hide the menu and leave if it's currently up
	if self.dropDownMenu then
		self.dropDownMenu:Hide()
		self.dropDownMenu = nil
		return
	end

	-- Position the menu
	self.relativeTo = frame
	self.point = "TOPLEFT"
	self.relativePoint = self.AnchorRelativePoint or "BOTTOMLEFT"
	self.xOffset = 0
	self.yOffset = 0

	-- Get the items
	self.items = Addon:New(Addon.UIElementsLib._DropDownMenuItems, function ()
		Addon.SchedulerLib:ScheduleTask(0.1, function ()
			self.dropDownMenu:Hide()
			self.dropDownMenu = nil
		end)
	end)
	self:AddItems(self.items)

	-- Show the menu
	self.dropDownMenu = Addon:New(Addon.UIElementsLib._DropDownMenu)
	self.items.selectedValue = self.selectedValue
	self.dropDownMenu:Show(self.items, self.point, self.relativeTo, self.relativePoint, self.xOffset, self.yOffset)

	-- Propagate value change messages for those menus using the stateful idiom
	self.items.DidSelectItemWithValue = function (menu, value)
		self:DidSelectItemWithValue(value)
	end
end

function Addon.UIElementsLib._ContextMenu:AddItems(menu)
	menu:AddItemWithValue("Test 1", "TEST1")
	menu:AddItemWithValue("Test 2", "TEST2")
	menu:AddItemWithValue("Test 3", "TEST3")
end

----------------------------------------
Addon.UIElementsLib._EditBox = {}
----------------------------------------

function Addon.UIElementsLib._EditBox:New(pParent, pLabel, pMaxLetters, pWidth, pPlain)
	return CreateFrame("EditBox", nil, pParent)
end

function Addon.UIElementsLib._EditBox:Construct(pParent, pLabel, pMaxLetters, pWidth, pPlain)
	self.Enabled = true
	
	self.cursorOffset = 0
	self.cursorHeight = 0
	
	self:SetWidth(pWidth or 150)
	self:SetHeight(25)
	
	self:SetFontObject(ChatFontNormal)
	
	self:SetMultiLine(false)
	self:EnableMouse(true)
	self:SetAutoFocus(false)
	self:SetMaxLetters(pMaxLetters or 200)
	
	if not pPlain then
		self.LeftTexture = self:CreateTexture(nil, "BACKGROUND")
		self.LeftTexture:SetTexture("Interface\\Common\\Common-Input-Border")
		self.LeftTexture:SetWidth(8)
		self.LeftTexture:SetHeight(20)
		self.LeftTexture:SetPoint("LEFT", self, "LEFT", -5, 0)
		self.LeftTexture:SetTexCoord(0, 0.0625, 0, 0.625)
		
		self.RightTexture = self:CreateTexture(nil, "BACKGROUND")
		self.RightTexture:SetTexture("Interface\\Common\\Common-Input-Border")
		self.RightTexture:SetWidth(8)
		self.RightTexture:SetHeight(20)
		self.RightTexture:SetPoint("RIGHT", self, "RIGHT", 0, 0)
		self.RightTexture:SetTexCoord(0.9375, 1, 0, 0.625)
		
		self.MiddleTexture = self:CreateTexture(nil, "BACKGROUND")
		self.MiddleTexture:SetHeight(20)
		self.MiddleTexture:SetTexture("Interface\\Common\\Common-Input-Border")
		self.MiddleTexture:SetPoint("LEFT", self.LeftTexture, "RIGHT")
		self.MiddleTexture:SetPoint("RIGHT", self.RightTexture, "LEFT")
		self.MiddleTexture:SetTexCoord(0.0625, 0.9375, 0, 0.625)
		
		self.Title = self:CreateFontString(nil, "BACKGROUND", "GameFontNormalSmall")
		self.Title:SetJustifyH("RIGHT")
		self.Title:SetPoint("RIGHT", self, "TOPLEFT", -10, -13)
		self.Title:SetText(pLabel or "")
	end
	
	self:SetScript("OnEscapePressed", function (self) self:ClearFocus() end)
	self:SetScript("OnEditFocusLost", self.EditFocusLost)
	self:SetScript("OnEditFocusGained", self.EditFocusGained)
	self:SetScript("OnTabPressed", self.OnTabPressed)
	self:SetScript("OnChar", self.OnChar)
	self:SetScript("OnCharComposition", self.OnCharComposition)
	self:SetScript("OnTextChanged", self.OnTextChanged)
	
	self:LinkIntoTabChain(pParent)
end

function Addon.UIElementsLib._EditBox:SetEnabled(pEnabled)
	self.Enabled = pEnabled
	
	if not pEnabled then
		self:ClearFocus()
	end
	
	self:EnableMouse(pEnabled)
	self:SetAlpha(pEnabled and 1.0 or 0.5)
end

function Addon.UIElementsLib._EditBox:SetAnchorMode(pMode)
	self.Title:ClearAllPoints()
	self:ClearAllPoints()
	
	if pMode == "TITLE" then
		self:SetPoint("TOPLEFT", self.Title, "RIGHT", 10, 12)
	else
		self.Title:SetPoint("RIGHT", self, "TOPLEFT", -10, -13)
	end
end

function Addon.UIElementsLib._EditBox:EditFocusLost()
	self.HaveKeyboardFocus = nil
	self.TextHasChanged = nil
	self:HighlightText(0, 0)
end

function Addon.UIElementsLib._EditBox:EditFocusGained()
	self.HaveKeyboardFocus = true
	self.TextHasChanged = nil
	self:HighlightText()
end

function Addon.UIElementsLib._EditBox:SetAutoCompleteFunc(pFunction)
	self.AutoCompleteFunc = pFunction
end

function Addon.UIElementsLib._EditBox:OnChar()
	if not self:IsInIMECompositionMode() then
		self:OnCharComposition()
	end
	self.TextHasChanged = self:GetText() ~= self.OrigText
end

function Addon.UIElementsLib._EditBox:OnCharComposition()
	if self.AutoCompleteFunc then
		self:AutoCompleteFunc()
	end
	self.TextHasChanged = self:GetText() ~= self.OrigText
end

function Addon.UIElementsLib._EditBox:SetText(pText, ...)
	self.TextHasChanged = nil
	self.OrigText = tostring(pText)
	
	self.Inherited.SetText(self, pText, ...)
end

function Addon.UIElementsLib._EditBox:OnTextChanged()
	local vText = self:GetText()
	
	self.TextHasChanged = vText ~= self.OrigText
	
	if self.EmptyText then
		if string.trim(vText) == "" then
			self.EmptyText:Show()
		else
			self.EmptyText:Hide()
		end
	end
end

function Addon.UIElementsLib._EditBox:LinkIntoTabChain(pParent)
	local vTabParent = pParent
	
	while vTabParent.TabParent do
		vTabParent = vTabParent.TabParent
	end
	
	self.NextEditBox = vTabParent.FirstEditBox
	self.PrevEditBox = vTabParent.LastEditBox
	
	if vTabParent.LastEditBox then
		vTabParent.LastEditBox.NextEditBox = self
	end
	
	vTabParent.LastEditBox = self
	
	if vTabParent.FirstEditBox then
		vTabParent.FirstEditBox.PrevEditBox = self
	else
		vTabParent.FirstEditBox = self
	end
end

function Addon.UIElementsLib._EditBox:OnTabPressed()
	local vReverse = IsShiftKeyDown()
	local vEditBox = self
	
	for vIndex = 1, 50 do
		local vNextEditBox
			
		if vReverse then
			vNextEditBox = vEditBox.PrevEditBox
		else
			vNextEditBox = vEditBox.NextEditBox
		end
		
		if not vNextEditBox then
			self:SetFocus()
			return
		end
		
		if vNextEditBox:IsVisible()
		and not vNextEditBox.isDisabled then
			vNextEditBox:SetFocus()
			return
		end
		
		vEditBox = vNextEditBox
	end
end

function Addon.UIElementsLib._EditBox:SetVertexColor(pRed, pGreen, pBlue, pAlpha)
	self.LeftTexture:SetVertexColor(pRed, pGreen, pBlue, pAlpha)
	self.MiddleTexture:SetVertexColor(pRed, pGreen, pBlue, pAlpha)
	self.RightTexture:SetVertexColor(pRed, pGreen, pBlue, pAlpha)
end

function Addon.UIElementsLib._EditBox:SetEmptyText(pText)
	if not self.EmptyText then
		self.EmptyText = self:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		self.EmptyText:SetPoint("LEFT", self, "LEFT")
		self.EmptyText:SetPoint("RIGHT", self, "RIGHT")
		self.EmptyText:SetJustifyH("LEFT")
		self.EmptyText:SetTextColor(1, 1, 1, 0.5)
	end
	
	self.EmptyText:SetText(pText)
end

----------------------------------------
Addon.UIElementsLib._DatePicker = {}
----------------------------------------

function Addon.UIElementsLib._DatePicker:New(parent, title)
	return CreateFrame("Frame", nil, parent)
end

function Addon.UIElementsLib._DatePicker:Construct(parent, title)
	self.Enabled = true

	-- Month menu
	self.MonthMenu = Addon:New(Addon.UIElementsLib._TitledDropDownMenuButton, self,
		function (menu)
			menu:AddSingleChoiceGroup(nil,
				{
					{title = Addon.CALENDAR_MONTH_NAMES[1], value = 1},
					{title = Addon.CALENDAR_MONTH_NAMES[2], value = 2},
					{title = Addon.CALENDAR_MONTH_NAMES[3], value = 3},
					{title = Addon.CALENDAR_MONTH_NAMES[4], value = 4},
					{title = Addon.CALENDAR_MONTH_NAMES[5], value = 5},
					{title = Addon.CALENDAR_MONTH_NAMES[6], value = 6},
					{title = Addon.CALENDAR_MONTH_NAMES[7], value = 7},
					{title = Addon.CALENDAR_MONTH_NAMES[8], value = 8},
					{title = Addon.CALENDAR_MONTH_NAMES[9], value = 9},
					{title = Addon.CALENDAR_MONTH_NAMES[10], value = 10},
					{title = Addon.CALENDAR_MONTH_NAMES[11], value = 11},
					{title = Addon.CALENDAR_MONTH_NAMES[12], value = 12},
				},
				function ()
					return self.month
				end,
				function (value)
					self.month = value
					self.MonthMenu:SetSelectedValue(value)
					self:ValidateDay()
					self:DateValueChanged()
				end
			)
		end)
	self.MonthMenu:SetWidth(120)

	-- Year menu
	self.YearMenu = Addon:New(Addon.UIElementsLib._TitledDropDownMenuButton, self,
		function (menu)
			local currentDate = C_Calendar.GetDate()
			menu:AddSingleChoiceGroup(nil,
				{
					{title = currentDate.year, value = currentDate.year},
					{title = currentDate.year + 1, value = currentDate.year + 1}
				},
				function ()
					return self.year
				end,
				function (value)
					self.year = value
					self.YearMenu:SetSelectedValue(value)
					self:ValidateDay()
					self:DateValueChanged()
				end
			)
		end)
	self.YearMenu:SetWidth(75)

	-- Day menu
	self.DayMenu = Addon:New(Addon.UIElementsLib._TitledDropDownMenuButton, self,
		function (menu)
			local numDays = Addon.DateLib:GetDaysInMonth(self.month, self.year)
			if not numDays then
				return
			end

			for day = 1, numDays do
				local item = menu:AddToggle(day,
					function ()
						return self.day == day
					end,
					function ()
						self.day = day
						self.DayMenu:SetSelectedValue(day)
						self:DateValueChanged()
					end
				)
				item.value = day
			end
		end)
	self.DayMenu:SetWidth(55)

	-- Layout the menus based on locale
	
	if string.sub(GetLocale(), -2) == "US" then
		self.MonthMenu:SetPoint("LEFT", self, "LEFT")
		self.DayMenu:SetPoint("LEFT", self.MonthMenu, "RIGHT", 8, 0)
		self.YearMenu:SetPoint("LEFT", self.DayMenu, "RIGHT", 8, 0)
		
		self.LeftMenu = self.MonthMenu
	else
		self.DayMenu:SetPoint("LEFT", self, "LEFT")
		self.MonthMenu:SetPoint("LEFT", self.DayMenu, "RIGHT", 8, 0)
		self.YearMenu:SetPoint("LEFT", self.MonthMenu, "RIGHT", 8, 0)
		
		self.LeftMenu = self.DayMenu
	end
	
	self:SetWidth(self.MonthMenu:GetWidth() + self.DayMenu:GetWidth() + self.YearMenu:GetWidth() + 16)
	self:SetHeight(self.MonthMenu:GetHeight())
	
	--
	
	self:SetLabel(title or "")
end

function Addon.UIElementsLib._DatePicker:SetEnabled(pEnabled)
	self.Enabled = pEnabled
	
	self.MonthMenu:SetEnabled(pEnabled)
	self.DayMenu:SetEnabled(pEnabled)
	self.YearMenu:SetEnabled(pEnabled)
end

function Addon.UIElementsLib._DatePicker:SetDate(month, day, year)
	self.month = month
	self.day = day
	self.year = year

	if not month then
		self.YearMenu:SetSelectedValue(nil)
		self.MonthMenu:SetSelectedValue(nil)
		self.DayMenu:SetSelectedValue(nil)
		return
	end
	
	-- Set DayMenu last so that month and year will be available for calculating
	-- the number of days in the month
	self.YearMenu:SetSelectedValue(year)
	self.MonthMenu:SetSelectedValue(month)
	self.DayMenu:SetSelectedValue(day)
end

function Addon.UIElementsLib._DatePicker:DateValueChanged()
	if self.ValueChangedFunc then
		self:ValueChangedFunc()
	end
end

function Addon.UIElementsLib._DatePicker:ValidateDay()
	local numDays = Addon.DateLib:GetDaysInMonth(self.MonthMenu:GetSelectedValue(), self.YearMenu:GetSelectedValue())
	
	if self.DayMenu:GetSelectedValue() > numDays then
		self.DayMenu:SetSelectedValue(numDays)
	end
end

function Addon.UIElementsLib._DatePicker:GetDate()
	return self.month, self.day, self.year
end

function Addon.UIElementsLib._DatePicker:SetLabel(pLabel)
	self.LeftMenu:SetTitle(pLabel)
end

----------------------------------------
Addon.UIElementsLib._TimePicker = {}
----------------------------------------

function Addon.UIElementsLib._TimePicker:New(pParent, pTitle)
	return CreateFrame("Frame", nil, pParent)
end

function Addon.UIElementsLib._TimePicker:Construct(pParent, pLabel)
	self.Enabled = true
	
	self:SetWidth(185)
	self:SetHeight(24)
	
	self.HourMenu = Addon:New(Addon.UIElementsLib._TitledDropDownMenuButton, self, function (menu)
		if self.Use24HTime then
			for hour = 0, 23 do
				menu:AddItemWithValue(hour, hour)
			end
		else
			for hour = 1, 12 do
				menu:AddItemWithValue(hour, hour)
			end
		end
	end)
	self.HourMenu:SetWidth(55)
	self.HourMenu:SetPoint("LEFT", self, "LEFT")
	self.HourMenu.DidSelectItemWithValue = function (menu, value)
		self.HourMenu:SetSelectedValue(value)
		self:TimeValueChanged()
	end
	
	self.MinuteMenu = Addon:New(Addon.UIElementsLib._TitledDropDownMenuButton, self, function (menu)
		for minute = 0, 59, 5 do
			menu:AddItemWithValue(string.format("%02d", minute), minute)
		end
	end)
	self.MinuteMenu:SetWidth(55)
	self.MinuteMenu:SetPoint("LEFT", self.HourMenu, "RIGHT", 8, 0)
	self.MinuteMenu.DidSelectItemWithValue = function (menu, value)
		self.MinuteMenu:SetSelectedValue(value)
		self:TimeValueChanged()
	end
	
	self.AMPMMenu = Addon:New(Addon.UIElementsLib._TitledDropDownMenuButton, self, function (menu)
		menu:AddItemWithValue("AM", "AM")
		menu:AddItemWithValue("PM", "PM")
	end)
	self.AMPMMenu:SetWidth(55)
	self.AMPMMenu:SetPoint("LEFT", self.MinuteMenu, "RIGHT", 8, 0)
	self.AMPMMenu.DidSelectItemWithValue = function (menu, value)
		self.AMPMMenu:SetSelectedValue(value)
		self:TimeValueChanged()
	end
	
	self:SetLabel(pLabel or "")
end

function Addon.UIElementsLib._TimePicker:SetEnabled(enabled)
	self.Enabled = enabled
	
	self.HourMenu:SetEnabled(enabled)
	self.MinuteMenu:SetEnabled(enabled)
	self.AMPMMenu:SetEnabled(enabled)
end

function Addon.UIElementsLib._TimePicker:SetTime(hour, minute)
	self.hour = hour
	self.minute = minute

	if not hour then
		self.HourMenu:SetSelectedValue(nil)
		self.MinuteMenu:SetSelectedValue(nil)
		self.AMPMMenu:SetSelectedValue(nil)
		return
	end
	
	local displayHour = hour

	if GetCVarBool("timeMgrUseMilitaryTime") then
		self.AMPMMenu:Hide()
		self.Use24HTime = true
	else
		local ampm = "AM"
		if hour == 0 then
			displayHour = 12
		elseif hour == 12 then
			displayHour = hour
			ampm = "PM"
		elseif hour > 12 then
			displayHour = hour - 12
			ampm = "PM"
		else
			displayHour = hour
		end
		
		if ampm == "PM" and displayHour > 12 then
			displayHour = displayHour - 12
		end
		
		if displayHour == 0 then
			displayHour = 12
		end
		
		self.AMPMMenu:SetSelectedValue(ampm)
		self.AMPMMenu:Show()
		
		self.Use24HTime = false
	end
	
	self.HourMenu:SetSelectedValue(displayHour)
	self.MinuteMenu:SetSelectedValue(minute)
end

function Addon.UIElementsLib._TimePicker:TimeValueChanged()
	if self.ValueChangedFunc then
		self:ValueChangedFunc()
	end
end

function Addon.UIElementsLib._TimePicker:GetTime()
	local vHour, vMinute
	
	vHour = self.HourMenu:GetSelectedValue()
	vMinute = self.MinuteMenu:GetSelectedValue()
	
	if not vHour or not vMinute then
		return
	end
	
	if not self.Use24HTime then
		if self.AMPMMenu:GetSelectedValue() == "AM" then
			if vHour == 12 then
				vHour = 0
			end
		else
			if vHour ~= 12 then
				vHour = vHour + 12
			end
		end
	end
	
	return vHour, vMinute
end

function Addon.UIElementsLib._TimePicker:SetLabel(pLabel)
	self.HourMenu:SetTitle(pLabel)
end

----------------------------------------
Addon.UIElementsLib._LevelRangePicker = {}
----------------------------------------

function Addon.UIElementsLib._LevelRangePicker:New(pParent, pLabel)
	return CreateFrame("Frame", nil, pParent)
end

function Addon.UIElementsLib._LevelRangePicker:Construct(pParent, pLabel)
	self.Enabled = true
	
	self.TabParent = pParent
	
	self:SetWidth(80)
	self:SetHeight(24)
	
	self.MinLevel = Addon:New(Addon.UIElementsLib._EditBox, self, pLabel, 3)
	self.MinLevel:SetWidth(30)
	self.MinLevel:SetPoint("LEFT", self, "LEFT")
	
	self.MaxLevel = Addon:New(Addon.UIElementsLib._EditBox, self, Addon.cLevelRangeSeparator, 3)
	self.MaxLevel:SetWidth(30)
	self.MaxLevel:SetAnchorMode("TITLE")
	self.MaxLevel.Title:SetPoint("LEFT", self.MinLevel, "RIGHT", 5, 0)
end

function Addon.UIElementsLib._LevelRangePicker:SetEnabled(pEnabled)
	self.Enabled = pEnabled
	
	self.MinLevel:SetEnabled(pEnabled)
	self.MaxLevel:SetEnabled(pEnabled)
end

function Addon.UIElementsLib._LevelRangePicker:SetLabel(pLabel)
	self.MinLevel:SetTitle(pLabel)
end

function Addon.UIElementsLib._LevelRangePicker:SetLevelRange(pMinLevel, pMaxLevel)
	self.MinLevel:SetText(pMinLevel or "")
	self.MaxLevel:SetText(pMaxLevel or "")
end

function Addon.UIElementsLib._LevelRangePicker:GetLevelRange()
	return tonumber(self.MinLevel:GetText()), tonumber(self.MaxLevel:GetText())
end

function Addon.UIElementsLib._LevelRangePicker:ClearFocus()
	self.MinLevel:ClearFocus()
	self.MaxLevel:ClearFocus()
end

----------------------------------------
Addon.UIElementsLib._PushButton = {}
----------------------------------------

function Addon.UIElementsLib._PushButton:New(pParent, pTitle, pWidth)
	return CreateFrame("Button", nil, pParent)
end

function Addon.UIElementsLib._PushButton:Construct(pParent, pTitle, pWidth)
	self:SetWidth(pWidth or 100)
	self:SetHeight(22)
	
	self.Text = self:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	self.Text:SetPoint("LEFT", self, "LEFT")
	self.Text:SetPoint("RIGHT", self, "RIGHT")
	self.Text:SetHeight(20)
	self.Text:SetText(pTitle)
	
	self.LeftTexture = self:CreateTexture(nil, "BACKGROUND")
	self.LeftTexture:SetWidth(12)
	self.LeftTexture:SetPoint("TOPLEFT", self, "TOPLEFT")
	self.LeftTexture:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT")
	self.LeftTexture:SetTexCoord(0, 0.09375, 0, 0.6875)
	
	self.RightTexture = self:CreateTexture(nil, "BACKGROUND")
	self.RightTexture:SetWidth(12)
	self.RightTexture:SetPoint("TOPRIGHT", self, "TOPRIGHT")
	self.RightTexture:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT")
	self.RightTexture:SetTexCoord(0.53125, 0.625, 0, 0.6875)
	
	self.MiddleTexture = self:CreateTexture(nil, "BACKGROUND")
	self.MiddleTexture:SetPoint("TOPLEFT", self.LeftTexture, "TOPRIGHT")
	self.MiddleTexture:SetPoint("BOTTOMLEFT", self.LeftTexture, "BOTTOMRIGHT")
	self.MiddleTexture:SetPoint("TOPRIGHT", self.RightTexture, "TOPLEFT")
	self.MiddleTexture:SetPoint("BOTTOMRIGHT", self.RightTexture, "BOTTOMLEFT")
	self.MiddleTexture:SetTexCoord(0.09375, 0.53125, 0, 0.6875)
	
	self.HighlightTexture = self:CreateTexture(nil, "HIGHLIGHT")
	self.HighlightTexture:SetAllPoints()
	self.HighlightTexture:SetTexCoord(0, 0.625, 0, 0.6875)
	self.HighlightTexture:SetBlendMode("ADD")
	
	self.Down = false
	self:UpdateButtonTexture()
	
	self:SetScript("OnMouseDown", function ()
		self.Down = true
		self:UpdateButtonTexture()
	end)
	
	self:SetScript("OnMouseUp", function ()
		self.Down = false
		self:UpdateButtonTexture()
	end)
end

function Addon.UIElementsLib._PushButton:SetEnabled(pEnabled)
	if pEnabled == self:IsEnabled() then
		return
	end
	
	if pEnabled then
		self:Enable()
	else
		self:Disable()
	end
end

function Addon.UIElementsLib._PushButton:SetTitle(pTitle)
	self.Text:SetText(pTitle)
end

function Addon.UIElementsLib._PushButton:Enable()
	self.Inherited.Enable(self)
	self:UpdateButtonTexture()
end

function Addon.UIElementsLib._PushButton:Disable()
	self.Inherited.Disable(self)
	self:UpdateButtonTexture()
end

function Addon.UIElementsLib._PushButton:IsEnabled()
	return self.Inherited.IsEnabled(self)
end

function Addon.UIElementsLib._PushButton:UpdateButtonTexture()
	if self:IsEnabled() then
		self:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
		self.HighlightTexture:SetTexture("Interface\\Buttons\\UI-Panel-Button-Highlight")
		
		if self.Down then
			self.LeftTexture:SetTexture("Interface\\Buttons\\UI-Panel-Button-Down")
			self.MiddleTexture:SetTexture("Interface\\Buttons\\UI-Panel-Button-Down")
			self.RightTexture:SetTexture("Interface\\Buttons\\UI-Panel-Button-Down")
		else
			self.LeftTexture:SetTexture("Interface\\Buttons\\UI-Panel-Button-Up")
			self.MiddleTexture:SetTexture("Interface\\Buttons\\UI-Panel-Button-Up")
			self.RightTexture:SetTexture("Interface\\Buttons\\UI-Panel-Button-Up")
		end
	else
		self:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
		self.HighlightTexture:SetTexture()
		
		if self.Down then
			self.LeftTexture:SetTexture("Interface\\Buttons\\UI-Panel-Button-Disabled-Down")
			self.MiddleTexture:SetTexture("Interface\\Buttons\\UI-Panel-Button-Disabled-Down")
			self.RightTexture:SetTexture("Interface\\Buttons\\UI-Panel-Button-Disabled-Down")
		else
			self.LeftTexture:SetTexture("Interface\\Buttons\\UI-Panel-Button-Disabled")
			self.MiddleTexture:SetTexture("Interface\\Buttons\\UI-Panel-Button-Disabled")
			self.RightTexture:SetTexture("Interface\\Buttons\\UI-Panel-Button-Disabled")
		end
	end
end

function Addon.UIElementsLib._PushButton:SetTextColor(pRed, pGreen, pBlue, pAlpha)
	self.Text:SetTextColor(pRed, pGreen, pBlue, pAlpha)
end

----------------------------------------
Addon.UIElementsLib._ScrollingEditBox = {}
----------------------------------------

function Addon.UIElementsLib._ScrollingEditBox:New(pParent, pLabel, pMaxLetters, pWidth, pHeight)
	return CreateFrame("Frame", nil, pParent)
end

Addon.UIElementsLib._ScrollingEditBox.InputFieldTextureInfo =
{
	TopLeft      = {Width =   5, Height =   5, Path = "Interface\\Common\\Common-Input-Border", Coords = {Left = 0, Right = 0.0390625, Top = 0, Bottom = 0.15625}},
	TopCenter    = {Width = 118, Height =   5, Path = "Interface\\Common\\Common-Input-Border", Coords = {Left = 0.0390625, Right = 0.9609375, Top = 0, Bottom = 0.15625}},
	TopRight     = {Width =   5, Height =   5, Path = "Interface\\Common\\Common-Input-Border", Coords = {Left = 0.9609375, Right = 1, Top = 0, Bottom = 0.15625}},
	MiddleLeft   = {Width =   5, Height =  10, Path = "Interface\\Common\\Common-Input-Border", Coords = {Left = 0, Right = 0.0390625, Top = 0.15625, Bottom = 0.46875}},
	MiddleCenter = {Width = 118, Height =  10, Path = "Interface\\Common\\Common-Input-Border", Coords = {Left = 0.0390625, Right = 0.9609375, Top = 0.15625, Bottom = 0.46875}},
	MiddleRight  = {Width =   5, Height =  10, Path = "Interface\\Common\\Common-Input-Border", Coords = {Left = 0.9609375, Right = 1, Top = 0.15625, Bottom = 0.46875}},
	BottomLeft   = {Width =   5, Height =   5, Path = "Interface\\Common\\Common-Input-Border", Coords = {Left = 0, Right = 0.0390625, Top = 0.46875, Bottom = 0.625}},
	BottomCenter = {Width = 118, Height =   5, Path = "Interface\\Common\\Common-Input-Border", Coords = {Left = 0.0390625, Right = 0.9609375, Top = 0.46875, Bottom = 0.625}},
	BottomRight  = {Width =   5, Height =   5, Path = "Interface\\Common\\Common-Input-Border", Coords = {Left = 0.9609375, Right = 1, Top = 0.46875, Bottom = 0.625}},
}

function Addon.UIElementsLib._ScrollingEditBox:Construct(pParent, pLabel, pMaxLetters, pWidth, pHeight)
	self.Enabled = true
	
	self:SetWidth(pWidth or 150)
	self:SetHeight(pHeight or 60)
	
	self.Title = self:CreateFontString(nil, "BACKGROUND", "GameFontNormalSmall")
	self.Title:SetJustifyH("RIGHT")
	self.Title:SetPoint("RIGHT", self, "TOPLEFT", -10, -9)
	self.Title:SetText(pLabel or "")
	
	self.BackgroundTextures = CreateFrame("Frame", nil, self)
	self.BackgroundTextures:SetPoint("TOPLEFT", self, "TOPLEFT", -4, 4)
	self.BackgroundTextures:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, -4)
	Addon.Inherit(self.BackgroundTextures, Addon.UIElementsLib._StretchTextures, self.InputFieldTextureInfo, self.BackgroundTextures, "BORDER")
	
	self.ScrollbarTrench = Addon:New(Addon.UIElementsLib._ScrollbarTrench, self)
	self.ScrollbarTrench:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 1)
	self.ScrollbarTrench:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, -2)
	
	self.Scrollbar = Addon:New(Addon.UIElementsLib._Scrollbar, self)
	self.Scrollbar:SetPoint("TOP", self.ScrollbarTrench, "TOP", 0, -19)
	self.Scrollbar:SetPoint("BOTTOM", self.ScrollbarTrench, "BOTTOM", 0, 17)
	self.Scrollbar:SetFrameLevel(self.ScrollbarTrench:GetFrameLevel() + 1)
	self.Scrollbar:SetScript("OnValueChanged", function (pScrollbar, pValue)
		self.ScrollFrame:SetVerticalScroll(pValue)
	end)
	
	--
	
	local vScrollFrameName = "MC2UIElementsLibScrollFrame"..MC2UIElementsLib.ScrollFrameIndex
	MC2UIElementsLib.ScrollFrameIndex = MC2UIElementsLib.ScrollFrameIndex + 1
	
	self.ScrollFrame = CreateFrame("ScrollFrame", vScrollFrameName, self)
	self.ScrollFrame:SetWidth(self:GetWidth() - self.ScrollbarTrench:GetWidth())
	self.ScrollFrame:SetHeight(self:GetHeight())
	self.ScrollFrame:SetPoint("TOPLEFT", self, "TOPLEFT")
	self.ScrollFrame:EnableMouseWheel(1)
	self.ScrollFrame:SetScript("OnVerticalScroll", function (pScrollFrame, pOffset)
		self.Scrollbar:SetValue(pOffset)
	end)
	self.ScrollFrame:SetScript("OnScrollRangeChanged", function (pScrollFrame, pHorizRange, pVertRange)
		if not pVertRange then
			pVertRange = self:GetVerticalScrollRange()
		end
		
		self.Scrollbar:SetMinMaxValues(0, pVertRange)

		local vValue = self.Scrollbar:GetValue()
		
		if vValue > pVertRange then
			vValue = pVertRange
			self.Scrollbar:SetValue(vValue)
		end
	end)
	self.ScrollFrame:SetScript("OnMouseWheel", function (pScrollFrame, pDelta)
		local vDistance = pScrollFrame:GetHeight() * 0.5
		local vValue = self.Scrollbar:GetValue()
		
		if pDelta > 0 then -- Scroll up
			self.Scrollbar:SetValue(vValue - vDistance)
		else
			self.Scrollbar:SetValue(vValue + vDistance)
		end
	end)
	
	--
	
	self.ScrollChildFrame = CreateFrame("Frame", nil, self.ScrollFrame)
	self.ScrollChildFrame:SetWidth(self.ScrollFrame:GetWidth())
	self.ScrollChildFrame:SetHeight(self.ScrollFrame:GetHeight())
	self.ScrollChildFrame:SetPoint("TOPLEFT", self.ScrollFrame, "TOPLEFT")
	self.ScrollChildFrame.TabParent = pParent
	
	self.EditBox = Addon:New(Addon.UIElementsLib._EditBox, self.ScrollChildFrame, nil, pMaxLetters or 200, self.ScrollChildFrame:GetWidth(), true)
	self.EditBox:SetHeight(self.ScrollChildFrame:GetHeight())
	self.EditBox:SetPoint("TOPLEFT", self.ScrollChildFrame, "TOPLEFT", 0, 0)
	self.EditBox:SetPoint("TOPRIGHT", self.ScrollChildFrame, "TOPRIGHT", 0, 0)
	self.EditBox:SetFontObject(ChatFontNormal)
	self.EditBox:SetMultiLine(true)
	self.EditBox:EnableMouse(true)
	self.EditBox:SetAutoFocus(false)
	Addon:HookScript(self.EditBox, "OnTextChanged", function (pEditBox)
		self:UpdateLimitText()
		ScrollingEdit_OnTextChanged(pEditBox, self.ScrollFrame)
	end)
	Addon:HookScript(self.EditBox, "OnCursorChanged", function (pEditBox, pCol, pRow, pWidth, pHeight)
		ScrollingEdit_OnCursorChanged(pEditBox, pCol, pRow - 10, pWidth, pHeight)
	end)
	Addon:HookScript(self.EditBox, "OnUpdate", function (pEditBox, pElapsed)
		ScrollingEdit_OnUpdate(pEditBox, pElapsed, self.ScrollFrame)
	end)

	self.ScrollFrame:SetScrollChild(self.ScrollChildFrame)
	
	self:EnableMouse(true)
	self:SetScript("OnMouseDown", function () if self.EditBox.Enabled then self.EditBox:SetFocus() end end)
end

function Addon.UIElementsLib._ScrollingEditBox:SetEnabled(pEnabled)
	self.Enabled = pEnabled
	self.EditBox:SetEnabled(pEnabled)
	
	self:SetAlpha(pEnabled and 1 or 0.5)
end

function Addon.UIElementsLib._ScrollingEditBox:GetText()
	return self.EditBox:GetText()
end

function Addon.UIElementsLib._ScrollingEditBox:SetText(pText)
	self.EditBox:SetText(pText)
end

function Addon.UIElementsLib._ScrollingEditBox:ShowLimitText()
	if self.LimitText then
		return
	end
	
	self.LimitText = self:CreateFontString(nil, "BACKGROUND", "GameFontNormalSmall")
	self.LimitText:SetJustifyH("RIGHT")
	self.LimitText:SetPoint("TOPRIGHT", self.Title, "BOTTOMRIGHT")
	
	self:UpdateLimitText()
end

function Addon.UIElementsLib._ScrollingEditBox:UpdateLimitText()
	if not self.LimitText then
		return
	end
	
	local vCurLength = self:GetText():len()
	local vMaxLength = self.EditBox:GetMaxLetters()
	
	self.LimitText:SetText(vCurLength.."/"..vMaxLength)

	-- Figure out the amount used in the description and color progress based on percentage
	
	local vPercentUsed = vCurLength / vMaxLength
	
	if vPercentUsed <= 0.75 then
		self.LimitText:SetVertexColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif vCurLength < vMaxLength then
		self.LimitText:SetVertexColor(0.9, 0.9, 0.05) -- Yellow
	else
		self.LimitText:SetVertexColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	end
end

function Addon.UIElementsLib._ScrollingEditBox:ClearFocus()
	self.EditBox:ClearFocus()
end

----------------------------------------
Addon.UIElementsLib._ProgressBar = {}
----------------------------------------

function Addon.UIElementsLib._ProgressBar:New(pParent)
	return CreateFrame("StatusBar", nil, pParent)
end

function Addon.UIElementsLib._ProgressBar:Construct()
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

function Addon.UIElementsLib._ProgressBar:SetText(pText)
	self.LabelText:SetText(pText)
end

function Addon.UIElementsLib._ProgressBar:SetProgress(pProgress)
	if pProgress then
		self:SetValue(pProgress)
	else
		self:SetValue(0)
	end
end

----------------------------------------
Addon.UIElementsLib._PowerDot = {}
----------------------------------------

function Addon.UIElementsLib._PowerDot:New(pParent)
	return CreateFrame("Frame", nil, pParent)
end

function Addon.UIElementsLib._PowerDot:Construct(pParent)
	local vAlphaAnimation
	
	self.Value = nil
	
	self:SetWidth(21)
	self:SetHeight(21)
	
	self.BackgroundTexture = self:CreateTexture(nil, "BACKGROUND")
	self.BackgroundTexture:SetTexture("Interface\\PlayerFrame\\MonkUI")
	self.BackgroundTexture:SetTexCoord(0.09375000, 0.17578125, 0.71093750, 0.87500000)
	self.BackgroundTexture:SetWidth(21)
	self.BackgroundTexture:SetHeight(21)
	self.BackgroundTexture:SetPoint("CENTER", self, "CENTER", 0, 0)

	self.OnTexture = self:CreateTexture(nil, "ARTWORK")
	self.OnTexture:SetTexture("Interface\\PlayerFrame\\MonkUI")
	self.OnTexture:SetTexCoord(0.00390625, 0.08593750, 0.71093750, 0.87500000)
	self.OnTexture:SetWidth(21)
	self.OnTexture:SetHeight(21)
	self.OnTexture:SetPoint("CENTER", self, "CENTER", 0, 0)
	self.OnTexture:SetAlpha(0) -- initially off
	
	-- Fade in
	self.activate = self.OnTexture:CreateAnimationGroup("activate")
	vAlphaAnimation = self.activate:CreateAnimation("Alpha")
	vAlphaAnimation:SetFromAlpha(0)
	vAlphaAnimation:SetToAlpha(1)
	vAlphaAnimation:SetDuration(0.2)
	vAlphaAnimation:SetOrder(1)
	
	-- Fade out
	self.deactivate = self.OnTexture:CreateAnimationGroup("deactivate")
	vAlphaAnimation = self.deactivate:CreateAnimation("Alpha")
	vAlphaAnimation:SetFromAlpha(1)
	vAlphaAnimation:SetToAlpha(0)
	vAlphaAnimation:SetDuration(0.3)
	vAlphaAnimation:SetOrder(2)
end

function Addon.UIElementsLib._PowerDot:SetValue(pValue)
	-- normalize the value
	pValue = pValue and true or nil
	
	-- return if the value isn't changing
	if pValue == self.Value then return end
	
	if pValue then
		if self.deactivate:IsPlaying() then self.deactivate:Stop() end
		if not self.activate:IsPlaying() then self.activate:Play() end
	else
		if self.activate:IsPlaying() then self.activate:Stop() end
		if not self.deactivate:IsPlaying() then self.deactivate:Play() end
	end
end

----------------------------------------
Addon.UIElementsLib._PowerDots = {}
----------------------------------------

function Addon.UIElementsLib._PowerDots:New(pParent)
	return CreateFrame("Frame", nil, pParent)
end

function Addon.UIElementsLib._PowerDots:Construct()
	self.MaxValue = 0
	self.Dots = {}
end

function Addon.UIElementsLib._PowerDots:SetMax(pMax)
	self.MaxValue = pMax
	while #self.Dots < self.MaxValue do
		table.insert(self.Dots, Addon:New(Addon.UIElementsLib._PowerDot, self))
	end
	self:LayoutDots()
end

function Addon.UIElementsLib._PowerDots:LayoutDots()
	local vLeft = 0
	local vSpacing = 5
	for vIndex = 1, self.MaxValue do
		local vDot = self.Dots[vIndex]
		vDot:ClearAllPoints()
		vDot:SetPoint("LEFT", self, "LEFT", vLeft, 0)
		vDot:Show()
		vLeft = vLeft + vDot:GetWidth() + vSpacing
	end
	-- Hide unused dots
	for vIndex = self.MaxValue + 1, #self.Dots do
		self.Dots[vIndex]:Hide()
	end 
end

function Addon.UIElementsLib._PowerDots:SetValue(pValue)
	for vIndex = 1, self.MaxValue do
		local vDot = self.Dots[vIndex]
		vDot:SetValue(vIndex <= pValue)
	end
end
