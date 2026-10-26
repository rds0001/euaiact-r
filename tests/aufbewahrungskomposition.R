library(euaiact)
fassung <- "EUAIACT_2026_07_27"
kalender <- list(von = "2026-01-01", bis = "2038-12-31", feiertage = list(),
  bezug = "SYNTHETISCH: ausdrücklich keine Feiertage im gesamten Zeitraum")
regeln <- c("AIA_018_AUFBEWAHRUNGSDAUER", "AIA_022_003_B_AUFBEWAHRUNGSDAUER",
  "AIA_023_005_AUFBEWAHRUNGSDAUER", "AIA_019_001_REGELMINDESTDAUER",
  "AIA_026_006_REGELMINDESTDAUER")
for (i in seq_along(regeln)) {
  dauer <- berechne_regel(regeln[i], list(), quellenfassung = fassung)
  ereignis <- if (i <= 3L) "2028-02-29" else "2026-08-31"
  erwartet <- if (i <= 3L) "2038-03-01" else "2027-03-01"
  ende <- berechne_frist(ereignis, dauer$wert$anzahl, dauer$wert$einheit,
    modus = "FRIST", kalender = kalender, quellenfassung = fassung)
  # Explizit gewählter allgemeiner Fristmodus: Februarende, Sonntag -> Montag.
  stopifnot(ende$status == "AUSGEWERTET", ende$wert == erwartet,
    ende$anwendbarkeit == "UNBEKANNT")
}
dauer <- berechne_regel("AIA_018_AUFBEWAHRUNGSDAUER", list(), quellenfassung = fassung)
kurz <- kalender
kurz$bis <- "2038-02-28"
for (k in list(NULL, kurz)) {
  ende <- berechne_frist("2028-02-29", dauer$wert$anzahl, dauer$wert$einheit,
    modus = "FRIST", kalender = k, quellenfassung = fassung)
  stopifnot(ende$status == "EINGABE_FEHLT", is.null(ende$wert))
}
pflicht <- ermittle_pflicht("P_AIA_026_006", list(betreiberrolle = TRUE,
  hochrisikosystem = TRUE, automatisch_erzeugte_protokolle_unter_eigener_kontrolle = TRUE),
  quellenfassung = fassung)
stopifnot(isTRUE(pflicht$wert$ausloeser_erfuellt),
  pflicht$wert$erfuellung == "NICHT_GEPRUEFT",
  identical(unlist(pflicht$wert$fristregel_ids), "AIA_026_006_REGELMINDESTDAUER"))
offen <- pruefe_tatbestand("AIA_PROTOKOLL_AUFBEWAHRUNGSKRITERIEN",
  list(sechsmonatsmindestdauer_der_protokollaufbewahrung_eingehalten = TRUE),
  quellenfassung = fassung)
stopifnot(offen$status == "EINGABE_FEHLT", is.null(offen$wert))
cat("7 Aufbewahrungs-Kompositionspruefungen bestanden\n")
