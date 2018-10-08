local gAddonName = ...

GroupCalendarClock_Data = nil

if not GroupCalendar.cHelpClock then
	GroupCalendar.cHelpClock = "Sets the minimap clock to display local time or server time"
end

function GroupCalendar.Clock:Initialize()
	if not GroupCalendarClock_Data then
		GroupCalendarClock_Data =
		{
			ShowLocalTime = false,
			HideMinimapClock = false
		}
	end
	
	self.Data = GroupCalendarClock_Data
	
	self.Frame = GroupCalendar:New(GroupCalendar._Clock, 40, GameTimeFrame, -1, 1, true, true)
	self.Frame:SetShowLocalTime(self.Data.ShowLocalTime)
	if self.Data.HideMinimapClock then
		self.Frame:Hide()
	end
end

function GroupCalendar.Clock:PrefsChanged()
	if self.Data.HideMinimapClock then
		self.Frame:Hide()
	else
		self.Frame:Show()
	end
end

function GroupCalendar:HookScript(pFrame, pScriptID, pFunction)
	if not pFrame:GetScript(pScriptID) then
		pFrame:SetScript(pScriptID, pFunction)
	else
		pFrame:HookScript(pScriptID, pFunction)
	end
end

----------------------------------------
-- /cal
----------------------------------------

if not GroupCalendar.InstallSlashCommand then
	function GroupCalendar:InstallSlashCommand()
		SlashCmdList.CAL = function (...) GroupCalendar:ExecuteCommand(...) end
		SLASH_CAL1 = "/cal"
	end

	function GroupCalendar:ExecuteCommand(pCommandString, ...)
		local _, _, vCommand, vParameter = string.find(pCommandString, "([^%s]+) ?(.*)")
		local vCommandFunc = self.Commands[strlower(vCommand or "help")] or self.Commands.help
		
		vCommandFunc(self, vParameter)
	end
	
	GroupCalendar.CommandHelp = {}
	GroupCalendar.Commands = {}
end

if GroupCalendar.EventLib then
	GroupCalendar.EventLib:RegisterCustomEvent("GC5_INIT", function () GroupCalendar.Clock:Initialize() end)
	GroupCalendar.EventLib:RegisterCustomEvent("GC5_PREFS_CHANGED", GroupCalendar.Clock.PrefsChanged, GroupCalendar.Clock)
else
	GroupCalendar:HookScript(GameTimeFrame, "OnEvent", function (pFrame, pEventID, pAddonName) if pEventID == "ADDON_LOADED" and pAddonName == gAddonName then GroupCalendar.Clock:Initialize() end end)
	GameTimeFrame:RegisterEvent("ADDON_LOADED")
end

----------------------------------------
-- Commands
----------------------------------------

table.insert(GroupCalendar.CommandHelp, HIGHLIGHT_FONT_COLOR_CODE.."/cal clock [local|server]"..NORMAL_FONT_COLOR_CODE.." "..GroupCalendar.cHelpClock)

function GroupCalendar.Commands:clock(pParam)
	local vParam = pParam:lower()
	
	if vParam == "local" then
		self.Clock.Data.ShowLocalTime = true
	elseif vParam == "server" then
		self.Clock.Data.ShowLocalTime = false
	elseif vParam == "on" then
		self.Clock.Data.HideMinimapClock = false
	elseif vParam == "off" then
		self.Clock.Data.HideMinimapClock = true
	end
	
	if GroupCalendar.EventLib then
		GroupCalendar.EventLib:DispatchEvent("GC5_PREFS_CHANGED")
	end
end
