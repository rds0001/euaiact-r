library(euaiact)
fassung <- "EUAIACT_2026_07_27"
faelle <- list(
 c("AIA_036_003_FORTGELTUNG", "2026-01-31", "2026-10-31"),
 c("AIA_036_009_GRUNDFORTGELTUNG", "2026-02-28", "2026-11-28"),
 c("AIA_036_009_BEWERTUNGSDAUER", "2026-02-28", "2027-02-28"),
 c("AIA_036_008_B_UEBERNAHMEDAUER", "2026-01-31", "2026-04-30"))
for (fall in faelle) {
 dauer <- berechne_regel(fall[1], list(), quellenfassung = fassung)$wert
 ergebnis <- berechne_frist(fall[2], dauer$anzahl, dauer$einheit,
  modus = "FESTER_TERMIN", quellenfassung = fassung)
 stopifnot(ergebnis$wert == fall[3], ergebnis$anwendbarkeit == "UNBEKANNT")
}
pflicht <- ermittle_pflicht("P_AIA_036_009_BEWERTUNG", list(
 stelle_hat_sofortige_verantwortung_nach_benennungswiderruf_schriftlich_uebernommen = TRUE), quellenfassung = fassung)
daten <- list(bewertung_durch_uebernehmende_stelle_innerhalb_zwoelf_monaten_abgeschlossen = FALSE)
verlauf <- pruefe_tatbestand("AIA_036_009_BEWERTUNGSVERLAUF", c(daten, list(
 zwoelfmonatsbewertungsfrist_nach_benennungswiderruf_abgelaufen = FALSE)), quellenfassung = fassung)
erfuellung <- pruefe_tatbestand("AIA_036_009_BEWERTUNG_KRITERIEN", daten, quellenfassung = fassung)
stopifnot(isTRUE(pflicht$wert$ausloeser_erfuellt), pflicht$wert$erfuellung == "NICHT_GEPRUEFT",
 identical(pflicht$wert$fristregel_ids, list("AIA_036_009_BEWERTUNGSDAUER")),
 isTRUE(verlauf$wert), identical(erfuellung$wert, FALSE))
cat("5 Fortgeltungskompositionen bestanden\n")
