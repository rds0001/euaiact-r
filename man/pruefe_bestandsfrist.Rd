\name{pruefe_bestandsfrist}
\alias{pruefe_bestandsfrist}
\title{Bestandsfristen nach Artikel 111 prüfen}
\description{Prüft Bestandsgrenze und festen Erfüllungstermin nach Artikel 111
Absätzen 1 bis 4 anhand ausdrücklich qualifizierter Fallgruppen.}
\usage{pruefe_bestandsfrist(fallgruppe, stichtag, ereignisse, quellenfassung)}
\arguments{
\item{fallgruppe}{GROSS_IT_ANHANG_X, GPAI_MODELL, SYNTHETISCHE_AUSGABEN_ART_50_2,
HOCHRISIKO_ANHANG_I, HOCHRISIKO_ANHANG_III oder HOCHRISIKO_DOPPELT.}
\item{stichtag}{ISO-Datum YYYY-MM-DD oder NULL.}
\item{ereignisse}{Benannte Liste mit inverkehrbringen und optional inbetriebnahme.
Jedes Ereignis ist NULL oder eine Liste mit erfolgt (logical/NULL) und datum
(ISO-Datum/NULL). Ein Datum verlangt erfolgt=TRUE und darf nicht nach dem
Stichtag liegen. Fehlende Ereignisse bleiben unbekannt.
Hochrisiko-Fallgruppen erlauben zusätzlich aenderungen (Liste von Listen mit
datum und erheblich), aenderungshistorie_vollstaendig, fuer_behoerden_bestimmt
und anbieter_oder_betreiber (je logical/NULL). Die Historie beschreibt tatsächliche
Entwurfsänderungen desselben Typs/Modells bis zum Stichtag; Vollständigkeit,
Erheblichkeit, Zweckbestimmung und Akteursrolle sind anhand eigener Nachweise
zu qualifizieren.}
\item{quellenfassung}{EUAIACT_2024_08_01 oder EUAIACT_2026_07_27. Die synthetische
Fallgruppe ist nur in der Fassung 2026 verfügbar.}
}
\details{Die Fallgruppe muss sachlich qualifiziert sein. Groß-IT: erstmaliges
Inverkehrbringen oder Inbetriebnahme vor 2027-08-02, Frist 2030-12-31.
GPAI: Inverkehrbringen vor 2025-08-02, Frist 2027-08-02.
Synthetische Ausgaben: Inverkehrbringen vor 2026-08-02, Frist 2026-12-02;
nur die Verpflichtung aus Artikel 50 Absatz 2 ist betroffen.
Ein bekanntes altes Ereignis entscheidet die Groß-IT-Alternative trotz unbekanntem
zweiten Ereignis. Ein junges Ereignis widerlegt ein unbekanntes altes nicht.
Keine Wochenendverschiebung. Artikel 2, Artikel 5, Artikel 113 und die
tatsächliche Pflichterfüllung sind separat zu prüfen.
Hochrisiko-Gruppen setzen den Ausschluss des Absatz-1-Groß-IT-Falls voraus.
Bestandsgrenzen: Fassung 2024 einheitlich 2026-08-02; Fassung 2026 Anhang III
2027-12-02, Anhang I 2028-08-02. Markt-/Betriebsereignisse müssen davor liegen,
erhebliche Änderungen zählen ab der Grenze einschließlich. Eine leere Liste
beweist Unverändertheit nur bei ausdrücklich vollständiger Historie.
Ein bekanntes relevantes Ereignis genügt auch bei unvollständiger Historie.
Die Auffangfrist 2030-08-02 betrifft Anbieter/Betreiber von Behördenbeständen.
Bei Doppelklassifikation werden beide Stichtage geprüft: gemeinsame Ergebnisse
bleiben nutzbar, abweichende Felder bleiben NULL bzw. UNBESTIMMT und
führen zu REGEL_UNGEKLAERT (F004).
Vollständiger Vertrag: system.file("notes", "UEBERGANG.md", package="euaiact").}
\value{Ergebnisumschlag mit Objekt in wert: bestand (logical/NULL),
erfuellungsfrist (Datum bei Bestand, sonst NULL) und friststatus
(VOR_FRISTTAG, FRISTTAG, NACH_FRISTTAG, KEINE_BESTANDSFRIST oder UNBESTIMMT).
Hochrisiko-Ergebnisse enthalten zusätzlich aenderungsvorbehalt_ausgeloest und
behoerdenfrist_betroffen (logical/NULL); erfuellungsfrist betrifft nur die
Behördenfrist, deren Nichtbetroffenheit KEINE_BEHOERDENFRIST ergibt.
Anwendbarkeit bleibt UNBEKANNT. Unvollständige Angaben führen zu EINGABE_FEHLT,
inkonsistente oder ungültige Angaben zu EINGABE_UNGUELTIG.}
\examples{
pruefe_bestandsfrist("GPAI_MODELL", "2027-08-02",
  list(inverkehrbringen = list(erfolgt = TRUE, datum = "2025-08-01")),
  "EUAIACT_2026_07_27")$wert
}
