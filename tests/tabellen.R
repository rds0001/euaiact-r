library(euaiact)
k <- tabellen_katalog()
stopifnot(identical(vapply(k, function(t) t$tabellen_id, character(1)), c("ANH_I", "ANH_II", "ANH_X", "ANH_XIII", "ANH_XIV")))
stopifnot(identical(vapply(k, function(t) t$zeilenanzahl, integer(1)), c(20L,16L,12L,7L,22L)))
rows <- tabelle_info("ANH_I")$zeilen
stopifnot(!any(vapply(rows, function(r) r$nummer == 1 || r$celex == "32006L0042", logical(1))))
machine <- Filter(function(r) r$celex == "32023R1230", rows)[[1L]]
stopifnot(machine$nummer == 21, machine$abschnitt == "B")
air <- Filter(function(r) r$nummer == 20, rows)[[1L]]
stopifnot(grepl("unbemannte", air$reichweite), grepl("Fernsteuerungsausr", air$reichweite))
codes <- stats::setNames(tabelle_info("ANH_XIV")$zeilen, vapply(tabelle_info("ANH_XIV")$zeilen, function(r) r$code, character(1)))
stopifnot(!"AIP 0101" %in% names(codes), codes[["AIP 0111"]]$zuordnung == "ANH_I/11", codes[["AIB 0203"]]$zuordnung == "ANH_III/1/c")
stopifnot(grepl("AIH 0401", codes[["AIH 0205"]]$systemtyp), grepl("agentischer KI", codes[["AIH 0401"]]$systemtyp))
eurodac <- Filter(function(r) r$gruppe == 3, tabelle_info("ANH_X")$zeilen)[[1L]]
stopifnot(eurodac$celex == "32024R1358")
t <- tabelle_info("ANH_II")
t$zeilen[[1L]]$deliktsgruppe <- "VERAENDERT"
t$grenzen <- list()
stopifnot(tabelle_info("ANH_II")$zeilen[[1L]]$deliktsgruppe == "Terrorismus", length(tabelle_info("ANH_II")$grenzen)>0L)
for (id in list(NULL, TRUE, list(), 1, NA_character_, character(), c("ANH_I","ANH_X"), "", "ANH_III", "anh_i")) {
  stopifnot(inherits(tryCatch(tabelle_info(id), error = identity), "error"))
}
