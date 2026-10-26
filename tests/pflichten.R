library(euaiact)
daten <- jsonlite::fromJSON("fixtures/pflichten_referenzen.json", simplifyVector = FALSE)
for (fall in daten$faelle) {
  vorher <- fall$eingaben
  ergebnis <- ermittle_pflicht(fall$pflicht_id, fall$eingaben, daten$quellenfassung)
  if (!identical(ergebnis$status, fall$status)) stop(fall$fall_id, ": ", fall$herleitung)
  if (fall$status == "EINGABE_UNGUELTIG") stopifnot(is.null(ergebnis$wert)) else {
    if (!identical(ergebnis$wert$ausloeser_erfuellt, fall$ausloeser_erfuellt)) stop(fall$fall_id, ": ", fall$herleitung)
    stopifnot(ergebnis$wert$pflicht_id == fall$pflicht_id, ergebnis$wert$erfuellung == "NICHT_GEPRUEFT", ergebnis$anwendbarkeit == "UNBEKANNT")
  }
  stopifnot(identical(vorher, fall$eingaben))
}
katalog <- pflicht_katalog()
stopifnot(!anyDuplicated(vapply(katalog, function(p) p$pflicht_id, character(1))))
for (pflicht in katalog) {
  stopifnot(!is.null(regel_info(pflicht$ausloeser_regel)$ausdruck))
  for (kennung in pflicht$erfuellungskriterien) stopifnot(!is.null(regel_info(kennung)$ausdruck))
}
katalog[[1L]]$nachweisanforderungen <- list()
stopifnot(length(pflicht_katalog()[[1L]]$nachweisanforderungen) > 0L)
cat(length(daten$faelle), "Pflichtreferenzen bestanden\n")

meldung <- ermittle_pflicht("P_AIA_052_001_MELDUNG", list(), "EUAIACT_2026_07_27")
stopifnot(identical(meldung$wert$fristregel_ids, list("AIA_052_001_MELDEHOECHSTDAUER")),
  identical(meldung$wert$fundstellen, list("ART_052/1")), nzchar(meldung$wert$gegenstand))
transparenz <- ermittle_pflicht("P_AIA_050_001", list(anbieterrolle = FALSE), "EUAIACT_2026_07_27")
stopifnot(identical(transparenz$wert$ausloeser_erfuellt, FALSE),
  transparenz$wert$erfuellung == "NICHT_GEPRUEFT",
  identical(transparenz$wert$fristregel_ids, list("AIA_050_005_INFORMATIONSZEITPUNKT")))
transparenz$wert$fristregel_ids <- list()
stopifnot(length(ermittle_pflicht("P_AIA_050_001", list(), "EUAIACT_2026_07_27")$wert$fristregel_ids) == 1L)
