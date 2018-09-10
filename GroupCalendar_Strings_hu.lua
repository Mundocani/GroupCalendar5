----------------------------------------
-- Group Calendar 5 Copyright 2005 - 2016 John Stephen, wobbleworks.com
-- All rights reserved, unauthorized redistribution is prohibited
----------------------------------------

if GetLocale() == "huHU" then

GroupCalendar.cTitle = "Group Calendar %s"
GroupCalendar.cCantReloadUI = "You must completely restart WoW to upgrade to this version of Group Calendar"

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

GroupCalendar.cGeneralEventGroup = "General"
GroupCalendar.cPersonalEventGroup = "Personal (not shared)"
GroupCalendar.cRaidClassicEventGroup = "Raids (Classic)"
GroupCalendar.cTBCRaidEventGroup = "Raids (Burning Crusade)"
GroupCalendar.cWotLKRaidEventGroup = "Raids (WotLK)"
GroupCalendar.cDungeonEventGroup = "Dungeons (Classic)"
GroupCalendar.cOutlandsDungeonEventGroup = "Dungeons (Burning Crusade)"
GroupCalendar.cWotLKDungeonEventGroup = "Dungeons (WotLK)"
GroupCalendar.cOutlandsHeroicDungeonEventGroup = "Heroics (Burning Crusade)"
GroupCalendar.cWotLKHeroicDungeonEventGroup = "Heroics (WotLK)"
GroupCalendar.cBattlegroundEventGroup = "PvP"
GroupCalendar.cOutdoorRaidEventGroup = "Outdoor Raids"

GroupCalendar.cMeetingEventName = "Meeting"
GroupCalendar.cBirthdayEventName = "Birthday"
GroupCalendar.cRoleplayEventName = "Roleplaying"
GroupCalendar.cHolidayEventName = "Holiday"
GroupCalendar.cDentistEventName = "Dentist"
GroupCalendar.cDoctorEventName = "Doctor"
GroupCalendar.cVacationEventName = "Vacation"
GroupCalendar.cOtherEventName = "Other"

GroupCalendar.cCooldownEventName = "%s Available"

GroupCalendar.cPersonalEventOwner = "Private"
GroupCalendar.cBlizzardOwner = "Blizzard"

GroupCalendar.cNone = "None"

GroupCalendar.cAvailableMinutesFormat = "%s in %d minutes"
GroupCalendar.cAvailableMinuteFormat = "%s in %d minute"
GroupCalendar.cStartsMinutesFormat = "%s starts in %d minutes"
GroupCalendar.cStartsMinuteFormat = "%s starts in %d minute"
GroupCalendar.cStartingNowFormat = "%s is starting now"
GroupCalendar.cAlreadyStartedFormat = "%s has already started"
GroupCalendar.cHappyBirthdayFormat = "Happy birthday %s!"

GroupCalendar.cLocalTimeNote = "(%s local)"
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

GroupCalendar.cLevelRangeFormat = "Levels %i to %i"
GroupCalendar.cMinLevelFormat = "Levels %i and up"
GroupCalendar.cMaxLevelFormat = "Up to level %i"
GroupCalendar.cAllLevels = "All levels"
GroupCalendar.cSingleLevel = "Level %i only"

GroupCalendar.cYes = "Yes! %s will attend this event"
GroupCalendar.cNo = "No. %s won't attend this event"
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
GroupCalendar.cTimeLabel = "Time:"
GroupCalendar.cDurationLabel = "Duration:"
GroupCalendar.cEventLabel = "Event:"
GroupCalendar.cTitleLabel = "Title:"
GroupCalendar.cLevelsLabel = "Levels:"
GroupCalendar.cLevelRangeSeparator = "to"
GroupCalendar.cDescriptionLabel = "Description:"
GroupCalendar.cCommentLabel = "Comment:"
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

GroupCalendar.cPluralMinutesFormat = "%d minutes"
GroupCalendar.cSingularHourFormat = "%d hour"
GroupCalendar.cPluralHourFormat = "%d hours"
GroupCalendar.cSingularHourPluralMinutes = "%d hour %d minutes"
GroupCalendar.cPluralHourPluralMinutes = "%d hours %d minutes"

GroupCalendar.cNewerVersionMessage = "A newer version is available (%s)"

GroupCalendar.cDelete = "Delete"

-- Event Group tab

GroupCalendar.cViewGroupBy = "Group by"
GroupCalendar.cViewByStatus = "Status"
GroupCalendar.cViewByClass = "Class"
GroupCalendar.cViewByRole = "Role"
GroupCalendar.cViewSortBy = "Sort by"
GroupCalendar.cViewByDate = "Date"
GroupCalendar.cViewByRank = "Rank"
GroupCalendar.cViewByName = "Name"

GroupCalendar.cInviteButtonTitle = "Invite Selected"
GroupCalendar.cAutoSelectButtonTitle = "Select Players..."
GroupCalendar.cAutoSelectWindowTitle = "Select Players"

GroupCalendar.cNoSelection = "No players selected"
GroupCalendar.cSingleSelection = "1 player selected"
GroupCalendar.cMultiSelection = "%d players selected"

GroupCalendar.cInviteNeedSelectionStatus = "Select players to be invited"
GroupCalendar.cInviteReadyStatus = "Ready to invite"
GroupCalendar.cInviteInitialInvitesStatus = "Sending initial invitations"
GroupCalendar.cInviteAwaitingAcceptanceStatus = "Waiting for initial acceptance"
GroupCalendar.cInviteConvertingToRaidStatus = "Converting to raid"
GroupCalendar.cInviteInvitingStatus = "Sending invitations"
GroupCalendar.cInviteCompleteStatus = "Invitations completed"
GroupCalendar.cInviteReadyToRefillStatus = "Ready to fill vacant slots"
GroupCalendar.cInviteNoMoreAvailableStatus = "No more players available to fill the group"
GroupCalendar.cRaidFull = "Raid full"

GroupCalendar.cWhisperPrefix = "[Group Calendar]"
GroupCalendar.cInviteWhisperFormat = "%s You are being invited to the event '%s'.  Please accept the invitation if you wish to join this event."
GroupCalendar.cAlreadyGroupedWhisper = "%s You are already in a group.  Please /w back when you leave your group."

GroupCalendar.cJoinedGroupStatus = "Joined"
GroupCalendar.cInvitedGroupStatus = "Invited"
GroupCalendar.cReadyGroupStatus = "Ready"
GroupCalendar.cGroupedGroupStatus = "In another group"
GroupCalendar.cStandbyGroupStatus = CALENDAR_STATUS_STANDBY
GroupCalendar.cMaybeGroupStatus = "Maybe"
GroupCalendar.cDeclinedGroupStatus = "Declined invitation"
GroupCalendar.cOfflineGroupStatus = "Offline"
GroupCalendar.cLeftGroupStatus = "Left group"

GroupCalendar.cTotalLabel = "Total:"

GroupCalendar.cAutoConfirmationTitle = "Auto Confirm by Class"
GroupCalendar.cRoleConfirmationTitle = "Auto Confirm by Role"
GroupCalendar.cManualConfirmationTitle = "Manual Confirmations"
GroupCalendar.cClosedEventTitle = "Closed Event"
GroupCalendar.cMinLabel = "min"
GroupCalendar.cMaxLabel = "max"

GroupCalendar.cStandby = CALENDAR_STATUS_STANDBY

-- Limits dialog

GroupCalendar.cMaxPartySizeLabel = "Maximum party size:"
GroupCalendar.cMinPartySizeLabel = "Minimum party size:"
GroupCalendar.cNoMinimum = "No minimum"
GroupCalendar.cNoMaximum = "No maximum"
GroupCalendar.cPartySizeFormat = "%d players"

GroupCalendar.cAddPlayerTitle = "Add..."
GroupCalendar.cAutoConfirmButtonTitle = "Settings..."

GroupCalendar.cClassLimitDescription = "Set the minimum and maximum number of players for each class.  Minimums will be met first, extra spots beyond the minimum will be filled until the maximum is reached or the group is full."
GroupCalendar.cRoleLimitDescription = "Set the minimum and maximum numbers of players for each role.  Minimums will be met first, extra spots beyond the minimum will be filled until the maximum is reached or the group is full.  You can also reserve spaces within each role for particular classes (requiring one ranged dps to be a shadow priest for example)"

GroupCalendar.cPriorityLabel = "Priority:"
GroupCalendar.cPriorityDate = "Date"
GroupCalendar.cPriorityRank = "Rank"

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

GroupCalendar.cSingleTimeDateFormat = "%s\r%s"
GroupCalendar.cTimeDateRangeFormat = "%s\rfrom %s to %s"

GroupCalendar.cStartEventHelp = "Click Start to begin forming your party or raid"
GroupCalendar.cResumeEventHelp = "Click Resume to continue forming your party or raid"

GroupCalendar.cShowClassReservations = "Reservations >>>"
GroupCalendar.cHideClassReservations = "<<< Reservations"

GroupCalendar.cInviteStatusText =
{
	JOINED = "|cff00ff00joined",
	CONFIRMED = "|cff88ff00confirmed",
	STANDBY = "|cffffff00standby",
	INVITED = "|cff00ff00invited",
	DECLINED = "|cffff0000declined",
	BUSY = "|cffff0000already grouped",
	OFFLINE = "|cff888888offline",
	LEFT = "|cff0000ffleft group",
}

GroupCalendar.cStart = "Start"
GroupCalendar.cPause = "Pause"
GroupCalendar.cResume = "Resume"
GroupCalendar.cRestart = "Restart"

-- About tab

GroupCalendar.cAboutTitle = "About Group Calendar %s"
GroupCalendar.cAboutAuthor = "Designed and written by John Stephen"
GroupCalendar.cAboutThanks = "Many thanks to all fans and supporters.  I hope my addons add to your gaming enjoyment as much as building them adds to mine."

-- Partners tab

GroupCalendar.cPartnersTitle = "Multi-guild partnerships"
GroupCalendar.cPartnersDescription1 = "Multi-guild partnerships make it easy to coordinate events across guilds by sharing guild rosters (name, rank, class and level only) with your partner guilds"
GroupCalendar.cPartnersDescription2 = "To create a partnership, add a player using the Add Player button at the bottom of this window"
GroupCalendar.cAddPlayer = "Add Player..."
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

GroupCalendar.cUnknown = "Unknown"

-- Main window

GroupCalendar.cCalendar = "Calendar"
GroupCalendar.cSettings = "Settings"
GroupCalendar.cPartners = "Partners"
GroupCalendar.cExport = "Export"
GroupCalendar.cAbout = "About"

GroupCalendar.cUseServerDateTime = "Use server dates and times"
GroupCalendar.cUseServerDateTimeDescription = "Turn on to show events using the server date and time, turn off to use your local date and time"
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

end -- huHU
