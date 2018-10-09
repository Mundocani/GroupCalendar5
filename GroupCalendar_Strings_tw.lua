----------------------------------------
-- Group Calendar 5 Copyright (c) 2018 John Stephen
-- This software is licensed under the MIT license.
-- See the included LICENSE.txt file for more information.
----------------------------------------

if GetLocale() == "zhTW" then

GroupCalendar.cTitle = "團隊行事曆 v%s"
GroupCalendar.cCantReloadUI = "必須完全重新啟動魔獸世界，才能更新Group Calendar版本"

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

GroupCalendar.cForeignRealmFormat = "%s 與 %s"

GroupCalendar.cSingleItemFormat = "%s"
GroupCalendar.cTwoItemFormat = "%s 和 %s"
GroupCalendar.cMultiItemFormat = "%s{{, %s}} 和 %s"

-- Event names

GroupCalendar.cGeneralEventGroup = "綜合"
GroupCalendar.cPersonalEventGroup = "私人活動 (非共享)"
GroupCalendar.cRaidClassicEventGroup = "團隊 (Classic)"
GroupCalendar.cTBCRaidEventGroup = "團隊 (Burning Crusade)"
GroupCalendar.cWotLKRaidNEventGroup = "團隊 (WotLK)"
GroupCalendar.cDungeonEventGroup = "副本/地下城 (Classic)"
GroupCalendar.cOutlandsDungeonEventGroup = "副本/地下城 (Burning Crusade)"
GroupCalendar.cWotLKDungeonEventGroup = "副本/地下城 (WotLK)"
GroupCalendar.cOutlandsHeroicDungeonEventGroup = "英雄模式副本 (Burning Crusade)"
GroupCalendar.cWotLKHeroicDungeonEventGroup = "英雄模式副本 (WotLK)"
GroupCalendar.cBattlegroundEventGroup = "戰場"
GroupCalendar.cOutdoorRaidEventGroup = "戶外團隊野戰"

GroupCalendar.cMeetingEventName = "聚會"
GroupCalendar.cBirthdayEventName = "生日"
GroupCalendar.cRoleplayEventName = "角色扮演"
GroupCalendar.cHolidayEventName = "假期"
GroupCalendar.cDentistEventName = "看牙醫"
GroupCalendar.cDoctorEventName = "看醫生"
GroupCalendar.cVacationEventName = "假期"
GroupCalendar.cOtherEventName = "其它"

GroupCalendar.cCooldownEventName = "%s 冷卻就緒"

GroupCalendar.cPersonalEventOwner = "私人活動"
GroupCalendar.cBlizzardOwner = "Blizzard"

GroupCalendar.cNone = "無"

GroupCalendar.cAvailableMinutesFormat = "%s 尚餘 %d 分鐘"
GroupCalendar.cAvailableMinuteFormat = "%s 尚餘 %d 分鐘"
GroupCalendar.cStartsMinutesFormat = "%s 將於 %d 分鐘後開始"
GroupCalendar.cStartsMinuteFormat = "%s 將於 %d 分鐘內開始"
GroupCalendar.cStartingNowFormat = "%s 現在開始"
GroupCalendar.cAlreadyStartedFormat = "%s 已經開始"
GroupCalendar.cHappyBirthdayFormat = "%s 祝你生日快樂！"

GroupCalendar.cLocalTimeNote = "(%s 本地)"
GroupCalendar.cServerTimeNote = "(%s server)"

-- Roles

GroupCalendar.cHRole = "主要補職"
GroupCalendar.cTRole = "主要坦職"
GroupCalendar.cDRole = "遠距傷害職"
GroupCalendar.cDRole = "近戰傷害職"

GroupCalendar.cHPluralRole = "主要補職"
GroupCalendar.cTPluralRole = "主要坦克"
GroupCalendar.cDPluralRole = "遠距DPS"
GroupCalendar.cDPluralRole = "近戰DPS"

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

GroupCalendar.cLevelRangeFormat = "等級 %i 至 %i"
GroupCalendar.cMinLevelFormat = "等級 %i 或以上"
GroupCalendar.cMaxLevelFormat = "等級 %i 或以下"
GroupCalendar.cAllLevels = "所有等級"
GroupCalendar.cSingleLevel = "只限等級 %i"

GroupCalendar.cYes = "是的！我會出席此活動！"
GroupCalendar.cNo = "不，我不會出席這個活動！"
GroupCalendar.cMaybe = "可能可以參加，把我放在候補名單！"

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

GroupCalendar.cAllDay = "全天"

GroupCalendar.cEventModeLabel = "Mode:"
GroupCalendar.cTimeLabel = "時間:"
GroupCalendar.cDurationLabel = "需時:"
GroupCalendar.cEventLabel = "活動:"
GroupCalendar.cTitleLabel = "標題:"
GroupCalendar.cLevelsLabel = "等級:"
GroupCalendar.cLevelRangeSeparator = "至"
GroupCalendar.cDescriptionLabel = "內容:"
GroupCalendar.cCommentLabel = "備註:"
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

GroupCalendar.cPluralMinutesFormat = "%d分鐘"
GroupCalendar.cSingularHourFormat = "%d小時"
GroupCalendar.cPluralHourFormat = "%d小時"
GroupCalendar.cSingularHourPluralMinutes = "%d小時%d分鐘"
GroupCalendar.cPluralHourPluralMinutes = "%d小時%d分鐘"

GroupCalendar.cNewerVersionMessage = "一個新的版本已經可以下載 (%s)"

GroupCalendar.cDelete = "刪除"

-- Event Group tab

GroupCalendar.cViewGroupBy = "分組依照:"
GroupCalendar.cViewByStatus = "狀況"
GroupCalendar.cViewByClass = "職業"
GroupCalendar.cViewByRole = "角色"
GroupCalendar.cViewSortBy = "排序依照:"
GroupCalendar.cViewByDate = "時間"
GroupCalendar.cViewByRank = "公會階級"
GroupCalendar.cViewByName = "名稱"

GroupCalendar.cInviteButtonTitle = "邀請已選玩家"
GroupCalendar.cAutoSelectButtonTitle = "選取玩家..."
GroupCalendar.cAutoSelectWindowTitle = "選取玩家"

GroupCalendar.cNoSelection = "沒有選取玩家"
GroupCalendar.cSingleSelection = "選取了 1 位玩家"
GroupCalendar.cMultiSelection = "選取了 %d 位玩家"

GroupCalendar.cInviteNeedSelectionStatus = "選擇準備邀請的玩家"
GroupCalendar.cInviteReadyStatus = "準備邀請"
GroupCalendar.cInviteInitialInvitesStatus = "傳送首次的邀請"
GroupCalendar.cInviteAwaitingAcceptanceStatus = "等待首次的邀請回應"
GroupCalendar.cInviteConvertingToRaidStatus = "轉換至團隊"
GroupCalendar.cInviteInvitingStatus = "傳送邀請"
GroupCalendar.cInviteCompleteStatus = "邀請完畢"
GroupCalendar.cInviteReadyToRefillStatus = "準備填補空缺"
GroupCalendar.cInviteNoMoreAvailableStatus = "已經沒有玩家可以填補隊伍"
GroupCalendar.cRaidFull = "團隊已滿"

GroupCalendar.cWhisperPrefix = "[團隊行事曆]"
GroupCalendar.cInviteWhisperFormat = "%s 您已經被邀請加入 '%s' 活動。若閣下想加入此活動，請接受此邀請。"
GroupCalendar.cAlreadyGroupedWhisper = "%s 您已經加入了一個隊伍。請閣下您在離開您現在的隊伍後，使用 /w 回覆。"

GroupCalendar.cJoinedGroupStatus = "已加入"
GroupCalendar.cInvitedGroupStatus = "已邀請"
GroupCalendar.cReadyGroupStatus = "就緒"
GroupCalendar.cGroupedGroupStatus = "在其他隊伍"
GroupCalendar.cStandbyGroupStatus = CALENDAR_STATUS_STANDBY
GroupCalendar.cMaybeGroupStatus = "Maybe"
GroupCalendar.cDeclinedGroupStatus = "拒絕邀請"
GroupCalendar.cOfflineGroupStatus = "下線"
GroupCalendar.cLeftGroupStatus = "離開隊伍"

GroupCalendar.cTotalLabel = "Total:"

GroupCalendar.cAutoConfirmationTitle = "自動確認"
GroupCalendar.cRoleConfirmationTitle = "自動照角色確認"
GroupCalendar.cManualConfirmationTitle = "手動確認"
GroupCalendar.cClosedEventTitle = "關閉活動"
GroupCalendar.cMinLabel = "最低"
GroupCalendar.cMaxLabel = "最高"

GroupCalendar.cStandby = CALENDAR_STATUS_STANDBY

-- Limits dialog

GroupCalendar.cMaxPartySizeLabel = "隊伍人數上限:"
GroupCalendar.cMinPartySizeLabel = "隊伍人數下限:"
GroupCalendar.cNoMinimum = "沒有下限"
GroupCalendar.cNoMaximum = "沒有上限"
GroupCalendar.cPartySizeFormat = "%d 位玩家"

GroupCalendar.cAddPlayerTitle = "新增..."
GroupCalendar.cAutoConfirmButtonTitle = "設定..."

GroupCalendar.cClassLimitDescription = "設定下列每種職業的最低及最高人數。若該職業的人數尚未符合最低要求，您將被自動填補空缺。當人數到達上限時，將會有額外的提示。"
GroupCalendar.cRoleLimitDescription = "設定下列每種角色的最低及最高人數。若該角色的人數尚未符合最低要求，您將被自動填補空缺。當角色人數到達上限時，將會有額外的提示。您可以手動設定各職業擔任各角色的下限(例如說需要一個暗牧當遠程DPS)"

GroupCalendar.cPriorityLabel = "優先權:"
GroupCalendar.cPriorityDate = "時間"
GroupCalendar.cPriorityRank = "階級"

GroupCalendar.cCachedEventStatus = "This event is a cached copy from $Name's calendar\rLast refreshed on $Date at $Time"

-- Class names

GroupCalendar.cClassName =
{
	DRUID = {Male = LOCALIZED_CLASS_NAMES_MALE.DRUID, Female = LOCALIZED_CLASS_NAMES_FEMALE.DRUID, Plural = "德魯伊"},
	HUNTER = {Male = LOCALIZED_CLASS_NAMES_MALE.HUNTER, Female = LOCALIZED_CLASS_NAMES_FEMALE.HUNTER, Plural = "獵人"},
	MAGE = {Male = LOCALIZED_CLASS_NAMES_MALE.MAGE, Female = LOCALIZED_CLASS_NAMES_FEMALE.MAGE, Plural = "法師"},
	PALADIN = {Male = LOCALIZED_CLASS_NAMES_MALE.PALADIN, Female = LOCALIZED_CLASS_NAMES_FEMALE.PALADIN, Plural = "聖騎士"},
	PRIEST = {Male = LOCALIZED_CLASS_NAMES_MALE.PRIEST, Female = LOCALIZED_CLASS_NAMES_FEMALE.PRIEST, Plural = "牧師"},
	ROGUE = {Male = LOCALIZED_CLASS_NAMES_MALE.ROGUE, Female = LOCALIZED_CLASS_NAMES_FEMALE.ROGUE, Plural = "盜賊"},
	SHAMAN = {Male = LOCALIZED_CLASS_NAMES_MALE.SHAMAN, Female = LOCALIZED_CLASS_NAMES_FEMALE.SHAMAN, Plural = "薩滿"},
	WARLOCK = {Male = LOCALIZED_CLASS_NAMES_MALE.WARLOCK, Female = LOCALIZED_CLASS_NAMES_FEMALE.WARLOCK, Plural = "術士"},
	WARRIOR = {Male = LOCALIZED_CLASS_NAMES_MALE.WARRIOR, Female = LOCALIZED_CLASS_NAMES_FEMALE.WARRIOR, Plural = "戰士"},
	DEATHKNIGHT = {Male = LOCALIZED_CLASS_NAMES_MALE.DEATHKNIGHT, Female = LOCALIZED_CLASS_NAMES_FEMALE.DEATHKNIGHT, Plural = "死亡騎士"},
	MONK = {Male = LOCALIZED_CLASS_NAMES_MALE.MONK, Female = LOCALIZED_CLASS_NAMES_FEMALE.MONK, Plural = "Monks"},
	DEMONHUNTER = {Male = LOCALIZED_CLASS_NAMES_MALE.DEMONHUNTER, Female = LOCALIZED_CLASS_NAMES_FEMALE.DEMONHUNTER, Plural = "Demon Hunters"},
}

GroupCalendar.cCurrentPartyOrRaid = "Current party or raid"

GroupCalendar.cViewByFormat = "View by %s / %s"

GroupCalendar.cConfirm = "Confirm"

GroupCalendar.cSingleTimeDateFormat = "%s  %s"
GroupCalendar.cTimeDateRangeFormat = "%s  %s至%s"

GroupCalendar.cStartEventHelp = "Click Start to begin forming your party or raid"
GroupCalendar.cResumeEventHelp = "Click Resume to continue forming your party or raid"

GroupCalendar.cShowClassReservations = "Reservations >>>"
GroupCalendar.cHideClassReservations = "<<< Reservations"

GroupCalendar.cInviteStatusText =
{
	JOINED = "|cff00ff00已加入",
	CONFIRMED = "|cff88ff00就緒",
	STANDBY = "|cffffff00等候",
	INVITED = "|cff00ff00已邀請",
	DECLINED = "|cffff0000拒絕邀請",
	BUSY = "|cffff0000在其他隊伍",
	OFFLINE = "|cff888888下線",
	LEFT = "|cff0000ff離開隊伍",
}

GroupCalendar.cStart = "Start"
GroupCalendar.cPause = "Pause"
GroupCalendar.cResume = "Resume"
GroupCalendar.cRestart = "Restart"

-- About tab

GroupCalendar.cAboutTitle = "關於團隊行事曆 %s"
GroupCalendar.cAboutAuthor = "由 John Stephen 設計及編寫"
GroupCalendar.cAboutThanks = "Many thanks to all fans and supporters.  I hope my addons add to your gaming enjoyment as much as building them adds to mine."

-- Partners tab

GroupCalendar.cPartnersTitle = "Multi-guild partnerships"
GroupCalendar.cPartnersDescription1 = "Multi-guild partnerships make it easy to coordinate events across guilds by sharing guild rosters (name, rank, class and level only) with your partner guilds"
GroupCalendar.cPartnersDescription2 = "To create a partnership, add a player using the Add Player button at the bottom of this window"
GroupCalendar.cAddPlayer = "加入玩家..."
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

GroupCalendar.cUnknown = "未知"

-- Invite tab

GroupCalendar.cModeratorTooltipTitle = "Moderator"
GroupCalendar.cModeratorTooltipDescription = "Turn this on to allow this player or group to co-manage your event"

-- Main window

GroupCalendar.cCalendar = "Calendar"
GroupCalendar.cSettings = "Settings"
GroupCalendar.cPartners = "Partners"
GroupCalendar.cExport = "Export"
GroupCalendar.cAbout = "About"

GroupCalendar.cUseServerDateTime = "使用伺服器的日期與時間(建議)"
GroupCalendar.cUseServerDateTimeDescription = "啟動此功能將會以伺服器的日期與時間來顯示活動資訊，若關閉此功能則會以您的電腦日期及時間來顯示。"
GroupCalendar.cShowCalendarLabel = "Show:"
GroupCalendar.cShowAlts = "Show alts"
GroupCalendar.cShowAltsDescription = "Turn on to show events cached from your other characters"
GroupCalendar.cShowDarkmoonCalendarDescription = "Turn on to show the Darkmoon Faire schedule"
GroupCalendar.cShowWeeklyCalendarDescription = "Turn on to show weekly events such as the Fishing Extravaganza"
GroupCalendar.cShowPvPCalendarDescription = "Turn on to show PvP weekends"
GroupCalendar.cShowLockoutCalendarDescription = "Turn on to show you active dungeon lockouts"

GroupCalendar.cMinimapButtonHint = "Left-click to show Group Calendar."
GroupCalendar.cMinimapButtonHint2 = "Right-click to show the WoW calendar."

GroupCalendar.cNewEvent = "新活動..."
GroupCalendar.cPasteEvent = "貼上活動"

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

end -- zhTW
