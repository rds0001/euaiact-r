# Jahresarbeitseinheiten: Personen, Abschnitte und Dezimalbeiträge

KMU-Anhang Artikel 5 und SMC-Anhang 5.1/5.2 trennen den einzubeziehenden
Personenkreis von der Gewichtung der Arbeitsleistung. Arbeitnehmer,
untergeordnet Tätige mit nationalrechtlichem Arbeitnehmerstatus,
mitarbeitende Eigentümer-Geschäftsführer sowie regelmäßig tätige Gesellschafter
mit finanziellen Vorteilen werden einbezogen. Die spezielle
Ausbildungs-/Berufsausbildungsvertragsausnahme bleibt erhalten.

`KMU_JAE_ZEITABSCHNITT` und `SMC_JAE_ZEITABSCHNITT` prüfen einen homogenen
Abschnitt der Person. Mutterschafts- und Elternurlaubszeiten zählen nicht.
Das bedeutet keine Ganzjahres-Ausnahme für eine Person, die nur einen Teil des
Jahres abwesend war. Andere Abwesenheiten werden nicht ohne Quellenbeleg pauschal
ausgeschlossen.

`KMU_JAE_DEZIMALBEITRAG` beziehungsweise `SMC_JAE_DEZIMALBEITRAG` multiplizieren
zwei fachlich bestimmte Anteile: Arbeitszeit relativ zur Vollzeitbasis und
anrechenbarer Abschnitt relativ zum vollen Bezugsjahr. Beide Eingaben sind
exakte endliche Dezimaltexte zwischen 0 und 1. Halbtags für ein halbes Jahr ergibt
0.25 JAE. Die Library setzt keine eigene 365-Tage-, Monats- oder Stundenbasis.

Dieser Rechenumfang ist bewusst ausdrücklich begrenzt: Nichtendliche Brüche wie
1/3 sind kein exakter endlicher Dezimaltext. Sie dürfen nicht still gerundet als
exakte Eingabe ausgegeben werden. Für solche Werte stehen die unten beschriebenen rationalen Rechner zur Verfügung. Grenznahe Größenprüfungen benötigen exakte qualifizierte Ausgangswerte.

`JAE_DEZIMALSUMME` addiert bereits qualifizierte, überschneidungsfreie Beiträge
für denselben Bezugszeitraum exakt. Personenidentität, überlappende Verträge,
Segmentierung, Unternehmenseinheit und spätere Gruppenhinzurechnung bleiben
explizite Aufgaben der Datenaufbereitung. Ein unbekanntes Pensum ist keine Null.
Die Ergebnisse sind native Dezimaltexte, keine binären Gleitkommazahlen.

Das synthetische Szenario PERSONAL_JAE_DEZIMAL zeigt eigene Feldnamen für Pensum,
Jahresabschnitt und disjunkte Summanden. Es enthält keine echten Personaldaten.
Personenkreis-/Abschnittsregeln, Quotenermittlung, Aggregation, Unternehmensgruppe
und Größenstatus müssen als getrennte Schritte nachvollziehbar bleiben.


## Exakte rationale Beiträge und Größenprüfung

Ergänzend werden Pensum und Jahresabschnitt als Zähler/Nenner aus nichtnegativen
Ganzzahltexten angegeben; Nenner sind positiv und für jeden Anteil gilt
Zähler kleiner oder gleich Nenner. Die Zeit-/Vollzeitbasis bleibt qualifiziert,
keine pauschale 365-Tage-Annahme. Beispiel: 1/3 Pensum für 1/2 Jahr ergibt exakt 1/6 JAE.
Rationale Summen und gewichtete Hinzurechnungen behalten den Bruch ohne Rundung;
Ausgaben enthalten gekürzte ganzzahlige Textwerte `zaehler` und `nenner`, Null als 0/1.
Eine rationale Größenprüfung vergleicht die Personalgröße per Kreuzprodukt mit
den bekannten strikten Schwellen; sie wandelt 1/3 nicht in einen gerundeten
Dezimalwert um. Finanzgrößen bleiben exakte Dezimaltexte und die gleichen
ODER-Finanzschwellen wie im bestehenden Größenrechner. Kein Gesamtstatus ohne
Gruppenbeziehungen, Statushistorie und qualifizierte Datenkreisabgrenzung.

Eingabetyp NATURZAHLTEXT: kanonische Dezimalziffern, keine Vorzeichen,
führenden Nullen außer 0, Exponenten, Kommas oder binären Zahleneingaben;
maximal 256 Stellen pro Operand. Diese technische Grenze wird im Schema
veröffentlicht, Überlänge abgewiesen und niemals gekürzt. Zwischenergebnisse
werden exakt gerechnet; eine spätere Weiterverwendung validiert die Grenze
erneut. Python nutzt rationale Ganzzahlarithmetik, R native Ziffernarithmetik
mit Division und euklidischer Kürzung, ohne externe Laufzeitbibliothek.

Die Regelkennungen lauten `KMU_JAE_RATIONALBEITRAG`,
`SMC_JAE_RATIONALBEITRAG`, `JAE_RATIONALSUMME`, `JAE_RATIONALGEWICHT` und
`KMU_RATIONALSCHWELLEN`. `eingabevertrag` und `schema_info` liefern ihre Felder.
Das synthetische Szenario PERSONAL_JAE_RATIONAL zeigt Drittelanteile, eine
exakte Summe und die strikte KMU-Personalgrenze. Die native Kompositionsprüfung
verbindet Datenmapping, Beitrag, Summe und Größenprüfung ohne Rundung.
