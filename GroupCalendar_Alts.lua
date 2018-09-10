----------------------------------------
-- Group Calendar 5 Copyright 2005 - 2016 John Stephen, wobbleworks.com
-- All rights reserved, unauthorized redistribution is prohibited
----------------------------------------

GroupCalendar._Alts = {}

function GroupCalendar._Alts:Construct()
	--self:InstallAltMail()
end

function GroupCalendar._Alts:InstallAltMail()
	if self.Orig_GetAutoCompleteResults then
		return
	end
	
	self.Orig_GetAutoCompleteResults = GetAutoCompleteResults
	GetAutoCompleteResults = function (...) return self:GetAutoCompleteResults(...) end
end

function GroupCalendar._Alts:UninstallAltMail()
	if not self.Orig_GetAutoCompleteResults then
		return
	end
	
	GetAutoCompleteResults = self.Orig_GetAutoCompleteResults
	self.Orig_GetAutoCompleteResults = nil
end

function GroupCalendar._Alts:GetAutoCompleteResults(pText, pInclude, pExclude, pMaxResults, pCursorPosition, ...)
	local vResults = {self.Orig_GetAutoCompleteResults(pText, pInclude, pExclude, pMaxResults, pCursorPosition, ...)}
	
	if true or bit.band(pInclude, AUTOCOMPLETE_FLAG_FRIEND) then
		local vText
		
		if pCursorPosition then
			vText = pText:utf8sub(1, pCursorPosition):utf8upper()
		else
			vText = pText:utf8upper()
		end
		
		local vTextLength = vText:utf8len()
		local vFaction = UnitFactionGroup("player")
		
		for vCharacterGUID, vCharacterInfo in pairs(GroupCalendar.RealmData.Characters) do
			if vCharacterInfo.Faction == vFaction
			and vText == vCharacterInfo.Name:utf8upper():utf8sub(1, vTextLength) then
				table.insert(vResults, 1, vCharacterInfo.Name)
				
				-- Remove extra instances of the same name
				
				for vIndex, vName in ipairs(vResults) do
					if vIndex > 1 and vName == vCharacterInfo.Name then
						table.remove(vResults, vIndex)
						break
					end
				end
			end
		end
	end
	
	while #vResults > pMaxResults do
		table.remove(vResults, #vResults)
	end
	
	return unpack(vResults)
end
