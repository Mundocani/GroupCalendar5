----------------------------------------
-- Group Calendar 5 Copyright 2005 - 2016 John Stephen, wobbleworks.com
-- All rights reserved, unauthorized redistribution is prohibited
----------------------------------------

----------------------------------------
GroupCalendar.UI._ExportView = {}
----------------------------------------

function GroupCalendar.UI._ExportView:New(pParent)
	return CreateFrame("Frame", nil, pParent)
end

function GroupCalendar.UI._ExportView:Construct(pParent)
	self.Title = self:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	self.Title:SetPoint("TOP", self, "TOP", 17, -7)
	self.Title:SetText(GroupCalendar.cExportTitle)
	
	self.SummaryText = self:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	self.SummaryText:SetPoint("TOP", self, "TOP", 0, -50)
	self.SummaryText:SetWidth(430)
	self.SummaryText:SetJustifyH("CENTER")
	self.SummaryText:SetText(GroupCalendar.cExportSummary)
	
	self.InstructionsText = self:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	self.InstructionsText:SetPoint("TOP", self.SummaryText, "BOTTOM", 0, -15)
	self.InstructionsText:SetWidth(400)
	self.InstructionsText:SetJustifyH("LEFT")
	self.InstructionsText:SetText(table.concat(GroupCalendar.cExportInstructions, FONT_COLOR_CODE_CLOSE.."\r\n\r\n"))
	
	self.IncludeGuildEvents = GroupCalendar:New(GroupCalendar.UIElementsLib._CheckButton, self, GroupCalendar.cGuildEvents)
	self.IncludeGuildEvents:SetPoint("TOPLEFT", self.InstructionsText, "BOTTOMLEFT", -30, -15)
	self.IncludeGuildEvents:SetScript("OnClick", function (pCheckButton)
		GroupCalendar.Data.Prefs.ExportGuildEvents = pCheckButton:GetChecked() ~= nil
		self:Refresh()
	end)

	self.IncludeHolidays = GroupCalendar:New(GroupCalendar.UIElementsLib._CheckButton, self, GroupCalendar.cHolidays)
	self.IncludeHolidays:SetPoint("TOPLEFT", self.IncludeGuildEvents, "TOPLEFT", 0, -30)
	self.IncludeHolidays:SetScript("OnClick", function (pCheckButton)
		GroupCalendar.Data.Prefs.ExportHolidays = pCheckButton:GetChecked() ~= nil
		self:Refresh()
	end)

	self.IncludePrivateEvents = GroupCalendar:New(GroupCalendar.UIElementsLib._CheckButton, self, GroupCalendar.cPrivateEvents)
	self.IncludePrivateEvents:SetPoint("TOPLEFT", self.IncludeGuildEvents, "TOPLEFT", 180, 0)
	self.IncludePrivateEvents:SetScript("OnClick", function (pCheckButton)
		GroupCalendar.Data.Prefs.ExportPrivateEvents = pCheckButton:GetChecked() ~= nil
		self:Refresh()
	end)

	self.IncludeTradeskills = GroupCalendar:New(GroupCalendar.UIElementsLib._CheckButton, self, GroupCalendar.cTradeskills)
	self.IncludeTradeskills:SetPoint("TOPLEFT", self.IncludePrivateEvents, "TOPLEFT", 0, -30)
	self.IncludeTradeskills:SetScript("OnClick", function (pCheckButton)
		GroupCalendar.Data.Prefs.ExportTradeskillCooldowns = pCheckButton:GetChecked() ~= nil
		self:Refresh()
	end)

	self.IncludeAltEvents = GroupCalendar:New(GroupCalendar.UIElementsLib._CheckButton, self, GroupCalendar.cAlts)
	self.IncludeAltEvents:SetPoint("TOPLEFT", self.IncludePrivateEvents, "TOPLEFT", 180, 0)
	self.IncludeAltEvents:SetScript("OnClick", function (pCheckButton)
		GroupCalendar.Data.Prefs.ExportAltEvents = pCheckButton:GetChecked() ~= nil
		self:Refresh()
	end)

	self.IncludePersonalEvents = GroupCalendar:New(GroupCalendar.UIElementsLib._CheckButton, self, GroupCalendar.cPersonalEvents)
	self.IncludePersonalEvents:SetPoint("TOPLEFT", self.IncludeAltEvents, "TOPLEFT", 0, -30)
	self.IncludePersonalEvents:SetScript("OnClick", function (pCheckButton)
		GroupCalendar.Data.Prefs.ExportPersonalEvents = pCheckButton:GetChecked() ~= nil
		self:Refresh()
	end)

	self.ExportData = GroupCalendar:New(GroupCalendar.UIElementsLib._ScrollingEditBox, self, GroupCalendar.cExportData, 32000, 400, 150)
	self.ExportData:SetPoint("TOPLEFT", self.IncludeHolidays, "TOPLEFT", 50, -50)
	self.ExportData.EditBox:SetFontObject(GameFontHighlightSmall)
	
	self:SetScript("OnShow", self.Refresh)
end

function GroupCalendar.UI._ExportView:Refresh()
	self.IncludePrivateEvents:SetChecked(GroupCalendar.Data.Prefs.ExportPrivateEvents)
	self.IncludeGuildEvents:SetChecked(GroupCalendar.Data.Prefs.ExportGuildEvents)
	self.IncludeHolidays:SetChecked(GroupCalendar.Data.Prefs.ExportHolidays)
	self.IncludeTradeskills:SetChecked(GroupCalendar.Data.Prefs.ExportTradeskillCooldowns)
	self.IncludeAltEvents:SetChecked(GroupCalendar.Data.Prefs.ExportAltEvents)
	self.IncludePersonalEvents:SetChecked(GroupCalendar.Data.Prefs.ExportPersonalEvents)
	
	local vData = GroupCalendar.iCal:GetReport("GETTEXT")
	
	if type(vData) == "table" then
		vData = table.concat(vData, "\r\n")
	end
	
	self.ExportData:SetText(vData)
	self.ExportData.EditBox:SetFocus()
	self.ExportData.EditBox:HighlightText()
end
