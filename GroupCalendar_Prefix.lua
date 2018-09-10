----------------------------------------
-- Group Calendar 5 Copyright 2005 - 2016 John Stephen, wobbleworks.com
-- All rights reserved, unauthorized redistribution is prohibited
----------------------------------------

if GroupCalendar then
	error("You must disable previous versions of Group Calendar in order to run Group Calendar 5")
end

local AddonName
AddonName, GroupCalendar = ...

-- Check for attempts to upgrade when there are new files
if tonumber(GetAddOnMetadata(AddonName, "X-ReloadTag")) ~= 2 then
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
