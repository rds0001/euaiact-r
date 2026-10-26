# Offene Fachfragen der laufenden Spezifikation

Diese Fragen begrenzen die automatische Auswertung. Sie bleiben auch bei
technisch abgeschlossener Implementierung ausdrücklich offen. Fragen werden mit Quellenbezug geschlossen; fehlende
Eingaben eines konkreten Unternehmens sind keine offenen Rechtsauslegungen.

| ID | Fundstelle | Frage und Auswirkung | Bearbeitung |
|---|---|---|---|
| F001 | Artikel 6 Absatz 3, Erwägungsgrund 53 | Ist fehlender materieller Entscheidungseinfluss notwendiges gesondertes Merkmal oder eine Konkretisierung des fehlenden erheblichen Risikos? Der vorläufige Ausdruck wurde nach Wortlaut-/Erwägungsgrundabgleich und ergänzendem Leitlinienentwurf korrigiert. | Festgelegt in ENT_006_003; siehe entscheidung_006_003.json |
| F002 | Artikel 4a, Artikel 113, Änderungsverordnung Erwägungsgrund 9 | Zeitlicher Beginn der neu eingefügten datenschutzrechtlichen Ausnahme; keine automatische Rückwirkung auf Februar 2025. | Offen |
| F003 | Artikel 75c Absatz 5 | Wortlaut der Bezugsgröße für tägliche Zwangsgelder: keine stillschweigende Division eines Jahresumsatzes durch 365. Sprachfassungen und Systematik abgleichen. | Offen |
| F004 | Artikel 111 Absatz 2 und Artikel 113 Buchstabe c | Bestandsregel bei zugleich produkt- und anwendungsfallbezogener Hochrisiko-KI sowie Verhältnis zu Kapitel III Abschnitt 5. | Offen |
| F005 | Erwägungsgründe 40/41 und Protokolle 21/22 | Irland/Dänemark bei bestimmten polizeilichen und strafjustiziellen Anwendungen; unionsrechtliche Bindung nicht pauschal aus dem Länderkennzeichen ableiten. | Externe Bindung als begründete Nutzervorgabe vorsehen |
| F006 | Artikel 5 Absatz 1 ba, Änderungsverordnung Erwägungsgrund 12 | Medizinische Diagnose/Behandlung einer einwilligungsunfähigen Person im Notfall. Vorläufiger Grundtatbestand darf diesen Fall nicht als abschließend entschieden darstellen. | Festgelegt in ENT_005_BA_MEDIZIN; Ausnahme im Verwendungszweig, Anbieterzweig getrennt. |
| F007 | DVO (EU) 2026/1755 Artikel 12 und VO 1182/71 | Besondere Fristbeginnregel gegenüber allgemeiner Ereignisfrist; bei Rückwärtsfristen, festen Terminen und Inkrafttreten keine unzulässige Wochenendverlängerung. | Tagesumfang und allgemeine Rückwärtsperioden spezifiziert; elf zusätzliche Rückwärtsreferenzen. Sonderbeginn bei Wochen/Monaten/Jahren jetzt mit ausdrücklich begründetem Nutzerprofil in berechne_periodenfrist und berechne_verjaehrung implementiert; F007 bleibt rechtlich offen. Monatsbruchrechnung und Gesamtperiodenkomposition vorhanden, untertägige Endkonvention bei nichtganzen Bruchtagen separat offen. Kurze Stundenfristen implementiert, ab48StundenF011 |
| F008 | Empfehlung 2025/1099 Anhang 4.2 | Zweiperiodenregel und Beteiligungsänderungen; Gruppendaten und Statushistorie müssen eigenständig von aktuellen Schwellenwerten behandelt werden. | Reguläre Zweiperiodenfortschreibung des Größenrahmens und Neugründungsschätzung spezifiziert; Beteiligungs-/Kontrollwechsel und vollständige Statuskomposition bleiben offen. Sonderanlässe lösen im regulären Modell entscheidungsrelevant F008 aus. Siehe STATUSHISTORIE.md |
| F009 | Artikel 36 Absatz 9 | Zwölfmonatsgrenze zusätzlicher Verlängerungen gegenüber Gesamtgültigkeit und eigener Bewertungsfrist; lokale Sprachfassungen und amtliche Suche dokumentiert. | Offen; keine ungeprüfte Gesamtmonatszahl implementiert, siehe Regularien/recherche_F009_20261024.json |
| F010 | Artikel 3 Nummer 61 Buchstaben a/b | Verknüpfung der zwei Mehrstaaten-Fallgruppen ohne ausdrückliches UND/ODER in deutscher und englischer Primärfassung. Vergleichbares Verbraucherrecht enthält ausdrücklich ODER, ist aber nicht automatisch übertragbar. | Offen; getrennte Teilkriterien AIA_003_061_A/B und explizites Unsicherheitsmodell AIA_003_061_VERKNUEPFUNG. Entscheidungsrelevante Verknüpfung ergibt REGEL_UNGEKLAERT, keine stillschweigende UND-/ODER-Festlegung. Siehe Regularien/recherche_F010_20261024.json |
| F011 | VO 1182/71 Artikel 3 Absätze 1/2(a)/4/5 und AI Act Artikel 5/26 | Verhältnis gesetzlicher Stundenfristen zum Ausschluss der Ereignisstunde, zur Zwei-Arbeitstage-Regel bei 48 Stunden und zu etwaigen speziellen Höchstgrenzen. | Offen nach gezielter amtlicher Suche; keine Gleichsetzung 48 Stunden = zwei Kalendertage. Siehe Regularien/recherche_F011_20261025.json |

| F012 | Artikel 49 Absatz 4 Buchstabe b und Anhang VIII Abschnitt B | Verweis auf gestrichene Nummer 9; zusätzlich Verhältnis des einleitenden Hochrisikobezugs zur ausdrücklich einbezogenen Absatz-2-Registrierung. | Offen nach lokalem Textabgleich; keine Wiederaufnahme gelöschter Angaben und keine pauschale Wegbestimmung. Inhaltsbeschränkung B nun als AIA_049_004_DATEN_B mit entscheidungsrelevantem F012-Rechtsfrageknoten; Wegbestimmung jetzt mit entscheidungsrelevantem F012-Knoten ausführbar; rechtliche Auslegung bleibt offen. Normeigenes Registrierungsergebnis außerhalb des widersprüchlichen Sachkontexts bleibt entscheidbar. Siehe REGISTRIERUNG.md |

| F013 | DVO 2026/1755 Artikel 3 Absatz 6 Buchstabe c | Verweis auf begründete Anbieterbeobachtungen nach Absatz 4, obwohl diese in Absatz 5 stehen und Absatz 4 Artikel 78(2) für anwendbar erklärt. | Offen nach lokalem Primärtextabgleich; den Verweis nicht stillschweigend umschreiben. Regel a/b bleibt als Teilgründe ausgewiesen; ergänzendes Gesamtmodell DVO_1755_003_006_BEENDIGUNG liefert bei entscheidungsrelevantem c ausdrücklich REGEL_UNGEKLAERT. |

Weitere Pflichtlücken bestehen im noch nicht abgeschlossenen Gesamtregister.
Diese Liste enthält konkret aufgetretene Auslegungsfragen und ersetzt das
Normeninventar nicht.

## Abgleich F001 und F003 vom 24.10.2026

Der amtliche Leitlinienentwurf vom 19.05.2026, Teil Anhang III, Randnummern
85–90, beschreibt keine gesonderte unabhängige Risikobewertung neben den vier
Ausnahmebedingungen; diese seien eng und im Licht des fehlenden materiellen
Entscheidungseinflusses auszulegen. Das unterscheidet sich vom vorläufigen
Regelausdruck. Der Entwurf wurde lokal archiviert und ist ausdrücklich keine
finale oder bindende Rechtsquelle. Die zunächst offene Auslegung wurde anschließend
in ENT_006_003 festgelegt; der entsprechende Regelausdruck wurde korrigiert.

Für F003 wurde zusätzlich die deutsche Originalfassung der Änderungsverordnung
auf PDF-Seiten 31–32 geprüft. Auch sie enthält im Zwangsgeldtatbestand sowohl
Tageseinnahmen als auch einen Jahresumsatzbezug. Ein Tagesumsatz aus Division
durch 365 ist damit nicht allein durch den Sprachvergleich belegt. Die
Fundstellenangabe wurde auf Absatz 5 berichtigt.

| F014 | Empfehlung 2025/1099 Anhang 3.2 | Die Partnerdefinition verweist für verbundene Unternehmen auf Punkt 3.4, der Investorenausnahmen enthält; die Verbunddefinition steht in 3.5. Der gemeinsame Beteiligungsbesitz verweist im selben Satz zutreffend auf 3.5. | Lokaler englischer Primärtextbefund; keine stille Korrektur und keine vollständige SMC-Partnerdefinition implementiert. Investorenausnahme 3.4 und AIF-Ausnahme 3.5.3 sind separat ausführbar. EN/DE-Verweisabweichung amtlich verglichen, keine auflösende Berichtigung belegt; siehe Regularien/recherche_F014_F015_20261025.json. |

| F015 | Empfehlung 2025/1099 Anhang 3.4(a), EN/DE | EN verlangt Business-Angel-Gesamtinvestition unter 5 Millionen EUR, DE einen Betrag, der 5 Millionen EUR nicht überschreitet. | Genau 5 Millionen EUR im entscheidungsrelevanten Angelzweig liefern REGEL_UNGEKLAERT; darunter/darüber stimmen beide Fassungen überein. Unabhängig erfüllte Investorgruppe oder bekannter Verbundausschluss können die Frage unerheblich machen. Amtlicher Sprachvergleich und erfolgloser lokaler PDF-Abruf: Regularien/recherche_F014_F015_20261025.json. |

| F016 | Empfehlung 2003/361/EG Anhang Artikel 3(2)(a), EN/DE | Gleichartige Divergenz wie F015: EN unter 1250000 EUR, DE bis einschließlich 1250000 EUR Business-Angel-Gesamtinvestition. | Amtlicher zweisprachiger Primärtext bestätigt Unterschied. Entscheidend exakter Grenzfall liefert REGEL_UNGEKLAERT; keine bloße Übertragung aus parallelem Beihilferecht. Siehe Regularien/recherche_F016_20261025.json. |

| F017 | DVO 2025/454 Artikel 12 letzter Spiegelstrich | Verweist für thematische Anhörungen auf Artikel 7 Absatz 4; der lokale Primärtext regelt diese in Absatz 5, während Absatz 4 Interessenkonflikte bei Evaluationen betrifft. | Lokaler und amtlicher EN/DE-Befund bestätigt; keine auflösende Berichtigung belegt, siehe Regularien/recherche_F017_20261025.json. Keine stille Verweiskorrektur. Eigenständige Regel aus Artikel 7(5) separat möglich. |

| F018 | DVO 2025/454 Artikel 10 Absatz 4, EN/DE | EN verlangt Aktualisierung bei jeder Umstandsänderung, DE bei einer wesentlichen Änderung. | Wesentliche Änderung und Vorab-Anlässe sicher auswertbar; entscheidungsrelevante nicht wesentliche Änderung ergibt REGEL_UNGEKLAERT. Amtlicher Vergleich dokumentiert in Regularien/recherche_F018_20261025.json. |
