----------------------------------------
-- Group Calendar 5 Copyright (c) 2018 John Stephen
-- This software is licensed under the MIT license.
-- See the included LICENSE.txt file for more information.
----------------------------------------

if GroupCalendar then
	error("You must disable previous versions of Group Calendar in order to run Group Calendar 5")
end

local AddonName
AddonName, GroupCalendar = ...

-- Check for attempts to upgrade when there are new files
if tonumber(GetAddOnMetadata(AddonName, "X-ReloadTag")) ~= 3 then
	StaticPopupDialogs.GC5_CANT_RELOADUI =
	{
		text = "You must completely restart WoW to upgrade to this version of Group Calendar",
		button1 = OKAY,
		OnAccept = function() end,
		OnCancel = function() end,
		timeout = 0,
		whileDead = 1,
		hideOnEscape = 1,
		showAlert = 1,
	}
	StaticPopup_Show("GC5_CANT_RELOADUI")
	error(StaticPopupDialogs.GC5_CANT_RELOADUI.text)
end


GroupCalendar.DebugColorCode = "|cffcc88ff"
GroupCalendar.Debug = {}
GroupCalendar.Clock = {}
GroupCalendar.RAID_CLASS_COLOR_CODES = {}
for vClassID, vColor in pairs(RAID_CLASS_COLORS) do
	GroupCalendar.RAID_CLASS_COLOR_CODES[vClassID] = string.format("|cff%02x%02x%02x", vColor.r * 255 + 0.5, vColor.g * 255 + 0.5, vColor.b * 255 + 0.5)
end
