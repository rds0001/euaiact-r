\name{rechenregeln}
\alias{berechne_regel}
\alias{berechne_bussgeldobergrenze}
\title{Exakte Obergrenzen und Größenmerkmale}
\description{Berechnet die ausdrücklich spezifizierte Größe mit lokalen Daten.
Geldbeträge werden ohne implizite Rundung als Dezimalzeichenfolgen ausgegeben.}
\usage{
berechne_regel(regel_id, eingaben, quellenfassung)
berechne_bussgeldobergrenze(eingaben, quellenfassung)
}
\arguments{
\item{regel_id}{Eine Rechenregel-ID aus \code{regel_katalog()}.}
\item{eingaben}{Benannte Liste entsprechend \code{regel_info(regel_id)$eingaben}.
Geld, Anteile und Jahresarbeitseinheiten sind Dezimalzeichenfolgen. Kleine
Personen-/Stimmenzahlen sind skalare ganze Zahlen. Fehlende Angaben bleiben unbekannt.}
\item{quellenfassung}{Explizite Quellenfassung, gegenwärtig \code{EUAIACT_2026_07_27}.}
}
\details{
\code{AIA_075C_005_TAGESEINKOMMEN} berechnet exakt fuenf Prozent eines
vorgelagert rechtlich qualifizierten durchschnittlichen Tageseinkommens.
Keine automatische Basiswahl, Umsatzumrechnung, Cent-Rundung oder tatsaechliche
Sanktionsfestsetzung. Die offene Umsatzfrage F003 bleibt gesondert.

Die Regeln \code{AIA_097_003_WIRKSAMKEIT} und \code{OMN_003_03_WIRKSAMKEIT} berechnen den Tag nach der Amtsblattveroeffentlichung oder einen ausdruecklich spaeteren Tag. Es gibt keine Wochenendverschiebung; konkrete Delegation und zustaendiges Organ bleiben getrennte Voraussetzungen.

Die Regel \code{AIA_050_005_INFORMATIONSZEITPUNKT} vergleicht
\code{transparenzinformation_zeitpunkt} mit
\code{erste_interaktion_oder_exposition_zeitpunkt} und liefert wahr, wenn die
Information spätestens beim Erstkontakt bereitgestellt wurde. Zeichenfolgen
verwenden das Profil YYYY-MM-DDTHH:MM:SS mit optional ein bis sechs
Nachkommastellen und Z oder explizitem Offset (+/-HH:MM). Jahre 0001 bis 9999;
keine Schaltsekunden, kein unbekannter Offset -00:00, keine Systemzeitzone.
UTC-Sekunden und Mikrosekunden werden getrennt exakt verglichen. Pflichtauslöser,
Informationsqualität, Barrierefreiheit und zeitliche Anwendbarkeit separat.

Die Regeln \code{KMU_PARTNER_HINZURECHNUNG} und
\code{KMU_VERBUND_HINZURECHNUNG} addieren einen qualifizierten noch nicht
enthaltenen Unternehmenswert zur Aggregationsbasis. Die Partnerregel verwendet
zusätzlich die exakte \code{hinzurechnungsquote} zwischen null und eins,
die Verbundregel die feste Quote eins. Die Eingaben
\code{aggregationsbasiswert} und
\code{noch_hinzuzurechnender_unternehmenswert} betreffen dieselbe Kennzahl,
Einheit und Periode. Bereits konsolidierte Daten sind vorab auszuschließen.
Es erfolgt keine automatische Beteiligungsgraph- oder Größenstatusermittlung
und keine Rundung. Multiplikation und Addition erscheinen in der Rechenspur.
Je Dezimaleingabe gelten maximal 4096 Zeichen, auch bei Weiterverwendung.

Anlassabhängige Dauern wählen einen gesetzlichen Dauerparameter anhand eines
expliziten Enum-Feldes. Eine fehlende Anlasskategorie führt zu keinem Standardwert.
Höchstdauern sind von tatsächlich gewährten Zeiträumen zu unterscheiden.
Feste Dauern liefern Anzahl und Einheit bei leerer Eingabeliste. Zeitbezug
und Richtung sind in \code{regel_info} dokumentiert. Es wird kein Enddatum
berechnet; eine Vorankündigung darf nicht als nachlaufende Frist verwendet
werden. Aufbewahrungsdauern sind keine automatische Löschfreigabe.

\code{berechne_bussgeldobergrenze} ist der fachliche Einstieg für Artikel 99.
Die Kategorien lauten \code{VERBOT}, \code{PFLICHT} und \code{INFORMATION};
die Akteurklassen \code{KEIN_UNTERNEHMEN}, \code{KMU}, \code{SMC} und
\code{SONSTIGES_UNTERNEHMEN}. Für Unternehmen ist der
\code{weltweiter_vorjahresumsatz_eur} anzugeben.

Berechnet wird die gesetzliche Obergrenze, nicht das tatsächliche Bußgeld.
Zeitliche und rechtliche Anwendbarkeit sowie Größenstatus sind gesondert zu
prüfen. Die Regel \code{KMU_SCHWELLEN} liefert ausschließlich gegenwärtige
Größenmerkmale; Beteiligungen und Statushistorie werden dadurch nicht ersetzt.

AIA_073_MELDEFRISTTAGE verwendet die booleschen Eingaben
weitverbreiteter_verstoss, schwere_irreversible_kritische_infrastrukturstoerung
und todesfall. Ein wahrer Zweitagesgrund liefert 2 trotz anderer Lücken; bei zwei
falschen Zweitagesgründen gilt 10 für Todesfall, sonst 15. Fehlende entscheidende
Fakten bleiben unbekannt. Dies ist nur die äußerste Tagesdauer, kein Aufschub
einer unverzüglichen Meldung. Meldepflicht, Kenntnistag, Vorfallschwere und
Artikel 73 Absätze 9/10 sind separat zu prüfen.


AIA_030_EINWANDSPERIODE liefert die Anzahl 2 und die Einheit
WOCHE oder MONAT abhängig von der Notifizierungsgrundlage. Ereignisdatum,
Kalender, Fristablauf und Einwände sind gesondert zu prüfen.}
\value{Vollständiger Ergebnisumschlag wie bei \code{pruefe_tatbestand}, mit
\code{rechenschritte}, Einheit und typisiertem \code{wert}. Fehlende relevante
Angaben ergeben \code{EINGABE_FEHLT}, ungültige Angaben \code{EINGABE_UNGUELTIG}.
Teilweise bestimmbare Größenmerkmale können innerhalb des Objekts unbekannt bleiben.}

\section{Grundrechtebewertung vor Ersteinsatz}{
AIA_027_001_VOR_EINSATZ vergleicht fria_abschluss_zeitpunkt strikt mit
\code{erstmaliger_einsatz_zeitpunkt}. Beide Eingaben verwenden DATUMZEIT mit
explizitem UTC-Offset. Gleiche Instanten sind nicht vorher. Pflichtauslöser und
Bewertungsinhalte separat prüfen; keine Stundenfristberechnung.
}
\section{Jahresarbeitseinheiten}{
KMU_JAE_DEZIMALBEITRAG und SMC_JAE_DEZIMALBEITRAG multiplizieren die exakt
endlichen Dezimaltexte arbeitszeitanteil_an_vollzeit und anrechenbarer_jahresanteil
(jeweils 0 bis 1). JAE_DEZIMALSUMME addiert bisherige_jahresarbeitseinheiten und
zusaetzliche_jahresarbeitseinheiten. Personenkreis, anrechenbare homogene Abschnitte
und disjunkte Beiträge vorher qualifizieren. Keine automatische Kalenderbasis,
keine Rundung periodischer Brüche wie 1/3 und keine vollständige rationale
Quotenermittlung. Ergebnisse sind exakte Dezimaltexte.
}
\examples{
berechne_bussgeldobergrenze(list(
  verstosskategorie = "PFLICHT", akteurklasse = "SMC",
  weltweiter_vorjahresumsatz_eur = "100000000"
), "EUAIACT_2026_07_27")$wert
}
\seealso{\code{\link{pruefe_tatbestand}}, \code{\link{regel_info}}}
