\name{schema_info}
\alias{schema_info}
\title{Lokales JSON-Schema des Ergebnisumschlags}
\description{Lädt ausschließlich das mit dem Paket ausgelieferte Schema.
Keine Netzwerkzugriffe oder Auflösung externer Referenzen.}
\usage{
schema_info(schema_id = "ERGEBNIS_0_1_0")
}
\arguments{
\item{schema_id}{Explizite lokale Schema-ID. ERGEBNIS_0_1_0 oder eine Katalogregel-ID mit dem Suffix :EINGABEN.}
}
\value{Unabhängige benannte Liste mit dem JSON-Schema nach Draft 2020-12.
Eingabeschemata erlauben fehlende und null-Werte. Exakte Dezimalgrenzen
stehen als Annotationen im Schema und werden nur durch die native
Regelauswertung geprüft. Unbekannte IDs lösen einen Fehler aus. Die URI im Schema beschreibt den Standard
und wird von der Library nicht aufgerufen.}
\examples{
schema_info()$required
}
