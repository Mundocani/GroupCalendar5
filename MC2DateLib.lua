local _, Addon = ...

Addon.DateLib =
{
	Version = 1,
	
	cDaysInMonth = {31, 28, 31, 30,  31,  30,  31,  31,  30,  31,  30,  31},
	cDaysToMonth = { 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365},
	cMinutesPerDay = 1440,
	cSecondsPerDay = 86400,
	ServerToLocalOffset = 0, -- Offset which, when added to the server time yields the local time
}

if GetLocale() == "enUS" then
	Addon.DateLib.cLongDateFormat = "$month $day, $year"
	Addon.DateLib.cShortDateFormat = "$monthNum/$day"
	Addon.DateLib.cLongDateFormatWithDayOfWeek = "$dow $month $day, $year"
else
	Addon.DateLib.cLongDateFormat = "$day. $month $year"
	Addon.DateLib.cShortDateFormat = "$day.$monthNum"
	Addon.DateLib.cLongDateFormatWithDayOfWeek = "$dow $day. $month $year"
end

Addon.DateLib.CALENDAR_MONTH_NAMES =
{
	MONTH_JANUARY,
	MONTH_FEBRUARY,
	MONTH_MARCH,
	MONTH_APRIL,
	MONTH_MAY,
	MONTH_JUNE,
	MONTH_JULY,
	MONTH_AUGUST,
	MONTH_SEPTEMBER,
	MONTH_OCTOBER,
	MONTH_NOVEMBER,
	MONTH_DECEMBER,
}

-- Month names show up differently for full date displays in some languages

Addon.DateLib.CALENDAR_FULLDATE_MONTH_NAMES =
{
	FULLDATE_MONTH_JANUARY,
	FULLDATE_MONTH_FEBRUARY,
	FULLDATE_MONTH_MARCH,
	FULLDATE_MONTH_APRIL,
	FULLDATE_MONTH_MAY,
	FULLDATE_MONTH_JUNE,
	FULLDATE_MONTH_JULY,
	FULLDATE_MONTH_AUGUST,
	FULLDATE_MONTH_SEPTEMBER,
	FULLDATE_MONTH_OCTOBER,
	FULLDATE_MONTH_NOVEMBER,
	FULLDATE_MONTH_DECEMBER,
}

Addon.DateLib.CALENDAR_WEEKDAY_NAMES =
{
	WEEKDAY_SUNDAY,
	WEEKDAY_MONDAY,
	WEEKDAY_TUESDAY,
	WEEKDAY_WEDNESDAY,
	WEEKDAY_THURSDAY,
	WEEKDAY_FRIDAY,
	WEEKDAY_SATURDAY,
}

----------------------------------------
-- Server date/time functions
----------------------------------------

function Addon.DateLib:GetServerTime()
	return self:ConvertHMToTime(GetGameTime())
end

function Addon.DateLib:GetServerDateTime()
	local currentDate = C_Calendar.GetDate()
	
	if not currentDate or not currentDate.month or currentDate.month <= 0 then
		Addon:ErrorMessage("GetServerDateTime: C_Calendar.GetDate() not ready")
		Addon:DebugStack()
		return
	end
	
	return self:ConvertMDYToDate(currentDate.month, currentDate.monthDay, currentDate.year), self:GetServerTime(), currentDate.month, currentDate.monthDay, currentDate.year
end

function Addon.DateLib:GetServerDateTime60()
	return self:GetServerDateTime60FromLocalDateTime60(self:GetLocalDateTime60())
end

function Addon.DateLib:GetServerDateTimeStamp()
	local vDate, vTime60 = self:GetServerDateTime60()
	
	return vDate * self.cSecondsPerDay + vTime60
end

function Addon.DateLib:GetServerMonthOffsetDate(pDate)
	local month, day, year = ConvertDateToMDY(pDate)
	local currentDate = C_Calendar.GetDate()
	
	return month - currentDate.month, day
end

----------------------------------------
-- local date/time functions
----------------------------------------

function Addon.DateLib:GetLocalTime()
	local vDate = date("*t")
	
	return self:ConvertHMToTime(vDate.hour, vDate.min)
end

function Addon.DateLib:GetLocalMDY()
	local vDate = date("*t")
	
	return vDate.month, vDate.day, vDate.year
end

function Addon.DateLib:GetLocalDate()
	return self:ConvertMDYToDate(self:GetLocalMDY())
end

function Addon.DateLib:GetLocalDateTime()
	local vDate = date("*t")
	
	return self:ConvertMDYToDate(vDate.month, vDate.day, vDate.year), self:ConvertHMToTime(vDate.hour, vDate.min)
end

function Addon.DateLib:GetLocalYMDHMS()
	local vDate = date("*t")
	
	return vDate.year, vDate.month, vDate.day, vDate.hour, vDate.min, vDate.sec
end

function Addon.DateLib:GetLocalDateTime60()
	local vDate = date("*t")
	
	return self:ConvertMDYToDate(vDate.month, vDate.day, vDate.year), self:ConvertHMSToTime60(vDate.hour, vDate.min, vDate.sec)
end

function Addon.DateLib:GetLocalDateTimeStamp()
	local vDate, vTime60 = self:GetLocalDateTime60()
	
	return vDate * self.cSecondsPerDay + vTime60
end

----------------------------------------
-- UTC date/time functions
----------------------------------------

function Addon.DateLib:GetUTCTime()
	local vDate = date("!*t")
	
	return self:ConvertHMToTime(vDate.hour, vDate.min)
end

function Addon.DateLib:GetUTCDateTime()
	local vDate = date("!*t")
	
	return self:ConvertMDYToDate(vDate.month, vDate.day, vDate.year), self:ConvertHMToTime(vDate.hour, vDate.min)
end

function Addon.DateLib:GetUTCDateTime60()
	local vDate = date("!*t")
	
	return self:ConvertMDYToDate(vDate.month, vDate.day, vDate.year), self:ConvertHMSToTime60(vDate.hour, vDate.min, vDate.sec)
end

function Addon.DateLib:GetUTCDateTimeStamp()
	local vDate, vTime60 = self:GetUTCDateTime60()
	
	return vDate * self.cSecondsPerDay + vTime60
end

----------------------------------------
-- Time zone conversions
----------------------------------------

function Addon.DateLib:GetLocalTimeFromServerTime(pServerTime)
	if not pServerTime then
		return nil
	end
	
	local vLocalTime = pServerTime + self:GetServerToLocalOffset()

	if vLocalTime < 0 then
		vLocalTime = vLocalTime + self.cMinutesPerDay
	elseif vLocalTime >= self.cMinutesPerDay then
		vLocalTime = vLocalTime - self.cMinutesPerDay
	end
	
	return vLocalTime
end

function Addon.DateLib:GetServerTimeFromLocalTime(pLocalTime)
	local vServerTime = pLocalTime - self:GetServerToLocalOffset()

	if vServerTime < 0 then
		vServerTime = vServerTime + self.cMinutesPerDay
	elseif vServerTime >= self.cMinutesPerDay then
		vServerTime = vServerTime - self.cMinutesPerDay
	end
	
	return vServerTime
end

function Addon.DateLib:GetLocalDateTimeFromServerDateTime(pServerDate, pServerTime)
	if not pServerTime then
		return pServerDate, nil
	end
	
	local vLocalTime = pServerTime + self:GetServerToLocalOffset()
	local vLocalDate = pServerDate
	
	if vLocalTime < 0 then
		vLocalTime = vLocalTime + self.cMinutesPerDay
		vLocalDate = vLocalDate - 1
	elseif vLocalTime >= self.cMinutesPerDay then
		vLocalTime = vLocalTime - self.cMinutesPerDay
		vLocalDate = vLocalDate + 1
	end
	
	return vLocalDate, vLocalTime
end

function Addon.DateLib:GetServerDateTimeFromLocalDateTime(pLocalDate, pLocalTime)
	if not pLocalTime then
		return pLocalDate, nil
	end
	
	local vServerTime = pLocalTime - self:GetServerToLocalOffset()
	local vServerDate = pLocalDate
	
	if vServerTime < 0 then
		vServerTime = vServerTime + self.cMinutesPerDay
		vServerDate = vServerDate - 1
	elseif vServerTime >= self.cMinutesPerDay then
		vServerTime = vServerTime - self.cMinutesPerDay
		vServerDate = vServerDate + 1
	end
	
	return vServerDate, vServerTime
end

function Addon.DateLib:GetServerDateTime60FromLocalDateTime60(pLocalDate, pLocalTime60)
	if not pLocalTime60 then
		return pLocalDate, nil
	end
	
	local vServerTime60 = pLocalTime60 - self:GetServerToLocalOffset() * 60
	local vServerDate = pLocalDate
	
	if vServerTime60 < 0 then
		vServerTime60 = vServerTime60 + self.cSecondsPerDay
		vServerDate = vServerDate - 1
	elseif vServerTime60 >= self.cSecondsPerDay then
		vServerTime60 = vServerTime60 - self.cSecondsPerDay
		vServerDate = vServerDate + 1
	end
	
	return vServerDate, vServerTime60
end

function Addon.DateLib:AddOffsetToDateTime(pDate, pTime, pOffset)
	local vDateTime = pDate * self.cMinutesPerDay + pTime + pOffset
	
	return math.floor(vDateTime / self.cMinutesPerDay), math.fmod(vDateTime, self.cMinutesPerDay)
end

function Addon.DateLib:AddOffsetToDateTime60(pDate, pTime60, pOffset60)
	local vDateTime60 = pDate *  self.cSecondsPerDay + pTime60 + pOffset60
	
	return math.floor(vDateTime60 / self.cSecondsPerDay), math.fmod(vDateTime60, self.cSecondsPerDay)
end

function Addon.DateLib:GetServerDateTimeFromSecondsOffset(pSeconds)
	-- Calculate the local date and time of the reset (this is done in
	-- local date/time since it has a higher resolution)

	local vLocalDate, vLocalTime60 = self:GetLocalDateTime60()
	
	vLocalDate, vLocalTime60 = self:AddOffsetToDateTime60(vLocalDate, vLocalTime60, pSeconds)
	
	local vLocalTime = math.floor(vLocalTime60 / 60)

	-- Convert to server date/time

	return self:GetServerDateTimeFromLocalDateTime(vLocalDate, vLocalTime)
end

----------------------------------------
----------------------------------------

function Addon.DateLib:GetDateTimeFromTimeStamp(pTimeStamp)
	return math.floor(pTimeStamp / self.cSecondsPerDay), math.floor(math.fmod(pTimeStamp, self.cSecondsPerDay) / 60)
end

function Addon.DateLib:GetShortTimeString(pTime)
	if pTime == nil then
		return nil
	end
	
	if GetCVarBool("timeMgrUseMilitaryTime") then
		local vHour, vMinute = self:ConvertTimeToHM(pTime)
		
		return format(TIME_TWENTYFOURHOURS, vHour, vMinute)
	else
		local vHour, vMinute, vAMPM = self:ConvertTimeToHMAMPM(pTime)
		
		if vAMPM == 0 then
			return format(TIME_TWELVEHOURAM, vHour, vMinute)
		else
			return format(TIME_TWELVEHOURPM, vHour, vMinute)
		end
	end
end

function Addon.DateLib:ConvertTimeToHM(pTime)
	if not pTime then
		return
	end
	
	local vMinute = math.fmod(pTime, 60)
	local vHour = math.floor((pTime - vMinute) / 60 + 0.5)
	
	return vHour, vMinute
end

function Addon.DateLib:ConvertTime60ToHMS(pTime60)
	if not pTime60 then
		return
	end
	
	local vSecond = math.fmod(pTime60, 60)
	local vHourMinute = math.floor((pTime60 - vSecond) / 60 + 0.5)
	local vMinute = math.fmod(vHourMinute, 60)
	local vHour = math.floor((vHourMinute - vMinute) / 60 + 0.5)
	
	return vHour, vMinute, vSecond
end

function Addon.DateLib:ConvertHMToTime(pHour, pMinute)
	if not pHour
	or not pMinute then
		return
	end
	
	return pHour * 60 + pMinute
end

function Addon.DateLib:ConvertHMSToTime60(pHour, pMinute, pSecond)
	return pHour * 3600 + pMinute * 60 + pSecond
end

function Addon.DateLib:ConvertTimeToHMAMPM(pTime)
	local vHour, vMinute = self:ConvertTimeToHM(pTime)
	local vAMPM
	
	if vHour < 12 then
		vAMPM = 0
		
		if vHour == 0 then
			vHour = 12
		end
	else
		vAMPM = 1

		if vHour > 12 then
			vHour = vHour - 12
		end
	end

	return vHour, vMinute, vAMPM
end

function Addon.DateLib:ConvertHMAMPMToTime(pHour, pMinute, pAMPM)
	local vHour
	
	if pAMPM == 0 then
		vHour = pHour
		if vHour == 12 then
			vHour = 0
		end
	else
		vHour = pHour + 12
		if vHour == 24 then
			vHour = 12
		end
	end
	
	return self:ConvertHMToTime(vHour, pMinute)
end

----------------------------------------
-- Date/time string conversion
----------------------------------------

function Addon.DateLib:GetLongDateString(pDate, pIncludeDayOfWeek)
	if not pDate then	
		return
	end
	
	local vFormat
	
	if pIncludeDayOfWeek then
		vFormat = self.cLongDateFormatWithDayOfWeek
	else
		vFormat = self.cLongDateFormat
	end
	
	return self:GetFormattedDateString(pDate, vFormat)
end

function Addon.DateLib:GetShortDateString(pDate, pIncludeDayOfWeek)
	if not pDate then	
		return
	end
	
	return self:GetFormattedDateString(pDate, self.cShortDateFormat)
end

function Addon.DateLib:FormatNamed(pFormat, pFields)
	return string.gsub(pFormat, "%$(%w+)", pFields)
end

function Addon.DateLib:GetFormattedDateString(pDate, pFormat)
	local vMonth, vDay, vYear = self:ConvertDateToMDY(pDate)
	
	local vDate =
			{
				dow = self.CALENDAR_WEEKDAY_NAMES[self:GetDayOfWeekFromDate(pDate) + 1],
				month = self.CALENDAR_MONTH_NAMES[vMonth],
				monthNum = vMonth,
				day = vDay,
				year = vYear,
			}
	
	return self:FormatNamed(pFormat, vDate)
end

----------------------------------------
-- Time zone estimation
----------------------------------------

function Addon.DateLib:CalculateTimeZoneOffset()
	local vServerDate, vServerTime = self:GetServerDateTime()
	local vLocalDate, vLocalTime = self:GetLocalDateTime()
	local vUTCDate, vUTCTime = self:GetUTCDateTime()
	
	local vLocalDateTime = vLocalDate * 1440 + vLocalTime
	local vServerDateTime = vServerDate * 1440 + vServerTime
	local vUTCDateTime = vUTCDate * 1440 + vUTCTime
	
	local vServerToLocalOffset = self:RoundTimeOffsetToNearest30(vLocalDateTime - vServerDateTime)
	
	self.ServerUTCOffset = self:RoundTimeOffsetToNearest30(vUTCDateTime - vServerDateTime)
	
	if vServerToLocalOffset ~= self.ServerToLocalOffset then
		self.ServerToLocalOffset = vServerToLocalOffset
		Addon.EventLib:DispatchEvent("SERVER_TIME_OFFSET_CHANGED")
	end
end

function Addon.DateLib:GetServerToLocalOffset()
	if not self.DidCalculateZoneOffset then
		self.DidCalculateZoneOffset = true
		self:CalculateTimeZoneOffset()
	end
	
	return self.ServerToLocalOffset
end

function Addon.DateLib:GetServerUTCOffset()
	if not self.DidCalculateZoneOffset then
		self.DidCalculateZoneOffset = true
		self:CalculateTimeZoneOffset()
	end
	
	return self.ServerUTCOffset
end

function Addon.DateLib:RoundTimeOffsetToNearest30(pOffset)
	local vNegativeOffset
	local vOffset
	
	if pOffset < 0 then
		vNegativeOffset = true
		vOffset = -pOffset
	else
		vNegativeOffset = false
		vOffset = pOffset
	end
	
	vOffset = vOffset - (math.fmod(vOffset + 15, 30) - 15)
	
	if vNegativeOffset then
		return -vOffset
	else
		return vOffset
	end
end

----------------------------------------
-- Date properties
----------------------------------------

function Addon.DateLib:GetDaysInMonth(pMonth, pYear)
	if not pMonth
	or not pYear then
		return
	end
	
	if pMonth == 2 and self:IsLeapYear(pYear) then
		return self.cDaysInMonth[pMonth] + 1
	else
		return self.cDaysInMonth[pMonth]
	end
end

function Addon.DateLib:GetDaysToMonth(pMonth, pYear)
	if pMonth > 2 and self:IsLeapYear(pYear) then
		return self.cDaysToMonth[pMonth] + 1
	elseif pMonth == 2 then
		return self.cDaysToMonth[pMonth]
	else
		return 0
	end
end

function Addon.DateLib:GetDaysInYear(pYear)
	if self:IsLeapYear(pYear) then
		return 366
	else
		return 365
	end
end

function Addon.DateLib:IsLeapYear(pYear)
	return (math.fmod(pYear, 400) == 0)
	   or ((math.fmod(pYear, 4) == 0) and (math.fmod(pYear, 100) ~= 0))
end

function Addon.DateLib:GetDaysToDate(pMonth, pDay, pYear)
	local vDays
	
	vDays = self.cDaysToMonth[pMonth] + pDay - 1
	
	if self:IsLeapYear(pYear) and pMonth > 2 then
		vDays = vDays + 1
	end
	
	return vDays
end

function Addon.DateLib:ConvertMDYToDate(pMonth, pDay, pYear)
	if not pMonth or not pDay or not pYear then
		return
	end
	
	local vDays = 0
	
	for vYear = 2000, pYear - 1 do
		vDays = vDays + self:GetDaysInYear(vYear)
	end
	
	return vDays + self:GetDaysToDate(pMonth, pDay, pYear)
end

function Addon.DateLib:ConvertDateToMDY(pDate)
	if not pDate then
		return nil
	end
	
	local vDays = pDate
	local vYear = 2000
	local vDaysInYear = self:GetDaysInYear(vYear)
	
	while vDays >= vDaysInYear do
		vDays = vDays - vDaysInYear

		vYear = vYear + 1
		vDaysInYear = self:GetDaysInYear(vYear)
	end
	
	local vIsLeapYear = self:IsLeapYear(vYear)
	
	for vMonth = 1, 12 do
		local vDaysInMonth = self.cDaysInMonth[vMonth]
		
		if vMonth == 2 and vIsLeapYear then
			vDaysInMonth = vDaysInMonth + 1
		end
		
		if vDays < vDaysInMonth then
			return vMonth, vDays + 1, vYear
		end
		
		vDays = vDays - vDaysInMonth
	end
	
	return 0, 0, 0
end

function Addon.DateLib:GetDayOfWeek(pMonth, pDay, pYear)
	local vDayOfWeek = 6 -- January 1, 2000 is a Saturday
	
	for vYear = 2000, pYear - 1 do
		if self:IsLeapYear(vYear) then
			vDayOfWeek = vDayOfWeek + 2
		else
			vDayOfWeek = vDayOfWeek + 1
		end
	end
	
	vDayOfWeek = vDayOfWeek + self:GetDaysToDate(pMonth, pDay, pYear)
	
	return math.fmod(vDayOfWeek, 7)
end

function Addon.DateLib:GetDayOfWeekFromDate(pDate)
	return math.fmod(pDate + 6, 7);  -- + 6 because January 1, 2000 is a Saturday
end

function Addon.DateLib:CompareMDY(pMonth1, pDay1, pYear1, pMonth2, pDay2, pYear2)
	if not pYear1 then
		return false, not pYear2
	elseif not pYear2 then
		return true
	end
	
	if pYear1 < pYear2 then
		return true
	elseif pYear1 > pYear2 then
		return false
	end
	
	if pMonth1 < pMonth2 then
		return true
	elseif pMonth1 > pMonth2 then
		return false
	end
	
	if pDay1 < pDay2 then
		return true
	elseif pDay1 > pDay2 then
		return false
	end
	
	-- They're equal
	
	return false, true
end

function Addon.DateLib:CompareHM(pHour1, pMinute1, pHour2, pMinute2)
	if not pHour1 then
		return false, not pHour2
	elseif not pHour2 then
		return true
	end
	
	if pHour1 < pHour2 then
		return true
	elseif pHour1 > pHour2 then
		return false
	end
	
	if pMinute1 < pMinute2 then
		return true
	elseif pMinute1 > pMinute2 then
		return false
	end
	
	-- They're equal
	
	return false, true
end

function Addon.DateLib:CompareMDYHM(pMonth1, pDay1, pYear1, pHour1, pMinute1, pMonth2, pDay2, pYear2, pHour2, pMinute2)
	local vLess, vEqual = self:CompareMDY(pMonth1, pDay1, pYear1, pMonth2, pDay2, pYear2)
	
	if not vEqual then
		return vLess
	end
	
	return self:CompareHM(pHour1, pMinute1, pHour2, pMinute2)
end

function Addon.DateLib:CompareDateTime(pDate1, pTime1, pDate2, pTime2)
	if not pDate1 then
		return false, not pDate2
	elseif not pDate2 then
		return true
	end
	
	if pDate1 < pDate2 then
		return true
	elseif pDate1 > pDate2 then
		return false
	end
	
	if not pTime1 then
		return false, not pTime2
	elseif not pTime2 then
		return true
	end
	
	if pTime1 < pTime2 then
		return true
	elseif pTime1 > pTime2 then
		return false
	end
	
	-- They're equal
	
	return false, true
end
