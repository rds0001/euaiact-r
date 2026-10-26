library(euaiact)
fehler <- function(ausdruck) inherits(tryCatch({force(ausdruck); NULL}, error = identity), "error")
pfad <- tempfile(fileext = ".json")
daten <- list(leer = setNames(list(), character()), liste = list(), null = NULL,
  zahl = 9007199254740991, betrag = "123456789.0000001", text = "Größe München", falsch = FALSE)
schreibe_json(daten, pfad)
stopifnot(identical(lese_json(pfad), daten))
stopifnot(suppressWarnings(fehler(schreibe_json(list(), pfad))))
stopifnot(identical(lese_json(pfad), daten))
unlink(pfad)
for (inhalt in c('{"a":1,"a":2}', '{"a":NaN}', '{"a":1.1}', '{"a":1.0}', '{"a":1e1}', '{"a":9007199254740991.1}', '{"a":9007199254740992}', '{"":true}')) {
  writeLines(inhalt, pfad)
  stopifnot(fehler(lese_json(pfad)))
}
writeLines(paste0(strrep("[", 102), "null", strrep("]", 102)), pfad)
stopifnot(fehler(lese_json(pfad)))
unlink(pfad)
for (pfad in c("https://example.test/a", "file:///tmp/a", "//server/a", "\\\\server\\a")) {
  stopifnot(fehler(lese_json(pfad)), fehler(schreibe_json(list(), pfad)))
}
daten <- list(heilzweck = FALSE, fremd = 7)
zuordnung <- list(mappingversion = "firma-1", felder = list(medizinisch = "heilzweck", arbeitsplatz = "betrieb"))
ergebnis <- ordne_daten_zu(daten, zuordnung)
stopifnot(identical(ergebnis$eingaben, list(arbeitsplatz = NULL, medizinisch = FALSE)),
  identical(ergebnis$herkunft, list(
    list(zielfeld = "arbeitsplatz", quellfeld = "betrieb", vorhanden = FALSE),
    list(zielfeld = "medizinisch", quellfeld = "heilzweck", vorhanden = TRUE))),
  identical(daten, list(heilzweck = FALSE, fremd = 7)))
cat("Lokaler JSON-Roundtrip, Präzision, Mapping und Fehlergrenzen bestanden\n")
