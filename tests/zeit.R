library(euaiact)
referenzen <- jsonlite::fromJSON("fixtures/anwendungsbeginn_referenzen.json", simplifyVector = FALSE)
for (fall in referenzen$faelle) {
  ergebnis <- do.call(pruefe_anwendungsbeginn, fall$eingaben)
  for (feld in names(fall$erwartung)) {
    if (!identical(ergebnis[[feld]], fall$erwartung[[feld]])) stop(fall$fall_id, ": ", fall$herleitung)
  }
  if (ergebnis$status == "AUSGEWERTET") stopifnot(ergebnis$anwendbarkeit == "UNBEKANNT")
}
cat(length(referenzen$faelle), "Zeitreferenzen bestanden\n")
