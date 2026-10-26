# Zusammengesetzte Perioden und qualifizierter Sonderbeginn

`berechne_periodenfrist(ereignisdatum, anzahl, einheit, *, modus, kalender=None,
monatsbruch=None, beginnkonvention=None, beginnbegruendung=None, quellenfassung)`
verarbeitet ganze `WOCHE`, `MONAT` oder `JAHR` sowie einen optionalen echten
Monatsbruch. In R werden dieselben benannten Parameter verwendet; optionale Werte
sind `NULL`. Für einfache Tages-/Arbeits-/Stundenfristen bleibt `berechne_frist`
die bestehende Schnittstelle.

`anzahl` ist eine nichtnegative native Ganzzahl bis1000000. Die Gesamtperiode muss
positiv sein und im ISO-Datumsbereich liegen. `monatsbruch` ist ausschließlich bei
`MONAT` zulässig und enthält genau `zaehler` und `nenner` als kanonische
Ganzzahltexte mit höchstens256Stellen. Der Nenner ist positiv, der Zähler kleiner
als der Nenner. `None`/`NULL` bedeutet ausdrücklich keine zusätzliche Bruchkomponente;
ein fehlender Zähler innerhalb einer gelieferten Komponente ist eine Datenlücke.
Null ganze Monate sind nur mit positivem Bruch möglich. Keine Rundung.

Ganze Monate werden zuerst kalendarisch berechnet. Erst danach werden die exakt
mit30Tagen pro Monat berechneten Bruchtage angefügt. Endverschiebung und die
Mindestzahl von Arbeitstagen werden nur auf die gesamte Periode angewandt.
Beispiel:31.01.2026 plus ein Monat und ein halber Monat ergibt zunächst28.02.,
danach15.03.; im Modus `FRIST` mit ausdrücklich leerem Feiertagskalender endet
die Frist am16.03.2026. Eine Zwischenverschiebung des Februarteils wäre falsch.
Zwei ganze Monate werden direkt zum korrespondierenden Tag berechnet, nicht als
zwei aufeinanderfolgende, jeweils gekappte Einmonatsperioden.

Die Modi `FRIST`, `FESTER_TERMIN`, `INKRAFTTRETEN` und `RUECKWAERTS` übernehmen
die dokumentierten Endregeln. Bei festen Terminen und Inkrafttreten gibt es
keine Arbeitstagsverschiebung. Im Rückwärtsmodus werden zuerst ganze Monate und
danach Bruchtage abgezogen; die Mindestarbeitstage bleiben gemäß Fristvertrag.
Ein Kalender enthält genau `von`, `bis`, `feiertage` und nichtleeren `bezug`.
Benötigte Tage außerhalb seiner Deckung liefern `EINGABE_FEHLT`.

Der Modus `VERFAHREN_1755` ist ausschließlich für einschlägige GPAI-Verfahren zu
qualifizieren. F007 bleibt rechtlich offen. Die API benötigt deshalb zusätzlich
eine explizite `beginnkonvention` und eine nichtleere `beginnbegruendung`:

| Konvention | Anker der kalendarischen Langperiode |
| --- | --- |
| `EREIGNISTAG` | Tatsächlicher Ereignistag |
| `BEGINNTAG` | Erster Arbeitstag nach dem Ereignis |
| `VORTAG_DES_BEGINNS` | Vortag dieses ersten Arbeitstags |

Die Mindestarbeitstage werden ab dem ersten folgenden Arbeitstag gezählt.
Beide Anker stehen in der Rechenspur; Auswahl und Begründung in `nutzervorgaben`.
Ohne begründetes Profil gibt es `REGEL_UNGEKLAERT` und kein geratenes Enddatum.
Ein synthetisches Profil in den Beispielen ist keine rechtliche Auflösung vonF007.
Andere Modi erlauben keine solchen Beginnparameter.

Wenn der exakte Monatsbruch nichtganze Tage ergibt, beispielsweise30/7, bleibt
auch dieser Wert exakt in der Rechenspur. Die vorliegende Datums-API legt keine
untertägige rechtliche Endkonvention fest: `REGEL_UNGEKLAERT`, kein gerundetes
Datum und keine stillschweigende Umrechnung in Stunden. Die Rechengröße selbst ist
über `EU_1182_MONATSBRUCH_TAGE` vollständig exakt verfügbar. Diese fachliche
Grenze ist von fehlenden Daten eines konkreten Unternehmens zu unterscheiden.

Ein erfolgreiches Ergebnis bezeichnet im Modus `INKRAFTTRETEN` den Beginn,
sonst den Ablauf des Ergebnistags. Es bescheinigt weder allgemeine Anwendbarkeit
noch die Erfüllung einer zusätzlichen Pflicht zum unverzüglichen Handeln.
Quellen:VO1182/71Artikel3(2)(c)/(d),3(4)/(5),4/5; DVO1755Artikel12.
