library(euaiact)
fassung <- "EUAIACT_2026_07_27"
faelle <- list(AKKREDITIERUNGSBESCHEINIGUNG = "2026-11-09", DOKUMENTENNACHWEISE = "2026-12-23")
for (grundlage in names(faelle)) {
  periode <- berechne_regel("AIA_030_EINWANDSPERIODE", list(notifizierungsgrundlage = grundlage), fassung)
  stopifnot(periode$status == "AUSGEWERTET")
  ergebnis <- berechne_frist("2026-10-23", periode$wert$anzahl, periode$wert$einheit, modus = "FRIST",
    kalender = list(von = "2026-10-01", bis = "2027-01-31", feiertage = list("2026-11-06"), bezug = "SYNTHETISCHER_FEIERTAG"), quellenfassung = fassung)
  stopifnot(ergebnis$status == "AUSGEWERTET", identical(ergebnis$wert, faelle[[grundlage]]))
}
