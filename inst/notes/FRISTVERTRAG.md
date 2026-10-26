# Fristberechnung nach VO 1182/71

Die Funktion `berechne_frist` berechnet eine kalendarische Endgrenze. Sie prüft
nicht, ob eine Meldung zusätzlich unverzüglich hätte erfolgen müssen.

Eingaben sind `ereignisdatum` (ISO-Datum), `anzahl` (positive ganze Zahl),
`einheit` (`TAG`, `ARBEITSTAG`, `WOCHE`, `MONAT`, `JAHR`) und `modus`
(`FRIST`, `FESTER_TERMIN`, `INKRAFTTRETEN`, `RUECKWAERTS` sowie der unten beschriebene Verfahrensmodus). Wenn Arbeitstagsregeln erforderlich
sind, wird ein ausdrücklicher Kalender mit `von`, `bis`, `feiertage` und `bezug`
übergeben. Bei festen Terminen und Inkrafttreten mit kalendarischen Einheiten
ist er nicht entscheidungsrelevant und kann entfallen. Gelieferte Kalender werden
auch in diesen Modi validiert.
Eine leere Feiertagsliste ist eine ausdrückliche Aussage für den angegebenen
Kalenderumfang, kein vom Paket angenommener Standardkalender.

Bei Ereignisfristen zählt der Ereignistag nicht mit. Tages-/Wochenfristen enden
auf dem entsprechenden Folgetag; Monats-/Jahresfristen am korrespondierenden
Kalendertag, bei fehlendem Tag am letzten Tag des Zielmonats. Arbeitstage schließen
Samstage, Sonntage und die übergebenen Feiertage aus.

Im Modus `FRIST` wird ein nicht arbeitstägiges Ende auf den nächsten Arbeitstag
verschoben. Fristen von mindestens zwei Tagen müssen mindestens zwei Arbeitstage
enthalten. Das kann eine weitere Verschiebung erfordern. Diese Regeln werden
bei `FESTER_TERMIN` und `INKRAFTTRETEN` gemäß Artikeln 4/5 nicht angewandt.
Der Modus `RUECKWAERTS` ist im folgenden Ergänzungsvertrag spezifiziert.

Fehlt die Kalenderdeckung für einen benötigten Tag, darf die Funktion nicht
stillschweigend von einem Werktag ausgehen. Sie liefert eine entscheidungsrelevante
Datenlücke. Ungültige Daten, Bruchzahlen als Periodenzahl und doppeldeutige
Datumsformate sind Eingabefehler.

Die stundenbezogenen Regeln aus Artikel 3 Absatz 1 sowie die Sonderregel der
DVO 2026/1755 Artikel 12 benötigen eigene Verträge. Sie werden nicht durch diese
datumbezogene Funktion vorgetäuscht. Der folgende erste Implementierungsumfang
beschränkt sich deshalb auf vorwärts laufende Ereignisfristen, feste Termine und
Inkrafttreten. Rückwärtsberechnung und kurze allgemeine Stundenfristen sind in den Ergänzungsverträgen unten festgelegt.

## Verfahrensfristen nach DVO 2026/1755 Artikel 12 – Tagesumfang

Zusätzlicher Modus `VERFAHREN_1755_TAGE`, ausschließlich Einheiten `TAG` und
`ARBEITSTAG`. Dieser Modus ist ausdrücklich für das GPAI-Kommissionsverfahren
zu wählen und darf nicht global auf sämtliche AI-Act-Fristen übertragen werden.
Der erste auf das Ereignis folgende Arbeitstag ist der erste gezählte Tag.
Bei `TAG` zählen danach auch Wochenenden und Feiertage. Die Endverschiebung und
die Mindestzahl von zwei Arbeitstagen nach VO 1182/71 bleiben erhalten.

Rechenvertrag: erst ersten folgenden Arbeitstag ermitteln; virtueller
Ereignisanker ist dessen Vortag. Von diesem Anker Tageszählung durchführen,
anschließend allgemeine Endregeln anwenden. Beide Anker bleiben in der Spur;
das Originalereignis wird nicht überschrieben. Ein fehlender Kalender oder eine
Lücke bei der Suche nach dem ersten Arbeitstag führt zu EINGABE_FEHLT.

Unabhängige Referenzen: Freitag 2026-10-23, drei Kalendertage, kein Feiertag:
Montag 26. ist Tag 1, Dienstag 27. Tag 2, Mittwoch 28. Tag 3. Ist Montag Feiertag,
läuft die Frist ab Dienstag und endet Donnerstag 29. Drei Arbeitstage ab Freitag
enden ohne Feiertag ebenfalls Mittwoch. Fünf Kalendertage ab Donnerstag 22.:
Freitag 23. Tag 1, Dienstag 27. Tag 5, Wochenende zählt innerhalb mit.

Wochen-/Monats-/Jahresfristen in diesem Sondermodus werden ausdrücklich nicht
angenommen: Die Wechselwirkung des verschobenen Beginns mit Korrespondenztagen
bedarf gesonderter Auslegung. Diese Eingaben sind EINGABE_UNGUELTIG statt einer
stillen Übernahme des allgemeinen Modus. Kurze allgemeine Stundenfristen und Rückwärtsperioden sind unten ergänzt. F007 ist damit für Tagesfristen spezifiziert, nicht global
als erledigt markiert.

Die Stundenimplementierung ist zusätzlich durch F011 abgegrenzt. Die gezielte
amtliche Suche vom 25.10.2026 löst die Wechselwirkung mit Artikel 3 Absatz 5
bei 48-Stunden-Perioden und möglichen speziellen AI-Act-Höchstgrenzen nicht
hinreichend auf. Ereignisstunde, Zeitzone und gesetzlicher Fristmodus dürfen
nicht stillschweigend durch eine einfache Addition von zwei Kalenderdaten ersetzt
werden. Rechercheprotokoll: `Regularien/recherche_F011_20261025.json`.

## Rückwärtsfristen – Artikel 3(4) Satz 2 und Absatz 5

`RUECKWAERTS` berechnet positive ganze Tages-, Arbeits-, Wochen-, Monats- oder
Jahresperioden vor dem ausdrücklich übergebenen Bezugstag. Dieser Tag zählt
nicht mit. Korrespondenzdatum/Monatsende werden rückwärts ermittelt. Das Ergebnis
bezeichnet den Ablauf des ermittelten Grenztags; konkrete Formulierungen wie
„mindestens vor“ und der Eingangszeitpunkt sind gesondert zu qualifizieren.

Artikel 3(4) Satz 2 nimmt Rückwärtsperioden von der dortigen Endverschiebung aus.
Er nimmt sie nicht von Absatz 5 aus. Bei mindestens zwei Tagen bleiben deshalb
mindestens zwei Arbeitstage erforderlich: Reicht der zurückgerechnete Zeitraum
nicht, wird er weiter in die Vergangenheit erweitert. Eine normale Monatsfrist
wird dabei nicht auf einen Arbeitstag vor- oder zurückverschoben, wenn sie
bereits zwei Arbeitstage enthält. Wochenenden/Feiertage am Grenztag sind zulässig.
Der Bezugstag selbst zählt auch bei der Mindestzahl nicht mit. Arbeitstage
werden ausschließlich aus dem angegebenen Kalender bestimmt.

Diese Festlegung folgt der ausdrücklichen Beschränkung der Ausnahme auf Absatz 4;
Artikel 4/5 nehmen demgegenüber ausdrücklich beide Absätze 4 und 5 aus.
Keine Übertragung dieses Modus auf Inkrafttreten oder feste Handlungstermine.
Die Auswahl des juristischen Modus bleibt beim Aufrufer. Primärtext lokal:
`arbeit/quellen/CELEX_31971R1182_EN.txt`, Artikel 3–5; amtlicher Text am 25.10.2026
ergänzend eingesehen. Die englische Berichtigung zu Artikel 3(2)c präzisiert den
fristauslösenden Tag, ändert die Ausnahmen der Absätze 4/5 nicht. Lokaler PDF-Abruf
lieferte eine leere Antwort, die nicht in den Quellenbestand übernommen wurde.

Elf unabhängige Referenzen erfassen Wochenenden, Mindestarbeitstage, Feiertage,
Schaltjahre, fehlende Monatstage und Delegations-Vorperioden. Unterlauf vor Jahr 1
ist ein Eingabefehler, fehlende rückwärtige Kalenderdeckung eine Datenlücke.
Sonderbeginn bei Wochen/Monaten/Jahren in DVO 1755, Monatsbruchteile und
Stundenfristen ab 48 Stunden bleiben getrennte offene Umfänge von F007/F011.


## Allgemeine Stundenfrist – ausdrücklich abgegrenzter Zusatzvertrag

`berechne_frist(..., einheit="STUNDE", modus="FRIST")` nimmt im bestehenden
Parameter `ereignisdatum` einen vollständigen ISO-Zeitstempel mit explizitem
UTC-Offset entgegen. Die Ereignisstunde wird nach Artikel3(1)/(2)(a)1182/71
vollständig ausgeschlossen, auch bei einem Ereignis genau auf der Stundengrenze.
Die volle erste gezählte Stunde beginnt an der nächsten lokalen Stundengrenze;
die Anzahl vollständiger Stunden wird anschließend addiert. Ausgabe ist ein
Objekt mit `beginn` und `ende_exklusiv` als UTC-Zeitstempel. Die Frist ist am
exklusiven Endzeitpunkt bereits abgelaufen. Kein künstliches Abziehen einer
Mikrosekunde und keine Rundung des Ereignisses zu seinen Gunsten.

Beispiel: Ereignis10:30Z, eine Stunde: Beginn11:00Z, exklusive Endgrenze12:00Z.
Bei10:30+05:30 beginnt die erste volle lokale Stunde11:00+05:30 =05:30Z.
Die bloße UTC-Abrundung wäre bei solchen Offsets falsch. Wochenend-Endverschiebung
nach Artikel3(4) gilt für Stundenfristen ausdrücklich nicht. Ein übergebener
Kalender bleibt typgeprüft, wird aber im eindeutigen kurzen Stundenfall nicht
für eine erfundene Endverschiebung benutzt.

Für48 oder mehr Stunden bleibt die Wechselwirkung mit der Zwei-Arbeitstage-Regel
F011 offen: gültige Daten liefern `REGEL_UNGEKLAERT` ohne scheinbar rechtliches
Fristende. Kein Schluss von diesem allgemeinen1182-Vertrag auf die spezialrechtliche
24-/48-Stunden-Höchstgrenze des AI Act; deren Normauswahl/Anwendbarkeit bleibt
separat. Der Stundenmodus deckt keine Rückwärts-, festen Termin- oder1755-
Sonderbeginnregeln ab. Unzulässige Datentypen, fehlender Offset, ungültige Kalender
und Datumsbereichsüberläufe bleiben Eingabefehler; fehlende Kerndaten Datenlücken.

## Monatsbruchteile – Artikel 3(2)(d)

`berechne_regel("EU_1182_MONATSBRUCH_TAGE", ...)` rechnet einen ausdrücklich
qualifizierten echten Monatsbruch exakt in Tage um: Zähler mal 30 durch Nenner.
Ein halber Monat ergibt 15 Tage, ein Drittel 10 Tage, ein Siebtel exakt 30/7 Tage.
Die Eingaben `monatsbruch_zaehler` und `monatsbruch_nenner` sind kanonische
Ganzzahltexte; Nenner positiv, Zähler nichtnegativ und strikt kleiner als Nenner.
Der Ergebniswert enthält `zaehler` und `nenner` als gekürzte Texte.

Ganze Monate unterliegen weiterhin der Kalenderregel. Eineinhalb Monate dürfen
nicht als 45 Tage behandelt werden. Der neue Rechner liefert nur den Bruchanteil,
kein Fristende. Nicht ganzzahlige Tage werden nicht heimlich auf- oder abgerundet.
Bei gemischten Perioden dürfen Endverschiebung und Mindestarbeitstage nicht auf
jeden Teil separat angewandt werden; die Gesamtperiodenkomposition ist noch offen.
