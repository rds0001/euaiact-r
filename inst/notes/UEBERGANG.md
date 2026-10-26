# Übergangsregeln nach Artikel 111 – Ereignisvertrag

Der allgemeine Beginn nach Artikel 113 und die Behandlung vorhandener Systeme
werden getrennt berechnet. `pruefe_anwendungsbeginn` entscheidet Artikel 111
ausdrücklich nicht. Das Modul darf seine Ergebnisse nicht allein aus
dem aktuellen Alter einer Softwareversion ableiten.

## Bestandsgrenzen und Rechtsfolgen

| Fall | Maßgebliches Ereignis | Strikte Bestandsgrenze | Rechtsfolge für Bestand |
|---|---|---|---|
| Groß-IT-System nach Anhang X | Erstes Inverkehrbringen oder erste Inbetriebnahme | vor 2027-08-02 | Anpassung bis 2030-12-31; Artikel 5 bleibt unberührt |
| GPAI-Modell | Erstes Inverkehrbringen | vor 2025-08-02 | Anbietermaßnahmen zur Erfüllung bis 2027-08-02 |
| Synthetische Ausgaben | Erstes Inverkehrbringen | vor 2026-08-02 | Artikel 50 Absatz 2 erfüllen bis 2026-12-02; keine Verschiebung sämtlicher Transparenzpflichten |
| Hochrisiko nach Anhang III, kein Groß-IT-Fall | Erste Einheit desselben Typs/Modells: Inverkehrbringen oder Inbetriebnahme | vor 2027-12-02 | Anwendbarkeit nur bei erheblichen Entwurfsänderungen ab diesem Datum; öffentlich bestimmte Systeme spätestens 2030-08-02 |
| Hochrisiko nach Anhang I, kein Groß-IT-Fall | Wie zuvor | vor 2028-08-02 | Wie zuvor; Artikel 5 bleibt unberührt |

Diese Tabelle bezieht sich auf EUAIACT_2026_07_27. Der Wortlaut von Artikel 111
Absatz 2 nennt die Anwendung auf Betreiber/Wirtschaftsakteure im weiteren Sinne;
der Auffangtermin 2030 richtet sich ausdrücklich an Anbieter und Betreiber von
für Behörden bestimmten Hochrisiko-Systemen. Beide Adressatenkreise sind zu
trennen. Anwendungsbereiche nach Artikel 2 Absatz 2 bleiben vorgelagert.

Erwägungsgrund 39 der Änderungsverordnung erläutert den Bestandsbezug anhand
der ersten Einheit desselben Typs und Modells. Ein neues Vertriebsdatum einer
weiteren Einheit ersetzt diesen Bezug nicht. Die Zuordnung von Einheiten zu
Typ/Modell muss aus eigenen belastbaren Produktdaten stammen.

## Daten- und Unbekanntvertrag

Inverkehrbringen und Inbetriebnahme sind getrennte Ereignisse. Für jedes Ereignis
wird zwischen nicht erfolgt, erfolgt mit bekanntem Datum und unbekanntem
Sachverhalt unterschieden. Ein bekannter Zeitpunkt vor der Bestandsgrenze genügt
für die Alternative, selbst wenn das andere Ereignis unbekannt ist. Ein bekannter
Zeitpunkt nach der Grenze genügt dagegen nicht zur Verneinung, wenn das andere
Ereignis unbekannt ist. Unmögliche Kombinationen wie ausdrücklich nicht erfolgt
mit gleichwohl angegebenem Datum sind Eingabekonflikte.

Designänderungen benötigen jeweils Datum und begründete Bewertung der
Erheblichkeit. Eine leere Liste bedeutet nur dann keine relevanten Änderungen,
wenn die Ereignisabdeckung des betrachteten Zeitraums ausdrücklich vollständig
ist. Ein einzelnes bekanntes erhebliches Änderungsereignis kann dagegen genügen.
Eine technische Versionsnummer ist kein Ersatz für diese Bewertung.

Bei gleichzeitig produkt- und anwendungsfallbezogenem Hochrisiko bleiben die
Abgrenzung der Bestandsstichtage und die Reichweite gegenüber weiteren Abschnitten
konkret zu klären (F004). Das Modul darf nicht stillschweigend einen der beiden
Stichtage auswählen. Die Behandlung ist als REGEL_UNGEKLAERT auszuweisen,
falls die offene Abgrenzung das konkrete Ergebnis beeinflusst.

## Ausführbarer Vertrag für Absatz 2

Die bestehende API `pruefe_bestandsfrist` erhält die Fallgruppen
`HOCHRISIKO_ANHANG_I`, `HOCHRISIKO_ANHANG_III` und `HOCHRISIKO_DOPPELT`.
Der Aufrufer qualifiziert Hochrisiko, den Akteursbezug und den Ausschluss des
Absatz-1-Groß-IT-Falls. Die Signatur bleibt unverändert. In `ereignisse` stehen
bei diesen Gruppen zusätzlich zu den bisherigen beiden Ereignissen:

* `aenderungen`: Liste tatsächlich erfolgter Entwurfsänderungen, jeweils mit
  `datum` (ISO-Datum/null) und `erheblich` (bool/null). Ein bekanntes Datum darf
  nicht nach dem Stichtag liegen. Herkunft: lokale Änderungs-/Freigabehistorie
  desselben Typs und Modells, ergänzt um begründete fachliche Bewertung.
* `aenderungshistorie_vollstaendig`: bool/null, ausdrückliche Abdeckung aller
  tatsächlich erfolgten Änderungen bis zum übergebenen Stichtag. Eine leere
  Liste ohne diese Bestätigung beweist keine unveränderte Gestaltung.
* `fuer_behoerden_bestimmt`: bool/null, konkrete Zweckbestimmung dieses Systems
  für öffentliche Behörden aus Produkt-/Vertragsunterlagen zum Stichtag.
* `anbieter_oder_betreiber`: bool/null, qualifizierte Rolle des bewerteten Akteurs
  nach Artikel 3 zum Stichtag; andere Wirtschaftsakteure sind hier false.

Die Ereignisse beziehen sich auf die erste Einheit desselben Typs/Modells.
In der ursprünglichen Fassung gilt für beide Hochrisikowege 2026-08-02.
In der Fassung 2026 gelten die beiden oben genannten Stichtage. Der Ereignistag
muss strikt davor liegen; erhebliche Änderungen zählen dagegen bereits am
Stichtag selbst. Vor diesem Tag kann keine Änderung den Vorbehalt auslösen.
Die Behördenfrist ist ein fester Termin ohne Arbeitstagsverschiebung.

Entscheidungstabelle (starke dreiwertige Logik):

| Ergebnis | Operation |
|---|---|
| bestand | Markt-vor-Grenze ODER Inbetriebnahme-vor-Grenze |
| aenderungsvorbehalt_ausgeloest | bestand UND erhebliche Änderung ab Grenze bis Auswertungsstichtag |
| behoerdenfrist_betroffen | bestand UND für Behörden bestimmt UND Anbieter oder Betreiber |
| erfuellungsfrist | 2030-08-02 nur wenn behoerdenfrist_betroffen wahr |
| friststatus | VOR_FRISTTAG / FRISTTAG / NACH_FRISTTAG bei betroffener Frist, sonst KEINE_BEHOERDENFRIST bzw. UNBESTIMMT |

Ein bekanntes relevantes Änderungsereignis genügt auch bei unvollständiger
Historie. Ist die Historie vollständig, aber ein möglicherweise relevantes Datum
oder die Erheblichkeit unbekannt, bleibt das Änderungsergebnis unbekannt.
Änderungen sicher vor der Grenze oder ausdrücklich unerhebliche Änderungen
können das Ergebnis nicht beeinflussen. Ein bekannter Nichtbestand entscheidet
beide bestandsbezogenen Folgen auf false, unabhängig von weiteren Datenlücken.
Ein negatives Ergebnis ist keine Freistellung von anderen Pflichten.
Insbesondere wird aus unverändertem Bestand keine Gesamt-Rechtmäßigkeit abgeleitet.

Bei doppelter Einstufung in der Fassung 2026 werden beide Stichtagswege getrennt
berechnet. Nur identische Ergebnisfelder werden gemeinsam ausgegeben; abweichende
Felder bleiben null (Friststatus UNBESTIMMT). Unterschiedliche Ergebnisse führen
zu REGEL_UNGEKLAERT mit F004 und beiden nachvollziehbaren Kandidaten. Gleiche
Ergebnisse werden ausgewertet bzw. bleiben wegen gleicher Datenlücken unbekannt.
Damit wird keine generelle Wahl des früheren oder späteren Stichtags getroffen.
In der Fassung 2024 gibt es diese Stichtagsdifferenz nicht.

Der volle Umschlag enthält alle fehlenden Angaben und separat die tatsächlich
entscheidungsrelevanten Lücken. Rechtsfrage F004 wird nicht als fehlendes
Unternehmensdatum ausgegeben. Artikel 2, Artikel 5, Artikel 113, tatsächliche
Pflichterfüllung und die Auswirkung auf konkrete Einzelpflichten bleiben separat.
