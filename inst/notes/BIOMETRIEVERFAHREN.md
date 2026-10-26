# Nachträgliche biometrische Fernidentifizierung

Artikel 26 Absatz 10 enthält unterschiedliche Regelungsbereiche. Die enge
Erstidentifikationsausnahme betrifft den Genehmigungsantrag; sie beseitigt weder
Dokumentation noch Datenschutz oder sonstige Einsatzgrenzen. Antragstellung
bedeutet keine Genehmigung und keine pauschale Zulässigkeit.

Ein Nachantrag muss unverzüglich UND innerhalb der gesetzlichen 48-Stunden-Grenze
erfolgen. Diese Grenze ist momentan eine qualifizierte Eingabe mit Zeitnachweis.
Der Stundenrechner ersetzt die rechtliche Qualifikation dieses Sonderregimes nicht; eine Kalender-Tagesrechnung ist kein Ersatz. Nach Ablehnung sind Stopp und Datenlöschung
kumulativ, bezogen auf den betreffenden Einsatz.

Ungezielte Strafverfolgungsnutzung ohne einen der gesetzlichen Bezüge und
nachteilige Rechtsentscheidungen allein aufgrund der Ausgabe sind getrennte
Verbote. Ein negatives Ergebnis einer Verbotsregel stellt keine Erlaubnis dar.
Die Erforderlichkeitsregel betrifft den konkreten Untersuchungszusammenhang;
sie darf nicht stillschweigend auf jeden anders geregelten Vermisstenfall
übertragen werden.

Jeder Einsatz wird unabhängig von Zweck und Betreiber dokumentiert. Zugang auf
Anfrage und jährliche Berichte sind eigene Pflichten; beide zuständigen
Behördengruppen und die Ausnahme sensibler operativer Daten bleiben sichtbar.
Ein bestimmter jährlicher Abgabetag wird nicht erfunden. Strengere nationale
Gesetze sowie Datenschutzregeln sind als externe Qualifikation einzubeziehen.

28 handverfasste Referenzen prüfen die Ausnahme, alternative Empfänger,
fehlende Fristkenntnis, verzögerten Antrag, Ablehnungsfolgen, Verbotsgrenzen,
Anfragezugang und beide Berichtsempfänger. Die gesetzliche Sonderfrist bleibt unter F011 rechtlich offen. Der unten beschriebene Ablauf verwendet ausdrücklich qualifizierte Zeitnachweise.


Ergänzt: `AIA_026_010_ZUGANGSKRITERIEN` trennt tatsächlichen Zugang für die
anfragende zuständige Behörde und Ausschluss sensibler operativer Daten. Alle
Eingaben des Absatz-10-Teilmodells besitzen fachliche Definitionen mit Nachweisen
und konkretem Ereignis-/Berichtsbezug.

`AIA_026_010_ANTRAG_VOR_EINSATZ` prüft den Ex-ante-Zweig anhand zweier expliziter
Offset-Zeitstempel mikrosekundengenau. Der Antrag muss strikt vor dem Einsatz
liegen. Gleichzeitigkeit genügt dafür nicht; ein negatives Ergebnis sagt nichts
über den gesonderten unverzüglichen Nachantrag aus. Bei der Zeitumstellung kann
02:30 Uhr mit Offset +02:00 vor 02:15 Uhr mit Offset +01:00 liegen. Die Library
verwendet weder die lokale Rechnerzeitzone noch die aktuelle Systemzeit.

Neun zusätzliche Zugangs- und sieben Zeitreferenzen begleiten diese Ergänzung.
Absatz 10 ist vollständig manuell gegen die unveränderte Primärfassung geprüft.
Die offene 48-Stunden-Auslegung F011 bleibt ausdrücklich bestehen; daraus wird
kein frei wählbarer legaler Fristmodus und keine globale Einsatzfreigabe.


## Laufender Verlauf und lokale Zeitnachweise

Die neuen Regeln `AIA_005_001_H_LAUFENDER_VERLAUF` und
`AIA_026_010_ANTRAGSVERSTOSS` bewerten den dokumentierten Verlauf bis zu einem
expliziten Stichtag. Unverzüglichkeit und gesetzliche Höchstfrist sind getrennte
Voraussetzungen. Eine noch laufende Höchstfrist gestattet kein Warten und beweist
keinen bereits gestellten Antrag. Ein fehlender Nachweis eines Verzugs ist auch
keine qualifizierte Feststellung, dass die Unverzüglichkeit gewahrt wurde.

`AIA_005_003_ANTRAG_AUSSTEHEND` und `AIA_026_010_ANTRAG_AUSSTEHEND` zeigen einen
noch ausstehenden erforderlichen Antrag. Die tatsächliche Erfüllung wird separat
geprüft. Eine dringliche Registrierungsnachholung ersetzt weder eine vorher
abgeschlossene Grundrechtefolgenabschätzung noch die übrigen Schutzvoraussetzungen.
Spätere Registrierung beseitigt einen früheren nachgewiesenen Verzug nicht.

Für jeden Einsatz können eigene Offset-Zeitstempel eingebunden werden. Die
Rechenregeln `AIA_005_BIOMETRIE_ZEITPUNKT_BIS_FRISTENDE` und
`AIA_026_BIOMETRIE_ZEITPUNKT_BIS_FRISTENDE` vergleichen einen tatsächlichen Antrag
oder ausdrücklich benannten Prüfzeitpunkt mikrosekundengenau mit einem lokal
rechtlich qualifizierten letzten zulässigen Zeitpunkt. Gleichheit ist umfasst;
unterschiedliche UTC-Offsets werden normalisiert. Diese Regeln bestimmen das
rechtliche Ende nicht selbst. Die Qualifikation muss Ereignis, Fristregime und
Endkonvention belegen. Ohne sie liefern die Verlaufsregeln `REGEL_UNGEKLAERT`
(F011), soweit die offene Frage entscheidungsrelevant ist.

Die mitgelieferten Ablaufprüfungen verbinden diese öffentlichen Bausteine ohne
Netzwerk, Systemuhr oder automatische Handlung. Sie prüfen insbesondere Antrag
an der Grenze, Überschreitung, F011, Registrierung und Ablehnung mit Stopp/Löschung.
Ein negatives Verbotsergebnis bleibt eine normeigene Teilentscheidung.
