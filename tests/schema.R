library(euaiact)
schema <- schema_info()
stopifnot(identical(schema[["$id"]], "urn:euaiact:ergebnis:0.1.0"))
erforderlich <- unlist(schema$required, use.names = FALSE)
for (regel in regel_katalog()) {
  funktion <- if (is.null(regel_info(regel$regel_id)$ausdruck)) berechne_regel else pruefe_tatbestand
  ergebnis <- funktion(regel$regel_id, list(), regel$quellenfassung)
  stopifnot(setequal(names(ergebnis), erforderlich))
}
schema$required <- list()
stopifnot(length(schema_info()$required) > 0L)
stopifnot(inherits(try(schema_info("https://example.test/schema"), silent = TRUE), "try-error"))
falsch <- pruefe_tatbestand(42, list(), list())
stopifnot(is.null(falsch$regel_id), is.null(falsch$quellenfassung), falsch$status == "EINGABE_UNGUELTIG")
cat("Lokales Ergebnisschema und Pflichtschluessel aller Katalogregeln bestanden\n")
for (eingaben in list(list(TRUE), stats::setNames(list(TRUE, FALSE), c("trainings_flops", "trainings_flops")))) {
  ergebnis <- pruefe_tatbestand("AIA_051_002", eingaben, "EUAIACT_2026_07_27")
  stopifnot(ergebnis$status == "EINGABE_UNGUELTIG", identical(ergebnis$eingaben, stats::setNames(list(), character())))
  stopifnot(identical(as.character(jsonlite::toJSON(ergebnis$eingaben, auto_unbox = TRUE)), "{}"))
}
