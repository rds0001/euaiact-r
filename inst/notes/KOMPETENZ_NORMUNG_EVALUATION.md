# KI-Kompetenz, Normungsverfahren und institutionelle Evaluationen

Die Regeln unterscheiden eine normenbezogene Pflicht von ihrer tatsächlichen
Erfüllung. Ein Ergebnis aus `ermittle_pflicht` bestätigt weder eine Handlung noch
Gesamtkonformität. Die genannten Erfüllungskriterien werden separat anhand eigener,
datierter Nachweise geprüft. Die Library versendet keine Informationen, löscht
keine Daten und greift auf keine Internetquelle zu.

## KI-Kompetenz nach Artikel4

`AIA_004_001` erfasst Anbieter und Betreiber von KI-Systemen. Die dazugehörigen
Kriterien verlangen tatsächliche Maßnahmen für die betroffenen Beschäftigten und
anderen im Auftrag handelnden Personen unter Berücksichtigung ihrer Kenntnisse,
Erfahrung, Bildung/Ausbildung, des Einsatzkontexts und der betroffenen Personen.
Sie verlangen kein garantiertes individuelles Kompetenzniveau. Ein Zertifikat
oder eine dokumentierte Teilnahme ersetzt nicht automatisch die Inhaltsbewertung
der Maßnahmen. Der allgemeine Anwendungsbereich einschließlich persönlicher
nichtberuflicher Nutzung bleibt separat.

Kommission und Mitgliedstaaten haben eigene Unterstützungsaufgaben, insbesondere
für KMU. Die Veröffentlichung praktischer Beispiele auf der Informationsplattform
ist eine gesonderte Kommissionsaufgabe. Die Empfehlungen des KI-Gremiums unter
Berücksichtigung europäischer Kompetenzrahmen sind weder Empfehlungen des
wissenschaftlichen Gremiums noch eine neue Pflicht einzelner Beschäftigter.

## Normung und gemeinsame Spezifikationen

Artikel40(2)/(3) erfasst die tatsächlichen Normungsaufträge, ihre Inhalte und
Konsultationen sowie die Bemühenspflichten der Normungsbeteiligten. Externe
Verfahrensanforderungen der Verordnung1025/2012 werden lokal qualifiziert.
Die Library behauptet nicht, technische Standards inhaltlich zu zertifizieren.

Die materiellen Erlassvoraussetzungen aus `AIA_041_001` stehen neben den
Verfahrensschritten: vorherige Ausschussinformation, Forumkonsultation und
Prüfverfahren. Ein positiver Erlasstatbestand erzeugt keinen Durchführungsakt.
Eine veröffentlichte harmonisierte Normreferenz löst unter den gesetzlichen
Voraussetzungen die Aufhebung entsprechender Spezifikationen aus; die tatsächliche
Aufhebung und der begrenzte abgedeckte Umfang bleiben getrennte Nachweise.
Ein Mitgliedstaatseinwand ist zu bewerten. Er führt nur bei entsprechendem
Bewertungsbefund zur Pflicht, die Spezifikation zu ändern.

## Vertraulichkeitsnachweise nach Artikel78

Geschäftsgeheimnisse und Quellcode, wirksame Aufsicht, Sicherheitsinteressen,
Straf-/Verwaltungsverfahren und klassifizierte Informationen bleiben als
Schutzgegenstände sichtbar. Datenanforderung, strikte Erforderlichkeit, wirksame
Cybersicherheit und tatsächliche zweckgebundene Löschung sind getrennte Schritte.
Ein Vertraulichkeitsvertrag allein belegt weder eine erforderliche Datenanforderung
noch eingerichtete technische Schutzmaßnahmen.

Bei der besonders geschützten Behördendokumentation sind Aufbewahrungsort,
sofortiger Zugang beziehungsweise Kopie auf Anfrage und Sicherheitsfreigabe des
Aufsichtspersonals eigene Nachweise. Artikel78(4) lässt die einschlägigen Rechte
und Pflichten zu Informationsaustausch, Warnungen und strafrechtlicher Auskunft
unberührt. Die Library gibt aus einer Vertraulichkeitspflicht keinen pauschalen
Bescheid aus, der jeden Informationsaustausch verbietet.

## Evaluationszyklen nach Artikel112

| Absatz | Erster fester Termin | Wiederkehr |
| --- | --- | --- |
| 2 | 2028-08-02 | alle4Jahre |
| 3 | 2029-08-02 | alle4Jahre |
| 5 | 2028-08-02 | einmalig |
| 6 | 2028-08-02 | alle4Jahre |
| 7 | 2028-08-02 | alle3Jahre |
| 13 | 2031-08-02 | einmalig |

Die Rechenregeln heißen `AIA_112_002_TERMIN`, `_003_TERMIN`, `_005_TERMIN`,
`_006_TERMIN`, `_007_TERMIN` und `_013_TERMIN`. Sie werden über `berechne_regel`
mit `evaluationszyklus_index` aufgerufen:0 ist der erste Termin,1 der nächste
vorgeschriebene Zyklus. Einmalige Termine akzeptieren ausschließlich0; bei
Wiederkehr gilt die dokumentierte technische Grenze1000. Kalendertermine werden
nicht auf Werktage verschoben. Ein fehlender Index wird nicht aus der Systemuhr
abgeleitet. Beispielsweise liefert Absatz2 bei Index1 den2032-08-02, Absatz7
dagegen den2031-08-02.

Die jährliche Prüfung nach Absatz1 ist davon verschieden: Sie gilt nach
Inkrafttreten innerhalb der maßgeblichen Delegationsdauer. Die konkrete jährliche
Prüfperiode und tatsächliche Delegationsdauer werden qualifiziert; es wird kein
zusätzlicher fester jährlicher Abgabetag erfunden.

Die inhaltlichen Kriterien unterscheiden Listen-/Bereichsevaluation,
Gesamtüberprüfung, KI-Büro-Ausstattung, energieeffiziente Normung, freiwillige
Kodizes und Durchsetzung. Übermittlung, Veröffentlichung, besondere Berichtsinhalte,
gegebenenfalls Änderungsvorschlag, Informationsbereitstellung und methodische
Entwicklungsbemühungen bleiben getrennt. Ein bereits berechneter Abgabetermin
belegt keine Erstellung, Übermittlung oder Veröffentlichung. Ein noch nicht
erfülltes Kriterium ist vor seinem maßgeblichen Termin nicht automatisch ein
festgestellter Fristverstoß.

Artikel 111 Absatz 1: Die Evaluation eines Groß-IT-Systems gemäß dessen
Einrichtungsrechtsakt oder bei dessen Ersetzung/Änderung muss AI-Act-Anforderungen
berücksichtigen. `P_AIA_111_001_EVALUATION` trennt den Evaluationsanlass von der
tatsächlichen Berücksichtigung. Die Pflicht endet nicht automatisch mit dem
Bestandssystemtermin 2030; ein allgemeiner Evaluationsrhythmus wird nicht erfunden.
