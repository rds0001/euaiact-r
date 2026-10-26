\name{aggregiere_unternehmensgruppe}
\alias{aggregiere_unternehmensgruppe}
\title{Qualifizierte Unternehmensgruppen exakt aggregieren}
\usage{
aggregiere_unternehmensgruppe(stamm_id, unternehmen, beziehungen,
  datenkreise, groesse, bezugsperiode, kreis_vollstaendig, quellenfassung)
}
\arguments{
\item{stamm_id}{ID des betrachteten Unternehmens.}
\item{unternehmen}{Eindeutige Unternehmens-IDs als unbenannte Liste oder Zeichenvektor.}
\item{beziehungen}{Unbenannte Liste qualifizierter VERBUND- oder PARTNER-Objekte.}
\item{datenkreise}{Disjunkte qualifizierte Unternehmensdaten; bei JAE mit Personensegmentinventar.}
\item{groesse}{JAE, UMSATZ_EUR oder BILANZ_EUR.}
\item{bezugsperiode}{Explizite gemeinsame Perioden-ID.}
\item{kreis_vollstaendig}{Belegte Vollstaendigkeit des qualifizierten Beziehungskreises.}
\item{quellenfassung}{EUAIACT_2026_07_27.}
}
\description{Ermittelt verbundene Komponenten und ihre unmittelbaren Partnergruppen
und aggregiert disjunkte konsolidierte Datenkreise ohne Rundung oder Netzwerk.
Beziehungsqualifikation und Konsolidierungsbuchungen sind vorgelagerte Aufgaben.}
\details{Verbundgruppen werden einmal voll, Partnergruppen proportional einbezogen.
Partner eines Partners werden nicht rekursiv verfolgt. Ueberlappende Datenkreise,
mehrfache Partnerpfade zwischen identischen Gruppen oder doppelte Personensegmente
werden abgewiesen. Finanzwerte sind exakte Dezimaltexte; JAE sind Zaehler/Nenner-Texte.
Der vollstaendige Vertrag befindet sich in inst/notes/UNTERNEHMENSGRUPPEN.md.}
\value{Ergebnisumschlag mit exakter Summe, Unternehmensgewichten, Datenkreisbeitraegen,
Quellen und Luecken. Keine allgemeine KMU-/SMC-Status- oder Rechtsentscheidung.}
