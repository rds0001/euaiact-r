library(euaiact)
id <- "AIA_050_005_INFORMATIONSZEITPUNKT"
fassung <- "EUAIACT_2026_07_27"
daten <- list(transparenzinformation_zeitpunkt = "2026-10-25T12:00:00.000001+02:00",
  erste_interaktion_oder_exposition_zeitpunkt = "2026-10-25T10:00:00Z")
e <- berechne_regel(id, daten, fassung)
stopifnot(identical(e$wert, FALSE), e$ergebnistyp == "WAHRHEITSWERT", e$status == "AUSGEWERTET",
  identical(e$rechenschritte[[1]]$operanden, unname(daten)))
e$rechenschritte[[1]]$operanden[[1]] <- "veraendert"
stopifnot(daten$transparenzinformation_zeitpunkt == "2026-10-25T12:00:00.000001+02:00")
for (wert in list(list(), list(x = 1), 1.5, as.POSIXct("2026-01-01", tz = "UTC"))) {
  stopifnot(berechne_regel(id, list(transparenzinformation_zeitpunkt = wert), fassung)$status == "EINGABE_UNGUELTIG")
}
ursprung <- Sys.getenv("TZ", unset = NA_character_)
ergebnisse <- lapply(c("UTC", "Pacific/Honolulu", "Europe/Berlin"), function(zone) {
  Sys.setenv(TZ = zone)
  berechne_regel(id, daten, fassung)
})
if (is.na(ursprung)) Sys.unsetenv("TZ") else Sys.setenv(TZ = ursprung)
stopifnot(identical(ergebnisse[[1]], ergebnisse[[2]]), identical(ergebnisse[[1]], ergebnisse[[3]]))
