\name{pruefe_anwendungsbeginn}
\alias{pruefe_anwendungsbeginn}
\title{Allgemeinen Anwendungsbeginn nach Artikel 113 prüfen}
\description{Vergleicht den ausdrücklich gewählten Stichtag mit dem allgemeinen
Beginn eines Bereichs in der ausdrücklich gewählten Quellenfassung.}
\usage{
pruefe_anwendungsbeginn(bereich, stichtag, quellenfassung)
}
\arguments{
\item{bereich}{Ein Bereich aus der nachfolgenden Liste.}
\item{stichtag}{ISO-Datum YYYY-MM-DD oder NULL für unbekannt.}
\item{quellenfassung}{EUAIACT_2024_08_01 oder EUAIACT_2026_07_27.}
}
\details{In beiden Fassungen: ALLGEMEIN, KAPITEL_I_II_BESTAND,
KAPITEL_III_ABSCHNITT_4, KAPITEL_V, KAPITEL_VII, KAPITEL_XII_OHNE_101,
ARTIKEL_78, ARTIKEL_101, ARTIKEL_6_5, ARTIKEL_102_BIS_110 und
HOCHRISIKO_ANHANG_III_ABSCHNITT_1_BIS_3_OHNE_6_5.

Nur 2024: HOCHRISIKO_ANHANG_I_ARTIKEL_6_1_UND_ZUGEHOERIGE_PFLICHTEN.
Nur 2026: HOCHRISIKO_ANHANG_I_ABSCHNITT_1_BIS_3_OHNE_6_5 und
ARTIKEL_5_BA_BB_1A_1B.

KAPITEL_I_II_BESTAND schließt den neuen Artikel 4a und die neuen Verbote aus.
Stichtage vor Inkrafttreten der gewählten Fassung sind ungültig. Die frühere
Fassung kann eine damalige Planung für spätere Daten abbilden; sie wird nicht
automatisch durch die neue Fassung ersetzt. Artikel 111 sowie sachlicher,
persönlicher und territorialer Geltungsbereich werden separat geprüft.

ARTIKEL_4A in der Fassung 2026 ist als offene Rechtsfrage F002
registriert. Vollständige gültige Eingaben liefern REGEL_UNGEKLAERT statt eines
geschätzten Beginns.}
\value{Ergebnisumschlag mit Boolean in wert und dem verglichenen Beginn in
entscheidungsschritte. Anwendbarkeit bleibt UNBEKANNT. Fehlende Angaben ergeben
EINGABE_FEHLT; ungültige Bereiche, Fassungen oder Daten EINGABE_UNGUELTIG.}
\examples{
pruefe_anwendungsbeginn("ARTIKEL_5_BA_BB_1A_1B", "2026-12-01",
  "EUAIACT_2026_07_27")$wert
}
