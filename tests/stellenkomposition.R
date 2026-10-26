library(euaiact)
fassung <- "EUAIACT_2026_07_27"
aktuell <- ermittle_pflicht("P_AIA_033_001", list(benannte_stelle = FALSE,
 spezifische_konformitaetsaufgabe_an_unterauftragnehmer = FALSE,
 konformitaetsaufgabe_durch_tochterunternehmen = FALSE), quellenfassung = fassung)
historisch <- ermittle_pflicht("P_AIA_033_004", list(
 aufgabe_als_benannte_stelle_an_unterauftragnehmer_oder_tochterunternehmen_uebertragen = TRUE), quellenfassung = fassung)
stopifnot(identical(aktuell$wert$ausloeser_erfuellt, FALSE),
 isTRUE(historisch$wert$ausloeser_erfuellt), historisch$wert$erfuellung == "NICHT_GEPRUEFT",
 identical(historisch$wert$fristregel_ids, list("AIA_033_004_AUFBEWAHRUNGSDAUER")))
basis <- list(notifizierende_behoerde = TRUE, benennung_ausgesetzt = TRUE,
 benennung_eingeschraenkt = FALSE, benennung_ganz_oder_teilweise_widerrufen = FALSE)
aufbewahrung <- ermittle_pflicht("P_AIA_036_006", basis, quellenfassung = fassung)
zugang <- ermittle_pflicht("P_AIA_036_006_ZUGANG", c(basis, list(
 betroffene_stellenakten_von_berechtigter_behoerde_angefordert = FALSE)), quellenfassung = fassung)
stopifnot(isTRUE(aufbewahrung$wert$ausloeser_erfuellt), identical(zugang$wert$ausloeser_erfuellt, FALSE))
for (abgedeckt in c(TRUE, FALSE)) {
 ergebnis <- pruefe_tatbestand("AIA_032", list(konformitaetsbewertungsstelle = TRUE,
  harmonisierte_normreferenz_im_amtsblatt_veroeffentlicht = TRUE,
  erfuellung_einschlaegiger_normkriterien_nachgewiesen = TRUE,
  norm_deckt_konkret_gepruefte_artikel_31_anforderung_ab = abgedeckt), quellenfassung = fassung)
 stopifnot(identical(ergebnis$wert, abgedeckt), ergebnis$anwendbarkeit == "UNBEKANNT")
}
pflicht <- ermittle_pflicht("P_AIA_033_001", list(benannte_stelle = TRUE,
 spezifische_konformitaetsaufgabe_an_unterauftragnehmer = TRUE,
 konformitaetsaufgabe_durch_tochterunternehmen = FALSE), quellenfassung = fassung)
zustimmung <- pruefe_tatbestand("AIA_033_003_ZUSTIMMUNG", list(
 anbieter_stimmt_konkreter_aufgabenauslagerung_zu = FALSE), quellenfassung = fassung)
stopifnot(isTRUE(pflicht$wert$ausloeser_erfuellt), pflicht$wert$erfuellung == "NICHT_GEPRUEFT",
 "AIA_033_003_ZUSTIMMUNG" %in% unlist(pflicht$wert$erfuellungskriterien),
 identical(zustimmung$wert, FALSE))
cat("5 Stellenkompositionen bestanden\n")
