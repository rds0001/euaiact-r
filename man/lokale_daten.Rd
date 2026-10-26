\name{lokale_daten}
\alias{lese_json}
\alias{schreibe_json}
\alias{ordne_daten_zu}
\title{Lokaler JSON-Austausch und nachvollziehbare Feldzuordnung}
\description{Explizite lokale Dateien und reine Zuordnung direkter Feldnamen.
Keine URLs, Remote-Referenzen oder ausführbaren Transformationen.}
\usage{
lese_json(pfad)
schreibe_json(daten, pfad)
ordne_daten_zu(datensatz, zuordnung)
}
\arguments{
\item{pfad}{Nichtleerer lokaler Dateipfad. URI/URLs und UNC-Pfade sind unzulässig.}
\item{daten}{JSON-kompatibler Wert: benannte/ unbenannte Listen für Objekte/Arrays,
skalare Texte, Boolean, NULL und ganze Zahlen bis absolut 9007199254740991.
Dezimal- und Geldwerte als Text; NA ist im Austauschvertrag unzulässig.}
\item{datensatz}{Benannte Liste mit eindeutigen, nichtleeren Quellfeldnamen.}
\item{zuordnung}{Liste mit genau mappingversion (nichtleerer Text) und felder
(benannte Liste: kanonischer Zielfeldname auf direkten Quellfeldnamen).
Zielnamen bestehen aus Kleinbuchstaben, Ziffern und Unterstrichen und beginnen
mit einem Buchstaben.}
}
\details{UTF-8, höchstens 16 MiB und 100 Verschachtelungsebenen. Doppelte
Objektschlüssel, ungenaue Zahlen und ungültige Typen werden abgelehnt.
Leeres Objekt: setNames(list(), character()); leeres Array: list().
Der Export validiert vor dem Öffnen und überschreibt niemals vorhandene Dateien.
Schreibfehler können eine unvollständige neue Datei hinterlassen. Eingebundene
Dateisysteme liegen in der Verantwortung des Betreibers.

Die Zuordnung übernimmt nur ausgewählte Felder, verändert keine Eingaben und
ergänzt fehlende Quellschlüssel als NULL. Vorhandenes NULL und fehlender Schlüssel
bleiben in der Herkunft unterscheidbar. Die anschließende Fachfunktion prüft
bekannte Zielfelder und deren fachlichen Typ-/Wertevertrag.}
\value{lese_json: native Daten; schreibe_json: unsichtbares NULL;
ordne_daten_zu: Liste mit mappingversion, eingaben und herkunft (zielfeld,
quellfeld, vorhanden), nach Zielfeld sortiert. Ungültige Verträge und
Betriebssystemfehler lösen einen Fehler aus.}
\examples{
ordne_daten_zu(list(heilzweck = FALSE), list(mappingversion = "beispiel-1",
  felder = list(medizinisch = "heilzweck", arbeitsplatz = "betrieb")))
pfad <- tempfile(fileext = ".json")
schreibe_json(list(kennzeichnung = "SYNTHETISCH", wert = "1.23"), pfad)
lese_json(pfad)
unlink(pfad)
}
