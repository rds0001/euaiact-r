# euaiact – R

Native Offline-Regeln zum EU AI Act. **Version 0.1.0 mit dokumentierten Auswertungsgrenzen.** Python wird weder benötigt noch aufgerufen.

```r
library(euaiact)
ergebnis <- pruefe_tatbestand(
  "AIA_051_002",
  list(trainings_flops = "10000000000000000000000001"),
  quellenfassung = "EUAIACT_2026_07_27"
)
stopifnot(isTRUE(ergebnis$wert))
```

Der Kern arbeitet mit eigenen benannten Listen. Fehlende Angaben bleiben
unbekannt. Dezimalzeichenfolgen werden ohne binäre Gleitkommarundung verglichen.
Ein entschiedener sachlicher Tatbestand ist keine allgemeine Rechtmäßigkeits-
oder Konformitätsaussage; Anwendungszeitpunkt und Übergänge werden separat geprüft.

Lokale Installation: Zuerst ein passendes, lokal bereitgestelltes `jsonlite`-Paket
installieren, anschließend `R CMD INSTALL /lokale/pakete/euaiact_0.1.0.tar.gz`.
Alternativ in R: `install.packages("/lokale/pakete/euaiact_0.1.0.tar.gz",
repos = NULL, type = "source")`. Dabei werden keine Abhängigkeiten heruntergeladen.
Für Quellpakete mit kompilierten Abhängigkeiten müssen deren Buildwerkzeuge lokal
vorhanden sein. Der bisherige lokale Nachweis verwendet R 4.1.2 und jsonlite 2.0.0
unter Linux; eine weitergehende Supportmatrix steht aus.

`help(package = "euaiact")` zeigt die öffentliche API. `eingabevertrag(regel_id)`
liefert auch die Felder referenzierter Regeln. `lese_json`, `schreibe_json` und
`ordne_daten_zu` ermöglichen die lokale Einbindung eigener Daten. Dezimalwerte
werden im Austausch als Text übergeben; fehlende Werte als `NULL`.

Acht synthetische Unternehmensszenarien sind installiert verfügbar:

```r
source(system.file("examples", "unternehmen.R", package = "euaiact"))
```

Der identische Beispielcode verarbeitet unterschiedliche Organisationen, Rollen
und ein zeitlich verändertes Portfolio. Die Daten sind ausschließlich synthetisch.
Die Skriptvariante `Rscript inst/examples/unternehmen.R` kann einen eigenen lokalen
Eingabepfad und optional einen neuen Ausgabepfad erhalten. Rollen, Bezüge und
Bewertungen sind vor einer eigenen Anwendung begründet zu ersetzen.

Das Repository kann mit `R CMD build .` und anschließend `R CMD check --no-manual`
auf dem erzeugten Quellarchiv eigenständig geprüft werden. Die Tests benötigen
neben R und jsonlite keine weitere Bibliothek.

Copyright RiskDataScience GmbH. Ansprechpartner: Dr. Dimitrios Geromichalos,
riskdatascience@web.de. Apache License 2.0. Herausgeber: https://riskdatascience.net.

`tabellen_katalog()` und `tabelle_info(tabellen_id)` stellen fünf lokale,
versionierte Anhangtabellen mit 77 Einträgen bereit: Rechtsakte, Deliktsgruppen,
IT-Systeme, GPAI-Kriterien und Notifizierungscodes. Sie enthalten Quellennachweise
und Grenzen; Listenmitgliedschaft allein ist keine Anwendbarkeitsentscheidung.

Über `berechne_regel` stehen exakte Partner-/Verbundhinzurechnungen bereit:
`KMU_PARTNER_HINZURECHNUNG` addiert den qualifizierten Zusatzwert anteilig,
`KMU_VERBUND_HINZURECHNUNG` vollständig. Basiswert, Zusatzwert und Partnerquote
sind Dezimaltexte. Bereits konsolidierte Daten sind vorab auszuschließen;
Beteiligungsgraph und abschließender Größenstatus werden nicht automatisch
aus Zahlen erraten. Die native Rechnung rundet weder Geld noch Personalwerte.


Zeitpunkte für Transparenzinformationen lassen sich mit
`berechne_regel("AIA_050_005_INFORMATIONSZEITPUNKT", ...)` vergleichen. Die Felder
`transparenzinformation_zeitpunkt` und
`erste_interaktion_oder_exposition_zeitpunkt` enthalten ausdrücklich qualifizierte
Ereignisse derselben Person und desselben System-/Inhaltskontexts. Beispiel:
`2026-10-25T12:00:00+02:00` entspricht `2026-10-25T10:00:00Z`.
Gleichzeitigkeit genügt; schon eine Mikrosekunde Verspätung ergibt `False`/`FALSE`.
Das technische Profil verlangt Jahre 0001–9999, `T`, vollständige Sekunden und
`Z` oder einen expliziten Offset `±HH:MM`; optional sind ein bis sechs
Nachkommastellen erlaubt. Schaltsekunden, `-00:00` (unbekannter Offset),
Uhrzeiten ohne Offset und implizite Datumsobjekt-Konvertierungen werden abgewiesen.
Die Library verwendet weder die Rechnerzeitzone noch die aktuelle Uhrzeit.
Geprüft wird nur die Zeitrelation, nicht die Informationsqualität oder die
Anwendbarkeit der Pflicht. Die übrigen Artikel-50-Kriterien bleiben separat.


Die Eingabeverträge sämtlicher Katalogregeln enthalten jetzt eine fachliche
`definition`, die erwartete `herkunft` und den maßgeblichen `bezugszeit`-Kontext.
`schema_info(regel_id + ":EINGABEN")` stellt diese Angaben auch im lokalen
JSON-Schema bereit. Boolesche Nachweisfelder speichern weder das Originaldokument
noch echte Unternehmensstammdaten: Sie setzen eine begründete Bewertung des
konkreten Vorgangs voraus. Bewahren Sie die zugrunde liegenden Belege und die
Bewertungsbegründung in Ihrer eigenen lokalen Datenhaltung auf und verbinden Sie
sie über stabile Vorgangskennungen mit den Eingaben und Ergebnissen. Ungeklärte
Sachverhalte bleiben unbekannt; offene Rechtsfragen werden dadurch nicht aufgelöst.

## Eigenständige kontinuierliche Prüfung

Der Workflow `.github/workflows/check.yml` arbeitet im jeweiligen einzelnen
GitHub-Repository. Er benötigt weder das andere Sprachpaket noch den
Factory-Quellbaum. Die Einrichtung der Entwicklungswerkzeuge in GitHub Actions
benötigt Netz; Bibliotheksbetrieb und Unternehmensbeispiele bleiben lokal.
Die Workflows veröffentlichen keine Pakete und haben nur Leserechte.

Python prüft auf Linux die Mindestversion 3.10 und Version 3.14, auf Windows und
macOS 3.14. `python tools/check_distributions.py` baut Wheel/sdist, prüft die
Metadaten und installiert beide getrennt ohne Indexzugriff. Tests laufen aus
den sdist-Inhalten außerhalb des Quellbaums; der Importort wird geprüft. Unter
Linux sperrt seccomp zusätzlich Netz-Sockets während Tests und Beispielen.
Andere Betriebssysteme erhalten dadurch keinen behaupteten seccomp-Nachweis.
Die Testwerkzeuge müssen vorher lokal bereitstehen: build, setuptools>=61,
wheel, twine, pytest und jsonschema. Ein optionaler `--test-filter` dient nur
gezielten lokalen Wiederholungen; CI verwendet die vollständige vorhandene Suite.

R prüft Linux/release, oldrel-1, devel und die Mindestreihe 4.1 sowie
Windows/release und macOS/release mit R CMD check --as-cran ohne PDF-Handbuch.
Auch Hinweise führen zum Fehlschlag. Anschließend werden die installierten
synthetischen Unternehmensbeispiele aus einem temporären Arbeitsverzeichnis
ausgeführt. R benötigt dafür keine Python-Installation.

Die Konfiguration ist kein Nachweis bereits ausgeführter GitHub-Jobs.
Plattformübergreifende CI-Ergebnisse liegen erst nach tatsächlicher Ausführung
in den künftigen Repositories vor.

## Hochrisiko-Bestand

`pruefe_bestandsfrist` unterstützt außerdem `HOCHRISIKO_ANHANG_I`,
`HOCHRISIKO_ANHANG_III` und `HOCHRISIKO_DOPPELT` nach Artikel 111 Absatz 2.
Lokale Entwurfsänderungen mit Datum und Erheblichkeitsbewertung werden zusammen
mit einer ausdrücklichen Vollständigkeitsangabe ausgewertet. Die Behördenfrist
wird separat ausgewiesen; unbekannte Daten sind keine negativen Nachweise.
Bei doppelter Einstufung bleiben gemeinsame Ergebnisse beider Stichtage nutzbar;
Abweichungen ergeben `REGEL_UNGEKLAERT` (F004). Der vollständige Vertrag liegt
in [inst/notes/UEBERGANG.md](inst/notes/UEBERGANG.md) und wird mitinstalliert:
`system.file("notes", "UEBERGANG.md", package = "euaiact")`.

## Wissenschaftliches Gremium: Transparenz

`DVO_0454_012_BASISINHALTE` prüft öffentliche Namen, Lebensläufe, drei
Erklärungsarten und Geschäftsordnung. `DVO_0454_012_PUBLIKATIONSWEG` prüft
den vorgeschriebenen Veröffentlichungsort und die qualifizierte Bereitstellung
ohne unangemessene Verzögerung. Für Stellungnahmen/Empfehlungen ist
`DVO_0454_012_STELLUNGNAHMEPFLICHT` der gesonderte Auslöser: jeder der
drei gesetzlich benannten Schutzgründe kann diesen Veröffentlichungspunkt
ausnehmen. Das beseitigt die Grundinformationspflicht nicht.

Die zwei zugehörigen Pflichtdatensätze geben Erfüllungskriterien an; ein
ausgelöster Tatbestand bedeutet keine bereits erfolgte Veröffentlichung.
Alle Publikations- und Schutzangaben werden aus eigenen lokalen Nachweisen
übergeben, ohne Netzwerkzugriff. Der unzutreffende Anhörungsverweis in Artikel12
bleibt als F017 getrennt offen; die tatsächliche Veröffentlichung nach Artikel7(5)
bleibt über den bestehenden Katalog erreichbar.

## Anhang VII: QMS-Änderungen und Bescheinigungsausstellung

Geplante Änderungen, tatsächliche Anbietermitteilung und Stellenprüfung sind
unterschiedliche Vorgänge. `AIA_ANH_VII_3_4_STELLENKRITERIEN` verlangt die
Untersuchung, die Entscheidung über fortbestehende Erfüllung oder Neubewertung
und deren Mitteilung mit Schlussfolgerungen und Begründung. Eine dokumentierte
Entscheidung bedeutet dabei nicht zwangsläufig eine positive Bewertung.

`P_AIA_ANH_VII_4_6_ERTEILUNG` nennt neben der Bewertungsmitteilung nun ausdrücklich
die tatsächliche Ausstellung und die Bescheinigungsinhalte als getrennte
Erfüllungskriterien. `AIA_ANH_VII_4_6_BESCHEINIGUNGSINHALTE` behandelt bestehende
Gültigkeitsbedingungen und Informationen zur Betriebskontrolle nur soweit
einschlägig; deren Nichtvorliegen muss qualifiziert sein, nicht bloß unbekannt.
Eine positive Bewertung allein belegt weder Ausstellung noch Inhaltsvollständigkeit.

AnhangVII-Verfahrensfolgen sind zusätzlich über eigene Pflichtdatensätze
verknüpft: QMS-Prüfung und Mitteilung, zusätzlicher Technikantrag, spezifische
Trainingsdaten-Ablehnungsbegründung sowie Änderungsprüfung und Ergänzungsweg.
Eine Mitteilung im Ergänzungsweg bleibt auch bei nicht genehmigten Änderungen
erforderlich; eine Ergänzungsausstellung verlangt dagegen die Genehmigung.
Nicht jede Bescheinigungsablehnung verlangt trainingsspezifische Gründe: diese
Folge setzt gerade den nachgewiesenen Trainingsdatenmangel voraus.
Zusatzbeleg-/Anbietertestanforderungen und zusätzliche Tests bei QMS-Audits
sind als Befugnisbedingungen getrennt von zwingenden und tatsächlichen Handlungen
erreichbar. Die materielle Konformitätsbewertung bleibt ein qualifizierter Nachweis.

Tatsächliche Daten-/Modellzugänge, eigene Stellentests, Neutraining und
Systemänderungsmitteilungen sind nun ausdrücklich als Erfüllungskriterien
mit den bestehenden AnhangVII-Pflichten verknüpft. Fernzugangssicherheit gilt
nur soweit einschlägig, Modellzugang bleibt unter dem qualifizierten Schutz
geistigen Eigentums und von Geschäftsgeheimnissen. Neutraining wird weder
aus einem Ablehnungsbescheid noch aus einem künftigen Trainingsplan abgeleitet;
Abschluss und Reihenfolge zum neuen Antrag sind gesondert nachzuweisen.
Interne Kontrolle nach AnhangVI, Weiterführung genehmigter QMS sowie
bewertungsbezogener Standortzugang und periodische Audits haben eigene
Pflichtdatensätze mit getrennten tatsächlichen Erfüllungskriterien.

Artikel43(1) wird über `AIA_043_001_GRUND_A` bis `GRUND_D` sowie
`AIA_043_001_VII_ERFORDERLICH` und `AIA_043_001_WAHL_VI_VII` ausgewertet.
Der sektorale Vorrang nach Absatz3 schließt die beiden Absatz1-Wege aus,
befreit aber nicht von der sektoralen Bewertung. Ein bekannter zwingender
Grund genügt trotz anderer Lücken. Normexistenz, tatsächliche Anwendung,
Spezifikationen und der betroffene Umfang einer Normeinschränkung sind getrennte
lokale Nachweise. Die Regeln wählen nicht selbst für den Anbieter und
bescheinigen keine bereits durchgeführte Konformitätsbewertung.
Der ergänzende Vertrag KONFORMITAETSWEGE.md liegt in den Python-docs bzw.
unter inst/notes des R-Pakets.

Die besonderen Delegationsgegenstände aus Artikel43(5)/(6) und47(5) sind
über GEGENSTAND-Regeln und gesonderte DELEGATIONSWEG-Regeln mit Artikel97
verbunden. Technischer Fortschritt begrenzt die Aktualisierung der AnhängeV
bzw.VI/VII. Eine Erweiterung der Drittbewertung nach43(6) verlangt die
Berücksichtigung der Wirksamkeit interner Kontrolle sowie der verfügbaren
angemessenen Stellenkapazitäten und Ressourcen. Ein passender Gegenstand
ersetzt weder bestehende zeitliche Befugnis noch Konsultation, Mitteilung und
Einwendungsvoraussetzungen. Publikation und weitere Wirksamkeitsfragen bleiben
separat; alle Angaben beziehen sich auf denselben konkreten Rechtsakt.

Weitere lokale Fachverträge: [Jahresarbeitseinheiten](inst/notes/JAHRESARBEITSEINHEITEN.md), [Begriffsabgrenzungen](inst/notes/BEGRIFFSABGRENZUNGEN.md) und [Gremiumsverfahren](inst/notes/GREMIUMSVERFAHREN.md).

[Reallabore, Realtests und Behördenverfahren](inst/notes/REALLABORVERFAHREN.md).

[Marktaufsicht, Verfahrensnachweise und Zwangsgeldgrenzen](inst/notes/MARKTAUFSICHT.md).

[Betrieb und Versionierung](inst/notes/BETRIEB_UND_VERSIONIERUNG.md) erläutert Integration
und Updates; [offene Fachfragen](inst/notes/OFFENE_FACHFRAGEN.md) begrenzen die
automatisch bestimmbaren Ergebnisse.
