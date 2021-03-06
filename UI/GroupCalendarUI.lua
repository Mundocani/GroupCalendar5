----------------------------------------
-- Group Calendar 5 Copyright (c) 2018 John Stephen
-- This software is licensed under the MIT license.
-- See the included LICENSE.txt file for more information.
----------------------------------------

GroupCalendar.UI =
{
	AddonPath = GroupCalendar.AddonPath,
}

function GroupCalendar.UI:ShowConfirmDeleteEvent(pAcceptFunc)
	if not StaticPopupDialogs.GC5_CONFIRM_DELETE_EVENT then
		StaticPopupDialogs.GC5_CONFIRM_DELETE_EVENT =
		{
			preferredIndex = 3,
			text = GroupCalendar.cConfirmDelete,
			button1 = OKAY,
			button2 = CANCEL,
			whileDead = 1,
			OnAccept = function (self) end,
			timeout = 0,
			hideOnEscape = 1,
			enterClicksFirstButton = 1,
		}
	end
	StaticPopupDialogs.GC5_CONFIRM_DELETE_EVENT.OnAccept = pAcceptFunc
	StaticPopup_Show("GC5_CONFIRM_DELETE_EVENT")
end

function GroupCalendar.UI:Initialize()
	self.Window = GroupCalendar:New(GroupCalendar.UI._Window)

	--SlashCmdList.CALENDAR = SlashCmdList.CAL
	--SLASH_CALENDAR1 = "/calendar"
	
	-- Prevent the Blizzard calendar from loading
	
	--function Calendar_LoadUI()
	--	return
	--end
	
	GameTimeFrame:SetScript("OnClick", function (pFrame, pButton, ...)
		if pButton == "RightButton" then
			if IsModifierKeyDown() then
				ToggleTimeManager()
			else
				SlashCmdList.CALENDAR("") -- Issue a fake /calendar command to toggle the Blizzard calendar (handles loading the addon)
			end
		else
			if GroupCalendar.UI.Window:IsShown() then
				GroupCalendar.UI.Window:Hide()
			else
				GroupCalendar.UI.Window:Show()
			end
		end
	end)
	
	--
	
	self.ClassLimitsDialog = GroupCalendar:New(GroupCalendar.UI._ClassLimitsDialog, UIParent)
	self.ClassLimitsDialog:SetPoint("TOP", UIParent, "TOP", 0, -200)
	self.ClassLimitsDialog:Hide()
	
	self.RoleLimitsDialog = GroupCalendar:New(GroupCalendar.UI._RoleLimitsDialog, UIParent)
	self.RoleLimitsDialog:SetPoint("TOP", UIParent, "TOP", 0, -200)
	self.RoleLimitsDialog:Hide()
	
	GroupCalendar.EventLib:RegisterEvent("CALENDAR_UPDATE_ERROR", self.CalendarUpdateError, self, true)
end

function GroupCalendar.UI:CalendarUpdateError(message)
	if not StaticPopupDialogs.CALENDAR_ERROR then
		StaticPopupDialogs.CALENDAR_ERROR =
		{
			preferredIndex = 3,
			text = CALENDAR_ERROR,
			button1 = OKAY,
			whileDead = 1,
			timeout = 0,
			showAlert = 1,
			hideOnEscape = 1,
			enterClicksFirstButton = 1,
		}
	end
	
	local localizedMessage = _G[message] or message
	StaticPopup_Show("CALENDAR_ERROR", localizedMessage)
end

table.insert(GroupCalendar.CommandHelp, HIGHLIGHT_FONT_COLOR_CODE.."/cal show"..NORMAL_FONT_COLOR_CODE.." "..GroupCalendar.cHelpShow)

function GroupCalendar.Commands:show()
	ShowUIPanel(self.UI.Window)
end

----------------------------------------
GroupCalendar.Themes = {}
----------------------------------------

GroupCalendar.DefaultThemeID = "BFA"

GroupCalendar.Themes.PARCHMENT =
{
	Name = GroupCalendar.cParchmentThemeName,
	Background = GroupCalendar.UI.AddonPath.."Textures\\DayFrameBack",
	Foreground = GroupCalendar.UI.AddonPath.."Textures\\DayFrameFront",
	TilesH = 2,
	TilesV = 2,
	RandomTile = true,
	UseShading = true,
	BackgroundBrightness = 1,
}

GroupCalendar.Themes.LIGHT_PARCHMENT =
{
	Name = GroupCalendar.cLightParchmentThemeName,
	Background = GroupCalendar.UI.AddonPath.."Textures\\DayFrameBrightBack",
	Foreground = GroupCalendar.UI.AddonPath.."Textures\\DayFrameFront",
	TilesH = 2,
	TilesV = 2,
	RandomTile = true,
	UseShading = true,
	BackgroundBrightness = 1,
}

GroupCalendar.Themes.BFA =
{
	Name = "Battle for Azeroth",
	Background =
	{
		GroupCalendar.UI.AddonPath.."Textures\\BfA\\BfA_Winter_2", -- Jan
		GroupCalendar.UI.AddonPath.."Textures\\BfA\\BfA_Winter_3", -- Feb
		GroupCalendar.UI.AddonPath.."Textures\\BfA\\BfA_Spring_1", -- Mar
		GroupCalendar.UI.AddonPath.."Textures\\BfA\\BfA_Spring_2", -- Apr
		GroupCalendar.UI.AddonPath.."Textures\\BfA\\BfA_Spring_3", -- May
		GroupCalendar.UI.AddonPath.."Textures\\BfA\\BfA_Summer_1", -- Jun
		GroupCalendar.UI.AddonPath.."Textures\\BfA\\BfA_Summer_2", -- Jul
		GroupCalendar.UI.AddonPath.."Textures\\BfA\\BfA_Summer_3", -- Aug
		GroupCalendar.UI.AddonPath.."Textures\\BfA\\BfA_Autumn_1", -- Sep
		GroupCalendar.UI.AddonPath.."Textures\\BfA\\BfA_Autumn_2", -- Oct
		GroupCalendar.UI.AddonPath.."Textures\\BfA\\BfA_Autumn_3", -- Nov
		GroupCalendar.UI.AddonPath.."Textures\\BfA\\BfA_Winter_1", -- Dec
	},
	Foreground = GroupCalendar.UI.AddonPath.."Textures\\DayFrameFront-Square",
	RandomTile = false,
	UseShading = false,
	BackgroundBrightness = 0.25,
}

----------------------------------------
--
----------------------------------------

GroupCalendar.EventLib:RegisterCustomEvent("GC5_INIT", GroupCalendar.UI.Initialize, GroupCalendar.UI)
