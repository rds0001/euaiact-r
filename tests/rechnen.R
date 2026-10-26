library(euaiact)
referenzen <- jsonlite::fromJSON("fixtures/rechenregeln_referenzen.json", simplifyVector = FALSE)
fassung <- "EUAIACT_2026_07_27"
for (fall in referenzen$faelle) {
  ergebnis <- berechne_regel(fall$regel_id, fall$eingaben, fassung)
  if (!identical(ergebnis$wert, fall$wert) || ergebnis$status != if (is.null(fall$status)) "AUSGEWERTET" else fall$status) {
    stop(paste(fall$fall_id, fall$herleitung))
  }
}
ergebnis <- berechne_bussgeldobergrenze(list(verstosskategorie = "PFLICHT", akteurklasse = "KMU"), fassung)
stopifnot(is.null(ergebnis$wert), ergebnis$status == "EINGABE_FEHLT",
  identical(ergebnis$entscheidungsrelevante_luecken, list("weltweiter_vorjahresumsatz_eur")))
ergebnis <- berechne_bussgeldobergrenze(list(verstosskategorie = "PFLICHT", akteurklasse = "KEIN_UNTERNEHMEN",
  weltweiter_vorjahresumsatz_eur = "-1"), fassung)
stopifnot(ergebnis$status == "EINGABE_UNGUELTIG")
ergebnis <- berechne_regel("KMU_SCHWELLEN", list(jahresarbeitseinheiten = "249", jahresumsatz_eur = "50000000"), fassung)
stopifnot(identical(ergebnis$wert, list(kleinst = FALSE, klein = FALSE, kmu = TRUE, smc_groessenrahmen = TRUE)),
  ergebnis$status == "AUSGEWERTET", identical(ergebnis$fehlende_angaben, list("jahresbilanzsumme_eur")),
  length(ergebnis$entscheidungsrelevante_luecken) == 0L)
cat(length(referenzen$faelle), "unabhaengige Rechenreferenzen und Unbekannt-Vertraege bestanden\n")
ergebnis <- berechne_regel("AIA_073_MELDEFRISTTAGE", list(weitverbreiteter_verstoss = TRUE), fassung)
stopifnot(identical(ergebnis$wert, 2L), length(ergebnis$fehlende_angaben) == 2L, length(ergebnis$entscheidungsrelevante_luecken) == 0L)
kennung <- "AIA_036_003_VORANKUENDIGUNG"
ergebnis <- berechne_regel(kennung, list(), fassung)
stopifnot(identical(ergebnis$wert, list(anzahl = 1L, einheit = "JAHR")),
  regel_info(kennung)$zeitrelation == "VOR",
  identical(as.character(jsonlite::toJSON(eingabevertrag(kennung)$felder, auto_unbox = TRUE)), "{}"))
ergebnis$wert$anzahl <- 99L
stopifnot(ergebnis$rechenschritte[[1]]$wert$anzahl == 1L,
  berechne_regel(kennung, list(), fassung)$wert$anzahl == 1L)

kennung <- "AIA_079_008_EINWANDSDAUER"
ergebnis <- berechne_regel(kennung, list(massnahmenanlass = "VERBOT_ARTIKEL_5"), fassung)
stopifnot(ergebnis$rechenschritte[[1]]$auswahl == "VERBOT_ARTIKEL_5")
ergebnis$wert$anzahl <- 999L
stopifnot(ergebnis$rechenschritte[[1]]$wert$anzahl == 30L,
  berechne_regel(kennung, list(massnahmenanlass = "VERBOT_ARTIKEL_5"), fassung)$wert$anzahl == 30L)
