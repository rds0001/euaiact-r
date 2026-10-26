library(euaiact)
referenzen <- jsonlite::fromJSON("fixtures/fristen_referenzen.json", simplifyVector = FALSE)
berechnen <- function(fall, kalender = referenzen$kalender) {
  if (missing(kalender) && "kalender" %in% names(fall)) kalender <- fall$kalender
  berechne_frist(fall$ereignisdatum, fall$anzahl, fall$einheit, fall$modus,
    kalender, referenzen$quellenfassung)
}
for (fall in referenzen$faelle) {
  ergebnis <- berechnen(fall)
  if (!identical(ergebnis$wert, fall$wert) || ergebnis$status != if (is.null(fall$status)) "AUSGEWERTET" else fall$status) {
    stop(paste(fall$fall_id, fall$herleitung))
  }
}
kalender <- referenzen$kalender
kalender$feiertage <- list("2026-10-26")
stopifnot(identical(berechnen(referenzen$faelle[[1L]], kalender)$wert, "2026-10-28"))
kalender <- referenzen$kalender
kalender$bis <- "2026-10-26"
ergebnis <- berechnen(referenzen$faelle[[1L]], kalender)
stopifnot(is.null(ergebnis$wert), ergebnis$status == "EINGABE_FEHLT")
for (datum in c("2026-02-30", "2026-2-1", "2026-01-01\n", "0000-01-01")) {
  fall <- referenzen$faelle[[1L]]
  fall$ereignisdatum <- datum
  stopifnot(berechnen(fall)$status == "EINGABE_UNGUELTIG")
}
cat(length(referenzen$faelle), "Datumsreferenzen und Kalender-/Validierungspruefungen bestanden\n")
ohne <- berechne_frist("2026-10-23", 2, "TAG", "FESTER_TERMIN", quellenfassung = referenzen$quellenfassung)
stopifnot(identical(ohne$wert, "2026-10-25"), identical(ohne$fehlende_angaben, list("kalender")), length(ohne$entscheidungsrelevante_luecken) == 0L)
stopifnot(berechne_frist("2026-10-23", 1, "MONAT", "VERFAHREN_1755_TAGE", referenzen$kalender, referenzen$quellenfassung)$status == "EINGABE_UNGUELTIG")
kalender <- referenzen$kalender
kalender$bis <- "2026-10-25"
ergebnis <- berechne_frist("2026-10-23", 3, "TAG", "VERFAHREN_1755_TAGE", kalender, referenzen$quellenfassung)
stopifnot(ergebnis$status == "EINGABE_FEHLT", identical(ergebnis$entscheidungsrelevante_luecken, list("kalenderdeckung")))

for (einheit in c("TAG", "ARBEITSTAG", "WOCHE", "MONAT", "JAHR")) {
  kalender <- referenzen$kalender
  kalender$von <- "0001-01-01"
  kalender$bis <- "0001-12-31"
  ergebnis <- berechne_frist("0001-01-01", 1, einheit, "RUECKWAERTS", kalender, referenzen$quellenfassung)
  stopifnot(ergebnis$status == "EINGABE_UNGUELTIG", is.null(ergebnis$wert))
}
kalender <- referenzen$kalender
kalender$von <- "2026-10-23"
vorher <- kalender
ergebnis <- berechne_frist("2026-10-26", 2, "TAG", "RUECKWAERTS", kalender, referenzen$quellenfassung)
stopifnot(ergebnis$status == "EINGABE_FEHLT", identical(ergebnis$entscheidungsrelevante_luecken, list("kalenderdeckung")), identical(kalender, vorher))
kalender$von <- "0001-01-01"
kalender$bis <- "0001-12-31"
kalender$feiertage <- list("0001-01-01", "0001-01-02")
ergebnis <- berechne_frist("0001-01-03", 2, "TAG", "RUECKWAERTS", kalender, referenzen$quellenfassung)
stopifnot(ergebnis$status == "EINGABE_UNGUELTIG")
