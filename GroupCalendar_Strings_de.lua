----------------------------------------
-- Group Calendar 5 Copyright (c) 2018 John Stephen
-- This software is licensed under the MIT license.
-- See the included LICENSE.txt file for more information.
----------------------------------------

if GetLocale() == "deDE" then

GroupCalendar.cTitle = "Group Calendar %s"
GroupCalendar.cCantReloadUI = "You must completely restart WoW to upgrade to this version of Group Calendar"

GroupCalendar.cHelpHeader = "Group Calendar Befehle"
GroupCalendar.cHelpHelp = "Zeige diese Liste von Befehlen"
GroupCalendar.cHelpReset = "Alle gespeicherten Daten und Einstellungen zurücksetzen"
GroupCalendar.cHelpDebug = "Debugcode aktivieren/deaktivieren"
GroupCalendar.cHelpClock = "Zeit des lokalen Computers oder des Servers auf der Minimap-Uhr anzeigen"
GroupCalendar.cHelpiCal = "iCal Exportdaten erzeugen (Default ist 'all')"
GroupCalendar.cHelpReminder = "Erinnerungen aktivieren/deaktivieren"
GroupCalendar.cHelpBirth = "Geburtstagsankündigungen aktivieren/deaktivieren"
GroupCalendar.cHelpAttend = "Teilnahmeerinnerungen aktivieren/deaktivieren"
GroupCalendar.cHelpShow = "Group Calendar Fenster anzeigen"

GroupCalendar.cTooltipScheduleItemFormat = "%s (%s)"

GroupCalendar.cForeignRealmFormat = "%s von %s"

GroupCalendar.cSingleItemFormat = "%s"
GroupCalendar.cTwoItemFormat = "%s und %s"
GroupCalendar.cMultiItemFormat = "%s{{, %s}} und %s"

-- Event names

GroupCalendar.cGeneralEventGroup = "Allgemein"
GroupCalendar.cPersonalEventGroup = "Persönlich"
GroupCalendar.cRaidClassicEventGroup = "Raids (Classic)"
GroupCalendar.cTBCRaidEventGroup = "Raids (Scherbenwelt)"
GroupCalendar.cWotLKRaidNEventGroup = "Raids (WotLK)"
GroupCalendar.cDungeonEventGroup = "Instanzen (Classic)"
GroupCalendar.cOutlandsDungeonEventGroup = "Instanzen (Scherbenwelt)"
GroupCalendar.cWotLKDungeonEventGroup = "Instanzen (WotLK)"
GroupCalendar.cOutlandsHeroicDungeonEventGroup = "Heroisch (Scherbenwelt)"
GroupCalendar.cWotLKHeroicDungeonEventGroup = "Heroisch (WotLK)"
GroupCalendar.cBattlegroundEventGroup = "PvP"
GroupCalendar.cOutdoorRaidEventGroup = "Raids im Freien"

GroupCalendar.cMeetingEventName = "Treffen"
GroupCalendar.cBirthdayEventName = "Geburtstag"
GroupCalendar.cRoleplayEventName = "Rollenspiel"
GroupCalendar.cHolidayEventName = "Feiertag"
GroupCalendar.cDentistEventName = "Zahnarzt"
GroupCalendar.cDoctorEventName = "Doktor"
GroupCalendar.cVacationEventName = "Urlaub"
GroupCalendar.cOtherEventName = "Anderes"

GroupCalendar.cCooldownEventName = "%s verfügbar"

GroupCalendar.cPersonalEventOwner = "Privat"
GroupCalendar.cBlizzardOwner = "Blizzard"

GroupCalendar.cNone = "Keines"

GroupCalendar.cAvailableMinutesFormat = "%s in %d Minuten"
GroupCalendar.cAvailableMinuteFormat = "%s in %d Minute"
GroupCalendar.cStartsMinutesFormat = "%s startet in %d Minuten"
GroupCalendar.cStartsMinuteFormat = "%s startet in %d Minute"
GroupCalendar.cStartingNowFormat = "%s startet jetzt"
GroupCalendar.cAlreadyStartedFormat = "%s hat bereits begonnen"
GroupCalendar.cHappyBirthdayFormat = "Herzlichen Glückwunsch zum Geburtstag %s!"

GroupCalendar.cLocalTimeNote = "(%s Lokalzeit)"
GroupCalendar.cServerTimeNote = "(%s server)"

-- Roles

GroupCalendar.cHRole = "Heiler"
GroupCalendar.cTRole = "Tank"
GroupCalendar.cRRole = "Fernkämpfer"
GroupCalendar.cMRole = "Nahkämpfer"

GroupCalendar.cHPluralRole = "Heiler"
GroupCalendar.cTPluralRole = "Tanks"
GroupCalendar.cRPluralRole = "Fernkämpfer"
GroupCalendar.cMPluralRole = "Nahkämpfer"

GroupCalendar.cHPluralLabel = GroupCalendar.cHPluralRole..":"
GroupCalendar.cTPluralLabel = GroupCalendar.cTPluralRole..":"
GroupCalendar.cRPluralLabel = GroupCalendar.cRPluralRole..":"
GroupCalendar.cMPluralLabel = GroupCalendar.cMPluralRole..":"

-- iCalendar export

GroupCalendar.cExportTitle = "Export to iCalendar"
GroupCalendar.cExportSummary = "Addons können leider nicht direkt auf Deinen Computer schreiben, deswegen sind für einen ICalender Datenexport ein paar einfache Schritte notwendig, die Du selbst durchführen musst:"
GroupCalendar.cExportInstructions =
{
	"Step 1: "..HIGHLIGHT_FONT_COLOR_CODE.."Wähle die zu exportierenden Events aus",
	"Step 2: "..HIGHLIGHT_FONT_COLOR_CODE.."Kopiere den Text aus dem Datenfeld",
	"Step 3: "..HIGHLIGHT_FONT_COLOR_CODE.."Erstelle ein neues File mit einem beliebigen Texteditor und kopiere den Text hinein",
	"Step 4: "..HIGHLIGHT_FONT_COLOR_CODE.."Speichere das File mit der Filextension '.ics' (z.B. Calendar.ics)",
	RED_FONT_COLOR_CODE.."WICHTIG: "..HIGHLIGHT_FONT_COLOR_CODE.."Das File muss unbedingt als 'plain Text' gespeichert werden, andernfalls ist es nicht verwendbar",
	"Step 5: "..HIGHLIGHT_FONT_COLOR_CODE.."Importiere das File in Deine Kalenderapplikation",
}

GroupCalendar.cPrivateEvents = "Private Events"
GroupCalendar.cGuildEvents = "Gildenevents"
GroupCalendar.cHolidays = "Urlaub"
GroupCalendar.cTradeskills = "Fertigkeitencooldowns"
GroupCalendar.cPersonalEvents = "Pers. Events"
GroupCalendar.cAlts = "Alts"
GroupCalendar.cOthers = "Sonstige"

GroupCalendar.cExportData = "Daten"

-- View tab

GroupCalendar.cLevelRangeFormat = "Levels %i bis %i"
GroupCalendar.cMinLevelFormat = "Ab Level %i"
GroupCalendar.cMaxLevelFormat = "Bis Level %i"
GroupCalendar.cAllLevels = "Alle Level"
GroupCalendar.cSingleLevel = "Nur Level %i"

GroupCalendar.cYes = "Ja - Ich werde teilnehmen"
GroupCalendar.cNo = "Nein - Ich werde nicht teilnehmen"
GroupCalendar.cMaybe = "Ich nehme vielleicht teil"

GroupCalendar.cStatusFormat = "Status: %s"
GroupCalendar.cInvitedByFormat = "Eingeladen von %s"

GroupCalendar.cInvitedStatus = "Eingeladen, warte auf Deine Antwort"
GroupCalendar.cAcceptedStatus = "Akzeptiert, warte auf Bestätigung"
GroupCalendar.cTentativeStatus = "Vielleicht, warte auf Bestätigung"
GroupCalendar.cDeclinedStatus = "Teilnahme abgelehnt"
GroupCalendar.cConfirmedStatus = "Bestätigt"
GroupCalendar.cOutStatus = CALENDAR_STATUS_OUT
GroupCalendar.cStandbyStatus = "Bestätigt, auf standby"
GroupCalendar.cSignedUpStatus = CALENDAR_STATUS_SIGNEDUP
GroupCalendar.cNotSignedUpStatus = CALENDAR_STATUS_NOT_SIGNEDUP

GroupCalendar.cAllDay = "ganztags"

GroupCalendar.cEventModeLabel = "Art:"
GroupCalendar.cTimeLabel = "Uhrzeit:"
GroupCalendar.cDurationLabel = "Dauer:"
GroupCalendar.cEventLabel = "Event:"
GroupCalendar.cTitleLabel = "Titel:"
GroupCalendar.cLevelsLabel = "Levels:"
GroupCalendar.cLevelRangeSeparator = "bis"
GroupCalendar.cDescriptionLabel = "Beschreibung:"
GroupCalendar.cCommentLabel = "Kommentar:"
GroupCalendar.cRepeatLabel = "Wiederholung:"
GroupCalendar.cAutoConfirmLabel = "Autom. Bestätigung"
GroupCalendar.cLockoutLabel = "Autom.Schliessen"
GroupCalendar.cEventClosedLabel = "Anmeldungen geschlossen"
GroupCalendar.cAutoConfirmRoleLimitsTitle = "Limits autom. bestätigen"
GroupCalendar.cAutoConfirmLimitsLabel = "Limits..."
GroupCalendar.cNormalMode = "Privates Event"
GroupCalendar.cAnnounceMode = "Gildenankündigung"
GroupCalendar.cSignupMode = "Gildenevent"
GroupCalendar.cCommunityMode = "Community event"

GroupCalendar.cLockout0 = "zu Beginn"
GroupCalendar.cLockout15 = "15 Minuten zu früh"
GroupCalendar.cLockout30 = "30 Minuten zu früh"
GroupCalendar.cLockout60 = "1 Stunde zu früh"
GroupCalendar.cLockout120 = "2 Stunden zu früh"
GroupCalendar.cLockout180 = "3 Stunden zu früh"
GroupCalendar.cLockout1440 = "1 Tag zu früh"

GroupCalendar.cPluralMinutesFormat = "%d Minuten"
GroupCalendar.cSingularHourFormat = "%d Stunde"
GroupCalendar.cPluralHourFormat = "%d Stunden"
GroupCalendar.cSingularHourPluralMinutes = "%d Stunde %d Minuten"
GroupCalendar.cPluralHourPluralMinutes = "%d Stunden %d Minuten"

GroupCalendar.cNewerVersionMessage = "Eine neue Version ist verfügbar (%s)"

GroupCalendar.cDelete = "Löschen"

-- Event Group tab

GroupCalendar.cViewGroupBy = "Gruppieren nach"
GroupCalendar.cViewByStatus = "Status"
GroupCalendar.cViewByClass = "Klasse"
GroupCalendar.cViewByRole = "Aufgabe"
GroupCalendar.cViewSortBy = "Sortiere nach"
GroupCalendar.cViewByDate = "Datum"
GroupCalendar.cViewByRank = "Rang"
GroupCalendar.cViewByName = "Name"

GroupCalendar.cInviteButtonTitle = "Ausgewählte einladen"
GroupCalendar.cAutoSelectButtonTitle = "Spieler wählen..."
GroupCalendar.cAutoSelectWindowTitle = "Spieler wählen"

GroupCalendar.cNoSelection = "Keine Spieler gewählt"
GroupCalendar.cSingleSelection = "1 Spieler gewählt"
GroupCalendar.cMultiSelection = "%d Spieler gewählt"

GroupCalendar.cInviteNeedSelectionStatus = "Wähle Spieler für Einladung"
GroupCalendar.cInviteReadyStatus = "Bereit zum Einladen"
GroupCalendar.cInviteInitialInvitesStatus = "Sende erste Einladungen"
GroupCalendar.cInviteAwaitingAcceptanceStatus = "Warte auf erste Rückmeldungen"
GroupCalendar.cInviteConvertingToRaidStatus = "Umwandeln in Schlachtzug"
GroupCalendar.cInviteInvitingStatus = "Sende Einladungen"
GroupCalendar.cInviteCompleteStatus = "Einladungen komplett"
GroupCalendar.cInviteReadyToRefillStatus = "Bereit, leere Plätze zu füllen"
GroupCalendar.cInviteNoMoreAvailableStatus = "Keine weiteren Spieler verfügbar"
GroupCalendar.cRaidFull = "Schlachtzug voll"

GroupCalendar.cWhisperPrefix = "[Group Calendar]"
GroupCalendar.cInviteWhisperFormat = "%s Du bist eingeladen zum Event '%s'.  Bitte nimm die Einladung an, wenn du am Event teilnehmen willst."
GroupCalendar.cAlreadyGroupedWhisper = "%s Du bist bereits in einer Gruppe.  Bitte flüstere mich an, wenn du die Gruppe verlassen hast."

GroupCalendar.cJoinedGroupStatus = "Beigetreten"
GroupCalendar.cInvitedGroupStatus = "Eingeladen"
GroupCalendar.cReadyGroupStatus = "Bereit"
GroupCalendar.cGroupedGroupStatus = "In anderer Gruppe"
GroupCalendar.cStandbyGroupStatus = CALENDAR_STATUS_STANDBY
GroupCalendar.cMaybeGroupStatus = "Vielleicht"
GroupCalendar.cDeclinedGroupStatus = "Einladung abgewiesen"
GroupCalendar.cOfflineGroupStatus = "Offline"
GroupCalendar.cLeftGroupStatus = "Gruppe verlassen"

GroupCalendar.cTotalLabel = "Total:"

GroupCalendar.cAutoConfirmationTitle = "Automatische Bestätigung"
GroupCalendar.cRoleConfirmationTitle = "Automatische Bestätigung durch Aufgabe"
GroupCalendar.cManualConfirmationTitle = "Manuelle Bestätigung"
GroupCalendar.cClosedEventTitle = "Event geschlossen"
GroupCalendar.cMinLabel = "min"
GroupCalendar.cMaxLabel = "max"

GroupCalendar.cStandby = "Standby"

-- Limits dialog

GroupCalendar.cMaxPartySizeLabel = "Maximale Gruppengröße:"
GroupCalendar.cMinPartySizeLabel = "Minimale Gruppengröße:"
GroupCalendar.cNoMinimum = "Kein Minimum"
GroupCalendar.cNoMaximum = "Kein Maximum"
GroupCalendar.cPartySizeFormat = "%d Spieler"

GroupCalendar.cAddPlayerTitle = "Hinzu.."
GroupCalendar.cAutoConfirmButtonTitle = "Optionen..."

GroupCalendar.cClassLimitDescription = "Benutze die Felder, um die minimale und maximale Anzahl Spieler pro Klasse festzulegen.  Klassen, die das Minimum nicht erreicht haben, werden zuerst aufgefüllt. Danach werden noch freie Plätze in Anmeldereihenfolge vergeben."
GroupCalendar.cRoleLimitDescription = "Benutze die Felder um die minimale und maximale Anzahl Spieler pro Aufgabe festzulegen.  Aufgaben, die das Minimum nicht erreicht haben, werden zuerst aufgefüllt. Danach werden noch freie Plätze in Anmeldereihenfolge vergeben.  Optional kannst Du die minimale Anzahl jeder Klasse für eine bestimmt Aufgabe festlegen (zum Beispiel: Es wird mindestens ein Schattenpriester als Fernkämpfer benötigt)"

GroupCalendar.cPriorityLabel = "Priorität:"
GroupCalendar.cPriorityDate = "Datum"
GroupCalendar.cPriorityRank = "Rang"

GroupCalendar.cCachedEventStatus = "Dieses Event ist eine gecachte Kopie von $Name's Kalender\rzuletzt upgedatet am $Date um $Time"

-- Class names

GroupCalendar.cClassName =
{
	DRUID = {Male = LOCALIZED_CLASS_NAMES_MALE.DRUID, Female = LOCALIZED_CLASS_NAMES_FEMALE.DRUID, Plural = "Druiden"},
	HUNTER = {Male = LOCALIZED_CLASS_NAMES_MALE.HUNTER, Female = LOCALIZED_CLASS_NAMES_FEMALE.HUNTER, Plural = "Jäger"},
	MAGE = {Male = LOCALIZED_CLASS_NAMES_MALE.MAGE, Female = LOCALIZED_CLASS_NAMES_FEMALE.MAGE, Plural = "Magier"},
	PALADIN = {Male = LOCALIZED_CLASS_NAMES_MALE.PALADIN, Female = LOCALIZED_CLASS_NAMES_FEMALE.PALADIN, Plural = "Paladine"},
	PRIEST = {Male = LOCALIZED_CLASS_NAMES_MALE.PRIEST, Female = LOCALIZED_CLASS_NAMES_FEMALE.PRIEST, Plural = "Priester"},
	ROGUE = {Male = LOCALIZED_CLASS_NAMES_MALE.ROGUE, Female = LOCALIZED_CLASS_NAMES_FEMALE.ROGUE, Plural = "Schurken"},
	SHAMAN = {Male = LOCALIZED_CLASS_NAMES_MALE.SHAMAN, Female = LOCALIZED_CLASS_NAMES_FEMALE.SHAMAN, Plural = "Schamanen"},
	WARLOCK = {Male = LOCALIZED_CLASS_NAMES_MALE.WARLOCK, Female = LOCALIZED_CLASS_NAMES_FEMALE.WARLOCK, Plural = "Hexenmeister"},
	WARRIOR = {Male = LOCALIZED_CLASS_NAMES_MALE.WARRIOR, Female = LOCALIZED_CLASS_NAMES_FEMALE.WARRIOR, Plural = "Krieger"},
	DEATHKNIGHT = {Male = LOCALIZED_CLASS_NAMES_MALE.DEATHKNIGHT, Female = LOCALIZED_CLASS_NAMES_FEMALE.DEATHKNIGHT, Plural = "Todesritter"},
	MONK = {Male = LOCALIZED_CLASS_NAMES_MALE.MONK, Female = LOCALIZED_CLASS_NAMES_FEMALE.MONK, Plural = "Monks"},
	DEMONHUNTER = {Male = LOCALIZED_CLASS_NAMES_MALE.DEMONHUNTER, Female = LOCALIZED_CLASS_NAMES_FEMALE.DEMONHUNTER, Plural = "Demon Hunters"},
}

GroupCalendar.cCurrentPartyOrRaid = "Dzt. Gruppe oder Raid"

GroupCalendar.cViewByFormat = "Anzeigen nach %s / %s"

GroupCalendar.cConfirm = "Bestätigen"

GroupCalendar.cSingleTimeDateFormat = "%s\r%s"
GroupCalendar.cTimeDateRangeFormat = "%s\r%s bis %s"

GroupCalendar.cStartEventHelp = "Start drücken, um mit Gruppen- oder Raidbildung zu beginnen"
GroupCalendar.cResumeEventHelp = "Weiter drücken, um mit Gruppen- oder Raidbildung fortzufahren"

GroupCalendar.cShowClassReservations = "Reservierungen >>>"
GroupCalendar.cHideClassReservations = "<<< Reservierungen"

GroupCalendar.cInviteStatusText =
{
	JOINED = "|cff00ff00beigetreten",
	CONFIRMED = "|cff88ff00bestätigt",
	STANDBY = "|cffffff00standby",
	INVITED = "|cff00ff00eingeladen",
	DECLINED = "|cffff0000Einladung abgewiesen",
	BUSY = "|cffff0000in anderer Gruppe",
	OFFLINE = "|cff888888offline",
	LEFT = "|cff0000ffGruppe verlassen",
}

GroupCalendar.cStart = "Start"
GroupCalendar.cPause = "Pause"
GroupCalendar.cResume = "Weiter"
GroupCalendar.cRestart = "Restart"

-- About tab

GroupCalendar.cAboutTitle = "Über Group Calendar %s"
GroupCalendar.cAboutAuthor = "Entworfen und programmiert von John Stephen"
GroupCalendar.cAboutThanks = "Herzlichen Dank an alle Fans und Unterstützer. Ich hoffe meine Addons bereiten Euch ebenso viel Freude im Spiel wie es mir Freude macht, sie zu entwickeln."

-- Partners tab

-- Partners tab

GroupCalendar.cPartnersTitle = "Gildenpartnerschaften"
GroupCalendar.cPartnersHelp =
[[
<html><body>
<h1>Gildenpartnerschaften machen es einfach, gemeinsame Events mehreren Gilden zur Verfügung zu stellen, indem die jeweiligen Mitgliederlisten (Name, Rang, Klasse und Level) zwischen befreundeten Gilden ausgetauscht werden. Die gesharten Mitgliederlisten scheinen dann im "Einladen" Bereich Deines Events auf, wo dann entweder selektive oder Masseneinladungen von Spielern aus der Partnergilde vorgenommen werden können.<br/><br/></h1>
<h2>Um eine Gildenpartnerschaft zu erstellen, gehe bitte wie folgt vor:<br/><br/></h2>
<p>* Du und ein Spieler der Partnergilde müssen die aktuelle Version von Group Calendar 5 installiert und aktiviert haben<br/>
* Beide Spieler müssen den "Partnerschaften" Bereich im Group Calendar geöffnet haben<br/>
* Einer der beiden Spieler beginnt das Erstellen einer Gildenpartnerschaft durch das Hinzufügen des anderen Spielers im Fenster und der Bestätigung durch die Schaltfläche unten.<br/>
* Der andere Spieler erhält danach eine entsprechende Meldung und wird um Bestätigung gebeten. Danach werden die Mitgliederlisten der beiden Gilden ausgetauscht und die Gildenpartnerschaft erstellt.</p>
<h1><br/>Die Mitgliederlisten werden dann automatisch überprüft und bei Bedarf neu synchronisiert. Um Performanceprobleme zu verhindern, findet während Kämpfen keine Synchronisation statt.</h1>
</body></html>
]]

GroupCalendar.cPartnersLabel = NORMAL_FONT_COLOR_CODE.."Partner:"..FONT_COLOR_CODE_CLOSE.." %s"
GroupCalendar.cSync = "Sync"

GroupCalendar.cConfirmDeletePartnerGuild = "Bist Du sicher, die Partnerschaft mit der Gilde <%s> zu löschen ?"
GroupCalendar.cConfirmDeletePartner = "Bist Du sicher, dass Du %s aus der Liste Deiner Partner entfernen willst ?"
GroupCalendar.cConfirmPartnerRequest = "%s würde gerne eine Partnerschaft mit Dir einrichten."

GroupCalendar.cLastPartnerUpdate = "Zuletzt synchronisiert am %s um %s Uhr"
GroupCalendar.cNoPartnerUpdate = "nicht synchronisiert"

GroupCalendar.cPartnerStatus =
{
	PARTNER_SYNC_CONNECTING = "Verbinde mit %s",
	PARTNER_SYNC_CONNECTED = "Synchronisiere mit %s",
}

-- Settings tab

GroupCalendar.cSettingsTitle = "Einstellungen"
GroupCalendar.cThemeLabel = "Thema"
GroupCalendar.cParchmentThemeName = "Pergament"
GroupCalendar.cLightParchmentThemeName = "Light Pergament"
GroupCalendar.cSeasonalThemeName = "Saisonal"
GroupCalendar.cTwentyFourHourTime = "24 Stunden Anzeige"
GroupCalendar.cAnnounceBirthdays = "Geburtstagserinnerungen anzeigen"
GroupCalendar.cAnnounceEvents = "Ereigniserinnungen anzeigen"
GroupCalendar.cAnnounceTradeskills = "Fertigkeitenerinnerungen anzeigen"
GroupCalendar.cRecordTradeskills = "Fertigkeitencooldowns aufzeichnen"
GroupCalendar.cRememberInvites = "Remember event invitations for use in future events"

GroupCalendar.cUnderConstruction = "Dieser Bereich befindet sich noch in Entwicklung"

GroupCalendar.cUnknown = "Unbekannt"

-- Main window

GroupCalendar.cCalendar = "Kalender"
GroupCalendar.cSettings = "Einstellungen"
GroupCalendar.cPartners = "Gildenpartnerschaften"
GroupCalendar.cExport = "Export"
GroupCalendar.cAbout = "Über"

GroupCalendar.cUseServerDateTime = "Benutze Server-Zeitformat"
GroupCalendar.cUseServerDateTimeDescription = "Aktivieren, um Events im Server-Zeitformat anzuzeigen. Deaktivieren, um Events im lokalen Zeitformat anzuzeigen."
GroupCalendar.cShowCalendarLabel = "Zeige:"
GroupCalendar.cShowAlts = "Alts anzeigen"
GroupCalendar.cShowAltsDescription = "Einschalten, um gecachte Events von Ihren anderen Charakteren zu zeigen"
GroupCalendar.cShowDarkmoonCalendarDescription = "Einschalten, um die Termine des Dunkelmondjahrmarkts zu zeigen"
GroupCalendar.cShowWeeklyCalendarDescription = "Einschalten, um wöchentliche Termine (z.B. Anglerwettbewerb) zu zeigen"
GroupCalendar.cShowPvPCalendarDescription = "Einschalten, um die Termine der PvP Wochenende zu zeigen"
GroupCalendar.cShowLockoutCalendarDescription = "Einschalten, um aktive Dungeonresets anzuzeigen"

GroupCalendar.cMinimapButtonHint = "Links klicken, um Group Calendar anzuzeigen."
GroupCalendar.cMinimapButtonHint2 = "Rechts klicken, um WoW Kalender anzuzeigen."

GroupCalendar.cNewEvent = "Neues Event..."
GroupCalendar.cPasteEvent = "Event einfügen"

GroupCalendar.cConfirmDelete = "Sind Sie sicher, dass Sie dieses Event löschen wollen? Diese Aktion wird das Event aus allen Kalendern, auch denen von anderen Spielern, löschen."

GroupCalendar.cGermanLocalization = "Deutsche Übersetzung"
GroupCalendar.cChineseLocalization = "Chinesische Übersetzung"
GroupCalendar.cFrenchLocalization = "Französische Übersetzung"
GroupCalendar.cSpanishLocalization = "Spanische Übersetzung"
GroupCalendar.cRussianLocalization = "Russische Übersetzung"
GroupCalendar.cContributingDeveloper = "Mitwirkender Entwickler"
GroupCalendar.cGuildCreditFormat = "Die Gilde %s"

GroupCalendar.cExpiredEventNote = "Dieses Ereignis ist bereits vorbei und kann nicht mehr geändert werden."

GroupCalendar.cMore = "mehr..."

GroupCalendar.cRespondedDateFormat = "Geantwortet %s"

GroupCalendar.cStartDayLabel = "Start week on:"

end -- deDE
