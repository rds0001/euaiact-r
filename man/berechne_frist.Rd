\name{berechne_frist}
\alias{berechne_frist}
\title{Kalenderfrist mit ausdrücklichem Nutzerkalender}
\description{Berechnet ein Enddatum nach den ausdrücklich gewählten
Datumsregeln der Verordnung 1182/71. Verwendet keine Systemzeit.}
\usage{
berechne_frist(ereignisdatum, anzahl, einheit, modus, kalender = NULL, quellenfassung)
}
\arguments{
\item{ereignisdatum}{ISO-Datum als Text YYYY-MM-DD, Jahre 0001 bis 9999. Bei STUNDE ein ISO-Zeitstempel mit explizitem UTC-Offset.}
\item{anzahl}{Positive ganze Zahl.}
\item{einheit}{TAG, ARBEITSTAG, WOCHE, MONAT, JAHR oder STUNDE (nur FRIST).}
\item{modus}{FRIST, FESTER_TERMIN, INKRAFTTRETEN, RUECKWAERTS oder VERFAHREN_1755_TAGE.}
\item{kalender}{Liste mit genau von, bis (ISO-Daten), feiertage (Liste von
ISO-Daten) und bezug (nichtleerer Herkunfts-/Geltungsbereichstext).
Feiertage müssen eindeutig und innerhalb der Kalenderdeckung liegen.
Für FESTER_TERMIN/INKRAFTTRETEN ohne ARBEITSTAG-Einheit ist kein Kalender erforderlich.}
\item{quellenfassung}{Explizit EUAIACT_2026_07_27.}
}
\details{Der Ereignistag wird ausgeschlossen. Monate und Jahre verwenden
den entsprechenden Tag oder den letzten Tag des Zielmonats. Im Modus FRIST
wird ein Ende an einem arbeitsfreien Tag auf den nächsten Arbeitstag verschoben;
Fristen ab zwei Tagen enthalten mindestens zwei Arbeitstage. FESTER_TERMIN und
INKRAFTTRETEN wenden diese beiden Verlängerungen nicht an. Samstag, Sonntag und
explizite Feiertage sind arbeitsfrei. Unzureichende Kalenderdeckung bleibt unbekannt.
VERFAHREN_1755_TAGE wendet Artikel 12 Absatz 2 der DVO 2026/1755 für
GPAI-Kommissionsverfahren an: erster folgender Arbeitstag ist Tag 1; danach
normale Endregeln. Nur TAG und ARBEITSTAG sind für diesen Modus zulässig.
RUECKWAERTS rechnet vor dem ausgeschlossenen Bezugstag zurück. Keine
Endverschiebung auf einen Arbeitstag; mindestens zwei Arbeitstage bei Perioden
ab zwei Tagen werden durch weitere Rückrechnung erreicht. Kalender erforderlich.
Korrespondenztag oder letzter Zielmonatstag, Ergebnis zum Ablauf des Grenztags.
Wochen-/Monats-/Jahresfristen des Sonderverfahrens sind nicht enthalten.
STUNDE im Modus FRIST schliesst die Ereignisstunde aus und zaehlt volle folgende
Stunden. Der Ergebniswert enthaelt beginn und ende_exklusiv als UTC-Texte;
an der exklusiven Endgrenze ist die Frist bereits abgelaufen. Keine
Wochenend-Endverschiebung. Ab48Stunden bleibt F011 als REGEL_UNGEKLAERT ohne
Fachwert erhalten. Keine automatische Anwendung auf spezielle AI-Act-Hoechstgrenzen.
Eine zusätzliche Pflicht zu unverzüglichem Handeln wird nicht bewertet.}
\value{Ergebnisumschlag mit ISO-Datum in wert beziehungsweise Stundenobjekt mit beginn/ende_exklusiv, Rechenschritten und Fundstelle.
Ungültige Angaben ergeben EINGABE_UNGUELTIG; fehlende Angaben oder benötigte
Kalenderdeckung EINGABE_FEHLT. Rechtliche Anwendbarkeit bleibt UNBEKANNT.}
\examples{
berechne_frist("2026-10-23", 2, "TAG", "FRIST",
  list(von = "2026-01-01", bis = "2026-12-31", feiertage = list(),
       bezug = "SYNTHETISCH: keine Feiertage"), "EUAIACT_2026_07_27")$wert
}
