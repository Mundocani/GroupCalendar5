----------------------------------------
-- Group Calendar 5 Copyright 2005 - 2016 John Stephen, wobbleworks.com
-- All rights reserved, unauthorized redistribution is prohibited
----------------------------------------

if GetLocale() == "zhCN" then

GroupCalendar.cTitle = "团体行事历 v%s"
GroupCalendar.cCantReloadUI = "你必须重新启动游戏来完成 Group Calendar 的此次版本更新"

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

GroupCalendar.cForeignRealmFormat = "%s of %s"

GroupCalendar.cSingleItemFormat = "%s"
GroupCalendar.cTwoItemFormat = "%s and %s"
GroupCalendar.cMultiItemFormat = "%s{{, %s}} and %s"

-- Event names

GroupCalendar.cGeneralEventGroup = "综合"
GroupCalendar.cPersonalEventGroup = "私人 (非共享)"
GroupCalendar.cRaidClassicEventGroup = "团队 (艾泽拉斯)"
GroupCalendar.cTBCRaidEventGroup = "团队 (外域)"
GroupCalendar.cWotLKRaidEventGroup = "团队 (WotLK)"
GroupCalendar.cDungeonEventGroup = "地下城 (艾泽拉斯)"
GroupCalendar.cOutlandsDungeonEventGroup = "地下城 (外域)"
GroupCalendar.cWotLKDungeonEventGroup = "地下城 (WotLK)"
GroupCalendar.cOutlandsHeroicDungeonEventGroup = "英雄模式副本 (外域)"
GroupCalendar.cWotLKHeroicDungeonEventGroup = "英雄模式副本 (WotLK)"
GroupCalendar.cBattlegroundEventGroup = "战场"
GroupCalendar.cOutdoorRaidEventGroup = "Outdoor Raids"

GroupCalendar.cMeetingEventName = "聚会"
GroupCalendar.cBirthdayEventName = "生日"
GroupCalendar.cRoleplayEventName = "角色扮演"
GroupCalendar.cHolidayEventName = "假期"
GroupCalendar.cDentistEventName = "牙医"
GroupCalendar.cDoctorEventName = "医生"
GroupCalendar.cVacationEventName = "假期"
GroupCalendar.cOtherEventName = "其它"

GroupCalendar.cCooldownEventName = "%s 就绪"

GroupCalendar.cPersonalEventOwner = "私人"
GroupCalendar.cBlizzardOwner = "Blizzard"

GroupCalendar.cNone = "None"

GroupCalendar.cAvailableMinutesFormat = "%s 尚余 %d 分钟"
GroupCalendar.cAvailableMinuteFormat = "%s 尚余 %d 分钟"
GroupCalendar.cStartsMinutesFormat = "%s 将于 %d 分钟后开始"
GroupCalendar.cStartsMinuteFormat = "%s 将于 in %d 分钟内开始"
GroupCalendar.cStartingNowFormat = "%s 现在开始"
GroupCalendar.cAlreadyStartedFormat = "%s 已经开始"
GroupCalendar.cHappyBirthdayFormat = "%s 生日快乐!"

GroupCalendar.cLocalTimeNote = "(%s 本地)"
GroupCalendar.cServerTimeNote = "(%s server)"

-- Roles

GroupCalendar.cHRole = "Healer"
GroupCalendar.cTRole = "Tank"
GroupCalendar.cRRole = "Ranged"
GroupCalendar.cMRole = "Melee"

GroupCalendar.cHPluralRole = "Healers"
GroupCalendar.cTPluralRole = "Tanks"
GroupCalendar.cRPluralRole = "Ranged"
GroupCalendar.cMPluralRole = "Melee"

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

GroupCalendar.cLevelRangeFormat = "等级 %i 至 %i"
GroupCalendar.cMinLevelFormat = "等级 %i 或以上"
GroupCalendar.cMaxLevelFormat = "等级 %i 或以下"
GroupCalendar.cAllLevels = "所有等级"
GroupCalendar.cSingleLevel = "只限等级 %i"

GroupCalendar.cYes = "嗯! 我会出席此活动"
GroupCalendar.cNo = "不, 我不会出席此活动"
GroupCalendar.cMaybe = "Maybe. I'm not sure yet"

GroupCalendar.cStatusFormat = "Status: %s"
GroupCalendar.cInvitedByFormat = "Invited by %s"

GroupCalendar.cInvitedStatus = "Invited, awaiting your response"
GroupCalendar.cAcceptedStatus = "Accepted, awaiting confirmation"
GroupCalendar.cTentativeStatus = "Tentative, awaiting confirmation"
GroupCalendar.cDeclinedStatus = CALENDAR_STATUS_DECLINED
GroupCalendar.cConfirmedStatus = CALENDAR_STATUS_CONFIRMED
GroupCalendar.cOutStatus = CALENDAR_STATUS_OUT
GroupCalendar.cStandbyStatus = CALENDAR_STATUS_STANDBY
GroupCalendar.cSignedUpStatus = CALENDAR_STATUS_SIGNEDUP
GroupCalendar.cNotSignedUpStatus = CALENDAR_STATUS_NOT_SIGNEDUP

GroupCalendar.cAllDay = "All day"

GroupCalendar.cEventModeLabel = "Mode:"
GroupCalendar.cTimeLabel = "时间:"
GroupCalendar.cDurationLabel = "需时:"
GroupCalendar.cEventLabel = "活动:"
GroupCalendar.cTitleLabel = "标题:"
GroupCalendar.cLevelsLabel = "等级:"
GroupCalendar.cLevelRangeSeparator = "至"
GroupCalendar.cDescriptionLabel = "内容:"
GroupCalendar.cCommentLabel = "备注:"
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

GroupCalendar.cPluralMinutesFormat = "%d分钟"
GroupCalendar.cSingularHourFormat = "%d小时"
GroupCalendar.cPluralHourFormat = "%d小时"
GroupCalendar.cSingularHourPluralMinutes = "%d小时%d分钟"
GroupCalendar.cPluralHourPluralMinutes = "%d小时%d分钟"

GroupCalendar.cNewerVersionMessage = "A newer version is available (%s)"

GroupCalendar.cDelete = "删除"

-- Event Group tab

GroupCalendar.cViewGroupBy = "Group by"
GroupCalendar.cViewByStatus = "检视状态"
GroupCalendar.cViewByClass = "Class"
GroupCalendar.cViewByRole = "Role"
GroupCalendar.cViewSortBy = "Sort by"
GroupCalendar.cViewByDate = "检视日期"
GroupCalendar.cViewByRank = "检视阶级"
GroupCalendar.cViewByName = "检视名称"

GroupCalendar.cInviteButtonTitle = "邀请已选玩家"
GroupCalendar.cAutoSelectButtonTitle = "选取玩家..."
GroupCalendar.cAutoSelectWindowTitle = "选取玩家"

GroupCalendar.cNoSelection = "没有玩家选取"
GroupCalendar.cSingleSelection = "选取了 1 位玩家"
GroupCalendar.cMultiSelection = "选取了 %d 位玩家"

GroupCalendar.cInviteNeedSelectionStatus = "选择准备邀请的玩家"
GroupCalendar.cInviteReadyStatus = "准备邀请"
GroupCalendar.cInviteInitialInvitesStatus = "传送首次的邀请"
GroupCalendar.cInviteAwaitingAcceptanceStatus = "等待首次的邀请回应"
GroupCalendar.cInviteConvertingToRaidStatus = "转换至团队"
GroupCalendar.cInviteInvitingStatus = "传送邀请"
GroupCalendar.cInviteCompleteStatus = "邀请完毕"
GroupCalendar.cInviteReadyToRefillStatus = "准备填补空缺"
GroupCalendar.cInviteNoMoreAvailableStatus = "已经没有玩家可以填补队伍"
GroupCalendar.cRaidFull = "团队已满"

GroupCalendar.cWhisperPrefix = "[团体行事历]"
GroupCalendar.cInviteWhisperFormat = "%s 您已经被邀请加入 '%s' 活动。若阁下想加入此活动，请接受此邀请。"
GroupCalendar.cAlreadyGroupedWhisper = "%s 您已经加入了一个队伍。请阁下您在取消您的队伍后，使用 /w 回覆。"

GroupCalendar.cJoinedGroupStatus = "已加入"
GroupCalendar.cInvitedGroupStatus = "已邀请"
GroupCalendar.cReadyGroupStatus = "就绪"
GroupCalendar.cGroupedGroupStatus = "在其他队伍"
GroupCalendar.cStandbyGroupStatus = "等候"
GroupCalendar.cMaybeGroupStatus = "Maybe"
GroupCalendar.cDeclinedGroupStatus = "拒绝邀请"
GroupCalendar.cOfflineGroupStatus = "下线"
GroupCalendar.cLeftGroupStatus = "离开队伍"

GroupCalendar.cTotalLabel = "Total:"

GroupCalendar.cAutoConfirmationTitle = "自动确认"
GroupCalendar.cRoleConfirmationTitle = "Auto Confirm by Role"
GroupCalendar.cManualConfirmationTitle = "手动确认"
GroupCalendar.cClosedEventTitle = "关闭活动"

GroupCalendar.cMinLabel = "最低"
GroupCalendar.cMaxLabel = "最高"

GroupCalendar.cStandby = CALENDAR_STATUS_STANDBY

-- Limits dialog

GroupCalendar.cMaxPartySizeLabel = "队伍人数上限:"
GroupCalendar.cMinPartySizeLabel = "队伍人数下限:"
GroupCalendar.cNoMinimum = "没有下限"
GroupCalendar.cNoMaximum = "没有上限"
GroupCalendar.cPartySizeFormat = "%d 位玩家"

GroupCalendar.cAddPlayerTitle = "新增..."
GroupCalendar.cAutoConfirmButtonTitle = "设定..."

GroupCalendar.cClassLimitDescription = "设定下列每种职业的最低及最高人数。若该职业的人数尚未符合最低要求，您将被自动填补空缺。当人数到达上限时，将会有额外的提示。"
GroupCalendar.cRoleLimitDescription = "Set the minimum and maximum numbers of players for each role.  Minimums will be met first, extra spots beyond the minimum will be filled until the maximum is reached or the group is full.  You can also reserve spaces within each role for particular classes (requiring one ranged dps to be a shadow priest for example)"

GroupCalendar.cPriorityLabel = "优先权:"
GroupCalendar.cPriorityDate = "时间"
GroupCalendar.cPriorityRank = "阶级"

GroupCalendar.cCachedEventStatus = "This event is a cached copy from $Name's calendar\rLast refreshed on $Date at $Time"

-- Class names

GroupCalendar.cClassName =
{
	DRUID = {Male = LOCALIZED_CLASS_NAMES_MALE.DRUID, Female = LOCALIZED_CLASS_NAMES_FEMALE.DRUID, Plural = "Druids"},
	HUNTER = {Male = LOCALIZED_CLASS_NAMES_MALE.HUNTER, Female = LOCALIZED_CLASS_NAMES_FEMALE.HUNTER, Plural = "Hunters"},
	MAGE = {Male = LOCALIZED_CLASS_NAMES_MALE.MAGE, Female = LOCALIZED_CLASS_NAMES_FEMALE.MAGE, Plural = "Mages"},
	PALADIN = {Male = LOCALIZED_CLASS_NAMES_MALE.PALADIN, Female = LOCALIZED_CLASS_NAMES_FEMALE.PALADIN, Plural = "Paladins"},
	PRIEST = {Male = LOCALIZED_CLASS_NAMES_MALE.PRIEST, Female = LOCALIZED_CLASS_NAMES_FEMALE.PRIEST, Plural = "Priests"},
	ROGUE = {Male = LOCALIZED_CLASS_NAMES_MALE.ROGUE, Female = LOCALIZED_CLASS_NAMES_FEMALE.ROGUE, Plural = "Rogues"},
	SHAMAN = {Male = LOCALIZED_CLASS_NAMES_MALE.SHAMAN, Female = LOCALIZED_CLASS_NAMES_FEMALE.SHAMAN, Plural = "Shaman"},
	WARLOCK = {Male = LOCALIZED_CLASS_NAMES_MALE.WARLOCK, Female = LOCALIZED_CLASS_NAMES_FEMALE.WARLOCK, Plural = "Warlocks"},
	WARRIOR = {Male = LOCALIZED_CLASS_NAMES_MALE.WARRIOR, Female = LOCALIZED_CLASS_NAMES_FEMALE.WARRIOR, Plural = "Warriors"},
	DEATHKNIGHT = {Male = LOCALIZED_CLASS_NAMES_MALE.DEATHKNIGHT, Female = LOCALIZED_CLASS_NAMES_FEMALE.DEATHKNIGHT, Plural = "Death Knights"},
	MONK = {Male = LOCALIZED_CLASS_NAMES_MALE.MONK, Female = LOCALIZED_CLASS_NAMES_FEMALE.MONK, Plural = "Monks"},
	DEMONHUNTER = {Male = LOCALIZED_CLASS_NAMES_MALE.DEMONHUNTER, Female = LOCALIZED_CLASS_NAMES_FEMALE.DEMONHUNTER, Plural = "Demon Hunters"},
}

GroupCalendar.cCurrentPartyOrRaid = "Current party or raid"

GroupCalendar.cViewByFormat = "View by %s / %s"

GroupCalendar.cConfirm = "Confirm"

GroupCalendar.cSingleTimeDateFormat = "%s %s"
GroupCalendar.cTimeDateRangeFormat = "%s %s至%s"

GroupCalendar.cStartEventHelp = "Click Start to begin forming your party or raid"
GroupCalendar.cResumeEventHelp = "Click Resume to continue forming your party or raid"

GroupCalendar.cShowClassReservations = "Reservations >>>"
GroupCalendar.cHideClassReservations = "<<< Reservations"

GroupCalendar.cInviteStatusText =
{
	JOINED = "|cff00ff00已加入",
	CONFIRMED = "|cff88ff00就绪",
	STANDBY = "|cffffff00等候",
	INVITED = "|cff00ff00已邀请",
	DECLINED = "|cffff0000拒绝邀请",
	BUSY = "|cffff0000在其他队伍",
	OFFLINE = "|cff888888下线",
	LEFT = "|cff0000ff离开队伍",
}

GroupCalendar.cStart = "Start"
GroupCalendar.cPause = "Pause"
GroupCalendar.cResume = "Resume"
GroupCalendar.cRestart = "Restart"

-- About tab

GroupCalendar.cAboutTitle = "关于团体行事历 s"
GroupCalendar.cAboutAuthor = "由 John Stephen 设计及编写"
GroupCalendar.cAboutThanks = "Many thanks to all fans and supporters.  I hope my addons add to your gaming enjoyment as much as building them adds to mine."

-- Partners tab

GroupCalendar.cPartnersTitle = "Multi-guild partnerships"
GroupCalendar.cPartnersDescription1 = "Multi-guild partnerships make it easy to coordinate events across guilds by sharing guild rosters (name, rank, class and level only) with your partner guilds"
GroupCalendar.cPartnersDescription2 = "To create a partnership, add a player using the Add Player button at the bottom of this window"
GroupCalendar.cAddPlayer = "加入玩家"
GroupCalendar.cRemovePlayer = "Remove Player"

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

GroupCalendar.cUnknown = "未知"

-- Main window

GroupCalendar.cCalendar = "行事历"
GroupCalendar.cSetup = "设置"
GroupCalendar.cPartners = "Partners"
GroupCalendar.cExport = "Export"
GroupCalendar.cAbout = "关于"

GroupCalendar.cUseServerDateTime = "使用伺服器日期与时间"
GroupCalendar.cUseServerDateTimeDescription = "启动此功能将会以伺服器的日期与时间来显示活动资讯，若关闭此功能则会以您的电脑日期及时间来显示。"
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

end -- zhCN
