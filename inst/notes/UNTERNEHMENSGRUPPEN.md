# Unternehmensgruppen aus eigenen Daten aggregieren

`aggregiere_unternehmensgruppe` verbindet einen lokal qualifizierten Beziehungsgraphen
mit disjunkten Datenkreisen. Die Funktion rechnet für eine ausdrücklich bezeichnete
Bezugsperiode genau eine Größe: `JAE`, `UMSATZ_EUR` oder `BILANZ_EUR`. Python und R
verwenden dieselbe Signatur, dieselben Feldnamen und exakte Arithmetik.

```python
from euaiact import aggregiere_unternehmensgruppe

result = aggregiere_unternehmensgruppe(
    "A", ["A", "B"],
    [{"von": "A", "nach": "B", "art": "PARTNER", "quote": "0.25"}],
    [{"kreis_id": "A", "unternehmen_ids": ["A"], "wert": "100"},
     {"kreis_id": "B", "unternehmen_ids": ["B"], "wert": "80"}],
    groesse="UMSATZ_EUR", bezugsperiode="2025",
    kreis_vollstaendig=True, quellenfassung="EUAIACT_2026_07_27",
)
assert result["wert"]["summe"] == "120"
```

In R werden die Arrays als unbenannte Listen, Objekte als benannte Listen übergeben.
Unternehmens-IDs dürfen auch ein gewöhnlicher Zeichenvektor sein. Die lokalen
JSON-Adapter lesen denselben Datensatz in beiden Sprachen.

## Identitäten, Beziehungen und Bezugsbasis

`unternehmen` enthält alle eindeutigen Unternehmens-IDs des qualifizierten Graphen;
`stamm_id` bezeichnet das zu prüfende Unternehmen. IDs und `bezugsperiode` sind
1–128 ASCII-Zeichen: erstes Zeichen alphanumerisch, danach zusätzlich `_ . : -`.
Für Klarnamen oder personenbezogene Daten besteht keine Anforderung.

`VERBUND`-Kanten besitzen genau `von`, `nach` und `art`. Sie bilden den zuvor
rechtlich qualifizierten unmittelbaren oder mittelbaren Verbund ab. Die Funktion
ermittelt dessen zusammenhängende Komponenten; Zyklen und mehrere Verbundwege
führen zu keiner doppelten Hinzurechnung. Kapitalmehrheit allein ist weiterhin
keine automatische rechtliche Verbundqualifikation. Auch Beziehungen über
natürliche Personen, Investorenausnahmen und öffentliche Beteiligungen sind mit
den vorhandenen Einzelregeln vorgelagert zu prüfen.

`PARTNER`-Kanten besitzen zusätzlich `quote`, einen exakten Dezimaltext zwischen
`0.25` und `1`. Diese Quote muss bereits auf die **beiden vollständigen
Verbundgruppen** bezogen sein und gemeinsamen Besitz, Kapital-/Stimmrechtsvergleich
sowie Kreuzbeteiligung berücksichtigen. Sie ist keine frei wählbare Gewichtung.
Pro Paar von Verbundgruppen ist genau eine Partnerkante zulässig. Mehrere Kanten
werden abgewiesen, da deren bloße Addition oder Maximumwahl unzutreffend sein kann.
Partner innerhalb desselben Verbunds sind widersprüchlich und werden abgewiesen.

Der eigene Verbund zählt vollständig. Direkt angrenzende Partnerverbünde zählen
mit ihrer qualifizierten Quote einschließlich ihrer verbundenen Unternehmen.
Partner eines bloßen Partners werden nicht rekursiv hinzugezählt. Die Richtung
der qualifizierten Kante ändert die Aggregation nicht. Diese Schritte folgen
Artikel6 des KMU-Anhangs beziehungsweise Punkt6 des SMC-Anhangs.

`kreis_vollstaendig=True` bestätigt die vorgelagert belegte Vollständigkeit des
Beziehungskreises, einschließlich relevanter mittelbarer Beziehungen und Ausnahmen.
False oder null liefert `EINGABE_FEHLT`, keine Nullsumme. Das Feld bestätigt nicht
automatisch den KMU-/SMC-Status. Die rechtliche Beziehungsqualifikation unter
F014 und Änderungen des Größenstatus unter F008 bleiben ausdrücklich separat.

## Konsolidierung und Doppelzählung

Jeder Datenkreis enthält genau `kreis_id`, `unternehmen_ids` und `wert`, bei JAE
zusätzlich `personensegmente`. Seine Unternehmens-IDs dürfen sich mit keinem
anderen Datenkreis überschneiden. Ein konsolidierter Kreis kann mehrere verbundene
Unternehmen umfassen; diese werden dann nicht noch einmal einzeln addiert.

Die Zahlen müssen die rechtlich maßgebliche Konsolidierung und Eliminierungen
bereits enthalten. Die Funktion erstellt keine Konzernbilanz aus Rohbuchungen.
In einem Datenkreis müssen alle enthaltenen Unternehmen dieselbe Hinzurechnungsquote
haben. Eine unaufgeschlüsselte Mischung aus vollständig und anteilig erfassten
Unternehmen wird abgewiesen und verlangt eine fachlich qualifizierte disjunkte
Aufteilung. Bei Teilkonsolidierung ist entsprechend der noch nicht erfasste,
belegte Datenkreis aufzubereiten; bloße Prozentkorrekturen eines unbekannten
Gesamtbetrags sind kein zulässiger Ersatz.

Fehlt für ein einzubeziehendes Unternehmen ein Datenkreis oder dessen Wert,
bleibt die Gesamtsumme unbekannt. Ein fehlender Wert eines nicht einzubeziehenden
Partnerpartners verhindert die Rechnung nicht; dessen Gewicht0 wird dokumentiert.
Ungültige Typen oder überlappende Kreise werden auch bei Gewicht0 zurückgewiesen.

Bei JAE besteht `wert` aus den Ganzzahltexten `zaehler` und `nenner`, mit positivem
Nenner. `personensegmente` ist ein Inventar von Objekten mit `person_id` und
`segment_id`. Dasselbe Paar darf über alle Datenkreise nur einmal vorkommen.
Positive JAE verlangen ein nichtleeres Inventar. Die Segment-ID bezeichnet einen
bereits fachlich abgegrenzten realen Arbeitsanteil; bloßes Umbenennen eines
Duplikats stellt keine zulässige Datenaufbereitung dar. Verschiedene belegte
Arbeitsanteile derselben Person bleiben erhalten. Zeitbasis, Personenkreis,
Mutterschafts-/Elternurlaub und Teilzeit werden mit den vorhandenen JAE-Regeln
vorgelagert geprüft; die Funktion schätzt keine Stunden oder Personennamen.

## Ergebnisse und Grenzen

`wert.summe` ist bei JAE ein gekürzter exakter Bruch, bei Finanzgrößen ein exakter
Dezimaltext. Das Ergebnis enthält für jedes Unternehmen Verbund-ID und Gewicht,
für jeden Datenkreis Beitrag und Berücksichtigung sowie die nötigen Quellen und
Lücken. Es verändert keine Eingaben. Reihenfolgeänderungen verändern den fachlichen
Befund und die geordneten Rechenschritte nicht. Es gibt keine Rundung.

Maximal10000 Einträge je Liste und256 Zeichen beziehungsweise Ziffern je
numerischem Eingabeoperand sind erlaubt. Ein gekürztes Zwischenergebnis oberhalb
4096 Ziffern wird ausdrücklich abgewiesen. Diese technischen Grenzen werden
nicht durch Rundung oder Abschneiden umgangen.

Das Ergebnis wird erst danach mit den Größen- und Zweiperiodenregeln verbunden.
Eine neue Beteiligungsstruktur erfordert einen neu qualifizierten Graphen und
neue Datenkreise für den maßgeblichen Beurteilungszeitpunkt. Reguläre
Zweiperiodenfortschreibung ist implementiert; rechtliche Transaktionsfolgen unter
F008 werden weiterhin als `REGEL_UNGEKLAERT` ausgegeben. Eine alternative Gruppe
zu berechnen ist keine Entscheidung, wann ein Statuswechsel rechtlich eintritt.
