# Lokaler Betrieb und Versionierung

Version 0.1.0 enthält 1.662 Logikregeln, 104 Rechenregeln, 545 Pflichtdatensätze
und 21 öffentliche Funktionen. Der Quellenstand ist ausdrücklich
`EUAIACT_2026_07_27`; ergänzende Quellen reichen bis zur Entscheidung 2026/2274.
Die Pakete prüfen Daten und qualifizierte Bewertungen. Sie treffen keine pauschale
Rechtmäßigkeitsentscheidung über ein Unternehmen oder KI-System.

Python benötigt zur Laufzeit ausschließlich die Standardbibliothek; R benötigt
`jsonlite`. Kein Paket enthält einen Netzwerkclient, einen Updateabruf oder
Telemetrie. Installation und Aktualisierung erfolgen durch den Betreiber mit
lokal bereitgestellten Artefakten und Abhängigkeiten. JSON-Adapter verarbeiten
lokale Dateien und explizite Feldzuordnungen; Nachweisreferenzen werden nicht geöffnet.

Eigene Daten zuerst mit `eingabevertrag` beziehungsweise `schema_info` aufbereiten,
dann `ordne_daten_zu` für eine versionierte Namenszuordnung verwenden. Tatsächliche
Bewertungen, Belegqualität, Geltung und externe Rechtsgrundlagen bleiben explizite
Eingaben. Beispiele enthalten acht synthetische Unternehmen-/Portfolioszenarien
und zwölf gesonderte Geltungsabläufe. Keine Beispieldaten ungeprüft übernehmen.

`IMPLEMENTIERT_GRENZEN_DOKUMENTIERT` bezeichnet den Implementierungsstand.
`AUSGEWERTET` betrifft den angefragten Tatbestand; `EINGABE_FEHLT` bleibt unbekannt.
`REGEL_UNGEKLAERT` kennzeichnet entscheidungsrelevante Rechtsfragen. Ein
Negativbefund oder eine nicht entscheidende Datenlücke darf diese Statusunterschiede
nicht verdecken. Einzelne Pflichten getrennt über Auslösung und Erfüllung prüfen.
Siehe OFFENE_FACHFRAGEN.md und die jeweiligen fachlichen Vertragsdokumente.

Paket-, Regel-, Quellen-, Mapping- und Ergebnisschemaversion gemeinsam mit den
Eingaben und dem Ergebnis archivieren. Die Library verwendet keine aktuelle Uhrzeit.
Ältere, nicht mitgelieferte Quellenfassungen werden abgewiesen, nicht automatisch
auf den aktuellen Stand umgebogen. Mehrere Fassungen bei Bedarf getrennt installieren.

Bei einem Update zunächst Artefakthash, Änderungsnotizen und Schemas vergleichen;
anschließend eigene gespeicherte Fälle in einer getrennten Umgebung erneut
bewerten. Bestehende Ergebnisse nicht überschreiben. In der 0.x-Reihe können
Minder-Versionen Vertragsänderungen enthalten. Feldumbenennungen ausdrücklich in
einer neuen Mappingversion abbilden, zum Beispiel `internes_flops` auf
`trainings_flops`; keine stillen Feld- oder Quellenmigrationen. Es gibt in 0.1.0
keine abgekündigten öffentlichen Funktionen.

Nachweise dieser Lieferung werden separat für eingefrorene Artefakthashes geführt.
Lokale Zielumgebung: Linux, Python 3.10 und R 4.1.2 mit jsonlite 2.0.0. Die
GitHub-Workflows enthalten weitere Plattform-/Versionsprüfungen; eine vorhandene
Konfiguration ist kein Nachweis ihrer tatsächlichen Ausführung. Registry-Upload
und CRAN-Aufnahme sind eigene Veröffentlichungsschritte.
