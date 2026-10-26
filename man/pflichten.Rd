\name{pflicht_katalog}
\alias{pflicht_katalog}
\alias{ermittle_pflicht}
\title{Pflichtenkatalog und sachliche Pflichtauslösung}
\description{Verknüpft sachliche Auslöser mit strukturierten, bedingten
Rechtsfolgen und fachlich abgeleiteten Nachweisarten. Der Katalog ist ein Teilbestand.}
\usage{
pflicht_katalog()
ermittle_pflicht(pflicht_id, eingaben, quellenfassung)
}
\arguments{
\item{pflicht_id}{Stabile Kennung aus pflicht_katalog().}
\item{eingaben}{Benannte Liste nach eingabevertrag() der im Katalog hinterlegten
Auslöserregel. Keine automatische Auswahl aus zusätzlichen Unternehmensfeldern.}
\item{quellenfassung}{Explizite Quellenfassung, gegenwärtig EUAIACT_2026_07_27.}
}
\details{Der Katalog enthält Pflichtversion, Adressat, Gegenstand, Auslöserregel,
Rechtsfolge, Ausnahmen, Zeitbezug, Nachweisarten, verfügbare Erfüllungskriterien,
Quellenfassung und Bearbeitungsstatus. Kopien können unabhängig verändert werden.

ermittle_pflicht() prüft ausschließlich den sachlichen Auslöser. Zeitliche und
allgemeine rechtliche Anwendbarkeit bleiben UNBEKANNT. Erfüllung und Belege werden
nicht geprüft. Eine positive Auslöserprüfung ist keine Konformitätsaussage.
Nachweisarten sind fachlich abgeleitete Belegarten, keine zusätzlich erfundenen
gesetzlichen Dokumentpflichten. Es werden keine externen Aktionen ausgeführt.

Die Pflichtausgabe enthaelt auch Gegenstand, Ausnahmen, Fundstellen und \code{fristregel_ids}. Diese Zeitregelverweise sind mit \code{regel_info} und \code{berechne_regel} verwendbar. Ereignisdaten muessen separat uebergeben werden; keine automatische Frist- oder Erfuellungspruefung.}
\value{pflicht_katalog() liefert eine Liste von Pflichtdatensätzen.
ermittle_pflicht() liefert einen Ergebnisumschlag vom Typ OBJEKT. Bei gültigen
Eingaben enthält wert pflicht_id, pflichtversion, ausloeser_erfuellt,
adressat, gegenstand, ausnahmen, fundstellen, fristregel_ids, rechtsfolge, zeitbezug,
nachweisanforderungen, erfuellungskriterien und
erfuellung mit dem festen Wert NICHT_GEPRUEFT. Die Rechtsfolge ist immer bedingt,
auch bei falschem oder unbekanntem Auslöser. Unbekannte Pflicht-ID oder ungültige
Eingaben ergeben EINGABE_UNGUELTIG und wert=NULL; fehlende entscheidende Fakten
EINGABE_FEHLT mit partiellem Objekt. Entscheidungsspur und Quellen bleiben erhalten.}
\examples{
ermittle_pflicht("P_AIA_026_007", list(betreiberrolle = TRUE,
  hochrisikosystem = TRUE, betreiber_ist_arbeitgeber = TRUE,
  einsatz_am_arbeitsplatz_geplant = TRUE), "EUAIACT_2026_07_27")$wert
}
\seealso{\code{\link{eingabevertrag}}, \code{\link{pruefe_tatbestand}}}
