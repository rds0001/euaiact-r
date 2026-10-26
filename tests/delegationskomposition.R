library(euaiact)
fassung <- "EUAIACT_2026_07_27"
kalender <- list(von = "2024-01-01", bis = "2036-12-31", feiertage = list(),
 bezug = "SYNTHETISCH: keine Feiertage; keine reale Behördenkalenderfreigabe")
for (f in list(list("2024-08-01", "2029-08-01", "2028-11-01", "2029-05-01"),
               list("2026-07-27", "2031-07-27", "2030-10-27", "2031-04-27"))) {
 dauer <- berechne_regel("AIA_097_002_DELEGATIONSDAUER", list(), quellenfassung = fassung)
 termin <- berechne_frist(f[[1]], dauer$wert$anzahl, dauer$wert$einheit,
  modus = "FESTER_TERMIN", quellenfassung = fassung)
 stopifnot(termin$wert == f[[2]])
 for (i in 1:2) {
  regel <- c("AIA_097_002_BERICHTSVORLAUF", "AIA_097_002_WIDERSPRUCHSVORLAUF")[[i]]
  vorlauf <- berechne_regel(regel, list(), quellenfassung = fassung)
  frist <- berechne_frist(f[[2]], vorlauf$wert$anzahl, vorlauf$wert$einheit,
   modus = "RUECKWAERTS", kalender = kalender, quellenfassung = fassung)
  stopifnot(frist$wert == f[[i+2]])
 }
}
for (wirksam in list(FALSE, TRUE, NULL)) {
 daten <- list(delegation_97_2_einschlaegig = TRUE,
  pruefzeitpunkt_liegt_in_wirksamer_delegationsperiode = TRUE,
  akteur_ist_europaeisches_parlament = TRUE, akteur_ist_rat = FALSE,
  widerrufsentscheidung_tatsaechlich_erlassen = TRUE,
  widerrufsentscheidung_erfasst_konkret_betrachtete_delegation = TRUE,
  widerrufsentscheidung_ist_zum_pruefzeitpunkt_wirksam = wirksam)
 befugnis <- pruefe_tatbestand("AIA_097_BEFUGNIS", daten, quellenfassung = fassung)
 stopifnot(identical(befugnis$wert, if (is.null(wirksam)) NULL else !wirksam),
   befugnis$anwendbarkeit == "UNBEKANNT")
}
pflicht <- ermittle_pflicht("P_AIA_097_002_BERICHT", list(
 betrachteter_akteur_ist_europaeische_kommission = TRUE,
 delegation_97_2_einschlaegig = TRUE,
 konkrete_delegationsperiode_ist_gegenstand_des_97_2_berichts = TRUE), quellenfassung = fassung)
stopifnot(isTRUE(pflicht$wert$ausloeser_erfuellt), pflicht$wert$erfuellung == "NICHT_GEPRUEFT",
 identical(pflicht$wert$fristregel_ids, list("AIA_097_002_BERICHTSVORLAUF")))
cat("6 Delegationskompositionen bestanden\n")
