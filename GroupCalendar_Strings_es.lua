----------------------------------------
-- Group Calendar 5 Copyright (c) 2018 John Stephen
-- This software is licensed under the MIT license.
-- See the included LICENSE.txt file for more information.
----------------------------------------

if GetLocale() == "esES" then

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
GroupCalendar.cTwoItemFormat = "%s y %s"
GroupCalendar.cMultiItemFormat = "%s{{, %s}} y %s"

-- Event names

GroupCalendar.cGeneralEventGroup = "General"
GroupCalendar.cPersonalEventGroup = "Personal (no se comparte)"
GroupCalendar.cRaidEventGroup = "Bandas (Azeroth)"
GroupCalendar.cTBCRaidEventGroup = "Bandas (Terrallende)"
GroupCalendar.cWotLKRaidEventGroup = "Bandas (WotLK)"
GroupCalendar.cDungeonEventGroup = "Mazmorras (Azeroth)"
GroupCalendar.cOutlandsDungeonEventGroup = "Mazmorras (Terrallende)"
GroupCalendar.cWotLKDungeonEventGroup = "Mazmorras (WotLK)"
GroupCalendar.cOutlandsHeroicDungeonEventGroup = "Heroicas (Terrallende)"
GroupCalendar.cWotLKHeroicDungeonEventGroup = "Heroicas (WotLK)"
GroupCalendar.cBattlegroundEventGroup = "JcJ"
GroupCalendar.cOutdoorRaidEventGroup = "Encuentros de Banda"

GroupCalendar.cMeetingEventName = "Cita"
GroupCalendar.cBirthdayEventName = "Cumpleaños"
GroupCalendar.cRoleplayEventName = "Roleo"
GroupCalendar.cHolidayEventName = "Día de fiesta"
GroupCalendar.cDentistEventName = "Dentista"
GroupCalendar.cDoctorEventName = "Médico"
GroupCalendar.cVacationEventName = "Vacaciones"
GroupCalendar.cOtherEventName = "Otros"

GroupCalendar.cCooldownEventName = "%s disponible"

GroupCalendar.cPersonalEventOwner = "Privado"
GroupCalendar.cBlizzardOwner = "Blizzard"

GroupCalendar.cNone = "Ninguno"

GroupCalendar.cAvailableMinutesFormat = "%s en %d minutos"
GroupCalendar.cAvailableMinuteFormat = "%s en %d minuto"
GroupCalendar.cStartsMinutesFormat = "%s comienza en %d minutos"
GroupCalendar.cStartsMinuteFormat = "%s comienza en %d minuto"
GroupCalendar.cStartingNowFormat = "%s esta comenzando ahora"
GroupCalendar.cAlreadyStartedFormat = "%s ya ha comenzado"
GroupCalendar.cHappyBirthdayFormat = "¡Feliz cumpleaños %s!"

GroupCalendar.cLocalTimeNote = "(%s local)"
GroupCalendar.cServerTimeNote = "(%s server)"

-- Roles

GroupCalendar.cHRole = "Curandero"
GroupCalendar.cTRole = "Tanque"
GroupCalendar.cRRole = "Distancia"
GroupCalendar.cMRole = "C. a cuerpo"

GroupCalendar.cHPluralRole = "Curanderos"
GroupCalendar.cTPluralRole = "Tanques"
GroupCalendar.cRPluralRole = "Distancia"
GroupCalendar.cMPluralRole = "C a cuerpo"

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

GroupCalendar.cLevelRangeFormat = "Niveles %i a %i"
GroupCalendar.cMinLevelFormat = "Niveles %i y más"
GroupCalendar.cMaxLevelFormat = "Hasta el nivel %i" --Q Revisar "Up to level" Posible mala traduccion
GroupCalendar.cAllLevels = "Todos los niveles"
GroupCalendar.cSingleLevel = "Solo nivel %i"

GroupCalendar.cYes = "¡Si! Asistiré a este evento"
GroupCalendar.cNo = "No asistiré a este evento"
GroupCalendar.cMaybe = "Quizás. Ponme en la lista de espera"

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
GroupCalendar.cTimeLabel = "Hora:"
GroupCalendar.cDurationLabel = "Duración:"
GroupCalendar.cEventLabel = "Evento:"
GroupCalendar.cTitleLabel = "Título:"
GroupCalendar.cLevelsLabel = "Niveles:"
GroupCalendar.cLevelRangeSeparator = "a"
GroupCalendar.cDescriptionLabel = "Descripción:"
GroupCalendar.cCommentLabel = "Comentario:"
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

GroupCalendar.cPluralMinutesFormat = "%d minutos"
GroupCalendar.cSingularHourFormat = "%d hora"
GroupCalendar.cPluralHourFormat = "%d horas"
GroupCalendar.cSingularHourPluralMinutes = "%d hora %d minutos"
GroupCalendar.cPluralHourPluralMinutes = "%d horas %d minutos"

GroupCalendar.cNewerVersionMessage = "Hay una nueva versión disponible (%s)"

GroupCalendar.cDelete = "Eliminar"

-- Event Group tab

GroupCalendar.cViewGroupBy = "Grupo por"
GroupCalendar.cViewByStatus = "Estado"
GroupCalendar.cViewByClass = "Clase"
GroupCalendar.cViewByRole = "Papel"
GroupCalendar.cViewSortBy = "Ordenar por"
GroupCalendar.cViewByDate = "Fecha"
GroupCalendar.cViewByRank = "Rango"
GroupCalendar.cViewByName = "Nombre"

GroupCalendar.cInviteButtonTitle = "Invitar Seleccionado"
GroupCalendar.cAutoSelectButtonTitle = "Seleccionar Jugadores..."
GroupCalendar.cAutoSelectWindowTitle = "Seleccionar Jugadores"

GroupCalendar.cNoSelection = "No hay jugadores seleccionados"
GroupCalendar.cSingleSelection = "1 jugador seleccionado"
GroupCalendar.cMultiSelection = "%d jugadores seleccionados"

GroupCalendar.cInviteNeedSelectionStatus = "Selecciona jugadores a invitar"
GroupCalendar.cInviteReadyStatus = "Listo para invitar"
GroupCalendar.cInviteInitialInvitesStatus = "Enviando invitaciones iniciales"
GroupCalendar.cInviteAwaitingAcceptanceStatus = "Esperando aceptación inicial"
GroupCalendar.cInviteConvertingToRaidStatus = "Conviritendo a banda"
GroupCalendar.cInviteInvitingStatus = "Enviando invitaciones"
GroupCalendar.cInviteCompleteStatus = "Invitaciones completas"
GroupCalendar.cInviteReadyToRefillStatus = "Listo para llenar los huecos vacantes"
GroupCalendar.cInviteNoMoreAvailableStatus = "No hay más personajes disponibles para completar el grupo"
GroupCalendar.cRaidFull = "Banda completa"

GroupCalendar.cWhisperPrefix = "[Group Calendar]"
GroupCalendar.cInviteWhisperFormat = "%s Estas siendo invitado al evento '%s'.  Por favor acepta la invitación si deseas unirte a este evento."
GroupCalendar.cAlreadyGroupedWhisper = "%s Ya estas en un grupo.  Porfavor vuelve a susurrarme(/su) cuando dejes tu grupo."

GroupCalendar.cJoinedGroupStatus = "Unido"
GroupCalendar.cInvitedGroupStatus = "Invitado"
GroupCalendar.cReadyGroupStatus = "Preparado"
GroupCalendar.cGroupedGroupStatus = "En otro grupo"
GroupCalendar.cStandbyGroupStatus = "Reserva"
GroupCalendar.cMaybeGroupStatus = "Quizás"
GroupCalendar.cDeclinedGroupStatus = "Invitación Rechazada"
GroupCalendar.cOfflineGroupStatus = "Desconectado"
GroupCalendar.cLeftGroupStatus = "Abandono Grupo"

GroupCalendar.cTotalLabel = "Total:"

GroupCalendar.cAutoConfirmationTitle = "Autoconfirmar clase"
GroupCalendar.cRoleConfirmationTitle = "Autoconfirmar papel"
GroupCalendar.cManualConfirmationTitle = "Confirmaciones manuales"
GroupCalendar.cClosedEventTitle = "Evento Cerrado"
GroupCalendar.cMinLabel = "mín"
GroupCalendar.cMaxLabel = "máx"

GroupCalendar.cStandby = CALENDAR_STATUS_STANDBY

-- Limits dialog

GroupCalendar.cMaxPartySizeLabel = "Máx tamaño grupo:"
GroupCalendar.cMinPartySizeLabel = "Mín tamaño grupo:"
GroupCalendar.cNoMinimum = "Sin mín"
GroupCalendar.cNoMaximum = "Sin máx"
GroupCalendar.cPartySizeFormat = "%d jugadores"

GroupCalendar.cAddPlayerTitle = "Agregar..."
GroupCalendar.cAutoConfirmButtonTitle = "Configuración..."

GroupCalendar.cClassLimitDescription = "Usa los campos de abajo para definir el mínimo y el máximo número de cada clase.  Las clases que aun no hayan alcanzado el minimo se rellenaraán primero, el resto de huecos se irán completando en orden de respuesta hasta que el máximo se alcance."
GroupCalendar.cRoleLimitDescription = "Usa los campos de abajo para definir el mínimo y el máximo número de cada papel.  Los papeles (tanque, curandero, etc) que aun no hayan alcanzado el minimo se rellenaraán primero, el resto de huecos se irán completando en orden de respuesta hasta que el máximo se alcance.  Opcionalmente puedes definir el número de cada clase dentro de cada papel (requerido un dps a distancia que sea sacerdote de sombras, por ejemplo)"

GroupCalendar.cPriorityLabel = "Prioridad:"
GroupCalendar.cPriorityDate = "Fecha"
GroupCalendar.cPriorityRank = "Rango"

GroupCalendar.cCachedEventStatus = "This event is a cached copy from $Name's calendar\rLast refreshed on $Date at $Time"

-- Class names

GroupCalendar.cClassName =
{
	DRUID = {Male = LOCALIZED_CLASS_NAMES_MALE.DRUID, Female = LOCALIZED_CLASS_NAMES_FEMALE.DRUID, Plural = "Druidas"},
	HUNTER = {Male = LOCALIZED_CLASS_NAMES_MALE.HUNTER, Female = LOCALIZED_CLASS_NAMES_FEMALE.HUNTER, Plural = "Cazadores"},
	MAGE = {Male = LOCALIZED_CLASS_NAMES_MALE.MAGE, Female = LOCALIZED_CLASS_NAMES_FEMALE.MAGE, Plural = "Magos"},
	PALADIN = {Male = LOCALIZED_CLASS_NAMES_MALE.PALADIN, Female = LOCALIZED_CLASS_NAMES_FEMALE.PALADIN, Plural = "Paladines"},
	PRIEST = {Male = LOCALIZED_CLASS_NAMES_MALE.PRIEST, Female = LOCALIZED_CLASS_NAMES_FEMALE.PRIEST, Plural = "Sacerdotes"},
	ROGUE = {Male = LOCALIZED_CLASS_NAMES_MALE.ROGUE, Female = LOCALIZED_CLASS_NAMES_FEMALE.ROGUE, Plural = "Pícaros"},
	SHAMAN = {Male = LOCALIZED_CLASS_NAMES_MALE.SHAMAN, Female = LOCALIZED_CLASS_NAMES_FEMALE.SHAMAN, Plural = "Chamanes"},
	WARLOCK = {Male = LOCALIZED_CLASS_NAMES_MALE.WARLOCK, Female = LOCALIZED_CLASS_NAMES_FEMALE.WARLOCK, Plural = "Brujos"},
	WARRIOR = {Male = LOCALIZED_CLASS_NAMES_MALE.WARRIOR, Female = LOCALIZED_CLASS_NAMES_FEMALE.WARRIOR, Plural = "Guerreros"},
	DEATHKNIGHT = {Male = LOCALIZED_CLASS_NAMES_MALE.DEATHKNIGHT, Female = LOCALIZED_CLASS_NAMES_FEMALE.DEATHKNIGHT, Plural = "Death Knights"},
	MONK = {Male = LOCALIZED_CLASS_NAMES_MALE.MONK, Female = LOCALIZED_CLASS_NAMES_FEMALE.MONK, Plural = "Monks"},
	DEMONHUNTER = {Male = LOCALIZED_CLASS_NAMES_MALE.DEMONHUNTER, Female = LOCALIZED_CLASS_NAMES_FEMALE.DEMONHUNTER, Plural = "Demon Hunters"},
}

GroupCalendar.cCurrentPartyOrRaid = "Current party or raid"

GroupCalendar.cViewByFormat = "View by %s / %s"

GroupCalendar.cConfirm = "Confirm"

GroupCalendar.cSingleTimeDateFormat = "%s\r%s"
GroupCalendar.cTimeDateRangeFormat = "%s\rfrom %s a %s"

GroupCalendar.cStartEventHelp = "Click Start to begin forming your party or raid"
GroupCalendar.cResumeEventHelp = "Click Resume to continue forming your party or raid"

GroupCalendar.cShowClassReservations = "Reservations >>>"
GroupCalendar.cHideClassReservations = "<<< Reservations"

GroupCalendar.cInviteStatusText =
{
	JOINED = "|cff00ff00unido",
	CONFIRMED = "|cff88ff00preparado",
	STANDBY = "|cffffff00reserva",
	INVITED = "|cff00ff00invitado",
	DECLINED = "|cffff0000invitación rechazada",
	BUSY = "|cffff0000en otro grupo",
	OFFLINE = "|cff888888desconectado",
	LEFT = "|cff0000ffabandono grupo",
}

GroupCalendar.cStart = "Start"
GroupCalendar.cPause = "Pause"
GroupCalendar.cResume = "Resume"
GroupCalendar.cRestart = "Restart"

-- About tab

GroupCalendar.cAboutTitle = "Acerca de Group Calendar %s"
GroupCalendar.cAboutAuthor = "Diseñado y escrito por John Stephen"
GroupCalendar.cAboutThanks = "Many thanks to all fans and supporters.  I hope my addons add to your gaming enjoyment as much as building them adds to mine."

-- Partners tab

GroupCalendar.cPartnersTitle = "Multi-guild partnerships"
GroupCalendar.cPartnersDescription1 = "Multi-guild partnerships make it easy to coordinate events across guilds by sharing guild rosters (name, rank, class and level only) with your partner guilds"
GroupCalendar.cPartnersDescription2 = "To create a partnership, add a player using the Add Player button at the bottom of this window"
GroupCalendar.cAddPlayer = "Agregar jugador..."
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

GroupCalendar.cUnknown = "Desconocido"

-- Main window

GroupCalendar.cCalendar = "Calendario"
GroupCalendar.cSettings = "Configuración"
GroupCalendar.cPartners = "Partners"
GroupCalendar.cExport = "Export"
GroupCalendar.cAbout = "Acerca de"

GroupCalendar.cUseServerDateTime = "Usar fecha y hora del servidor"
GroupCalendar.cUseServerDateTimeDescription = "Activa para mostrar los eventos usando la fecha y hora del servidor, desactiva para usar tu fecha y hora local"
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

end -- esES
