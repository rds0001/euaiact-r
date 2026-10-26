library(euaiact)
referenzen <- jsonlite::fromJSON("fixtures/grundregeln_referenzen.json", simplifyVector = FALSE)
fassung <- referenzen$quellenfassung
for (fall in referenzen$faelle) {
  eingaben <- fall$eingaben
  ergebnis <- pruefe_tatbestand(fall$regel_id, eingaben, fassung)
  if (!identical(ergebnis$wert, fall$erwartung$wert) ||
      !identical(ergebnis$status, fall$erwartung$status)) {
    stop(paste(fall$fall_id, fall$herleitung, "Ist:", ergebnis$status))
  }
  stopifnot(identical(eingaben, fall$eingaben))
}
ergebnis <- pruefe_tatbestand("AIA_053_002", list(gpai_modell_mit_systemischem_risiko = TRUE), fassung)
stopifnot(length(ergebnis$fehlende_angaben) > 0L,
          length(ergebnis$entscheidungsrelevante_luecken) == 0L,
          identical(ergebnis$anwendbarkeit, "UNBEKANNT"))
info <- regel_info("AIA_051_002")
info$ausdruck$argumente[[2L]]$dezimal <- "1"
stopifnot(identical(pruefe_tatbestand("AIA_051_002", list(trainings_flops = "2"), fassung)$wert, FALSE))
faelle <- list(
  list(fall_id = "gueltig", regel_id = "AIA_051_002", eingaben = list(trainings_flops = "0")),
  list(fall_id = "ungueltig", regel_id = "AIA_051_002", eingaben = list(trainings_flops = 1)))
ergebnisse <- pruefe_stapel(faelle, fassung)
stopifnot(identical(ergebnisse[[1L]]$ergebnis$status, "AUSGEWERTET"),
          identical(ergebnisse[[2L]]$ergebnis$status, "EINGABE_UNGUELTIG"))
stopifnot(inherits(try(pruefe_stapel(list(faelle[[1L]], faelle[[1L]]), fassung), silent = TRUE), "try-error"))
stopifnot(identical(pruefe_tatbestand("AIA_051_002", list(), "EUAIACT_2024_08_01")$status, "EINGABE_UNGUELTIG"))
cat(length(referenzen$faelle), "unabhaengige Fachreferenzen und native R-Kernvertraege bestanden\n")
vertrag <- eingabevertrag("AIA_053_001_A")
stopifnot(all(c("gewichte_oeffentlich", "anbieterrolle") %in% names(vertrag$felder)))
vertrag$felder$gewichte_oeffentlich$typ <- "VERAENDERT"
stopifnot(identical(eingabevertrag("AIA_053_001_A")$felder$gewichte_oeffentlich$typ, "BOOLEAN"))
blatt <- pruefe_tatbestand("AIA_ANH_III_4_A", list(), fassung)
stopifnot(tail(blatt$entscheidungsschritte, 1L)[[1L]]$operator == "REGELERGEBNIS")
spur <- pruefe_tatbestand("AIA_051_002", list(trainings_flops = "10000000000000000000000001"), fassung)$entscheidungsschritte
stopifnot(identical(spur[[1L]]$bedingung_id, "AIA_051_002:K0.0"),
  identical(spur[[1L]]$wert, "10000000000000000000000001"),
  identical(spur[[2L]]$bedingung_id, "AIA_051_002:K0"))
