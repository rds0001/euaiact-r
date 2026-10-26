library(euaiact)
ref <- jsonlite::fromJSON("fixtures/strukturreferenzen.json", simplifyVector = FALSE)
for (fall in ref$faelle) {
  daten <- fall$eingaben
  result <- pruefe_tatbestand(fall$regel_id, daten, ref$quellenfassung)
  stopifnot(identical(result$wert, fall$erwartung$wert),
            identical(result$status, fall$erwartung$status), identical(daten, fall$eingaben))
  targets <- vapply(result$entscheidungsschritte, function(s) paste0(s$bedingung_id, ":",
    if (is.null(s$wert)) "None" else if (identical(s$wert, TRUE)) "True" else if (identical(s$wert, FALSE)) "False" else "kein_bool"), "")
  stopifnot(all(unlist(fall$ziel_ids) %in% targets))
}
cat(length(ref$faelle), "gezielte Strukturzeugen bestanden\n")

# Complete, explicitly stated primitive truth tables (21 combinations).
values <- list(TRUE, FALSE, NULL)
sets <- list(
 list("AIA_003_004", "0.1.0", c("natuerliche_person", "rein_persoenlich_nicht_beruflich"),
      list(TRUE,FALSE,NULL,FALSE,FALSE,FALSE,NULL,FALSE,NULL)),
 list("AIA_003_003", "0.0", c("entwickelt_selbst", "laesst_entwickeln"),
      list(TRUE,TRUE,TRUE,TRUE,FALSE,NULL,TRUE,NULL,NULL)),
 list("AIA_003_023", "0.1", "bei_urspruenglicher_bewertung_vorgesehen", list(FALSE,TRUE,NULL)))
for (case in sets) {
  k <- 0L
  for (a in values) for (b in if (length(case[[3]]) == 2L) values else list(NULL)) {
    k <- k + 1L
    data <- setNames(if (length(case[[3]]) == 2L) list(a,b) else list(a), case[[3]])
    result <- pruefe_tatbestand(case[[1]], data, ref$quellenfassung)
    steps <- Filter(function(s) identical(s$bedingung_id, paste0(case[[1]], ":K", case[[2]])), result$entscheidungsschritte)
    stopifnot(length(steps) == 1L, identical(steps[[1]]$wert, case[[4]][[k]]))
  }
}
cat("21 Grundoperator-Kombinationen bestanden\n")
