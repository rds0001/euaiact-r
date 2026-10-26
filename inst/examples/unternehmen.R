# Ausfuehren mit Rscript unter einer Installation des Pakets euaiact.
library(euaiact)
argumente <- commandArgs(trailingOnly = TRUE)
pfad <- if (length(argumente)) argumente[[1L]] else system.file("examples", "unternehmen_synthetisch.json", package = "euaiact")
daten <- lese_json(pfad)
vorher <- daten
ergebnisse <- list()
for (szenario in daten$szenarien) {
  stopifnot(identical(szenario$kennzeichnung, "SYNTHETISCH"))
  for (fall in szenario$faelle) {
    zugeordnet <- ordne_daten_zu(fall$daten, fall$zuordnung)
    eingaben <- zugeordnet$eingaben
    if (fall$art == "TATBESTAND") {
      ergebnis <- pruefe_tatbestand(fall$regel_id, eingaben, fall$quellenfassung)
      stapel <- pruefe_stapel(list(list(fall_id = fall$fall_id, regel_id = fall$regel_id, eingaben = eingaben)), fall$quellenfassung)
      stopifnot(identical(stapel[[1L]]$ergebnis, ergebnis))
    } else if (fall$art == "RECHENREGEL") {
      ergebnis <- berechne_regel(fall$regel_id, eingaben, fall$quellenfassung)
    } else {
      stopifnot(fall$art == "ANWENDUNGSBEGINN")
      ergebnis <- do.call(pruefe_anwendungsbeginn, c(eingaben, list(quellenfassung = fall$quellenfassung)))
    }
    for (feld in names(fall$erwartung)) {
      if (!identical(ergebnis[[feld]], fall$erwartung[[feld]])) stop(fall$fall_id, ": ", fall$herleitung)
    }
    ergebnisse[[length(ergebnisse) + 1L]] <- list(szenario_id = szenario$szenario_id,
      fall_id = fall$fall_id, zuordnung = zugeordnet, ergebnis = ergebnis)
  }
}
stopifnot(identical(daten, vorher))
if (length(argumente) >= 2L) schreibe_json(ergebnisse, argumente[[2L]])
cat("Synthetische Szenarien:", length(ergebnisse), "Integrationsfaelle bestanden\n")
