\name{berechne_verjaehrung}
\alias{berechne_verjaehrung}
\title{Qualifizierte Verjaehrungsverlaeufe}
\description{Berechnet lokale Ereignisablaeufe mit getrennten Verfahrensregeln.}
\usage{
berechne_verjaehrung(verfahren, ereignisdatum, unterbrechungen, hemmungen,
  stichtag, kalender, quellenfassung, beginnkonvention = NULL,
  beginnbegruendung = NULL)
}
\arguments{
\item{verfahren}{GPAI_VERFOLGUNG, GPAI_VOLLSTRECKUNG, KI_BUERO_VERFOLGUNG oder KI_BUERO_VOLLSTRECKUNG.}
\item{ereignisdatum}{Qualifizierter Tattag, Ende fortdauernden Verhaltens oder Bestandskraft, YYYY-MM-DD.}
\item{unterbrechungen}{Liste mit hoechstens1000 benannten Listen mit datum und verfahrensspezifischer art.}
\item{hemmungen}{Liste mit hoechstens1000 benannten Listen mit von, bis_exklusiv und art. NULL als Ende bezeichnet laufende Hemmung. Grenzen sind qualifizierte volle Kalendertage.}
\item{stichtag}{Explizites Datum des betrachteten Ereignisbestands.}
\item{kalender}{Benannte Liste mit von, bis, feiertage als Liste und nichtleerem bezug.}
\item{quellenfassung}{Explizit EUAIACT_2026_07_27.}
\item{beginnkonvention}{Fuer GPAI explizite Nutzervorgabe EREIGNISTAG, BEGINNTAG oder VORTAG_DES_BEGINNS; ohne Auswahl bleibt F007 offen. Im75c-Verfahren NULL.}
\item{beginnbegruendung}{Nichtleere dokumentierte Begruendung der GPAI-Nutzervorgabe; keine Rechtsklaerung durch die Library. Im75c-Verfahren NULL.}
}
\details{GPAI-Verfolgung hat eine urspruengliche Zehnjahreshoechstfrist mit gerichtlicher Hemmung; Vollstreckung hat keinen solchen Deckel. Hemmungen werden vereinigt. Keine Wiederbelebung abgelaufener Fristen und keine Uebernahme1755 auf75c. Laufende relevante Hemmung liefert kein endgueltiges Fristende. Vollstaendiger Vertrag und Ereignisarten in der installierten Datei notes/VERJAEHRUNGSVERTRAG.md.}
\value{Gemeinsamer Ergebnisumschlag mit Fristenden, Unterbrechungsschritten, Nutzervorgaben und ausdruecklichen Daten-/Rechtsluecken. Kein automatischer Verjaehrungsbescheid.}
\examples{
berechne_verjaehrung("GPAI_VERFOLGUNG", "2026-10-23", list(), list(),
  "2026-10-25", list(von="2026-01-01", bis="2038-12-31",
  feiertage=list(), bezug="SYNTHETISCH"), "EUAIACT_2026_07_27")
}
