# Registrierungsinhalte

Die Regeln `AIA_049_004_DATEN_A`, `_C` und `_IX` prüfen die Beschränkung
auf die in Artikel 49 Absatz 4 Buchstaben a, c und d genannten Angaben.
Ihr Einsatz setzt voraus, dass der nichtöffentliche Registrierungsweg für den
konkreten Fall bereits rechtlich bestimmt wurde. Sie bestimmen diesen Weg nicht.

Die Kennungen sind die Nummern der Angaben in Anhang VIII Abschnitt A/C bzw.
Anhang IX, als eindeutige Textwerte in einem JSON-Array. Python verwendet eine
Liste, R eine unbenannte Liste (beispielsweise `list("1", "3")`).
Leeres Array bedeutet keine eingereichten Angaben, `null` bedeutet unbekannt.
Doppelte, unbekannte oder nichttextuelle Kennungen sind ungültig.

Der neue native Feldtyp `ENUMMENGE` und Operator `TEILMENGE` prüfen die
Beschränkung direkt anhand der gelieferten Kennungen. Das lokale Eingabeschema
enthält die erlaubte Grundmenge, Eindeutigkeits- und Längenbeschränkung.
Eine leere Menge erfüllt die Beschränkung, aber nicht die Vollständigkeit der
Registrierung. Richtigkeit, erforderlicher Inhalt, Aktualität und zeitliche
Anwendbarkeit bleiben jeweils gesonderte Fragen.

## Offener Verweis

Artikel 49 Absatz 4 Buchstabe b verweist weiterhin auf Nummer 9 des Anhangs VIII
Abschnitt B. Diese Nummer ist in der konsolidierten Fassung gestrichen. Zudem
bezieht Absatz 4 ausdrücklich auch die Registrierung nach Absatz 2 ein, obwohl
er eingangs Hochrisikosysteme nennt. Die Regeln erfinden weder eine Wiederaufnahme
der Nummer 9 noch eine pauschale Auflösung dieses Anwendungsbereichs.
Die Inhaltsbeschränkung für Abschnitt B ist nun als AIA_049_004_DATEN_B mit expliziter Rechtsunsicherheit ausführbar. Die Wegbestimmung ist mit entscheidungsrelevantem F012-Knoten ausführbar; die Rechtsfrage bleibt offen.

## Allgemeiner Inhalt und Datenbankverfahren

`AIA_ANH_VIII_A_INHALT`, `_B_INHALT`, `_C_INHALT` und `AIA_ANH_IX_INHALT`
bilden die erforderlichen Inhaltsgruppen für den allgemeinen Registrierungsweg
ab. Bedingte Vertreter-, Einreicher-, Zertifikats- und Datenschutzfolgenangaben
werden getrennt ausgewertet. Die freiwillige URL aus VIII A Nummer 13 wird nicht
zur Pflicht. In VIII B werden die gestrichenen Nummern 7 und 9 nicht eingefordert.

Diese Regeln sind nicht als universelle Erfüllungskriterien der Artikel-49-
Pflichten verknüpft: Die eingeschränkten Inhalte nach Absatz 4 erfordern eine
vorgelagerte Wegbestimmung. Die Norm verlangt außerdem Aktualität; ein positiver
Inhaltsbefund ist weder eine behördliche Registrierung noch deren dauerhafte Pflege.

Artikel-71-Regeln unterscheiden die eintragenden Rollen, Konsultationen zur
funktionalen Spezifikation, den allgemeinen öffentlichen Zugang mit Abschnitts-
ausnahmen, den beschränkten Testdatenzugang ohne Anbieterzustimmung sowie die
Erforderlichkeit einzelner personenbezogener Daten. Fehlende Zustimmung ist
nicht gleichbedeutend mit fehlender Rechtsgeltung; vorhandene Zustimmung beseitigt
nicht automatisch andere Geheimhaltungs- oder Datenschutzgrenzen.


Abschnitt B akzeptiert für den Datenabgleich auch die historischen Kennungen
7/9. Dadurch leben gestrichene Inhalte nicht wieder auf. Die Mengenbeschränkung
ist für ausschließlich 1–5/8 erfüllt, bei 6/7 unabhängig verletzt und bei
entscheidungsrelevanter 9 ausdrücklich REGEL_UNGEKLAERT (F012). Das gilt nur für
den bereits qualifizierten beschränkten Weg und ersetzt weder dessen Bestimmung
noch eine Inhaltsvollständigkeitsprüfung. Eine leere Liste erfüllt nur die
Beschränkung, nicht die Registrierungspflicht.

Artikel 71: Einrichtung/Pflege/Zusammenarbeit, Experten-/Gremiumskonsultation,
Vertreterangaben, Support und Barrierefreiheit sind als eigene Kriterien
verfügbar. Die gesetzlichen Verantwortlichenaufgaben liegen bei der Kommission.
Für öffentliche Informationen werden zwingender Zugang/Benutzerfreundlichkeit
und die folgenden should-Merkmale Navigierbarkeit/Maschinenlesbarkeit getrennt.
Der zusätzliche Testdaten-Zugriffskreis ist nur eine einzelne Zugangsschranke;
Anbieterzustimmung beseitigt keine anderen Datenschutz-/Geheimhaltungsvorschriften.


## Wegvertrag und verbleibende Rechtsfrage

Die nichtöffentliche Registrierung verlangt gemeinsam AnhangIII-Nummer1/6/7
und den Bereich Strafverfolgung/Migration/Asyl/Grenzkontrollmanagement. Für
Hochrisikoregistrierungen nach49(1)/(3) ist dieser Weg eindeutig. Für49(2)
bleibt bei demselben Sachkontext die F012-Frage entscheidungsrelevant; außerhalb
dieses Kontextes wird nicht pauschal jede Registrierung unentscheidbar.

Die Erfüllungsbausteine verknüpfen tatsächliche Registrierung, tatsächlichen
Datenbankbereich, Aktualität, vollständige erforderliche Inhalte und im
beschränkten Weg zusätzlich die Mengenbeschränkung. Eine leere Inhaltsliste
ist kein Vollständigkeitsnachweis. B9 wird nicht wiederhergestellt. Inhalte
sind qualifizierte Angaben über den tatsächlichen Datenbankeintrag; mitgelieferte
Kennungslisten dürfen keine vorgelegten Inhalte ausblenden. Der aktuelle
Eintrag und seine Kennungsliste müssen denselben vollständigen Bestand abbilden.

Nationaler Nummer2-Weg bleibt von EU-Registrierung getrennt. Artikel26(8) bindet
die jeweils einschlägigen Betreiber-/nationalen Pflichten bedingt ein; eine
nicht einschlägige EU-Registrierung wird nicht pauschal verlangt. Zeitgrenzen
vor erster Markteinführung/Inbetriebnahme bzw. erster Inbetriebnahme/Nutzung
werden als separate strikte Zeitpunktvergleiche geprüft, keine fiktive Frist
für das bloße Betrachten der Pflicht. Alle Folgerungen bleiben lokal.
