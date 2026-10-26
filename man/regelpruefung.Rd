\name{regelpruefung}
\alias{regel_info}
\alias{regel_katalog}
\alias{pruefe_tatbestand}
\alias{pruefe_stapel}
\title{Lokale sachliche Regelprüfung mit unbekannten Angaben}
\description{
Wertet ausdrücklich übergebene Fakten anhand eines paketinternen Regelkatalogs
aus. Der Katalog ist ein fachlicher Entwicklungsstand. Die Prüfung eines
Tatbestands ist keine umfassende Konformitätsprüfung.
}
\usage{
regel_info(regel_id)
regel_katalog()
pruefe_tatbestand(regel_id, eingaben, quellenfassung)
pruefe_stapel(faelle, quellenfassung)
}
\arguments{
\item{regel_id}{Eindeutige Zeichenfolge aus dem Regelkatalog.}
\item{eingaben}{Benannte Liste mit eindeutigen Schlüsseln. Booleanfelder sind
skalare logische Werte. Dezimalfelder sind kanonische Zeichenfolgen mit höchstens
4096 Zeichen; Exponenten, Tausendertrennzeichen und Komma sind unzulässig.
Fehlende Schlüssel, \code{NULL} und skalare \code{NA}-Werte bedeuten unbekannt.
\code{NaN} ist ungültig.}
\item{quellenfassung}{Explizite Quellenkennung. Der gegenwärtige Katalog verwendet
\code{EUAIACT_2026_07_27}; nicht verfügbare Fassungen werden abgewiesen.}
\item{faelle}{Liste von Fällen mit genau \code{fall_id}, \code{regel_id} und
\code{eingaben}. Fall-IDs müssen eindeutige, nichtleere Zeichenfolgen sein.}
}
\details{
Entscheidungsrelevante offene Rechtsfragen liefern den Status
\code{REGEL_UNGEKLAERT}. Sie sind keine fehlenden Unternehmensdaten und werden
als \code{frage_id} beziehungsweise \code{offene_rechtsfragen} in der Spur
sowie in den Hinweisen ausgewiesen. Datenlücken bleiben separat; eine
Rechtsfrage ist kein überschreibbares Eingabefeld. Ein bestimmendes anderes
UND-/ODER-Glied kann sie unerheblich machen. Aktuelle Fälle sind divergierende
EN/DE-Business-Angel-Grenzen: exakt fünf Millionen EUR bei SMC (F015) und
exakt 1,25 Millionen EUR bei KMU (F016).


UND wird durch einen falschen Operanden falsch, ODER durch einen wahren Operanden
wahr. In sonst nicht entscheidbaren Fällen bleibt der Wert unbekannt.
Alle gelieferten Angaben werden unabhängig von ihrer Entscheidungsrelevanz
typgeprüft. Die Funktionen verändern keine Eingaben und führen keine
Netzwerkzugriffe oder externen Programmausführungen aus.

Zeitliche, territoriale und sonstige rechtliche Anwendbarkeit wird durch diese
Funktionen nicht bestimmt. Deshalb ist \code{anwendbarkeit} bei einer gültigen
Tatbestandsprüfung \code{UNBEKANNT}, auch wenn der sachliche Wert entschieden ist.
Der Katalogstatus bleibt im Ergebnis sichtbar.
ENUM-Kategorien werden exakt verglichen; zulässige Werte stehen in
\code{eingabevertrag(regel_id)}. AIA_002_002_NORMGRUPPE_ZULAESSIG prüft nur
den besonderen Normgruppenausschluss, keine allgemeine Anwendbarkeit.
AIA_002_013_VORAUSSETZUNGEN bestätigt keinen erlassenen Ausnahmeakt.

Quellenbelege umfassen die durchlaufenen Unterregeln mit regel_id und
regelversion. Unterregelgrenzen erscheinen in hinweise mit Regel-ID.
Besuchsreihenfolge bleibt erhalten; mehrfach referenzierte Regeln erhalten nur
eine Beleggruppe. Auch logisch nicht entscheidende Zweige werden betrachtet.
}
\value{
\code{regel_info} liefert die Regelspezifikation als Liste und löst bei einer
unbekannten ID einen Fehler aus. \code{regel_katalog} liefert eine Liste von
Katalogeinträgen. \code{pruefe_tatbestand} liefert eine benannte Liste mit
\code{wert}, \code{status}, Fassungsinformationen, Eingaben, Entscheidungsschritten,
fehlenden Angaben, entscheidungsrelevanten Lücken und Quellenverweisen. Ein
unbekannter Wert ist \code{NULL}; ein falscher Wert ist \code{FALSE}.
\code{pruefe_stapel} liefert Ergebnisse mit ihren Fall-IDs. Strukturfehler und
doppelte IDs führen zu einem Fehler; ungültige Fakten werden fallbezogen berichtet.
}
\examples{
pruefe_tatbestand(
  "AIA_051_002",
  list(trainings_flops = "10000000000000000000000001"),
  "EUAIACT_2026_07_27"
)$wert

pruefe_tatbestand("AIA_051_002", list(), "EUAIACT_2026_07_27")$status
}
