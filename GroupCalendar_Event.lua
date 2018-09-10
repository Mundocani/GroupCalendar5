----------------------------------------
-- Group Calendar 5 Copyright 2005 - 2016 John Stephen, wobbleworks.com
-- All rights reserved, unauthorized redistribution is prohibited
----------------------------------------

----------------------------------------
-- Limits
----------------------------------------

GroupCalendar.DefaultLimits =
{
	[40] =
	{
		ClassLimits =
		{
			P = {Min = 4, Max = 6},
			R = {Min = 4, Max = 6},
			D = {Min = 4, Max = 6},
			W = {Min = 4, Max = 6},
			H = {Min = 4, Max = 6},
			K = {Min = 4, Max = 6},
			M = {Min = 4, Max = 6},
			L = {Min = 4, Max = 6},
			S = {Min = 4, Max = 6},
		},
		
		RoleLimits =
		{
			H = {Min = 4, Max = 10},
			T = {Min = 4, Max = 8},
			R = {Min = 5, Max = 27},
			M = {Min = 5, Max = 27},
		},
		
		MaxAttendance = 40,
	},
	[25] =
	{
		ClassLimits =
		{
			P = {Min = 2, Max = 4},
			R = {Min = 2, Max = 4},
			D = {Min = 2, Max = 4},
			W = {Min = 2, Max = 4},
			H = {Min = 2, Max = 4},
			K = {Min = 2, Max = 4},
			M = {Min = 2, Max = 4},
			L = {Min = 2, Max = 4},
			S = {Min = 2, Max = 4},
		},
		
		RoleLimits =
		{
			H = {Min = 4, Max = 6},
			T = {Min = 4, Max = 6},
			R = {Min = 4, Max = 14},
			M = {Min = 4, Max = 14},
		},
		
		MaxAttendance = 25,
	},
	[20] =
	{
		ClassLimits =
		{
			P = {Min = 2, Max = 3},
			R = {Min = 2, Max = 3},
			D = {Min = 2, Max = 3},
			W = {Min = 2, Max = 3},
			H = {Min = 2, Max = 3},
			K = {Min = 2, Max = 3},
			M = {Min = 2, Max = 3},
			L = {Min = 2, Max = 3},
			S = {Min = 2, Max = 3},
		},
		
		RoleLimits =
		{
			H = {Min = 3, Max = 6},
			T = {Min = 3, Max = 6},
			R = {Min = 2, Max = 6},
			M = {Min = 2, Max = 6},
		},
		
		MaxAttendance = 20,
	},
	[15] =
	{
		ClassLimits =
		{
			P = {Min = 1, Max = 3},
			R = {Min = 1, Max = 3},
			D = {Min = 1, Max = 3},
			W = {Min = 1, Max = 3},
			H = {Min = 1, Max = 3},
			K = {Min = 1, Max = 3},
			M = {Min = 1, Max = 3},
			L = {Min = 1, Max = 3},
			S = {Min = 1, Max = 3},
		},
		
		RoleLimits =
		{
			H = {Min = 3, Max = 4},
			T = {Min = 3, Max = 4},
			R = {Min = 2, Max = 4},
			M = {Min = 2, Max = 4},
		},
		
		MaxAttendance = 15,
	},
	[10] =
	{
		ClassLimits =
		{
			P = {Min = 1, Max = 2},
			R = {Min = 1, Max = 2},
			D = {Min = 1, Max = 2},
			W = {Min = 1, Max = 2},
			H = {Min = 1, Max = 2},
			K = {Min = 1, Max = 2},
			M = {Min = 1, Max = 2},
			L = {Min = 1, Max = 2},
			S = {Min = 1, Max = 2},
		},
		
		RoleLimits =
		{
			H = {Min = 2, Max = 3},
			T = {Min = 2, Max = 3},
			R = {Min = 2, Max = 3},
			M = {Min = 2, Max = 3},
		},
		
		MaxAttendance = 10,
	},
	[5] =
	{
		ClassLimits =
		{
			P = {Max = 1},
			R = {Max = 1},
			D = {Max = 1},
			W = {Max = 1},
			H = {Max = 1},
			K = {Max = 1},
			M = {Max = 1},
			L = {Max = 1},
			S = {Max = 1},
		},
		
		RoleLimits =
		{
			H = {Min = 1, Max = 1},
			T = {Min = 1, Max = 1},
			R = {Min = 1, Max = 2},
			M = {Min = 1, Max = 2},
		},
		
		MaxAttendance = 5,
	},
}

----------------------------------------
--
----------------------------------------

function GroupCalendar:LimitsAreEqual(pOldLimits, pNewLimits)
	if (pNewLimits == nil) ~= (pOldLimits == nil) then	
		return false
	end
	
	if not pNewLimits then
		return true
	end
	
	-- Not the same if max attendance changed
	
	if pNewLimits.MaxAttendance ~= pOldLimits.MaxAttendance then
		return false
	end
	
	-- Not the same if their limits modes don't match
	
	if ((pNewLimits.ClassLimits == nil) ~= (pOldLimits.ClassLimits == nil))
	or ((pNewLimits.RoleLimits == nil) ~= (pOldLimits.RoleLimits == nil)) then
		return false
	end
	
	if pNewLimits.ClassLimits then
		for vClassID, vClassInfo in pairs(GroupCalendar.ClassInfoByClassID) do
			local vNewClassLimits = pNewLimits.ClassLimits[vClassID]
			local vOldClassLimits = pOldLimits.ClassLimits[vClassID]
			
			if (vNewClassLimits == nil) ~= (vOldClassLimits == nil) then
				return false
			end
			
			if vNewClassLimits then
				if vNewClassLimits.Min ~= vOldClassLimits.Min
				or vNewClassLimits.Max ~= vOldClassLimits.Max then
					return false
				end
			end
		end
	end
	
	if pNewLimits.RoleLimits then
		for vRoleCode, vRoleInfo in pairs(GroupCalendar.RolesInfoByID) do
			local vNewRoleLimits = pNewLimits.RoleLimits[vRoleCode]
			local vOldRoleLimits = pOldLimits.RoleLimits[vRoleCode]
			
			if (vNewRoleLimits == nil) ~= (vOldRoleLimits == nil) then
				return false
			end
			
			if vNewRoleLimits then
				if vNewRoleLimits.Min ~= vOldRoleLimits.Min
				or vNewRoleLimits.Max ~= vOldRoleLimits.Max
				or (vNewRoleLimits.Class == nil) ~= (vOldRoleLimits.Class == nil) then
					return false
				end
				
				if vNewRoleLimits.Class then
					for vClassID, vClassInfo in pairs(GroupCalendar.ClassInfoByClassID) do
						local vNewClassLimit = vNewRoleLimits.Class[vClassID]
						local vOldClassLimit = vOldRoleLimits.Class[vClassID]
						
						if vNewClassLimit ~= vOldClassLimit then
							return false
						end
					end
				end
			end
		end
	end
	
	-- Done, they're the same
	
	return true
end

----------------------------------------
-- Classes
----------------------------------------

GroupCalendar.ClassInfoByClassID =
{
	DRUID =
	{
		ClassCode = "D",
		Roles = {"H", "T", "M", "R"},
		TalentRoles = {"R", "M", "H"}, -- Balance, Feral, Restoration
		DefaultRole = "M",
	},
	HUNTER =
	{
		ClassCode = "H",
		Roles = {"R"},
		TalentRoles = {"R", "R", "R"}, -- Beast mastery, Marksmanship, Survival
		DefaultRole = "R",
	},
	MAGE =
	{
		ClassCode = "M",
		Roles = {"R"},
		TalentRoles = {"R", "R", "R"}, -- Frost, Arcane, Fire
		DefaultRole = "R",
	},
	PALADIN =
	{
		ClassCode = "L",
		Roles = {"H", "T", "M"},
		TalentRoles = {"H", "T", "M"}, -- Holy, Protection, Retribution
		DefaultRole = "H",
	},
	PRIEST =
	{
		ClassCode = "P",
		Roles = {"H", "R"},
		TalentRoles = {"H", "H", "R"}, -- Discipline, Holy, Shadow
		DefaultRole = "H",
	},
	ROGUE =
	{
		ClassCode = "R",
		Roles = {"M"},
		TalentRoles = {"M", "M", "M"}, -- Assassination, Combat, Subtlety
		DefaultRole = "M",
	},
	SHAMAN =
	{
		ClassCode = "S",
		Roles = {"H", "M", "R"},
		TalentRoles = {"R", "M", "H"}, -- Elemental, Enhancement, Restoration
		DefaultRole = "H",
	},
	WARLOCK =
	{
		ClassCode = "K",
		Roles = {"R"},
		TalentRoles = {"R", "R", "R"}, -- Affliction, Demonology, Destruction
		DefaultRole = "R",
	},
	WARRIOR =
	{
		ClassCode = "W",
		Roles = {"T", "M"},
		TalentRoles = {"M", "M", "T"}, -- Arms, Fury, Protection
		DefaultRole = "T",
	},
	DEATHKNIGHT =
	{
		ClassCode = "T",
		Roles = {"T", "M"},
		TalentRoles = {"M", "M", "M"}, -- Blood, Frost, Unholy
		DefaultRole = "M",
	},
	MONK =
	{
		ClassCode = "O",
		Roles = {"T", "H", "M"},
		TalentRoles = {"T", "H", "M"}, -- Brewmaster, Mistweaver, Windwalker
		DefaultRole = "M",
	},
	DEMONHUNTER =
	{
		ClassCode = "N",
		Roles = {"T", "M"},
		TalentRoles = {"M", "T"}, -- Havoc, Vengeance
		DefaultRole = "M",
	},
}

GroupCalendar.ClassInfoByClassCode = {}

for vClassID, vClassInfo in pairs(GroupCalendar.ClassInfoByClassID) do
	vClassInfo.ClassID = vClassID
	GroupCalendar.ClassInfoByClassCode[vClassInfo.ClassCode] = vClassInfo
end

----------------------------------------
-- Roles
----------------------------------------

GroupCalendar.Roles =
{
	{ID = "H", Name = GroupCalendar.cHRole, Color = RAID_CLASS_COLORS.PRIEST, ColorCode = GroupCalendar.RAID_CLASS_COLOR_CODES.PRIEST},
	{ID = "T", Name = GroupCalendar.cTRole, Color = RAID_CLASS_COLORS.WARRIOR, ColorCode = GroupCalendar.RAID_CLASS_COLOR_CODES.WARRIOR},
	{ID = "R", Name = GroupCalendar.cRRole, Color = RAID_CLASS_COLORS.MAGE, ColorCode = GroupCalendar.RAID_CLASS_COLOR_CODES.MAGE},
	{ID = "M", Name = GroupCalendar.cMRole, Color = RAID_CLASS_COLORS.ROGUE, ColorCode = GroupCalendar.RAID_CLASS_COLOR_CODES.ROGUE},
}

-- RoleInfoByID

GroupCalendar.RoleInfoByID = {}

for vRoleIndex, vRoleInfo in pairs(GroupCalendar.Roles) do
	vRoleInfo.SortOrder = vRoleIndex
	vRoleInfo.Classes = {}
	GroupCalendar.RoleInfoByID[vRoleInfo.ID] = vRoleInfo
end

-- Add the class list to the role infos

for vClassID, vClassInfo in pairs(GroupCalendar.ClassInfoByClassID) do
	for _, vRoleCode in pairs(vClassInfo.Roles) do
		GroupCalendar.RoleInfoByID[vRoleCode].Classes[vClassID] = true
	end
end
