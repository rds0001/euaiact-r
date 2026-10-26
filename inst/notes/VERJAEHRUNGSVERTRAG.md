# Vertrag des Verjährungsverlaufs 

Der Ereignisrechner trennt die Verfahren der Artikel 10 und 11 der DVO 1755
von Artikel 75c Absatz 8. Er verwendet ausschließlich explizite lokale Daten.
Ausgangspunkt ist der Tattag, bei fortdauerndem/wiederholtem Verhalten dessen
qualifiziertes Ende, beziehungsweise die Bestandskraft der Entscheidung.
Die Library bestimmt diese rechtlichen Ereignisse nicht aus Freitext.

Die API `berechne_verjaehrung` erhält Verfahren, Ereignisdatum, Unterbrechungen,
Hemmungen, Stichtag, Kalender und Quellenfassung. Unterbrechungen haben `datum`
und einen verfahrensspezifischen `art`-Wert. Hemmungen haben `von`,
`bis_exklusiv` und `art`; die Grenzen bezeichnen qualifizierte volle Kalendertage.
`bis_exklusiv = null` bezeichnet eine noch laufende Hemmung. Vorgänge innerhalb
eines Tages benötigen vorgelagerte rechtliche Grenzqualifikation und werden nicht
ungeprüft auf volle Tage aufgerundet. Leere Listen sind eine ausdrücklich als
vollständig qualifizierte Ereignisakte; eine fehlende Liste ist keine leere Liste.

Der Stichtag begrenzt den bekannten Ereignisbestand. Ob das Fristende **vor** dem
Stichtagsdatum liegt, wird getrennt vom Ablauf während dieses Tages ausgewiesen.
Zukünftige Ereignisse werden zurückgewiesen. Bereits abgelaufene Fristen werden
durch nachträgliche Unterbrechungen oder Hemmungen nicht wiederbelebt.

Für GPAI-Verfolgung gilt eine neu beginnende Fünfjahresfrist je wirksamer
Unterbrechung und zusätzlich die ursprüngliche Zehnjahresgrenze, verlängert um
qualifizierte gerichtliche Hemmung. GPAI-Vollstreckung hat keine solche
Zehnjahresgrenze; sie berücksichtigt die gesonderten Unterbrechungsanlässe und
Zahlungsaufschub beziehungsweise gerichtliche Vollstreckungshemmung.
Überschneidende Hemmungsintervalle werden vereinigt und nur einmal angerechnet.
Eine Unterbrechung verwirft bereits verbrauchte Zeit der regulären Frist, verändert
aber nicht den ursprünglichen Anker der Verfolgungshöchstfrist.

F007 zum Anfang längerer 1755-Perioden bleibt offen. Ohne ausdrückliche
`beginnkonvention` und eine dokumentierte `beginnbegruendung` erfolgt keine
rechtlich bestimmte Langfristberechnung. Zulässige, ausdrücklich vom Anwender
qualifizierte Rechenkonventionen sind `EREIGNISTAG`, `BEGINNTAG` und
`VORTAG_DES_BEGINNS`. Die beiden letzten beziehen sich auf den ersten Arbeitstag
nach dem Ereignis. Diese Auswahl ist eine sichtbare Nutzervorgabe und keine
Auslegungsentscheidung der Library. Sie gilt auch für Neustarts und die Höchstfrist.

Bei Artikel 75c werden keine Unterbrechungs- oder Hemmungsregeln der DVO 1755
übernommen. Ohne solche Ereignisse ist die ausdrückliche Fünfjahresdauer aus dem
qualifizierten Ereignis bestimmbar. Bei vorgelegten Störereignissen fehlen die
konkret einschlägigen75d(3)-Folgeaktregeln; der Rechner meldet dies ausdrücklich.
Der Beginn der langen 1755-Perioden wird nicht auf das andere Verfahren übertragen.

Eine laufende, vor Fristablauf eingetretene Hemmung liefert kein endgültiges
Fristende. Nur deren bekannte Dauer wird als Berechnungsstand ausgewiesen.
Hemmungen, die erst während einer Wochenend-/Feiertags-Endverschiebung einsetzen,
werden als offene Konventionsgrenze behandelt; keine doppelte oder stillschweigend
veränderte Fristverlängerung. Weitere Gerichts-, Verfahrens- und materielle Fragen
bleiben getrennt. Keine automatische Entscheidung über Verjährung außerhalb dieses
qualifizierten Ereignis- und Kalendervertrags.

## Schnittstelle und Ereignisarten

Python: `berechne_verjaehrung(verfahren, ereignisdatum, unterbrechungen,
hemmungen, stichtag, *, kalender, quellenfassung, beginnkonvention=None,
beginnbegruendung=None)`. R hat dieselben benannten Parameter mit `NULL` als
Standard für die beiden Beginnparameter. Kalender enthält genau `von`, `bis`,
`feiertage` und einen nichtleeren lokalen `bezug`; Feiertage sind eine Liste.
Je Ereignisliste sind höchstens 1000 Einträge zulässig.

| Verfahren | Unterbrechungsarten | Hemmungsarten |
| --- | --- | --- |
| `GPAI_VERFOLGUNG` | `DOKUMENTENANFRAGE`, `MODELLZUGANG`, `DIALOGEINLADUNG`, `VERFAHRENSEROEFFNUNG`, `SONSTIGE_KOMMISSIONSERMITTLUNG` | `EUGH_ANHAENGIGKEIT` |
| `GPAI_VOLLSTRECKUNG` | `MITGETEILTE_BETRAGSAENDERUNG`, `MITGETEILTE_AENDERUNGSABLEHNUNG`, `KOMMISSIONSVOLLSTRECKUNG`, `STAATLICHE_VOLLSTRECKUNG_AUF_KOMMISSIONSERSUCHEN` | `ZAHLUNGSAUFSCHUB`, `EUGH_VOLLSTRECKUNGSHEMMUNG`, `NATIONALE_GERICHTLICHE_VOLLSTRECKUNGSHEMMUNG` |
| `KI_BUERO_VERFOLGUNG`, `KI_BUERO_VOLLSTRECKUNG` | `FOLGEAKT_75D3_ZU_QUALIFIZIEREN` | `FOLGEAKT_75D3_ZU_QUALIFIZIEREN` |

Die letzten beiden Verfahren liefern bei Störereignissen ausdrücklich
`REGEL_UNGEKLAERT`. Die Platzhalterart bedeutet keine bestätigte Rechtswirkung.
Bei den GPAI-Arten sind tatsächliche Kommissionszuständigkeit, Untersuchungszweck,
Mitteilung, gerichtliche Anhängigkeit oder Zahlungsaufschub zu belegen. Ein frei
gewähltes Etikett schafft kein wirksames Unterbrechungs- oder Hemmungsereignis.

Das Ergebnis nennt reguläres, gegebenenfalls maximales und wirksames Fristende,
den letzten Neustart, den Ablauf vor dem Stichtag und Unterbrechungsschritte.
`vereinigte_bekannte_hemmungstage` zählt die Vereinigungsmenge der gelieferten,
bis zum Stichtag bekannten Intervalle; das ist keine Aussage, dass alle diese
Tage für jeden einzelnen Neustart anzurechnen sind. Vor dem jeweiligen Lauf
liegende Zeiten werden bei dessen Ende nicht nochmals angerechnet.
`hemmungs_berechnungsstand_bis_exklusiv` benennt die Datumsgrenze des bekannten
Hemmungsbestands. Ein abgeschlossenes Intervall muss spätestens dort enden;
Unterbrechungen dürfen am Stichtag liegen. Die innerhalb dieses Tages genaue
Reihenfolge ist gegebenenfalls gesondert zu qualifizieren.
