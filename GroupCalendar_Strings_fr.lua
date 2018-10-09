----------------------------------------
-- Group Calendar 5 Copyright (c) 2018 John Stephen
-- This software is licensed under the MIT license.
-- See the included LICENSE.txt file for more information.
----------------------------------------

if GetLocale() == "frFR" then

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

GroupCalendar.cForeignRealmFormat = "%s de %s"

GroupCalendar.cSingleItemFormat = "%s"
GroupCalendar.cTwoItemFormat = "%s et %s"
GroupCalendar.cMultiItemFormat = "%s{{, %s}} et %s"

-- Event names

GroupCalendar.cGeneralEventGroup = "Général"
GroupCalendar.cPersonalEventGroup = "Personnel (non partagé)"
GroupCalendar.cRaidClassicEventGroup = "Raids (Classic)"
GroupCalendar.cTBCRaidEventGroup = "Raids (Burning Crusade)"
GroupCalendar.cWotLKRaidEventGroup = "Raids (WotLK)"
GroupCalendar.cDungeonEventGroup = "Dungeons (Classic)"
GroupCalendar.cOutlandsDungeonEventGroup = "Donjons (Burning Crusade)"
GroupCalendar.cWotLKDungeonEventGroup = "Donjons (WotLK)"
GroupCalendar.cOutlandsHeroicDungeonEventGroup = "Héroïque (Burning Crusade)"
GroupCalendar.cWotLKHeroicDungeonEventGroup = "Héroïque (WotLK)"
GroupCalendar.cBattlegroundEventGroup = "Champs de Bataille"
GroupCalendar.cOutdoorRaidEventGroup = "Raids extérieurs"

GroupCalendar.cMeetingEventName = "Réunion"
GroupCalendar.cBirthdayEventName = "Anniversaire"
GroupCalendar.cRoleplayEventName = "Jeu de rôle"
GroupCalendar.cHolidayEventName = "Vacances"
GroupCalendar.cDentistEventName = "Dentiste"
GroupCalendar.cDoctorEventName = "Docteur"
GroupCalendar.cVacationEventName = "Vacances"
GroupCalendar.cOtherEventName = "Autres"

GroupCalendar.cCooldownEventName = "%s disponible"

GroupCalendar.cPersonalEventOwner = "Privé"
GroupCalendar.cBlizzardOwner = "Blizzard"

GroupCalendar.cNone = "Aucun"

GroupCalendar.cAvailableMinutesFormat = "%s dans %d minutes"
GroupCalendar.cAvailableMinuteFormat = "%s dans %d minutes"
GroupCalendar.cStartsMinutesFormat = "%s commence dans %d minutes"
GroupCalendar.cStartsMinuteFormat = "%s commence dans %d minutes"
GroupCalendar.cStartingNowFormat = "%s commence maintenant"
GroupCalendar.cAlreadyStartedFormat = "%s a déjà commencé"
GroupCalendar.cHappyBirthdayFormat = "Joyeux anniversaire %s!"

GroupCalendar.cLocalTimeNote = "(%s local)"
GroupCalendar.cServerTimeNote = "(%s server)"

-- Roles

GroupCalendar.cHRole = "Soigneur"
GroupCalendar.cTRole = "Tank"
GroupCalendar.cRRole = "DPS Distant"
GroupCalendar.cMRole = "Mêlée"

GroupCalendar.cHPluralRole = "Soigneurs"
GroupCalendar.cTPluralRole = "Tanks"
GroupCalendar.cRPluralRole = "DPS Distants"
GroupCalendar.cMPluralRole = "Mêlées"

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

GroupCalendar.cLevelRangeFormat = "Niveaux %i à %i"
GroupCalendar.cMinLevelFormat = "Niveaux %i et +"
GroupCalendar.cMaxLevelFormat = "Jusqu\'au niveau %i"
GroupCalendar.cAllLevels = "Tous niveaux"
GroupCalendar.cSingleLevel = "Niveau %i uniquement"

GroupCalendar.cYes = "Oui! Je participe à cet événement"
GroupCalendar.cNo = "Non. je ne participe pas à cet événement"
GroupCalendar.cMaybe = "Peut-être. Me mettre sur la liste d'attente"

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
GroupCalendar.cTimeLabel = "Temps:"
GroupCalendar.cDurationLabel = "Durée:"
GroupCalendar.cEventLabel = "Evénement:"
GroupCalendar.cTitleLabel = "Titre:"
GroupCalendar.cLevelsLabel = "Niveaux:"
GroupCalendar.cLevelRangeSeparator = "à"
GroupCalendar.cDescriptionLabel = "Description:"
GroupCalendar.cCommentLabel = "Commentaire:"
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
GroupCalendar.cSingularHourFormat = "%d heure"
GroupCalendar.cPluralHourFormat = "%d heures"
GroupCalendar.cSingularHourPluralMinutes = "%d heure %d minutes"
GroupCalendar.cPluralHourPluralMinutes = "%d hueres %d minutes"

GroupCalendar.cNewerVersionMessage = "Une nouvelle version est disponible (%s)"

GroupCalendar.cDelete = "Effacer"

-- Event Group tab

GroupCalendar.cViewGroupBy = "Grouper par"
GroupCalendar.cViewByStatus = "Statut"
GroupCalendar.cViewByClass = "Classe"
GroupCalendar.cViewByRole = "Rôle"
GroupCalendar.cViewSortBy = "Trier par"
GroupCalendar.cViewByDate = "Date"
GroupCalendar.cViewByRank = "Rang"
GroupCalendar.cViewByName = "Nom"

GroupCalendar.cInviteButtonTitle = "Inviter sélection"
GroupCalendar.cAutoSelectButtonTitle = "Joueur sélectionné..."
GroupCalendar.cAutoSelectWindowTitle = "Joueurs sélectionnés"

GroupCalendar.cNoSelection = "Pas de joueur sélectionné"
GroupCalendar.cSingleSelection = "1 joueur sélectionné"
GroupCalendar.cMultiSelection = "%d joueurs sélectionnés"

GroupCalendar.cInviteNeedSelectionStatus = "Sélectionnez les joueurs à inviter"
GroupCalendar.cInviteReadyStatus = "Prêt à inviter"
GroupCalendar.cInviteInitialInvitesStatus = "Envoyer les invitations initiales"
GroupCalendar.cInviteAwaitingAcceptanceStatus = "En attente de l'acceptation initiale"
GroupCalendar.cInviteConvertingToRaidStatus = "Changement en raid"
GroupCalendar.cInviteInvitingStatus = "Envoi des invitations"
GroupCalendar.cInviteCompleteStatus = "Invitations terminées"
GroupCalendar.cInviteReadyToRefillStatus = "Prêt à remplir les places vacantes"
GroupCalendar.cInviteNoMoreAvailableStatus = "Plus de joueurs disponibles pour remplir les places vacantes"
GroupCalendar.cRaidFull = "Raid complet"

GroupCalendar.cWhisperPrefix = "[Group Calendar]"
GroupCalendar.cInviteWhisperFormat = "%s Vous êtes invité à l\'événement '%s'. Svp acceptez l\'invitation, si vous souhaitez participer à l'événement."
GroupCalendar.cAlreadyGroupedWhisper = "%s Vous êtes déjà dans un groupe. Svp /w de nouveau quand vous avez quitté votre groupe."

GroupCalendar.cJoinedGroupStatus = "Groupé"
GroupCalendar.cInvitedGroupStatus = "Invité"
GroupCalendar.cReadyGroupStatus = "Prêt"
GroupCalendar.cGroupedGroupStatus = "Dans un autre groupe"
GroupCalendar.cStandbyGroupStatus = "En attente"
GroupCalendar.cMaybeGroupStatus = "Peut-être"
GroupCalendar.cDeclinedGroupStatus = "Refuse l\'invitation"
GroupCalendar.cOfflineGroupStatus = "Hors ligne"
GroupCalendar.cLeftGroupStatus = "Quitte le groupe"

GroupCalendar.cTotalLabel = "Total:"

GroupCalendar.cAutoConfirmationTitle = "Confirmations automatiques par classe"
GroupCalendar.cRoleConfirmationTitle = "Confirmations automatiques par rôle"
GroupCalendar.cManualConfirmationTitle = "Confirmations manuelles"
GroupCalendar.cClosedEventTitle = "Evénement clos"
GroupCalendar.cMinLabel = "min"
GroupCalendar.cMaxLabel = "max"

GroupCalendar.cStandby = CALENDAR_STATUS_STANDBY

-- Limits dialog

GroupCalendar.cMaxPartySizeLabel = "Taille Maximum du groupe:"
GroupCalendar.cMinPartySizeLabel = "Taille Minimum du groupe:"
GroupCalendar.cNoMinimum = "Pas de minimum"
GroupCalendar.cNoMaximum = "Pas de maximum"
GroupCalendar.cPartySizeFormat = "%d joueurs"

GroupCalendar.cAddPlayerTitle = "Ajoute le joueur..."
GroupCalendar.cAutoConfirmButtonTitle = "Paramètre..."

GroupCalendar.cClassLimitDescription = "Utilisez les champs ci dessous pour définir les minimums et maximums pour chaque classe. Les classes n'ayant pas atteint leur minimum seront remplie en premier, les places suivantes seront remplies par ordre de réponse."
GroupCalendar.cRoleLimitDescription = "Set the minimum and maximum numbers of players for each role.  Minimums will be met first, extra spots beyond the minimum will be filled until the maximum is reached or the group is full.  You can also reserve spaces within each role for particular classes (requiring one ranged dps to be a shadow priest for example)"

GroupCalendar.cPriorityLabel = "Priorité:"
GroupCalendar.cPriorityDate = "Date"
GroupCalendar.cPriorityRank = "Rang"

GroupCalendar.cCachedEventStatus = "This event is a cached copy from $Name's calendar\rLast refreshed on $Date at $Time"

-- Class names

GroupCalendar.cClassName =
{
	DRUID = {Male = LOCALIZED_CLASS_NAMES_MALE.DRUID, Female = LOCALIZED_CLASS_NAMES_FEMALE.DRUID, Plural = "Druides"},
	HUNTER = {Male = LOCALIZED_CLASS_NAMES_MALE.HUNTER, Female = LOCALIZED_CLASS_NAMES_FEMALE.HUNTER, Plural = "Chasseurs"},
	MAGE = {Male = LOCALIZED_CLASS_NAMES_MALE.MAGE, Female = LOCALIZED_CLASS_NAMES_FEMALE.MAGE, Plural = "Mages"},
	PALADIN = {Male = LOCALIZED_CLASS_NAMES_MALE.PALADIN, Female = LOCALIZED_CLASS_NAMES_FEMALE.PALADIN, Plural = "Paladins"},
	PRIEST = {Male = LOCALIZED_CLASS_NAMES_MALE.PRIEST, Female = LOCALIZED_CLASS_NAMES_FEMALE.PRIEST, Plural = "Prêtres"},
	ROGUE = {Male = LOCALIZED_CLASS_NAMES_MALE.ROGUE, Female = LOCALIZED_CLASS_NAMES_FEMALE.ROGUE, Plural = "Voleurs"},
	SHAMAN = {Male = LOCALIZED_CLASS_NAMES_MALE.SHAMAN, Female = LOCALIZED_CLASS_NAMES_FEMALE.SHAMAN, Plural = "Chamans"},
	WARLOCK = {Male = LOCALIZED_CLASS_NAMES_MALE.WARLOCK, Female = LOCALIZED_CLASS_NAMES_FEMALE.WARLOCK, Plural = "Démonistes"},
	WARRIOR = {Male = LOCALIZED_CLASS_NAMES_MALE.WARRIOR, Female = LOCALIZED_CLASS_NAMES_FEMALE.WARRIOR, Plural = "Guerriers"},
	DEATHKNIGHT = {Male = LOCALIZED_CLASS_NAMES_MALE.DEATHKNIGHT, Female = LOCALIZED_CLASS_NAMES_FEMALE.DEATHKNIGHT, Plural = "Death Knights"},
	MONK = {Male = LOCALIZED_CLASS_NAMES_MALE.MONK, Female = LOCALIZED_CLASS_NAMES_FEMALE.MONK, Plural = "Monks"},
	DEMONHUNTER = {Male = LOCALIZED_CLASS_NAMES_MALE.DEMONHUNTER, Female = LOCALIZED_CLASS_NAMES_FEMALE.DEMONHUNTER, Plural = "Demon Hunters"},
}

GroupCalendar.cCurrentPartyOrRaid = "Current party or raid"

GroupCalendar.cViewByFormat = "View by %s / %s"

GroupCalendar.cConfirm = "Confirm"

GroupCalendar.cSingleTimeDateFormat = "%s\r%s"
GroupCalendar.cTimeDateRangeFormat = "%s\r%s à %s"

GroupCalendar.cStartEventHelp = "Click Start to begin forming your party or raid"
GroupCalendar.cResumeEventHelp = "Click Resume to continue forming your party or raid"

GroupCalendar.cShowClassReservations = "Reservations >>>"
GroupCalendar.cHideClassReservations = "<<< Reservations"

GroupCalendar.cInviteStatusText =
{
	JOINED = "|cff00ff00groupé",
	CONFIRMED = "|cff88ff00confirmed",
	STANDBY = "|cffffff00en attente",
	INVITED = "|cff00ff00invité",
	DECLINED = "|cffff0000refuse l\'invitation",
	BUSY = "|cffff0000dans un autre groupe",
	OFFLINE = "|cff888888hors ligne",
	LEFT = "|cff0000ffquitte le groupe",
}

GroupCalendar.cStart = "Start"
GroupCalendar.cPause = "Pause"
GroupCalendar.cResume = "Resume"
GroupCalendar.cRestart = "Restart"

-- About tab

GroupCalendar.cAboutTitle = "A propos de Group Calendar %s"
GroupCalendar.cAboutAuthor = "Designed and written by John Stephen"
GroupCalendar.cAboutThanks = "Many thanks to all fans and supporters.  I hope my addons add to your gaming enjoyment as much as building them adds to mine."

-- Partners tab

GroupCalendar.cPartnersTitle = "Multi-guild partnerships"
GroupCalendar.cPartnersDescription1 = "Multi-guild partnerships make it easy to coordinate events across guilds by sharing guild rosters (name, rank, class and level only) with your partner guilds"
GroupCalendar.cPartnersDescription2 = "To create a partnership, add a player using the Add Player button at the bottom of this window"
GroupCalendar.cAddPlayer = "Ajoute le joueur..."
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

GroupCalendar.cUnknown = "Inconnu"

-- Main window

GroupCalendar.cCalendar = "Calendrier"
GroupCalendar.cSettings = "Configuration"
GroupCalendar.cPartners = "Partners"
GroupCalendar.cExport = "Export"
GroupCalendar.cAbout = "A propos"

GroupCalendar.cUseServerDateTime = "Utiliser les horaires du serveur"
GroupCalendar.cUseServerDateTimeDescription = "Activer pour que les événements utilisent l'heure et la date du serveur, désactiver pour utiliser votre date et heure"
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

end -- frFR
