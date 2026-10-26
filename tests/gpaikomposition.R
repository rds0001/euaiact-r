library(euaiact)
fassung <- "EUAIACT_2026_07_27"
einstufung <- function(flop, ausnahme, entscheidung) {
  pruefe_tatbestand("AIA_051_SYSTEMRISIKOEINSTUFUNG", list(gpai_modell = TRUE,
    hohe_wirkmaechtigkeit_durch_geeignete_werkzeuge_und_methoden_bewertet = FALSE,
    trainings_flops = flop,
    kommission_hat_gleichwertige_faehigkeiten_oder_auswirkungen_festgestellt = entscheidung,
    kommissionsentscheidung_beruecksichtigt_anhang_xiii = TRUE,
    wirksame_kommissionsausnahmeentscheidung_zum_51_1_a_weg = ausnahme),
    quellenfassung = fassung)
}
faelle <- list(
  list("10000000000000000000000001", FALSE, FALSE, TRUE),
  list("10000000000000000000000001", TRUE, FALSE, FALSE),
  list("10000000000000000000000001", NULL, FALSE, NULL),
  list("10000000000000000000000000", FALSE, FALSE, FALSE),
  list("0", TRUE, TRUE, TRUE))
for (f in faelle) {
  status <- einstufung(f[[1]], f[[2]], f[[3]])
  stopifnot(identical(status$wert, f[[4]]))
  pflicht <- ermittle_pflicht("P_AIA_055_001_A", list(anbieterrolle = TRUE,
    gpai_modell_mit_systemischem_risiko = status$wert), quellenfassung = fassung)
  stopifnot(identical(pflicht$wert$ausloeser_erfuellt, f[[4]]),
    pflicht$wert$erfuellung == "NICHT_GEPRUEFT", pflicht$anwendbarkeit == "UNBEKANNT",
    pflicht$status == if (is.null(f[[4]])) "EINGABE_FEHLT" else "AUSGEWERTET")
}
for (systemisch in c(FALSE, TRUE)) {
  daten <- list(anbieterrolle = TRUE, gpai_modell = TRUE,
    lizenz_erlaubt_zugang_nutzung_aenderung_verbreitung = TRUE,
    gewichte_oeffentlich = TRUE, architekturinformation_oeffentlich = TRUE,
    nutzungsinformation_oeffentlich = TRUE, gpai_modell_mit_systemischem_risiko = systemisch)
  dokumentation <- ermittle_pflicht("P_AIA_053_001_A", daten, quellenfassung = fassung)
  urheberrecht <- ermittle_pflicht("P_AIA_053_001_C", list(anbieterrolle = TRUE,
    gpai_modell = TRUE), quellenfassung = fassung)
  stopifnot(identical(dokumentation$wert$ausloeser_erfuellt, systemisch),
    isTRUE(urheberrecht$wert$ausloeser_erfuellt),
    urheberrecht$wert$erfuellung == "NICHT_GEPRUEFT")
}
status <- einstufung("0", FALSE, FALSE)
stopifnot(identical(status$wert, FALSE))
meldung <- ermittle_pflicht("P_AIA_052_001_MELDUNG", list(anbieterrolle = TRUE,
  gpai_modell = TRUE,
  hohe_wirkmaechtigkeit_durch_geeignete_werkzeuge_und_methoden_bewertet = FALSE,
  trainings_flops = "0", bekannt_dass_hohe_wirkmaechtigkeit_erreicht_werden_wird = TRUE),
  quellenfassung = fassung)
stopifnot(isTRUE(meldung$wert$ausloeser_erfuellt), meldung$wert$erfuellung == "NICHT_GEPRUEFT")
cat("8 GPAI-Status-/Pflichtkompositionen bestanden\n")
