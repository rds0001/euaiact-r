library(euaiact)
fassung <- "EUAIACT_2026_07_27"
informationen <- list("2026-10-25T09:59:59.999999Z", "2026-10-25T12:00:00+02:00",
  "2026-10-25T10:00:00.000001Z", NULL)
erwartungen <- list(TRUE, TRUE, FALSE, NULL)
for (i in seq_along(informationen)) {
  zeit <- berechne_regel("AIA_050_005_INFORMATIONSZEITPUNKT", list(
    transparenzinformation_zeitpunkt = informationen[[i]],
    erste_interaktion_oder_exposition_zeitpunkt = "2026-10-25T10:00:00Z"), quellenfassung = fassung)
  stopifnot(identical(zeit$wert, erwartungen[[i]]))
  kriterium <- pruefe_tatbestand("AIA_050_005_KRITERIEN", list(
    transparenzinformation_klar = TRUE, transparenzinformation_unterscheidbar = TRUE,
    transparenzinformation_spaetestens_erste_interaktion_oder_exposition = zeit$wert,
    transparenzinformation_erfuellt_anwendbare_barrierefreiheit = TRUE), quellenfassung = fassung)
  stopifnot(identical(kriterium$wert, erwartungen[[i]]), kriterium$anwendbarkeit == "UNBEKANNT")
  pflicht <- ermittle_pflicht("P_AIA_050_004_BILD", list(betreiberrolle = TRUE,
    ki_generiert_oder_manipuliert_bild_audio_video = TRUE, inhalt_ist_deepfake = TRUE,
    gesetzlich_erlaubte_straftataufdeckung_verhuetung_untersuchung_oder_verfolgung = FALSE),
    quellenfassung = fassung)
  stopifnot(isTRUE(pflicht$wert$ausloeser_erfuellt), pflicht$wert$erfuellung == "NICHT_GEPRUEFT")
}
tage <- c("2026-12-01", "2026-12-02", "2026-12-03")
status <- c("VOR_FRISTTAG", "FRISTTAG", "NACH_FRISTTAG")
for (i in seq_along(tage)) {
  bestand <- pruefe_bestandsfrist("SYNTHETISCHE_AUSGABEN_ART_50_2", tage[[i]],
    ereignisse = list(inverkehrbringen = list(erfolgt = TRUE, datum = "2026-08-01")),
    quellenfassung = fassung)
  stopifnot(isTRUE(bestand$wert$bestand), bestand$wert$erfuellungsfrist == "2026-12-02",
    bestand$wert$friststatus == status[[i]], bestand$anwendbarkeit == "UNBEKANNT")
}
neu <- pruefe_bestandsfrist("SYNTHETISCHE_AUSGABEN_ART_50_2", "2026-12-01",
  ereignisse = list(inverkehrbringen = list(erfolgt = TRUE, datum = "2026-08-02")),
  quellenfassung = fassung)
stopifnot(identical(neu$wert$bestand, FALSE), is.null(neu$wert$erfuellungsfrist))
cat("8 Transparenz-Zeit-/Bestandskompositionen bestanden\n")
