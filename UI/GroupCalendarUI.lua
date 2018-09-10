----------------------------------------
-- Group Calendar 5 Copyright 2005 - 2016 John Stephen, wobbleworks.com
-- All rights reserved, unauthorized redistribution is prohibited
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

function GroupCalendar.UI:CalendarUpdateError(pMessage)
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
	
	StaticPopup_Show("CALENDAR_ERROR", pMessage)
end

table.insert(GroupCalendar.CommandHelp, HIGHLIGHT_FONT_COLOR_CODE.."/cal show"..NORMAL_FONT_COLOR_CODE.." "..GroupCalendar.cHelpShow)

function GroupCalendar.Commands:show()
	ShowUIPanel(self.UI.Window)
end

----------------------------------------
GroupCalendar.Themes = {}
----------------------------------------

GroupCalendar.DefaultThemeID = "LEGION"

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

GroupCalendar.Themes.LEGION =
{
	Name = "Legion",
	Background =
	{
		GroupCalendar.UI.AddonPath.."Textures\\January", -- Jan
		GroupCalendar.UI.AddonPath.."Textures\\February", -- Feb
		GroupCalendar.UI.AddonPath.."Textures\\March", -- Mar
		GroupCalendar.UI.AddonPath.."Textures\\April", -- Apr
		GroupCalendar.UI.AddonPath.."Textures\\May", -- May
		GroupCalendar.UI.AddonPath.."Textures\\June", -- Jun
		GroupCalendar.UI.AddonPath.."Textures\\July", -- Jul
		GroupCalendar.UI.AddonPath.."Textures\\August", -- Aug
		GroupCalendar.UI.AddonPath.."Textures\\September", -- Sep
		GroupCalendar.UI.AddonPath.."Textures\\October", -- Oct
		GroupCalendar.UI.AddonPath.."Textures\\November", -- Nov
		GroupCalendar.UI.AddonPath.."Textures\\December", -- Dec
	},
	Foreground = GroupCalendar.UI.AddonPath.."Textures\\DayFrameFront-Square",
	RandomTile = false,
	UseShading = false,
	BackgroundBrightness = 0.3,
}

----------------------------------------
--
----------------------------------------

GroupCalendar.EventLib:RegisterEvent("GROUPCALENDAR_INIT", GroupCalendar.UI.Initialize, GroupCalendar.UI)
