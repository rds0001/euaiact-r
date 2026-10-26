# Konformitätswege nach Artikel 43 – ergänzender Entscheidungsvertrag

Dieser Vertrag ergänzt die vorhandenen sektoralen Regeln und die Anhang-VI/VII-
Verfahrensbausteine. Er bewertet die Auswahl des Verfahrens, nicht schon dessen
Durchführung oder die tatsächliche Konformität des Systems.

## Vorrang und Kontext

Artikel 43 Absatz 3 gibt für Systeme unter Anhang I Abschnitt A dem dortigen
sektoralen Verfahren Vorrang, auch bei gleichzeitiger Einstufung unter Anhang III.
Die neuen Absatz-1-Regeln setzen deshalb Anbieterrolle, Hochrisiko, Zuordnung zu
Anhang III Nummer 1 und das Nichtvorliegen des sektoralen Vorrangfalls voraus.
Sie ersetzen `AIA_043_003` nicht. Für ausschließlich Nummern 2 bis 8 ohne
sektoralen Vorrang bleibt `AIA_043_002` der vorhandene interne Kontrollweg.

## Sachliche Merkmale für Absatz 1

Normen und gemeinsame Spezifikationen sind stets auf die für die konkrete
Bewertung betroffenen Abschnitt-2-Anforderungen zu beziehen. Die bloße Existenz
eines beliebigen Standards ist kein positiver Nachweis. Für gemeinsame
Spezifikationen ist die Einschlägigkeit nach Artikel 41 zu qualifizieren.
Normvolltexte und tatsächliche Anwendung sind lokale, qualifizierte Belege.

Die vier Gründe des zweiten Unterabsatzes werden gesondert modelliert:

1. Einschlägige harmonisierte Normen existieren nicht und gemeinsame
   Spezifikationen sind nicht verfügbar.
2. Eine einschlägige harmonisierte Norm existiert, ist vom Anbieter aber nicht
   oder nur teilweise angewandt. Der Bezug auf »die Norm« setzt eine vorhandene
   konkrete Norm voraus; fehlende Normexistenz wird durch Grund 1 behandelt.
3. Einschlägige gemeinsame Spezifikationen sind verfügbar, wurden vom Anbieter
   aber nicht angewandt.
4. Eine einschlägige harmonisierte Norm wurde mit Einschränkung veröffentlicht;
   der konkret bewertete Anforderungsteil fällt in diese Einschränkung.

Jeder dieser Gründe begründet im Absatz-1-Kontext den Anhang-VII-Weg. Eine
Einschränkung außerhalb des konkret bewerteten Teils genügt für Grund 4 nicht.
Die vier Gründe bilden eine ODER-Verknüpfung mit starker dreiwertiger Logik.
Ein bekannter Grund genügt trotz unbekannter anderer Gründe.

Die Auswahl zwischen Anhang VI und VII setzt im Absatz-1-Kontext die tatsächliche
Anwendung der einschlägigen harmonisierten Normen oder der einschlägigen
gemeinsamen Spezifikationen voraus, ohne einen entscheidenden zwingenden
Anhang-VII-Grund. Ein positiver Auswahlbefund erlaubt beide gesetzlich genannten
Wege; er entscheidet nicht für den Anbieter, welcher davon gewählt wird.

Beide Absatz-1-Ergebnisse sind bei eindeutigem sektoralen Vorrang false. Das
bedeutet keine Befreiung von der sektoralen Bewertung. Unbekannte Vorrang- oder
Anwendungsdaten werden nicht als negative Tatsachen angenommen. Sachliche
Wegwahl, Artikel-113-Beginn, Artikel-111-Bestand und tatsächliche Erfüllung bleiben
getrennte Ergebnisse.

## Fachliche Schlüsselreferenzen vor Implementierung

* Keine Norm und keine Spezifikation: zwingend VII, sofern Absatz-1-Kontext feststeht.
* Keine Norm, aber einschlägige Spezifikation vollständig angewandt und keine
  einschlägige Einschränkung: Auswahl VI/VII möglich, kein Grund 2 allein wegen
  fehlender Norm.
* Existierende Norm nur teilweise angewandt: zwingend VII.
* Verfügbare einschlägige Spezifikation nicht angewandt: zwingend VII.
* Einschränkung betrifft den bewerteten Teil: zwingend VII; betrifft sie einen
  anderen Teil, entscheidet dieser Umstand allein den Weg nicht.
* Konkreter sektorrechtlicher Vorrang: Absatz-1-Wege nicht einschlägig.
* Bekannter zwingender Grund entscheidet trotz weiterer Lücken; unbekannter
  notwendiger Anwendungs-/Vorrangbezug bleibt offen.

Quellen: lokale ursprüngliche und konsolidierte Fassung Artikel 43 Absatz 1;
Absatz 3 ersetzt durch Artikel 1 Nummer 19 des Änderungsakts. Keine neue
externe Normkonformitätsbehauptung und keine automatische Wahl der benannten Stelle.


## Benennungsantrag der sektoral notifizierten Stelle

Artikel43(3), zweiter Unterabsatz der Änderungsfassung, verlangt von den dort
bezeichneten sektoral notifizierten Stellen einen Benennungsantrag gemäß
Abschnitt4 bis28.01.2028. Antrag, Nachweis der bisherigen Bewertungsbefugnis und
tatsächliche neue Benennung sind getrennte Ereignisse. Ein rechtzeitiger Antrag
beweist weder Benennung noch fortdauernde Befugnis; ein verspäteter Antrag
bewirkt in dieser Library keinen automatisch erfundenen Befugnisverlust.

Der numerische Katalog erhält `AIA_043_003_ANTRAGSTERMIN` mit einem strikt
validierten gregorianischen Datum `benennungsantrag_datum` als YYYY-MM-DD.
Der rein kalendarische Vergleich mit2028-01-28 ist einschließlich dieses Tages.
Der Nutzer qualifiziert den rechtlich maßgeblichen Zugangstag im zuständigen
Verfahren; keine implizite Systemzeitzone, Feiertagsverschiebung oder erneute
Berechnung eines bereits gesetzlich genannten Datums. Relative Fristen bleiben
in `berechne_frist`. Datum vor/am/nach Termin ergibt true/true/false; fehlendes
Datum bleibt unbekannt. Ungültige Kalendertage, Jahr0000, Zeitstempel, numerische
Datumswerte und abweichende Formate sind ungültig.0001 und9999 sind zulässig.
