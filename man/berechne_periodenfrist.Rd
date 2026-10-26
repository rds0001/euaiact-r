\name{berechne_periodenfrist}
\alias{berechne_periodenfrist}
\title{Zusammengesetzte Kalenderperioden}
\description{Ganze Wochen, Monate oder Jahre und echte Monatsbrueche mit einmaliger Anwendung der Kalenderendregeln.}
\usage{
berechne_periodenfrist(ereignisdatum, anzahl, einheit, modus,
  kalender = NULL, monatsbruch = NULL, beginnkonvention = NULL,
  beginnbegruendung = NULL, quellenfassung)
}
\arguments{
\item{ereignisdatum}{Explizites ISO-Datum YYYY-MM-DD.}
\item{anzahl}{Ganze Anzahl von0bis1000000; Gesamtperiode muss positiv sein.}
\item{einheit}{WOCHE, MONAT oder JAHR.}
\item{modus}{FRIST, FESTER_TERMIN, INKRAFTTRETEN, RUECKWAERTS oder VERFAHREN_1755.}
\item{kalender}{Benannte Liste mit von, bis, feiertage und nichtleerem bezug. Erforderlich fuer Arbeitstagsregeln.}
\item{monatsbruch}{Nur fuer MONAT: Liste mit zaehler und nenner als kanonische Ganzzahltexte, echter nichtnegativer Bruch. NULL bedeutet keine Bruchkomponente.}
\item{beginnkonvention}{Nur fuer VERFAHREN_1755: explizites EREIGNISTAG, BEGINNTAG oder VORTAG_DES_BEGINNS.}
\item{beginnbegruendung}{Nichtleere Begruendung des1755-Profils. F007 wird dadurch nicht rechtlich geloest.}
\item{quellenfassung}{Explizit EUAIACT_2026_07_27.}
}
\details{Ganze Monate zuerst, danach30malMonatsbruch in Tagen. Endverschiebung und Mindestarbeitstage nur auf Gesamtperiode anwenden. Nichtganze Bruchtage bleiben ohne untertaegige Endkonvention REGEL_UNGEKLAERT. Ebenso1755-Langperioden ohne begruendetes Profil. Vollstaendiger Vertrag in notes/PERIODENFRISTEN.md.}
\value{Ergebnisumschlag mit Datum, Komponenten, Quellen und ausdruecklichen Daten-/Rechtsgrenzen.}
\examples{
berechne_periodenfrist("2026-01-31", 1, "MONAT", "FRIST",
  list(von="2026-01-01", bis="2026-12-31", feiertage=list(),
  bezug="SYNTHETISCH"), list(zaehler="1", nenner="2"),
  quellenfassung="EUAIACT_2026_07_27")
}
