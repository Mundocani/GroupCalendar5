----------------------------------------
-- Group Calendar 5 Copyright (c) 2018 John Stephen
-- This software is licensed under the MIT license.
-- See the included LICENSE.txt file for more information.
----------------------------------------

local _

----------------------------------------
GroupCalendar.UI._MonthView = {}
----------------------------------------

function GroupCalendar.UI._MonthView:New(pParent)
	return CreateFrame("Frame", nil, pParent)
end

function GroupCalendar.UI._MonthView:Construct(pParent)
	GC5FontMonthView = CreateFont("GC5FontMonthView")
	GC5FontMonthView:SetFontObject(SystemFont_Tiny)
	GC5FontMonthView:SetTextColor(1, 1, 1)
	GC5FontMonthView:SetShadowColor(0, 0, 0)
	GC5FontMonthView:SetShadowOffset(1, -1)
	
	-- Create the month navigation
	
	self.MonthYearText = self:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	self.MonthYearText:SetPoint("TOP", self, "TOP", 17, -7)
	
	self.PreviousMonthButton = CreateFrame("Button", nil, self)
	self.PreviousMonthButton:SetWidth(32)
	self.PreviousMonthButton:SetHeight(32)
	self.PreviousMonthButton:SetPoint("CENTER", self.MonthYearText, "CENTER", -100, 0)
	self.PreviousMonthButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up");
	self.PreviousMonthButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down");
	self.PreviousMonthButton:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled");
	self.PreviousMonthButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD");
	self.PreviousMonthButton:SetScript("OnClick", function () self:ShowPreviousMonth() end)
	
	self.NextMonthButton = CreateFrame("Button", nil, self)
	self.NextMonthButton:SetWidth(32)
	self.NextMonthButton:SetHeight(32)
	self.NextMonthButton:SetPoint("CENTER", self.MonthYearText, "CENTER", 100, 0)
	self.NextMonthButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up");
	self.NextMonthButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down");
	self.NextMonthButton:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled");
	self.NextMonthButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD");
	self.NextMonthButton:SetScript("OnClick", function () self:ShowNextMonth() end)
	
	self.TodayButton = CreateFrame("Button", nil, self)
	self.TodayButton:SetWidth(32)
	self.TodayButton:SetHeight(32)
	self.TodayButton:SetPoint("CENTER", self.NextMonthButton, "CENTER", 30, 0)
	self.TodayButton:SetNormalTexture(GroupCalendar.UI.AddonPath.."Textures\\TodayIcon-Up");
	self.TodayButton:SetPushedTexture(GroupCalendar.UI.AddonPath.."Textures\\TodayIcon-Down");
	self.TodayButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD");
	self.TodayButton:SetScript("OnClick", function ()
		local calendarDate = GroupCalendar.WoWCalendar:GetDate()
		GroupCalendar.UI.Window:ShowDaySidebar(calendarDate.month, calendarDate.monthDay, calendarDate.year)
		self:ShowCurrentMonth()
	end)
	
	-- Create the 'today' highlight
	
	self.TodayHighlight = CreateFrame("Frame", "GroupCalendarTodayHighlight", self, "AutoCastShineTemplate")
	self.TodayHighlight:SetWidth(64)
	self.TodayHighlight:SetHeight(64)
	self.TodayHighlight:SetScript("OnShow", AutoCastShine_AutoCastStart)
	self.TodayHighlight:SetScript("OnHide", AutoCastShine_AutoCastStop)
	
	AutoCastShine_OnLoad(self.TodayHighlight)
	
	self.TodayHighlight:SetFrameLevel(self.TodayHighlight:GetFrameLevel() + 10)
	self.TodayHighlight:Hide()
	
	-- Create the weekday labels
	
	self.WeekdayTitles = {}
	self.WeekdaySpacing = 72
	
	for index = 1, 7 do
		local vTitle = self:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		
		vTitle:SetPoint("CENTER", self, "TOPLEFT", 65 + (index - 1) * self.WeekdaySpacing, -48)
		
		self.WeekdayTitles[index] = vTitle
	end
	
	--
	
	self.DayFrames = {}
	
	local vFirstDayFrame
	
	for vWeek = 1, 6 do
		for vWeekday = 1, 7 do
			local vShading = ((vWeek - 1) * (vWeek - 1) + (vWeekday - 1) * (vWeekday - 1)) / 61
			
			vShading = 1 - (vShading * 0.5)
			
			if vShading > 1 then
				vShading = 1
			end
			
			local dayFrame = GroupCalendar:New(GroupCalendar._DayFrame, self, self.WeekdaySpacing, vShading)
			
			if not vFirstDayFrame then
				vFirstDayFrame = dayFrame
				dayFrame:SetPoint("TOP", self.WeekdayTitles[1], "BOTTOM", 0, -8)
			else
				dayFrame:SetPoint("TOPLEFT", vFirstDayFrame, "TOPLEFT", (vWeekday - 1) * self.WeekdaySpacing, -(vWeek - 1) * self.WeekdaySpacing)
			end
			
			dayFrame:SetMonthPosition(vWeekday, vWeek)
			
			table.insert(self.DayFrames, dayFrame)
			
			-- Leave room for the calendars picker
			
			if vWeek == 6
			and vWeekday == 4 then
				break
			end
		end
	end
	
	self.MonthViewOptions = GroupCalendar:New(GroupCalendar.UI._MonthViewOptions, self)
	self.MonthViewOptions:SetPoint("TOPLEFT", self.DayFrames[#self.DayFrames], "TOPRIGHT", 4, 0)
	self.MonthViewOptions:SetPoint("RIGHT", self.DayFrames[7], "RIGHT", -7, 0)
	self.MonthViewOptions:SetPoint("BOTTOM", self.DayFrames[36], "BOTTOM", 0, 4)
	
	--
	
	self:SetScript("OnShow", self.OnShow)
	self:SetScript("OnHide", self.OnHide)
	self:SetScript("OnEvent", self.OnEvent)
end

function GroupCalendar.UI._MonthView:SetThemeID(pThemeID)
	local vTheme = GroupCalendar.Themes[pThemeID]
	if not vTheme then
		vTheme = GroupCalendar.Themes.PARCHMENT
	end
	for _, vDayFrame in ipairs(self.DayFrames) do
		vDayFrame:SetTheme(vTheme)
	end
end

function GroupCalendar.UI._MonthView:AdjustWeekdayTitles()
	local vWeekdayNames =
	{
		WEEKDAY_SUNDAY,
		WEEKDAY_MONDAY,
		WEEKDAY_TUESDAY,
		WEEKDAY_WEDNESDAY,
		WEEKDAY_THURSDAY,
		WEEKDAY_FRIDAY,
		WEEKDAY_SATURDAY,
	}
	
	for index = 1, 7 do
		self.WeekdayTitles[index]:SetText(vWeekdayNames[(index + (GroupCalendar.Data.StartDay or 1) - 2) % 7 + 1])
	end
end

function GroupCalendar.UI._MonthView:SetStartDay(pStartDay)
	local vStartDay = tonumber(pStartDay)
	if vStartDay < 1 then vStartDay = 1
	elseif vStartDay > 7 then vStartDay = 7 end
end

function GroupCalendar.UI._MonthView:OnShow()
	-- Create the menus if they're not present yet
	if not self.DayMenu then
		self.DayMenu = GroupCalendar:New(GroupCalendar._DayContextMenu)
		for index, dayFrame in ipairs(self.DayFrames) do
			dayFrame.DayMenu = self.DayMenu
		end
	end
	if not self.EventMenu then
		self.EventMenu = GroupCalendar:New(GroupCalendar._EventContextMenu)
		for index, dayFrame in ipairs(self.DayFrames) do
			dayFrame.EventMenu = self.EventMenu
		end
	end
	
	GroupCalendar.EventLib:RegisterCustomEvent("GC5_CALENDAR_CHANGED", self.Refresh, self)
	GroupCalendar.EventLib:RegisterCustomEvent("GC5_PREFS_CHANGED", self.Refresh, self)
	
	self:RegisterEvent("CVAR_UPDATE")
	self:AdjustWeekdayTitles()
	self:ShowCurrentMonth()
end

function GroupCalendar.UI._MonthView:OnHide()
	if GroupCalendar.UI.Window then
		GroupCalendar.UI.Window:HideSidebars()
	end
	
	GroupCalendar.EventLib:UnregisterEvent("GC5_CALENDAR_CHANGED", self.Refresh, self)
	GroupCalendar.EventLib:UnregisterEvent("GC5_PREFS_CHANGED", self.Refresh, self)
	
	self:UnregisterEvent("CVAR_UPDATE")
end

function GroupCalendar.UI._MonthView:OnEvent(pEventID, ...)
	if pEventID == "CVAR_UPDATE" then
		local vName = select(1, ...)
		
		if vName == "calendarShowDarkmoon"
		or vName == "calendarShowWeeklyHolidays"
		or vName == "calendarShowBattlegrounds" then
			self:BlizzardCalendarChanged()
		end
	end
end

function GroupCalendar.UI._MonthView:BlizzardCalendarChanged()
	GroupCalendar.Calendars.BLIZZARD:FlushCaches()
	
	if IsAddOnLoaded("Blizzard_Calendar") then
		CalendarFrame_Update()
	end
	
	self:Refresh()
end

function GroupCalendar.UI._MonthView:ShowPreviousMonth()
	self.Month = self.Month - 1
	
	if self.Month == 0 then
		self.Month = 12
		self.Year = self.Year - 1
	end
	
	GroupCalendar.WoWCalendar:SetAbsMonth(self.Month, self.Year)
	
	self:Refresh()
end

function GroupCalendar.UI._MonthView:ShowNextMonth()
	self.Month = self.Month + 1
	
	if self.Month == 13 then
		self.Month = 1
		self.Year = self.Year + 1
	end
	
	GroupCalendar.WoWCalendar:SetAbsMonth(self.Month, self.Year)
	
	self:Refresh()
end

function GroupCalendar.UI._MonthView:ShowCurrentMonth()
	if GroupCalendar.Clock.Data.ShowLocalTime then
		self.TodaysMonth, self.TodaysDay, self.TodaysYear = GroupCalendar.DateLib:GetLocalMDY()
	else
		local calendarDate = GroupCalendar.WoWCalendar:GetDate()
		self.TodaysMonth = calendarDate.month
		self.TodaysDay = calendarDate.monthDay
		self.TodaysYear = calendarDate.year
	end
	
	self.Month = self.TodaysMonth
	self.Year = self.TodaysYear
	
	GroupCalendar.WoWCalendar:SetAbsMonth(self.Month, self.Year)
	
	self:Refresh()
end

function GroupCalendar.UI._MonthView:SelectDate(pMonth, pDay, pYear)
	local dayFrame
	
	-- Deselect the currently selected date
	if self.SelectedMonth then
		dayFrame = self:GetDayFrameByDate(self.SelectedMonth, self.SelectedDay, self.SelectedYear)
		if dayFrame then
			dayFrame:SetSelected(false)
		end
	end
	
	-- Change the selection
	self.SelectedMonth, self.SelectedDay, self.SelectedYear = pMonth, pDay, pYear
	
	-- Highlight the new selection
	if self.SelectedMonth then
		dayFrame = self:GetDayFrameByDate(self.SelectedMonth, self.SelectedDay, self.SelectedYear)
		if dayFrame then
			dayFrame:SetSelected(true)
		end
	end
end

function GroupCalendar.UI._MonthView:GetDayFrameByDate(month, day, year)
	local previousMonthInfo = GroupCalendar.WoWCalendar:GetMonthInfo(-1)
	local currentMonthInfo = GroupCalendar.WoWCalendar:GetMonthInfo(0)
	local nextMonthInfo  = GroupCalendar.WoWCalendar:GetMonthInfo(1)
	local dayFrameIndex
	
	local firstDay = (currentMonthInfo.firstWeekday - (GroupCalendar.Data.StartDay or 1)) % 7 + 1
	
	if month == previousMonthInfo.month and year == previousMonthInfo.year then
		dayFrameIndex = firstDay + day - previousMonthInfo.numDays - 1
		
	elseif month == currentMonthInfo.month and year == currentMonthInfo.year then
		dayFrameIndex = firstDay + day - 1

	elseif month == nextMonthInfo.month and year == nextMonthInfo.year then
		dayFrameIndex = firstDay + currentMonthInfo.numDays + day - 1
	end
	
	return self.DayFrames[dayFrameIndex]
end

function GroupCalendar.UI._MonthView:Refresh()
	local previousMonthInfo = GroupCalendar.WoWCalendar:GetMonthInfo(-1)
	local currentMonthInfo = GroupCalendar.WoWCalendar:GetMonthInfo(0)
	local nextMonthInfo  = GroupCalendar.WoWCalendar:GetMonthInfo(1)

	self.MonthYearText:SetText(string.format("%s %04d", GroupCalendar.CALENDAR_MONTH_NAMES[currentMonthInfo.month], currentMonthInfo.year))
	
	local firstDay = (currentMonthInfo.firstWeekday - (GroupCalendar.Data.StartDay or 1)) % 7 + 1
	
	-- 
	
	local didShowToday
	
	for dayFrameIndex, dayFrame in ipairs(self.DayFrames) do
		local frameMonth, frameDay, frameYear
		
		if dayFrameIndex < firstDay then
			frameMonth = previousMonthInfo.month
			frameDay = previousMonthInfo.numDays + dayFrameIndex - firstDay + 1
			frameYear = previousMonthInfo.year
		else
			frameDay = dayFrameIndex - firstDay + 1
			
			if frameDay <= currentMonthInfo.numDays then
				frameMonth = currentMonthInfo.month
				frameYear = currentMonthInfo.year
			else
				frameMonth = nextMonthInfo.month
				frameDay = frameDay - currentMonthInfo.numDays
				frameYear = nextMonthInfo.year
			end
		end
		
		dayFrame:SetDate(frameMonth, frameDay, frameYear, currentMonthInfo.month)
		dayFrame:Show()
		
		if frameMonth == self.TodaysMonth
		and frameDay == self.TodaysDay
		and frameYear == self.TodaysYear then
			self.TodayHighlight:SetPoint("CENTER", dayFrame, "CENTER")
			self.TodayHighlight:Show()
			
			didShowToday = true
		end
		
		if frameMonth == self.SelectedMonth
		and frameDay == self.SelectedDay
		and frameYear == self.SelectedYear then
			dayFrame:SetSelected(true)
		end
	end
	
	if not didShowToday then
		self.TodayHighlight:Hide()
	end
end

----------------------------------------
GroupCalendar._DayFrame = {}
----------------------------------------

local gDayFrameID = 1

GroupCalendar._DayFrame.cCooldownEventDogEarIndex =
{
	XMUT = 2, -- Transmutes
	ALCH = 2, -- Alchemy Research
	
	VOID = 27, -- Void Shatter
	SPHR = 27, -- Void Sphere 
	
	MOON = 0, -- Mooncloth
	PMON = 0, -- Primal Mooncloth
	SPEL = 0, -- Spellcloth
	SHAD = 0, -- Shadowcloth
	EBON = 0, -- Ebonweave
	SWEV = 0, -- Spellweave
	SHRD = 0, -- Moonshroud
	
	GLSS = 26, -- Brilliant Glass
	ICYP = 26, -- Icy Prism
	
	INSC = 4, -- Inscription Research
	INSN = 4, -- Northrend Inscription Research
	
	TITN = 12, -- Smelt Titansteel
}

function GroupCalendar._DayFrame:New(pParent, pSize, pShading)
	return CreateFrame("Frame", nil, pParent)
end

function GroupCalendar._DayFrame:Construct(pParent, pSize, pShading)
	self:SetWidth(pSize)
	self:SetHeight(pSize)
	
	self.BackgroundTile = self:CreateTexture(nil, "BACKGROUND")
	
	self.Shading = pShading
	self.Theme = GroupCalendar.Themes[GroupCalendar.Data.ThemeID or GroupCalendar.DefaultThemeID] or GroupCalendar.Themes.PARCHMENT
	self.BackgroundTile:SetPoint("TOPLEFT", self, "TOPLEFT")
	self.BackgroundTile:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT")
	
	self.BackgroundFrame = CreateFrame("Frame", nil, self)
	self.BackgroundFrame:SetPoint("TOPLEFT", self, "TOPLEFT")
	self.BackgroundFrame:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT")
	
	self.DayIcon = self.BackgroundFrame:CreateTexture(nil, "BORDER")
	self.DayIcon:SetTexture(0, 0, 0, 0)
	self.DayIcon:SetPoint("TOPLEFT", self, "TOPLEFT", 2, -2)
	self.DayIcon:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, 2)
	self.DayIcon:SetVertexColor(0.6, 0.6, 0.6, 1)
	self.DayIcon:Hide()
	
	self.OverlayIcon = self.BackgroundFrame:CreateTexture(nil, "OVERLAY")
	self.OverlayIcon:SetTexture()
	self.OverlayIcon:SetPoint("TOPLEFT", self, "TOPLEFT", 3, -3)
	self.OverlayIcon:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -3, 3)
	self.OverlayIcon:Hide()
	
	self.OverlayIconShadow = self.BackgroundFrame:CreateTexture(nil, "ARTWORK")
	self.OverlayIconShadow:SetTexture()
	self.OverlayIconShadow:SetPoint("TOPLEFT", self.OverlayIcon, "TOPLEFT", 2, -2)
	self.OverlayIconShadow:SetPoint("BOTTOMRIGHT", self.OverlayIcon, "BOTTOMRIGHT", 2, -2)
	self.OverlayIconShadow:SetVertexColor(0, 0, 0, 0.5)
	self.OverlayIconShadow:Hide()
	
	self.BirthdayIcon = self.BackgroundFrame:CreateTexture(nil, "OVERLAY")
	self.BirthdayIcon:SetTexture()
	self.BirthdayIcon:SetPoint("BOTTOMRIGHT", self.OverlayIcon, "BOTTOMRIGHT")
	self.BirthdayIcon:SetWidth(48)
	self.BirthdayIcon:SetHeight(48)
	
	self.SelectedTexture = self.BackgroundFrame:CreateTexture("GC5_DayFrameHighlight"..gDayFrameID, "ARTWORK")
	self.SelectedTexture:SetTexture(GroupCalendar.UI.AddonPath.."Textures\\DateButtonHighlight")
	self.SelectedTexture:SetVertexColor(1, 1, 0.4, 0.5)
	self.SelectedTexture:SetBlendMode("ADD")
	self.SelectedTexture:SetAllPoints()
	self.SelectedTexture:Hide()
	
	self.ButtonFrame = CreateFrame("Button", nil, self)
	self.ButtonFrame:SetPoint("TOPLEFT", self, "TOPLEFT")
	self.ButtonFrame:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT")
	self.ButtonFrame:SetFrameLevel(self:GetFrameLevel() + 10)
	self.ButtonFrame:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
	self.ButtonFrame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	self.ButtonFrame:SetScript("OnEnter", function (pButtonFrame, ...) self:OnEnter(...) end)
	self.ButtonFrame:SetScript("OnLeave", function (pButtonFrame, ...) self:OnLeave(...) end)
	self.ButtonFrame:SetScript("OnClick", function (pButtonFrame, ...) self:OnClick(...) end)
	
	self.ForegroundFrame = CreateFrame("Frame", nil, self)
	self.ForegroundFrame:SetFrameLevel(self:GetFrameLevel() + 20)
	self.ForegroundFrame:SetPoint("TOPLEFT", self, "TOPLEFT")
	self.ForegroundFrame:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT")
	
	self.DogEarIcon = self.ForegroundFrame:CreateTexture(nil, "BACKGROUND")
	self.DogEarIcon:SetTexture(GroupCalendar.UI.AddonPath.."Textures\\CooldownIcons")
	self.DogEarIcon:SetWidth(pSize * 0.3)
	self.DogEarIcon:SetHeight(pSize * 0.3)
	self.DogEarIcon:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, 0)
	
	self.ForegroundTile = self.ForegroundFrame:CreateTexture(nil, "BORDER")
	self.ForegroundTile:SetAllPoints()
	
	self.DateText = self.ForegroundFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	self.DateText:SetWidth(36)
	self.DateText:SetHeight(10)
	self.DateText:SetPoint("TOPLEFT", self, "TOPLEFT", -4, -7)
	self.DateText:SetText("10")
	
	self.CircledDate = self.ForegroundFrame:CreateTexture(nil, "ARTWORK")
	self.CircledDate:SetWidth(20)
	self.CircledDate:SetHeight(17)
	self.CircledDate:SetPoint("CENTER", self.DateText, "CENTER", 0, -1)
	self.CircledDate:SetTexture(GroupCalendar.UI.AddonPath.."Textures\\CircledDate")

	self.MoreText = self.ForegroundFrame:CreateFontString(nil, "OVERLAY", "GC5FontMonthView")
	self.MoreText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
	self.MoreText:SetText(GroupCalendar.cMore)
	self.MoreText:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -4, 2)
	
	self.EventFrames = {}
	self.Events = {}
	
	self:SetDogEarIndex(0)
	
	gDayFrameID = gDayFrameID + 1
end

function GroupCalendar._DayFrame:SetTheme(pTheme)
	self.Theme = pTheme
	self:ApplyTheme()
end

function GroupCalendar._DayFrame:ApplyTheme()
	self.ForegroundTile:SetTexture(self.Theme.Foreground)

	if type(self.Theme.Background) == "table" then
		self.BackgroundTile:SetTexture(self.Theme.Background[self.ViewMonth or 1])
	else
		self.BackgroundTile:SetTexture(self.Theme.Background)
	end
	
	if self.Theme.RandomTile then
		local tileTexLeft, tileTexRight, tileTexTop, tileTexBottom
		local column = math.floor(math.random() * self.Theme.TilesH)
		local row = math.floor(math.random() * self.Theme.TilesV)
		
		tileTexLeft = column / self.Theme.TilesH
		tileTexRight = (column + 1) / self.Theme.TilesH
		tileTexTop = row / self.Theme.TilesV
		tileTexBottom = (row + 1) / self.Theme.TilesV
		
		self.ForegroundTile:SetTexCoord(tileTexLeft, tileTexRight, tileTexTop, tileTexBottom)
		self.BackgroundTile:SetTexCoord(tileTexLeft, tileTexRight, tileTexTop, tileTexBottom)
	else
		self.BackgroundTile:SetTexCoord(
				(self.Weekday - 1) / 7,
				self.Weekday / 7,
				(self.Week - 1) / 6,
				self.Week / 6)
		
		self.ForegroundTile:SetTexCoord(0, 0.5, 0, 0.5)
	end
	
	local vShading = self.Month == self.ViewMonth and 1 or 0.25
	local vBackgroundShading = vShading * (self.Theme.UseShading and self.Shading or 1)
	
	self.BackgroundTile:SetVertexColor(vBackgroundShading, vBackgroundShading, vBackgroundShading, self.Theme.BackgroundBrightness)
	
	self.BackgroundFrame:SetAlpha(vShading)
	self.ForegroundFrame:SetAlpha(vShading)
end

function GroupCalendar._DayFrame:SetMonthPosition(pWeekday, pWeek)
	self.Weekday = pWeekday
	self.Week = pWeek
	
	self:ApplyTheme()
end

function GroupCalendar._DayFrame:SetDogEarIndex(index)
	local row = math.floor(index / 8)
	local column = math.fmod(index, 8)
	
	self.DogEarIcon:SetTexCoord(column / 8, (column + 1) / 8, row / 4, (row + 1) / 4)
end

function GroupCalendar._DayFrame:SetDate(pMonth, pDay, pYear, pViewMonth)
	if self.Month ~= pMonth 
	or self.Day ~= pDay
	or self.Year ~= pYear
	or self.ViewMonth ~= pViewMonth then
		self.Month = pMonth
		self.Day = pDay
		self.Year = pYear
		self.Date = GroupCalendar.DateLib:ConvertMDYToDate(self.Month, self.Day, self.Year)
		
		self.ViewMonth = pViewMonth
		
		self:ApplyTheme()
	end
	
	if not self.IsFlashing and not self.Selected then
		self.SelectedTexture:Hide()
	end
	
	self:Update()
end

function GroupCalendar._DayFrame:GetMergedSchedules(pMonth, pDay, pYear)
end

function GroupCalendar._DayFrame:Update()
	local currentDateTimeStamp = GroupCalendar.DateLib:GetServerDateTimeStamp()
	
	self.Events = GroupCalendar:GetDayEvents(self.Month, self.Day, self.Year, self.Events)
	
	--
	
	if self.SummaryEvents then
		for vKey, _ in pairs(self.SummaryEvents) do
			self.SummaryEvents[vKey] = nil
		end
	else
		self.SummaryEvents = {}
	end
		
	-- Set the day number
	self.DateText:SetText(self.Day)

	-- Scan the day's events to figure out which images to show
	local didSetIcon, iconEventData
	local didSetOverlay, didSetDogEarIcon, didSetBirthday
	local hasAppointment, appointmentEventData -- Appointments are events for which the player is signed up
	local hasUnseenEvent, hasMore

	for eventIndex, event in ipairs(self.Events) do

		-- Set the cooldown icon
		if event:IsCooldownEvent() and not didSetDogEarIcon then
			didSetDogEarIcon = true
			self.DogEarIcon:Show()
			self:SetDogEarIndex(self.cCooldownEventDogEarIndex[event.TitleTag] or 5)
		end

		-- Note unseen events so the highlighting can be adjusted below
		if event.Unseen then
			hasUnseenEvent = true
		end
		
		-- Set the main image for the frame
		if event.SequenceType ~= "ONGOING" -- ongoing events aren't interesting
		and (event.SequenceType ~= "END" or not event.DontDisplayEnd) -- ignore END events if they're not interesting
		and not event:IsCooldownEvent() -- cooldown events have their own special display
		and not event:IsBirthdayEvent() -- so do birthdays
		and event.InviteStatus ~= CALENDAR_INVITESTATUS_DECLINED then -- if the player doesn't care then it isn't interesting

			-- Bump the existing image if this is a player-created event and the existing image is a game-created event or an expired event
			if didSetIcon and event:IsPlayerCreated()
			and (iconEventData.CalendarType == "HOLIDAY" or iconEventData:HasPassed(currentDateTimeStamp)) then
				didSetIcon = false -- Un-set the icon so it'll get re-set by this event
			end

			-- Use this event if there's no image yet
			if not didSetIcon then
				local texturePath, texCoords = GroupCalendar:GetTextureFile(event.TextureID, event.CalendarType, event.NumSequenceDays ~= 2 and event.SequenceType or "", event.EventType, event.TitleTag)
				
				if texturePath then
					didSetIcon = true
					iconEventData = event
					
					self.DayIcon:SetTexture(texturePath)
					self.DayIcon:SetTexCoord(texCoords.left, texCoords.right, texCoords.top, texCoords.bottom)
					self.DayIcon:Show()
				end
			end
		end

		-- Remember the first event the player has signed up for
		if not hasAppointment and event:IsAttending() then
			hasAppointment = true
			appointmentEventData = event
		end

		-- Set the holiday overlay
		if not didSetOverlay and event.CalendarType == "HOLIDAY" and not event.DontDisplayBanner then

			-- Use the "ongoing" version of the texture to get the banner
			local sequenceType = event.NumSequenceDays ~= 2 and "ONGOING" or ""
			local texturePath, texCoords = GroupCalendar:GetTextureFile(event.TextureID, event.CalendarType, sequenceType, event.EventType, event.TitleTag)
			
			if texturePath then
				didSetOverlay = true

				self.OverlayIcon:SetTexture(texturePath)
				self.OverlayIcon:SetTexCoord(texCoords.left, texCoords.right, texCoords.top, texCoords.bottom)
				self.OverlayIcon:SetVertexColor(1, 1, 1, 1)
				self.OverlayIcon:Show()
				
				self.OverlayIconShadow:SetTexture(texturePath)
				self.OverlayIconShadow:SetTexCoord(texCoords.left, texCoords.right, texCoords.top, texCoords.bottom)
				self.OverlayIconShadow:Show()
			end
		end
		
		-- Light the candle if there's a birthday
		if not didSetBirthday and event.TitleTag == "BRTH" then
			self.BirthdayIcon:SetTexture(GroupCalendar.TitleTagInfo.BRTH.Texture)
			self.BirthdayIcon:Show()
			didSetBirthday = true
		end
		
		-- Display regular events in the in-date list
		if event.CalendarType ~= "HOLIDAY"
		and event.CalendarType ~= "RAID_LOCKOUT"
		and event.CalendarType ~= "RAID_RESET"
		and event.CalendarType ~= "ARENA"
		and not event:IsCooldownEvent()
		and not event:IsBirthdayEvent() then
			local vNeedToBump = #self.SummaryEvents >= 2
			
			if vNeedToBump then
				hasMore = true
			end
			
			if not vNeedToBump then
				table.insert(self.SummaryEvents, event)
			
			-- See if an event should be bumped
			
			-- ACCEPTED/TENTATIVE/CONFIRMED/STANDBY can bump anything except other ACCEPTED/TENTATIVE/CONFIRMED/STANDBY
			-- and the last INVITED response
			
			elseif event.InviteStatus == CALENDAR_INVITESTATUS_ACCEPTED
			    or event.InviteStatus == CALENDAR_INVITESTATUS_TENTATIVE
			    or event.InviteStatus == CALENDAR_INVITESTATUS_SIGNEDUP
				or event.InviteStatus == CALENDAR_INVITESTATUS_CONFIRMED
				or event.InviteStatus == CALENDAR_INVITESTATUS_STANDBY then
				
				local vLastInvitedIndex
				
				for existingEventIndex = #self.SummaryEvents, 1, -1 do
					local existingEventData = self.SummaryEvents[existingEventIndex]
					
					if existingEventData.InviteStatus == CALENDAR_INVITESTATUS_INVITED then
						if vLastInvitedIndex then
							table.remove(self.SummaryEvents, vLastInvitedIndex)
							table.insert(self.SummaryEvents, event)
							
							vLastInvitedIndex = existingEventIndex
							break
						end
						
						vLastInvitedIndex = existingEventIndex
					elseif (existingEventData.InviteStatus ~= CALENDAR_INVITESTATUS_ACCEPTED
					and existingEventData.InviteStatus ~= CALENDAR_INVITESTATUS_TENTATIVE
					and existingEventData.InviteStatus ~= CALENDAR_INVITESTATUS_SIGNEDUP
					and existingEventData.InviteStatus ~= CALENDAR_INVITESTATUS_CONFIRMED
					and existingEventData.InviteStatus ~= CALENDAR_INVITESTATUS_STANDBY)
					or existingEventData:HasPassed(currentDateTimeStamp) then
						table.remove(self.SummaryEvents, existingEventIndex)
						table.insert(self.SummaryEvents, event)
						break
					end
				end -- for existingEventIndex
				
			-- Invited can bump one ACCEPTED/CONFIRMED/STANDBY if no currently-selected events
			-- are INVITED responses
			
			elseif event.InviteStatus == CALENDAR_INVITESTATUS_INVITED then
				local hasInvited
				
				for existingEventIndex, existingEventData in ipairs(self.SummaryEvents) do
					if existingEventData.InviteStatus == CALENDAR_INVITESTATUS_INVITED then
						hasInvited = true
						
						-- Replace the existing one if it's in the past
						
						if existingEventData:HasPassed(currentDateTimeStamp) then
							table.remove(self.SummaryEvents, existingEventIndex)
							table.insert(self.SummaryEvents, event)
						end
						
						break
					end
				end
				
				if not hasInvited then
					for existingEventIndex = #self.SummaryEvents, 1, -1 do
						local existingEventData = self.SummaryEvents[existingEventIndex]
						
						if existingEventData.InviteStatus == CALENDAR_INVITESTATUS_ACCEPTED
						or existingEventData.InviteStatus == CALENDAR_INVITESTATUS_TENTATIVE
						or existingEventData.InviteStatus == CALENDAR_INVITESTATUS_SIGNEDUP
						or existingEventData.InviteStatus == CALENDAR_INVITESTATUS_CONFIRMED
						or existingEventData.InviteStatus == CALENDAR_INVITESTATUS_STANDBY then
							table.remove(self.SummaryEvents, existingEventIndex)
							table.insert(self.SummaryEvents, event)
							break
						end
					end
				end
				
			-- DECLINED and OUT can't bump anything
			
			else
			end
		end
	end -- for event

	if not didSetDogEarIcon then
		self.DogEarIcon:Hide()
	end
	
	if not didSetIcon then
		self.DayIcon:SetTexture()
		self.DayIcon:Hide()
	end
	
	if not didSetOverlay then
		self.OverlayIcon:SetTexture()
		self.OverlayIcon:Hide()
		
		self.OverlayIconShadow:SetTexture()
		self.OverlayIconShadow:Hide()
	end
	
	if not didSetBirthday then
		self.BirthdayIcon:SetTexture()
		self.BirthdayIcon:Hide()
	end
	
	if hasUnseenEvent then
		self:StartFlashing()
	else
		self:StopFlashing()
	end
	
	if hasMore then
		self.MoreText:Show()
	else
		self.MoreText:Hide()
	end
	
	-- Circle the date if the player is signed up to an event
	if hasAppointment then
		local color = appointmentEventData:GetEventColor()
		
		self.CircledDate:SetVertexColor(color.r, color.g, color.b, 0.7)
		self.CircledDate:SetAlpha(vAppointmentIsDimmed and 0.4 or 1.0)
		self.CircledDate:Show()
	else
		self.CircledDate:Hide()
	end
	
	-- Set the summary
	
	local vDisplayIndex = #self.SummaryEvents - 1
	
	for index, event in ipairs(self.SummaryEvents) do
		local eventFrame = self.EventFrames[index]
		
		if not eventFrame then
			eventFrame = GroupCalendar.DayFrameEventPool:GetFrame()
			self.EventFrames[index] = eventFrame
		end
		
		eventFrame:SetDayFrame(self, vDisplayIndex, hasMore)
		eventFrame:SetEvent(event)
		
		vDisplayIndex = vDisplayIndex - 1
	end
	
	while #self.EventFrames > #self.SummaryEvents do
		GroupCalendar.DayFrameEventPool:ReleaseFrame(self.EventFrames[#self.EventFrames])
		table.remove(self.EventFrames, #self.EventFrames)
	end
end

function GroupCalendar._DayFrame:OnEnter()
	if #self.Events == 0 then
		return
	end
	
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:AddLine(GroupCalendar.DateLib:GetLongDateString(self.Date, true), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	GroupCalendar:AddTooltipEvents(GameTooltip, self.Events, GroupCalendar.Clock.Data.ShowLocalTime)
	GameTooltip:Show()
end

function GroupCalendar._DayFrame:OnLeave()
	GameTooltip:Hide()
end

function GroupCalendar._DayFrame:OnClick(pButton)
	if pButton == "RightButton" then
		self.DayMenu:Toggle(self, self.Month, self.Day, self.Year)
	else
		GroupCalendar.UI.Window:ShowDaySidebar(self.Month, self.Day, self.Year)
	end
end

function GroupCalendar._DayFrame:SetSelected(pSelected)
	self.Selected = pSelected
	
	if pSelected then
		self.SelectedTexture:Show()
	elseif not self.IsFlashing then
		self.SelectedTexture:Hide()
	end
end

function GroupCalendar._DayFrame:StartFlashing()
	if self.IsFlashing then
		return
	end
	
	self.IsFlashing = true
	
	if not self.FlashAnimationGroup then
		self.FlashAnimationGroup = self.SelectedTexture:CreateAnimationGroup()
		local fadeIn = self.FlashAnimationGroup:CreateAnimation("Alpha")
		fadeIn:SetDuration(0.5)
		fadeIn:SetFromAlpha(0)
		fadeIn:SetToAlpha(1)
		fadeIn:SetOrder(1)
		fadeIn:SetEndDelay(0.4)
		
		local fadeOut = self.FlashAnimationGroup:CreateAnimation("Alpha")
		fadeOut:SetDuration(0.5)
		fadeOut:SetFromAlpha(1)
		fadeOut:SetToAlpha(0)
		fadeOut:SetOrder(2)
		fadeOut:SetEndDelay(0.2)
		
		self.FlashAnimationGroup:SetLooping("REPEAT")
	end
	
	self.SelectedTexture:Show()
	self.FlashAnimationGroup:Play()
end

function GroupCalendar._DayFrame:StopFlashing()
	if not self.IsFlashing then
		return
	end
	
	self.IsFlashing = false
	self.FlashAnimationGroup:Stop()
	self.SelectedTexture:SetAlpha(0.5)
	
	if self.Selected then
		self.SelectedTexture:Show()
	else
		self.SelectedTexture:Hide()
	end
end

----------------------------------------
GroupCalendar._DayFrameEvent = {}
----------------------------------------

GroupCalendar._DayFrameEvent.Height = 20

function GroupCalendar._DayFrameEvent:New()
	return CreateFrame("Button", nil, UIParent)
end

function GroupCalendar._DayFrameEvent:Construct()
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	self:SetHeight(self.Height)
	
	self.Title = self:CreateFontString(nil, "OVERLAY", "GC5FontMonthView")
	self.Title:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
	self.Title:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, -10)
	self.Title:SetHeight(10)
	self.Title:SetJustifyH("LEFT")
	
	self.Time = self:CreateFontString(nil, "OVERLAY", "GC5FontMonthView")
	self.Time:SetPoint("TOPLEFT", self.Title, "BOTTOMLEFT", 0, 0)
	self.Time:SetPoint("BOTTOMRIGHT", self.Title, "BOTTOMRIGHT", 0, -10)
	self.Time:SetHeight(10)
	self.Time:SetJustifyH("LEFT")
	
	self.Highlight = self:CreateTexture(nil, "HIGHLIGHT")
	self.Highlight:SetAllPoints()
	self.Highlight:SetTexture("Interface\\HelpFrame\\HelpFrameButton-Highlight")
	self.Highlight:SetTexCoord(0, 1, 0, 0.578125)
	self.Highlight:SetBlendMode("ADD")
	
	self:SetScript("OnEnter", self.OnEnter)
	self:SetScript("OnLeave", self.OnLeave)
	self:SetScript("OnClick", self.OnClick)
	
	self:EnableMouse(true)
end

function GroupCalendar._DayFrameEvent:SetDayFrame(pDayFrame, pEventLevel, pHasMore)
	self.DayFrame = pDayFrame
	
	self:SetParent(pDayFrame.ForegroundFrame)
	self:SetFrameLevel(pDayFrame.ForegroundFrame:GetFrameLevel() + 20)
	
	self:ClearAllPoints()
	
	local vY = 4 + pEventLevel * self.Height
	
	if pHasMore then
		vY = vY + 8
	end
	
	self:SetPoint("BOTTOMLEFT", pDayFrame, "BOTTOMLEFT", 4, vY)
	self:SetPoint("BOTTOMRIGHT", pDayFrame, "BOTTOMRIGHT", 0, vY)
	
	self:Show()
end

function GroupCalendar._DayFrameEvent:SetEvent(pEvent)
	self.Event = pEvent
	
	local color = self.Event:GetEventColor()
	
	self.Title:SetTextColor(color.r, color.g, color.b)
	
	if self.Event:IsAllDayEvent() then
		self.Title:SetText(self.Event.Title)
		self.Time:SetText("")
	else
		local vTime = GroupCalendar.DateLib:ConvertHMToTime(self.Event.Hour, self.Event.Minute)
		
		if GroupCalendar.Clock.Data.ShowLocalTime then
			vTime = GroupCalendar.DateLib:GetLocalTimeFromServerTime(vTime)
		end
		
		local vTimeString = GroupCalendar.DateLib:GetShortTimeString(vTime)

		self.Title:SetText(self.Event.Title)
		self.Time:SetText(vTimeString)
	end
end

function GroupCalendar._DayFrameEvent:AddTooltipAttendees(pTitle, pAttendees, pColor)
	if not pAttendees then
		return
	end
	
	local vAttendees = table.concat(pAttendees, ", ")
	
	GameTooltip:AddLine(pTitle..": "..vAttendees, pColor.r, pColor.g, pColor.b, 1)
end

function GroupCalendar._DayFrameEvent:OnEnter()
	local vTimeString = GroupCalendar.DateLib:GetShortTimeString(GroupCalendar.DateLib:ConvertHMToTime(self.Event.Hour, self.Event.Minute))
	
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:AddDoubleLine(self.Event.Title, vTimeString)
	GameTooltip:AddLine(self.Event.Description, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, 1)
	
	local vAttendeesByStatus = {}
	
	if self.Event.Attendance then
		for vName, vInfo in pairs(self.Event.Attendance) do
			local vInviteStatus = vInfo.InviteStatus
			
			-- Put "Signed up" people with "Accepted" people
			
			if vInviteStatus == CALENDAR_INVITESTATUS_SIGNEDUP then
				vInviteStatus = CALENDAR_INVITESTATUS_ACCEPTED
			end
			
			if not vAttendeesByStatus[vInfo.InviteStatus] then
				vAttendeesByStatus[vInfo.InviteStatus] = {}
			end
			
			table.insert(vAttendeesByStatus[vInfo.InviteStatus], vName)
		end
	end
	
	for _, vAttendees in pairs(vAttendeesByStatus) do
		table.sort(vAttendees)
	end
	
	self:AddTooltipAttendees(CALENDAR_STATUS_CONFIRMED, vAttendeesByStatus[CALENDAR_INVITESTATUS_CONFIRMED], GREEN_FONT_COLOR)
	self:AddTooltipAttendees(CALENDAR_STATUS_STANDBY, vAttendeesByStatus[CALENDAR_INVITESTATUS_STANDBY], {r=0.5,g=0.5,b=1})
	self:AddTooltipAttendees(CALENDAR_STATUS_ACCEPTED, vAttendeesByStatus[CALENDAR_INVITESTATUS_ACCEPTED], NORMAL_FONT_COLOR)
	self:AddTooltipAttendees(CALENDAR_STATUS_TENTATIVE, vAttendeesByStatus[CALENDAR_INVITESTATUS_TENTATIVE], YELLOW_FONT_COLOR)
	self:AddTooltipAttendees(CALENDAR_STATUS_DECLINED, vAttendeesByStatus[CALENDAR_INVITESTATUS_DECLINED], RED_FONT_COLOR)
	self:AddTooltipAttendees(CALENDAR_STATUS_OUT, vAttendeesByStatus[CALENDAR_INVITESTATUS_OUT], RED_FONT_COLOR)
	
	GameTooltip:Show()
end

function GroupCalendar._DayFrameEvent:OnLeave()
	GameTooltip:Hide()
end

function GroupCalendar._DayFrameEvent:OnClick(pButton)
	if pButton == "RightButton" then
		self.DayFrame.EventMenu:Toggle(self, self.DayFrame.Month, self.DayFrame.Day, self.DayFrame.Year, self.Event)
	else
		GroupCalendar.UI.Window:ShowEventSidebar(self.Event)
	end
end

----------------------------------------
GroupCalendar.DayFrameEventPool = {}
----------------------------------------

GroupCalendar.DayFrameEventPool.Frames = {}

function GroupCalendar.DayFrameEventPool:GetFrame()
	local vFrame = table.remove(self.Frames)
	
	if not vFrame then
		vFrame = GroupCalendar:New(GroupCalendar._DayFrameEvent)
	end
	
	return vFrame
end

function GroupCalendar.DayFrameEventPool:ReleaseFrame(pFrame)
	pFrame:Hide()
	pFrame:SetParent(UIParent)
	
	table.insert(self.Frames, pFrame)
end

----------------------------------------
GroupCalendar.UI._MonthViewOptions = {}
----------------------------------------

function GroupCalendar.UI._MonthViewOptions:New(pParent)
	return CreateFrame("Frame", nil, pParent)
end

function GroupCalendar.UI._MonthViewOptions:Construct(pParent)
	self:SetWidth(210)
	self:SetHeight(60)
	
	self.UseServerTimeCheckbox = GroupCalendar:New(GroupCalendar.UIElementsLib._CheckButton, self, GroupCalendar.cUseServerDateTime)
	self.UseServerTimeCheckbox:SetPoint("TOPLEFT", self, "TOPLEFT", 10, -10)
	self.UseServerTimeCheckbox.Title:SetWidth(175)
	self.UseServerTimeCheckbox:SetScript("OnClick", function (pCheckButton)
		GroupCalendar.Clock.Data.ShowLocalTime = not pCheckButton:GetChecked()
		GroupCalendar.EventLib:DispatchEvent("GC5_PREFS_CHANGED")
	end)
	
	--[[
	self.ShowCalendarLabel = self:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	self.ShowCalendarLabel:SetPoint("TOP", self.UseServerTimeCheckbox.Title, "BOTTOM", 0, -13)
	self.ShowCalendarLabel:SetPoint("LEFT", self.UseServerTimeCheckbox, "LEFT", 10, 0)
	self.ShowCalendarLabel:SetText(GroupCalendar.cShowCalendarLabel)
	]]
	self.ShowDarkmoonCalendar = GroupCalendar:New(GroupCalendar._EventFilterButton, self, "Interface\\Calendar\\Holidays\\Calendar_DarkmoonFaireTerokkarStart")
	self.ShowDarkmoonCalendar.NormalTexture:SetTexCoord(0, 0.7109375, 0, 0.7109375)
	self.ShowDarkmoonCalendar:SetPoint("TOPLEFT", self.UseServerTimeCheckbox, "BOTTOMLEFT", 0, -13)
	self.ShowDarkmoonCalendar.OnClick = function (pCheckButton, pMouseButton) self:SetShowDarkmoonCalendar(pCheckButton:GetChecked()) end
	self.ShowDarkmoonCalendar.NewbieTooltipTitle = CALENDAR_FILTER_DARKMOON
	self.ShowDarkmoonCalendar.NewbieTooltipDescription = GroupCalendar.cShowDarkmoonCalendarDescription
	
	self.ShowWeeklyCalendar = GroupCalendar:New(GroupCalendar._EventFilterButton, self, "Interface\\Calendar\\Holidays\\Calendar_FishingExtravaganza")
	self.ShowWeeklyCalendar.NormalTexture:SetTexCoord(0, 0.7109375, 0, 0.7109375)
	self.ShowWeeklyCalendar:SetPoint("LEFT", self.ShowDarkmoonCalendar, "RIGHT", 6, 0)
	self.ShowWeeklyCalendar.OnClick = function (pCheckButton, pMouseButton) self:SetShowWeeklyCalendar(pCheckButton:GetChecked()) end
	self.ShowWeeklyCalendar.NewbieTooltipTitle = CALENDAR_FILTER_WEEKLY_HOLIDAYS
	self.ShowWeeklyCalendar.NewbieTooltipDescription = GroupCalendar.cShowWeeklyCalendarDescription
	
	self.ShowPvPCalendar = GroupCalendar:New(GroupCalendar._EventFilterButton, self, "Interface\\Icons\\Ability_Hunter_RapidKilling")
	self.ShowPvPCalendar:SetPoint("LEFT", self.ShowWeeklyCalendar, "RIGHT", 6, 0)
	self.ShowPvPCalendar.OnClick = function (pCheckButton, pMouseButton) self:SetShowPvPCalendar(pCheckButton:GetChecked()) end
	self.ShowPvPCalendar.NewbieTooltipTitle = CALENDAR_FILTER_BATTLEGROUND
	self.ShowPvPCalendar.NewbieTooltipDescription = GroupCalendar.cShowPvPCalendarDescription
	
	self.ShowLockoutCalendar = GroupCalendar:New(GroupCalendar._EventFilterButton, self, "Interface\\Icons\\INV_Misc_Key_03")
	self.ShowLockoutCalendar:SetPoint("LEFT", self.ShowPvPCalendar, "RIGHT", 6, 0)
	self.ShowLockoutCalendar.OnClick = function (pCheckButton, pMouseButton) self:SetShowLockoutCalendar(pCheckButton:GetChecked()) end
	self.ShowLockoutCalendar.NewbieTooltipTitle = CALENDAR_FILTER_RAID_LOCKOUTS
	self.ShowLockoutCalendar.NewbieTooltipDescription = GroupCalendar.cShowLockoutCalendarDescription
	
	self.ShowAltsCalendar = GroupCalendar:New(GroupCalendar._EventFilterButton, self, "Interface\\Icons\\INV_Misc_Head_Dwarf_02")
	self.ShowAltsCalendar:SetPoint("LEFT", self.ShowLockoutCalendar, "RIGHT", 6, 0)
	self.ShowAltsCalendar.OnClick = function (pCheckButton, pMouseButton) self:SetShowAltsCalendar(pCheckButton:GetChecked()) end
	self.ShowAltsCalendar.NewbieTooltipTitle = GroupCalendar.cShowAlts
	self.ShowAltsCalendar.NewbieTooltipDescription = GroupCalendar.cShowAltsDescription
	
	self:SetScript("OnShow", self.OnShow)
end

function GroupCalendar.UI._MonthViewOptions:OnShow()
	self.UseServerTimeCheckbox:SetChecked(not GroupCalendar.Clock.Data.ShowLocalTime)
	self.ShowDarkmoonCalendar:SetChecked(GetCVarBool("calendarShowDarkmoon"))
	self.ShowWeeklyCalendar:SetChecked(GetCVarBool("calendarShowWeeklyHolidays"))
	self.ShowPvPCalendar:SetChecked(GetCVarBool("calendarShowBattlegrounds"))
	self.ShowLockoutCalendar:SetChecked(GroupCalendar.PlayerData.Prefs.ShowLockouts)
	self.ShowAltsCalendar:SetChecked(GroupCalendar.PlayerData.Prefs.ShowAlts)
end

function GroupCalendar.UI._MonthViewOptions:SetShowAltsCalendar(pShow)
	GroupCalendar.PlayerData.Prefs.ShowAlts = pShow
	self.ShowAltsCalendar:SetChecked(pShow)
	GroupCalendar.EventLib:DispatchEvent("GC5_PREFS_CHANGED")
end

function GroupCalendar.UI._MonthViewOptions:SetShowLockoutCalendar(pShow)
	GroupCalendar.PlayerData.Prefs.ShowLockouts = pShow
	self.ShowLockoutCalendar:SetChecked(pShow)
	GroupCalendar.EventLib:DispatchEvent("GC5_PREFS_CHANGED")
end

function GroupCalendar.UI._MonthViewOptions:SetShowPvPCalendar(pShow)
	SetCVar("calendarShowBattlegrounds", pShow and "1" or "0")
	
	self.ShowPvPCalendar:SetChecked(pShow)
	
	self:GetParent():BlizzardCalendarChanged()
end

function GroupCalendar.UI._MonthViewOptions:SetShowWeeklyCalendar(pShow)
	SetCVar("calendarShowWeeklyHolidays", pShow and "1" or "0")
	
	self.ShowWeeklyCalendar:SetChecked(pShow)
	
	self:GetParent():BlizzardCalendarChanged()
end

function GroupCalendar.UI._MonthViewOptions:SetShowDarkmoonCalendar(pShow)
	SetCVar("calendarShowDarkmoon", pShow and "1" or "0")
	
	self.ShowDarkmoonCalendar:SetChecked(pShow)
	
	self:GetParent():BlizzardCalendarChanged()
end

----------------------------------------
GroupCalendar._EventFilterButton = {}
----------------------------------------

function GroupCalendar._EventFilterButton:New(pParent, pIconTexture)
	return CreateFrame("CheckButton", nil, pParent)
end

function GroupCalendar._EventFilterButton:Construct(pParent, pIconTexture)
	self:SetWidth(26)
	self:SetHeight(26)
	
	if pIconTexture then
		self.NormalTexture = self:CreateTexture(nil, "BACKGROUND")
		self.NormalTexture:SetTexture(pIconTexture)
		self.NormalTexture:SetAllPoints()
	end
	
	self:SetCheckedTexture(GroupCalendar.UI.AddonPath.."Textures\\DateButtonHighlight")
	self:GetCheckedTexture():SetVertexColor(0.2, 0.8, 0.2)
	
	self:SetHighlightTexture(GroupCalendar.UI.AddonPath.."Textures\\DateButtonHighlight")
	self:GetHighlightTexture():SetBlendMode("ADD")
	
	self:SetScript("OnClick", self._OnClick)
	self:SetScript("OnEnter", self.OnEnter)
	self:SetScript("OnLeave", self.OnLeave)
end

function GroupCalendar._EventFilterButton:_OnClick(...)
	if self:GetChecked() then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
	end
	
	if self.OnClick then
		self:OnClick(...)
	end
end

function GroupCalendar._EventFilterButton:OnEnter()
	if self.NewbieTooltipTitle then
		GroupCalendar:ShowTooltip(self, self.NewbieTooltipTitle, self.NewbieTooltipDescription)
	end
end

function GroupCalendar._EventFilterButton:OnLeave()
	GroupCalendar:HideTooltip()
end

----------------------------------------
GroupCalendar._DayContextMenu = {}
----------------------------------------

function GroupCalendar._DayContextMenu:Construct()
	self:Inherit(GroupCalendar.UIElementsLib._ContextMenu)
end

function GroupCalendar._DayContextMenu:Toggle(frame, month, day, year)
	self.Month, self.Day, self.Year = month, day, year
	self:ToggleMenu(frame)
end

function GroupCalendar._DayContextMenu:AddItems(menu)
	if not self.Month then
		return
	end
	
	menu:AddCategoryTitle(GroupCalendar.DateLib:GetLongDateString(GroupCalendar.DateLib:ConvertMDYToDate(self.Month, self.Day, self.Year), true))
	
	menu:AddFunction(CALENDAR_CREATE_EVENT, function ()
		GroupCalendar.UI.Window:OpenNewEvent(self.Month, self.Day, self.Year, "PLAYER")
		end)

	if CanEditGuildEvent() then
		menu:AddFunction(CALENDAR_CREATE_GUILD_EVENT, function ()
			GroupCalendar.UI.Window:OpenNewEvent(self.Month, self.Day, self.Year, "GUILD_EVENT")
		end)

		menu:AddFunction(CALENDAR_CREATE_GUILD_ANNOUNCEMENT, function ()
			GroupCalendar.UI.Window:OpenNewEvent(self.Month, self.Day, self.Year, "GUILD_ANNOUNCEMENT")
		end)
	end
	menu:AddFunction(CALENDAR_CREATE_COMMUNITY_EVENT, function ()
		GroupCalendar.UI.Window:OpenNewEvent(self.Month, self.Day, self.Year, "COMMUNITY_EVENT")
		end)

	local vCanCreate = GroupCalendar:CanCreateEventOnDate(self.Month, self.Day, self.Year)
	local vCanPaste = vCanCreate and GroupCalendar.WoWCalendar:ContextMenuEventClipboard()
	
	if vCanCreate and vCanPaste then
		menu:AddDivider()
		menu:AddFunction(CALENDAR_PASTE_EVENT, function ()
			GroupCalendar.WoWCalendar:ContextMenuEventPaste(GroupCalendar.WoWCalendar:GetMonthOffset(self.Month, self.Year), self.Day);
		end)
	end
end

----------------------------------------
GroupCalendar._EventContextMenu = {}
----------------------------------------

function GroupCalendar._EventContextMenu:Construct()
	self:Inherit(GroupCalendar._DayContextMenu)
end

function GroupCalendar._EventContextMenu:Toggle(frame, month, day, year, event)
	self.Event = event
	self.inherited.Toggle(self, frame, month, day, year)
end

function GroupCalendar._EventContextMenu:AddItems(menu)
	if not self.Event then
		return
	end
	
	self.inherited.AddItems(self, menu)
	
	-- Add editing items
	
	if self.Event:CanEdit() then
		menu:AddDivider()
		menu:AddCategoryTitle(self.Event.Title)

		menu:AddFunction(CALENDAR_COPY_EVENT, function ()
			self.Event:Copy()
		end)
		menu:AddFunction(CALENDAR_DELETE_EVENT, function ()
			if self.Event then
				GroupCalendar.UI:ShowConfirmDeleteEvent(function ()
					self.Event:Delete()
				end)
			else
				self.Event:Delete()
			end
		end)
	end
	
	-- Add response items. These commands aren't available to the creator of an event due to restrictions in Blizzard's API
	if self.Event.ModStatus ~= "CREATOR" then
		if self.Event:CanRSVP() then
			menu:AddDivider()

			local vAttending = GroupCalendar.UI._EventViewer.cStatusAttending[self.Event.InviteStatus]

			menu:AddToggle(GroupCalendar.cYes:format(self.Event.OwnersName),
				function ()
					local attending = GroupCalendar.UI._EventViewer.cStatusAttending[self.Event.InviteStatus]
					return attending == "Y"
				end,
				function ()
					self.Event:SetConfirmedStatus()
				end)

			menu:AddToggle(GroupCalendar.cMaybe,
				function ()
					local attending = GroupCalendar.UI._EventViewer.cStatusAttending[self.Event.InviteStatus]
					return attending == "?"
				end,
				function ()
					self.Event:SetTentativeStatus()
				end)

			menu:AddToggle(GroupCalendar.cNo:format(self.Event.OwnersName),
				function ()
					local attending = GroupCalendar.UI._EventViewer.cStatusAttending[self.Event.InviteStatus]
					return attending == "N"
				end,
				function ()
					self.Event:SetDeclinedStatus()
				end)
		end

		if self.Event:CanRemove() then
			menu:AddDivider()
			menu:AddFunction(CALENDAR_REMOVE_INVITATION, function ()
				self.Event:Remove()
			end)
		end

		if self.Event:CanComplain() then
			menu:AddDivider()
			menu:AddFunction(REPORT_SPAM, function ()
				self.Event:Complain()
			end)
		end
	end
end
