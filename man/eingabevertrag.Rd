\name{eingabevertrag}
\alias{eingabevertrag}
\title{Vollständige Eingabefelder einer Katalogregel}
\description{Liefert die Feldverträge einschließlich transitiver Regelverweise
als unabhängige native Daten. Enthält keine Unternehmensdaten.}
\usage{
eingabevertrag(regel_id)
}
\arguments{
\item{regel_id}{Bekannte ID aus regel_katalog(). Unbekannte IDs lösen einen Fehler aus.}
}
\details{Zusammengesetzte Regeln benötigen auch Felder der referenzierten Regeln.
Die unmittelbaren eingaben in regel_info() allein sind dann nicht vollständig.
Fehlende Felder und NULL bleiben unbekannt; zusätzliche Felder sind unzulässig.
Zeit- und Fristfunktionen haben separat dokumentierte Parameterverträge.}
\value{Liste mit regel_id, regelversion, quellenfassung, schemaversion,
felder (nach Namen sortiert), unbekannt und zusaetzliche_felder.
Jeder Feldvertrag enthält den Typ und gegebenenfalls Einheit, Kategorieauswahl
oder exakte Grenzen als Dezimalzeichenfolgen.}
\examples{
names(eingabevertrag("AIA_053_001_A")$felder)
}
