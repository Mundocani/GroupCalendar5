----------------------------------------
-- Group Calendar 5 Copyright (c) 2018 John Stephen
-- This software is licensed under the MIT license.
-- See the included LICENSE.txt file for more information.
----------------------------------------

if GetLocale() == "ruRU" then

GroupCalendar.cTitle = "Организатор %s"
GroupCalendar.cCantReloadUI = "Вам необходимо перезапустить WoW для обновления Group Calendar"

GroupCalendar.cHelpHeader = "Group Calendar Commands"
GroupCalendar.cHelpHelp = "Shows this list of commands"
GroupCalendar.cHelpReset = "Resets all saved data and settings"
GroupCalendar.cHelpDebug = "Enables or disables the debug code"
GroupCalendar.cHelpClock = "Sets the minimap clock to display local time or server time"
GroupCalendar.cHelpiCal = "Generates iCal data (default is 'all')"
GroupCalendar.cHelpReminder = "Turns reminders on or off"
GroupCalendar.cHelpBirth = "Turns birthday announcements on or off"
GroupCalendar.cHelpAttend = "Turns attendance reminders on or off"
GroupCalendar.cHelpShow = "Shows the calendar window"

GroupCalendar.cTooltipScheduleItemFormat = "%s (%s)"

GroupCalendar.cForeignRealmFormat = "%s из %s"

GroupCalendar.cSingleItemFormat = "%s"
GroupCalendar.cTwoItemFormat = "%s и %s"
GroupCalendar.cMultiItemFormat = "%s{{, %s}} и %s"

-- Event names

GroupCalendar.cGeneralEventGroup = "Общий"
GroupCalendar.cPersonalEventGroup = "Личные (не общий)"
GroupCalendar.cRaidClassicEventGroup = "Рейды (Азерот)"
GroupCalendar.cTBCRaidEventGroup = "Рейды (Запределье)"
GroupCalendar.cWotLKRaidEventGroup = "Рейды (WotLK)"
GroupCalendar.cDungeonEventGroup = "Инстансы (Азерот)"
GroupCalendar.cOutlandsDungeonEventGroup = "Инстансы (Запределье)"
GroupCalendar.cWotLKDungeonEventGroup = "Инстансы (WotLK)"
GroupCalendar.cOutlandsHeroicDungeonEventGroup = "Героики (Запределье)"
GroupCalendar.cWotLKHeroicDungeonEventGroup = "Героики (WotLK)"
GroupCalendar.cBattlegroundEventGroup = "ПвП"
GroupCalendar.cOutdoorRaidEventGroup = "Внешние Рейды"

GroupCalendar.cMeetingEventName = "Собрание"
GroupCalendar.cBirthdayEventName = "День рождения"
GroupCalendar.cRoleplayEventName = "Ролевая игра"
GroupCalendar.cHolidayEventName = "Развлечения"
GroupCalendar.cDentistEventName = "Дантист"
GroupCalendar.cDoctorEventName = "Доктор"
GroupCalendar.cVacationEventName = "Дуэли, тренинг ПвП"
GroupCalendar.cOtherEventName = "Другое"

GroupCalendar.cCooldownEventName = "%s Доступна"

GroupCalendar.cPersonalEventOwner = "Личный"
GroupCalendar.cBlizzardOwner = "Blizzard"

GroupCalendar.cNone = "None"

GroupCalendar.cAvailableMinutesFormat = "%s через %d минуты"
GroupCalendar.cAvailableMinuteFormat = "%s через %d минут"
GroupCalendar.cStartsMinutesFormat = "%s старт через %d минут"
GroupCalendar.cStartsMinuteFormat = "%s старт через %d минуты"
GroupCalendar.cStartingNowFormat = "%s уже начинается"
GroupCalendar.cAlreadyStartedFormat = "%s уже начался"
GroupCalendar.cHappyBirthdayFormat = "С днем рождения %s!"

GroupCalendar.cLocalTimeNote = "(%s local)"
GroupCalendar.cServerTimeNote = "(%s server)"

-- Roles

GroupCalendar.cHRole = "Целитель"
GroupCalendar.cTRole = "Танк"
GroupCalendar.cRRole = "Снайпер"
GroupCalendar.cMRole = "ДД"

GroupCalendar.cHPluralRole = "Целитель"
GroupCalendar.cTPluralRole = "Танк"
GroupCalendar.cRPluralRole = "Снайпер"
GroupCalendar.cMPluralRole = "Паразит"

GroupCalendar.cHPluralLabel = GroupCalendar.cHPluralRole..":"
GroupCalendar.cTPluralLabel = GroupCalendar.cTPluralRole..":"
GroupCalendar.cRPluralLabel = GroupCalendar.cRPluralRole..":"
GroupCalendar.cMPluralLabel = GroupCalendar.cMPluralRole..":"

-- iCalendar export

GroupCalendar.cExportTitle = "Export to iCalendar"
GroupCalendar.cExportSummary = "Addons can not write files directly to your computer for you, so exporting the iCalendar data requires a few easy steps you must complete yourself"
GroupCalendar.cExportInstructions =
{
	"Step 1: "..HIGHLIGHT_FONT_COLOR_CODE.."Select the event types to be included",
	"Step 2: "..HIGHLIGHT_FONT_COLOR_CODE.."Copy the text in the Data box",
	"Step 3: "..HIGHLIGHT_FONT_COLOR_CODE.."Create a new file using any text editor and paste in the text",
	"Step 4: "..HIGHLIGHT_FONT_COLOR_CODE.."Save the file with an extension of '.ics' (ie, Calendar.ics)",
	RED_FONT_COLOR_CODE.."IMPORTANT: "..HIGHLIGHT_FONT_COLOR_CODE.."You must save the file as plain text or it will not be usable",
	"Step 5: "..HIGHLIGHT_FONT_COLOR_CODE.."Import the file into your calendar application",
}

GroupCalendar.cPrivateEvents = "Private events"
GroupCalendar.cGuildEvents = "Guild events"
GroupCalendar.cHolidays = "Holidays"
GroupCalendar.cTradeskills = "Cooldown events"
GroupCalendar.cPersonalEvents = "Personal events"
GroupCalendar.cAlts = "Alts"
GroupCalendar.cOthers = "Others"

GroupCalendar.cExportData = "Data"

-- Event Edit tab

GroupCalendar.cLevelRangeFormat = "С уровня %i до %i"
GroupCalendar.cMinLevelFormat = "С уровня %i и выше"
GroupCalendar.cMaxLevelFormat = "До уровня %i"
GroupCalendar.cAllLevels = "Все уровни"
GroupCalendar.cSingleLevel = "Только %i уровня"

GroupCalendar.cYes = "Да! Я буду на этом событии"
GroupCalendar.cNo = "Нет! Я не буду на этом событии"
GroupCalendar.cMaybe = "Возможно. Запишите в список резерва"

GroupCalendar.cStatusFormat = "Status: %s"
GroupCalendar.cInvitedByFormat = "Invited by %s"

GroupCalendar.cInvitedStatus = "Invited, awaiting your response"
GroupCalendar.cAcceptedStatus = "Accepted, awaiting confirmation"
GroupCalendar.cDeclinedStatus = CALENDAR_STATUS_DECLINED
GroupCalendar.cConfirmedStatus = CALENDAR_STATUS_CONFIRMED
GroupCalendar.cOutStatus = CALENDAR_STATUS_OUT
GroupCalendar.cStandbyStatus = CALENDAR_STATUS_STANDBY
GroupCalendar.cSignedUpStatus = CALENDAR_STATUS_SIGNEDUP
GroupCalendar.cNotSignedUpStatus = CALENDAR_STATUS_NOT_SIGNEDUP

GroupCalendar.cAllDay = "All day"

GroupCalendar.cEventModeLabel = "Mode:"
GroupCalendar.cTimeLabel = "Время:"
GroupCalendar.cDurationLabel = "Длина:"
GroupCalendar.cEventLabel = "Событие:"
GroupCalendar.cTitleLabel = "Название:"
GroupCalendar.cLevelsLabel = "Уровни:"
GroupCalendar.cLevelRangeSeparator = "до"
GroupCalendar.cDescriptionLabel = "Описание:"
GroupCalendar.cCommentLabel = "Заметка:"
GroupCalendar.cRepeatLabel = "Repeat:"
GroupCalendar.cAutoConfirmLabel = "Auto confirm"
GroupCalendar.cLockoutLabel = "Auto-close:"
GroupCalendar.cEventClosedLabel = "Signups closed"
GroupCalendar.cAutoConfirmRoleLimitsTitle = "Auto confirm limits"
GroupCalendar.cAutoConfirmLimitsLabel = "Limits..."
GroupCalendar.cNormalMode = "Private event"
GroupCalendar.cAnnounceMode = "Guild announcement"
GroupCalendar.cSignupMode = "Guild event"

GroupCalendar.cLockout0 = "at the start"
GroupCalendar.cLockout15 = "15 minutes early"
GroupCalendar.cLockout30 = "30 minutes early"
GroupCalendar.cLockout60 = "1 hour early"
GroupCalendar.cLockout120 = "2 hours early"
GroupCalendar.cLockout180 = "3 hours early"
GroupCalendar.cLockout1440 = "1 day early"

GroupCalendar.cPluralMinutesFormat = "%d минут"
GroupCalendar.cSingularHourFormat = "%d час"
GroupCalendar.cPluralHourFormat = "%d часа"
GroupCalendar.cSingularHourPluralMinutes = "%d час %d минут"
GroupCalendar.cPluralHourPluralMinutes = "%d часа %d минут"

GroupCalendar.cNewerVersionMessage = "Доступна новая версия (%s)"

GroupCalendar.cDelete = "Удалить"

-- Event Group tab

GroupCalendar.cViewGroupBy = "Группы по"
GroupCalendar.cViewByStatus = "Статусу"
GroupCalendar.cViewByClass = "Классу"
GroupCalendar.cViewByRole = "Роли"
GroupCalendar.cViewSortBy = "Сортировать"
GroupCalendar.cViewByDate = "По дате"
GroupCalendar.cViewByRank = "По рангу"
GroupCalendar.cViewByName = "По Имени"

GroupCalendar.cInviteButtonTitle = "Пригласить"
GroupCalendar.cAutoSelectButtonTitle = "Выбрать игроков..."
GroupCalendar.cAutoSelectWindowTitle = "Выбрать игроков"

GroupCalendar.cNoSelection = "Нет выбранных игроков"
GroupCalendar.cSingleSelection = "1 игрок выбран"
GroupCalendar.cMultiSelection = "%d игрока выбраны"

GroupCalendar.cInviteNeedSelectionStatus = "Выбрать для приглашения"
GroupCalendar.cInviteReadyStatus = "Готовы для приглашения"
GroupCalendar.cInviteInitialInvitesStatus = "Отправить приглашение"
GroupCalendar.cInviteAwaitingAcceptanceStatus = "Ожидание приема"
GroupCalendar.cInviteConvertingToRaidStatus = "Конвертировать в рейд"
GroupCalendar.cInviteInvitingStatus = "Рассылка приглашений"
GroupCalendar.cInviteCompleteStatus = "Приглашение закончено"
GroupCalendar.cInviteReadyToRefillStatus = "Заполнения свободных мест готово"
GroupCalendar.cInviteNoMoreAvailableStatus = "Нет больше игроков чтобы вступить в группу"
GroupCalendar.cRaidFull = "Рейд полон"

GroupCalendar.cWhisperPrefix = "[Организатор]"
GroupCalendar.cInviteWhisperFormat = "%s Приветствую! Я приглашаю вас для Участия в событии '%s'.  Если вы можете, то прошу принять участие в этом событии."
GroupCalendar.cAlreadyGroupedWhisper = "%s Вы уже в группе :(.  Пожалуйста /w отпишите, когда вы покинете группу."

GroupCalendar.cJoinedGroupStatus = "Присоединен"
GroupCalendar.cInvitedGroupStatus = "Приглашен"
GroupCalendar.cReadyGroupStatus = "Готов"
GroupCalendar.cGroupedGroupStatus = "В другой группе"
GroupCalendar.cStandbyGroupStatus = "Резерв"
GroupCalendar.cMaybeGroupStatus = "Возможно"
GroupCalendar.cDeclinedGroupStatus = "Отклонил приглашение"
GroupCalendar.cOfflineGroupStatus = "Не в сети"
GroupCalendar.cLeftGroupStatus = "Покинул группу"

GroupCalendar.cTotalLabel = "Total:"

GroupCalendar.cAutoConfirmationTitle = "Авто подтвердить по классу"
GroupCalendar.cRoleConfirmationTitle = "Авто подтвердить по роли"
GroupCalendar.cManualConfirmationTitle = "Ручное подтверждение"
GroupCalendar.cClosedEventTitle = "Закрытое событие"
GroupCalendar.cMinLabel = "мин"
GroupCalendar.cMaxLabel = "макс"

GroupCalendar.cStandby = CALENDAR_STATUS_STANDBY

-- Limits dialog

GroupCalendar.cMaxPartySizeLabel = "Макс размер группы:"
GroupCalendar.cMinPartySizeLabel = "Мин размер группы:"
GroupCalendar.cNoMinimum = "Нет минимума"
GroupCalendar.cNoMaximum = "Не ограничено"
GroupCalendar.cPartySizeFormat = "%d игроков"

GroupCalendar.cAddPlayerTitle = "Добавить..."
GroupCalendar.cAutoConfirmButtonTitle = "Настройки..."

GroupCalendar.cClassLimitDescription = "В области ниже, установите минимальное и максимальное количество каждого класса. Игроки не попавшие в лимит автоматически попадают в резерв. Дополнительные места будут заполнены в порядке ответа до достижения максимума."
GroupCalendar.cRoleLimitDescription = "В области ниже, установите минимальное и максимальное количество каждой роли.  Игроки не попавшие в лимит автоматически попадают в резерв. Дополнительные места будут заполнены в порядке ответа до достижения максимума..  Вы можете по выбору установить число минимума классов по роли (запрашивая одного удаленного дамагера шадов приста для примера)"

GroupCalendar.cPriorityLabel = "Приоритет:"
GroupCalendar.cPriorityDate = "Дата"
GroupCalendar.cPriorityRank = "Ранг"

GroupCalendar.cCachedEventStatus = "This event is a cached copy from $Name's calendar\rLast refreshed on $Date at $Time"

-- Class names

GroupCalendar.cClassName =
{
	DRUID = {Male = LOCALIZED_CLASS_NAMES_MALE.DRUID, Female = LOCALIZED_CLASS_NAMES_FEMALE.DRUID, Plural = "Друиды"},
	HUNTER = {Male = LOCALIZED_CLASS_NAMES_MALE.HUNTER, Female = LOCALIZED_CLASS_NAMES_FEMALE.HUNTER, Plural = "Охотники"},
	MAGE = {Male = LOCALIZED_CLASS_NAMES_MALE.MAGE, Female = LOCALIZED_CLASS_NAMES_FEMALE.MAGE, Plural = "Маги"},
	PALADIN = {Male = LOCALIZED_CLASS_NAMES_MALE.PALADIN, Female = LOCALIZED_CLASS_NAMES_FEMALE.PALADIN, Plural = "Паладины"},
	PRIEST = {Male = LOCALIZED_CLASS_NAMES_MALE.PRIEST, Female = LOCALIZED_CLASS_NAMES_FEMALE.PRIEST, Plural = "Жрецы"},
	ROGUE = {Male = LOCALIZED_CLASS_NAMES_MALE.ROGUE, Female = LOCALIZED_CLASS_NAMES_FEMALE.ROGUE, Plural = "Разбойники"},
	SHAMAN = {Male = LOCALIZED_CLASS_NAMES_MALE.SHAMAN, Female = LOCALIZED_CLASS_NAMES_FEMALE.SHAMAN, Plural = "Шаманы"},
	WARLOCK = {Male = LOCALIZED_CLASS_NAMES_MALE.WARLOCK, Female = LOCALIZED_CLASS_NAMES_FEMALE.WARLOCK, Plural = "Чернокнижники"},
	WARRIOR = {Male = LOCALIZED_CLASS_NAMES_MALE.WARRIOR, Female = LOCALIZED_CLASS_NAMES_FEMALE.WARRIOR, Plural = "Воины"},
	DEATHKNIGHT = {Male = LOCALIZED_CLASS_NAMES_MALE.DEATHKNIGHT, Female = LOCALIZED_CLASS_NAMES_FEMALE.DEATHKNIGHT, Plural = "Death Knights"},
	MONK = {Male = LOCALIZED_CLASS_NAMES_MALE.MONK, Female = LOCALIZED_CLASS_NAMES_FEMALE.MONK, Plural = "Monks"},
	DEMONHUNTER = {Male = LOCALIZED_CLASS_NAMES_MALE.DEMONHUNTER, Female = LOCALIZED_CLASS_NAMES_FEMALE.DEMONHUNTER, Plural = "Demon Hunters"},
}

GroupCalendar.cCurrentPartyOrRaid = "Current party or raid"

GroupCalendar.cViewByFormat = "View by %s / %s"

GroupCalendar.cConfirm = "Confirm"

GroupCalendar.cSingleTimeDateFormat = "%s\r%s"
GroupCalendar.cTimeDateRangeFormat = "%s\rc %s до %s"

GroupCalendar.cStartEventHelp = "Click Start to begin forming your party or raid"
GroupCalendar.cResumeEventHelp = "Click Resume to continue forming your party or raid"

GroupCalendar.cShowClassReservations = "Reservations >>>"
GroupCalendar.cHideClassReservations = "<<< Reservations"

GroupCalendar.cInviteStatusText =
{
	JOINED = "|cff00ff00Присоединен",
	CONFIRMED = "|cff88ff00Готов",
	STANDBY = "|cffffff00Резерв",
	INVITED = "|cff00ff00Приглашен",
	DECLINED = "|cffff0000Отклонил приглашение",
	BUSY = "|cffff0000В другой группе",
	OFFLINE = "|cff888888Не в сети",
	LEFT = "|cff0000ffПокинул группу",
}

GroupCalendar.cStart = "Start"
GroupCalendar.cPause = "Pause"
GroupCalendar.cResume = "Resume"
GroupCalendar.cRestart = "Restart"

-- About tab

GroupCalendar.cAboutTitle = "Об Организаторе %s"
GroupCalendar.cAboutAuthor = "Разработал и написал аддон John Stephen"
GroupCalendar.cAboutThanks = "Many thanks to all fans and supporters.  I hope my addons add to your gaming enjoyment as much as building them adds to mine."

-- Partners tab

GroupCalendar.cPartnersTitle = "Multi-guild partnerships"
GroupCalendar.cPartnersDescription1 = "Multi-guild partnerships make it easy to coordinate events across guilds by sharing guild rosters (name, rank, class and level only) with your partner guilds"
GroupCalendar.cPartnersDescription2 = "To create a partnership, add a player using the Add Player button at the bottom of this window"
GroupCalendar.cAddPlayer = "Добавить игрока..."
GroupCalendar.cRemovePlayer = "Remove Player..."

GroupCalendar.cPartnersLabel = NORMAL_FONT_COLOR_CODE.."Partners:"..FONT_COLOR_CODE_CLOSE.." %s"
GroupCalendar.cSync = "Sync"

GroupCalendar.cConfirmDeletePartnerGuild = "Are you sure you want to delete your partnership with <%s>?"
GroupCalendar.cConfirmDeletePartner = "Are you sure you want to remove %s from your partnerships?"
GroupCalendar.cConfirmPartnerRequest = "[Group Calendar]: %s is requesting a partnership with you."

GroupCalendar.cLastPartnerUpdate = "Last synchronized %s %s"
GroupCalendar.cNoPartnerUpdate = "Not synchronized"

GroupCalendar.cPartnerStatus =
{
	PARTNER_SYNC_CONNECTING = "Connecting to %s",
	PARTNER_SYNC_CONNECTED = "Synchronizing with %s",
}

-- Settings tab

GroupCalendar.cSettingsTitle = "Settings"
GroupCalendar.cThemeLabel = "Theme"
GroupCalendar.cParchmentThemeName = "Parchment"
GroupCalendar.cLightParchmentThemeName = "Light Parchment"
GroupCalendar.cSeasonalThemeName = "Seasonal"
GroupCalendar.cTwentyFourHourTime = "24 hour time"
GroupCalendar.cAnnounceBirthdays = "Show birthday reminders"
GroupCalendar.cAnnounceEvents = "Show event reminders"
GroupCalendar.cAnnounceTradeskills = "Show tradeskill reminders"
GroupCalendar.cRecordTradeskills = "Record tradeskill cooldowns"
GroupCalendar.cRememberInvites = "Remember event invitations for use in future events"

GroupCalendar.cUnderConstruction = "This area is under construction"

GroupCalendar.cUnknown = "Неизвестно"

-- Invite tab

GroupCalendar.cModeratorTooltipTitle = "Moderator"
GroupCalendar.cModeratorTooltipDescription = "Turn this on to allow this player or group to co-manage your event"

-- Main window

GroupCalendar.cCalendar = "Календарь"
GroupCalendar.cSettings = "Установки"
GroupCalendar.cPartners = "Partners"
GroupCalendar.cExport = "Export"
GroupCalendar.cAbout = "О Аддоне"

GroupCalendar.cUseServerDateTime = "Дата и Время сервера"
GroupCalendar.cUseServerDateTimeDescription = "Включите, для использования серверного время и даты для событий, либо выключите, чтобы использовалось локальное время и дата"
GroupCalendar.cShowCalendarLabel = "Show:"
GroupCalendar.cShowAlts = "Show alts"
GroupCalendar.cShowAltsDescription = "Turn on to show events cached from your other characters"
GroupCalendar.cShowDarkmoonCalendarDescription = "Turn on to show the Darkmoon Faire schedule"
GroupCalendar.cShowWeeklyCalendarDescription = "Turn on to show weekly events such as the Fishing Extravaganza"
GroupCalendar.cShowPvPCalendarDescription = "Turn on to show PvP weekends"
GroupCalendar.cShowLockoutCalendarDescription = "Turn on to show you active dungeon lockouts"

GroupCalendar.cMinimapButtonHint = "Left-click to show Group Calendar."
GroupCalendar.cMinimapButtonHint2 = "Right-click to show the WoW calendar."

GroupCalendar.cNewEvent = "New Event..."
GroupCalendar.cPasteEvent = "Paste Event"

GroupCalendar.cConfirmDelete = "Are you sure you want to delete this event?  This will remove the event from all calendars, including other players."

GroupCalendar.cGermanLocalization = "German Localization"
GroupCalendar.cChineseLocalization = "Chinese Localization"
GroupCalendar.cFrenchLocalization = "French Localization"
GroupCalendar.cSpanishLocalization = "Spanish Localization"
GroupCalendar.cRussianLocalization = "Russian Localization"
GroupCalendar.cContributingDeveloper = "Contributing Developer"
GroupCalendar.cGuildCreditFormat = "The guild of %s"

GroupCalendar.cExpiredEventNote = "This event has already occurred and can no longer be modified"

GroupCalendar.cMore = "more..."

GroupCalendar.cRespondedDateFormat = "Responded on %s"

GroupCalendar.cStartDayLabel = "Start week on:"

end -- ruRU
