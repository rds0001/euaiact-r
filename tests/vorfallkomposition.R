library(euaiact)
fassung <- "EUAIACT_2026_07_27"
kalender <- list(von = "2026-10-01", bis = "2026-11-30", feiertage = list(),
  bezug = "SYNTHETISCH: explizit keine Feiertage")
dauer <- berechne_regel("AIA_073_008_BEHOERDENDAUER", list(), quellenfassung = fassung)
stopifnot(dauer$status == "AUSGEWERTET")
ende <- berechne_frist("2026-10-23", dauer$wert$anzahl, dauer$wert$einheit,
  modus = "FRIST", kalender = kalender, quellenfassung = fassung)
stopifnot(ende$wert == "2026-10-30", ende$anwendbarkeit == "UNBEKANNT")
kurz <- berechne_regel("AIA_073_MELDEFRISTTAGE", list(weitverbreiteter_verstoss = TRUE,
  schwere_irreversible_kritische_infrastrukturstoerung = NULL, todesfall = NULL),
  quellenfassung = fassung)
stopifnot(kurz$wert == 2)
ende <- berechne_frist("2026-10-23", kurz$wert, "TAG", modus = "FRIST",
  kalender = kalender, quellenfassung = fassung)
stopifnot(ende$wert == "2026-10-27")
# Expliziter allgemeiner Fristmodus mit zwei Mindestarbeitstagen; keine Warteerlaubnis.
offen <- berechne_frist("2026-10-23", dauer$wert$anzahl, "TAG", modus = "FRIST",
  quellenfassung = fassung)
stopifnot(offen$status == "EINGABE_FEHLT", is.null(offen$wert))
cat("3 Vorfall-Dauer-/Kalenderkompositionen bestanden\n")
