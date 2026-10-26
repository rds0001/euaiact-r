library(euaiact)
id <- "AIA_049_004_DATEN_A"
pruefen <- function(x) pruefe_tatbestand(id, list(registrierte_angaben_a = x), quellenfassung = "EUAIACT_2026_07_27")
stopifnot(identical(pruefen(list())$wert, TRUE))
stopifnot(identical(pruefen(list("10", "3", "1"))$wert, TRUE))
stopifnot(identical(pruefen(list("6"))$wert, FALSE))
stopifnot(identical(pruefen(NULL)$status, "EINGABE_FEHLT"))
for (x in list(c("1", "2"), list("1", "1"), list(NULL), list(NA), list(TRUE), list(list("1")), list(a = "1"), stats::setNames(list(), character()))) {
  stopifnot(identical(pruefen(x)$status, "EINGABE_UNGUELTIG"))
}
x <- list("10", "1")
ergebnis <- pruefen(x)
stopifnot(identical(ergebnis$eingaben$registrierte_angaben_a, x))
stopifnot(identical(ergebnis$entscheidungsschritte[[1L]]$wert, x))
