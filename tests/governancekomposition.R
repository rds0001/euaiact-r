library(euaiact)
fassung <- "EUAIACT_2026_07_27"
for (fall in list(list(17L, TRUE, FALSE), list(18L, TRUE, TRUE), list(18L, FALSE, FALSE))) {
  quorum <- berechne_regel("AIA_065_005_ZWEIDRITTELMEHRHEIT",
    list(benannte_mitgliedstaatenvertreter = 27L), quellenfassung = fassung)
  stopifnot(quorum$wert == 18)
  kriterium <- pruefe_tatbestand("AIA_065_005_KRITERIEN", list(
    ki_gremium_geschaeftsordnung_von_benannten_vertretern_mit_zweidritteln_angenommen = fall[[1]] >= quorum$wert,
    ki_gremium_geschaeftsordnung_regelt_vorsitzauswahl_amtsdauer_und_aufgaben = fall[[2]],
    ki_gremium_geschaeftsordnung_regelt_abstimmung_und_organisation_einschliesslich_untergruppen = TRUE),
    quellenfassung = fassung)
  stopifnot(identical(kriterium$wert, fall[[3]]))
  pflicht <- ermittle_pflicht("P_AIA_065_005",
    list(betrachteter_akteur_ist_europaeisches_ki_gremium = TRUE), quellenfassung = fassung)
  stopifnot(isTRUE(pflicht$wert$ausloeser_erfuellt),
    pflicht$wert$erfuellung == "NICHT_GEPRUEFT", length(pflicht$wert$fristregel_ids) == 0)
}
for (empfang in list(FALSE, TRUE, NULL)) {
  pflicht <- ermittle_pflicht("P_AIA_070_006_WEITERLEITUNG", list(
    betrachteter_akteur_ist_europaeische_kommission = TRUE,
    kommission_hat_ressourceninformation_nach_artikel_70_6_erhalten = empfang), quellenfassung = fassung)
  stopifnot(identical(pflicht$wert$ausloeser_erfuellt, empfang),
    pflicht$wert$erfuellung == "NICHT_GEPRUEFT", pflicht$anwendbarkeit == "UNBEKANNT")
}
cat("6 Governance-Kompositionen bestanden\n")

perioden <- list(
 list("AIA_065_003_AMTSDAUER", "2026-08-03", "2029-08-03"),
 list("AIA_067_004_AMTSDAUER", "2026-08-03", "2028-08-03"),
 list("AIA_067_004_VERLAENGERUNGSHOECHSTDAUER", "2028-08-03", "2032-08-03"),
 list("AIA_067_006_AMTSDAUER", "2026-08-03", "2028-08-03"),
 list("AIA_070_006_BERICHTSINTERVALL", "2025-08-02", "2027-08-02"),
 list("AIA_070_006_BERICHTSINTERVALL", "2027-08-02", "2029-08-02"))
for (f in perioden) {
 dauer <- berechne_regel(f[[1]], list(), quellenfassung = fassung)
 ende <- berechne_frist(f[[2]], dauer$wert$anzahl, dauer$wert$einheit,
   modus = "FESTER_TERMIN", quellenfassung = fassung)
 stopifnot(ende$wert == f[[3]], ende$anwendbarkeit == "UNBEKANNT")
}
for (regel in c("AIA_065_003_VERLAENGERUNG", "AIA_067_006_VERLAENGERUNG")) {
 feld <- "bisherige_verlaengerungen_der_amtszeit"
 erlaubt <- pruefe_tatbestand(regel, setNames(list(0L), feld), quellenfassung = fassung)
 abgelehnt <- pruefe_tatbestand(regel, setNames(list(1L), feld), quellenfassung = fassung)
 stopifnot(isTRUE(erlaubt$wert), identical(abgelehnt$wert, FALSE))
}
cat("8 zusätzliche Perioden-/Verlängerungskompositionen bestanden\n")
