\name{tabelle_info}
\alias{tabelle_info}
\alias{tabellen_katalog}
\title{Versionierte lokale Anhangtabellen}
\description{Strukturierte Listen aus den Anhaengen I, II, X, XIII und XIV der Quellenfassung EUAIACT_2026_07_27, ohne Netzwerkzugriff.}
\usage{
tabellen_katalog()
tabelle_info(tabellen_id)
}
\arguments{
\item{tabellen_id}{Eine Zeichenkette: \code{ANH_I}, \code{ANH_II}, \code{ANH_X}, \code{ANH_XIII} oder \code{ANH_XIV}.}
}
\value{\code{tabellen_katalog} liefert eine unbenannte Liste von Metadaten mit ID, Version, Quellenfassung, Bezeichnung, Status und Zeilenzahl. \code{tabelle_info} liefert eine Liste mit geordneten Spalten und Zeilen, Quellennachweis, Grenzen und Status. Aufrufer koennen ihre Kopie veraendern, ohne den internen Bestand zu aendern. Unbekannte oder ungueltige IDs erzeugen einen Fehler.}
\details{Tabellenmitgliedschaft entscheidet keine individuelle Anwendbarkeit. Sektorale Rechtsakte werden nicht vollstaendig implementiert. Die Maschinenverordnung ist in dieser Fassung Anhang I Abschnitt B Nummer 21 zugeordnet; der gestrichene Eintrag A Nummer 1 ist kein aktueller Datensatz. Codes des Anhangs XIV beschreiben den Notifizierungsumfang, keine automatische Systemzulassung. Datensaetze koennen lokal mit eigenen Daten ueber explizite IDs oder CELEX-Kennungen verbunden werden. Keine automatische Aktualisierung.}
\examples{
tabellen_katalog()
t <- tabelle_info("ANH_I")
maschinen <- Filter(function(z) z$celex == "32023R1230", t$zeilen)
stopifnot(maschinen[[1]]$abschnitt == "B")
}
