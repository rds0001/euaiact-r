library(euaiact)
fassung <- "EUAIACT_2026_07_27"
e <- berechne_regel("KMU_VERBUND_HINZURECHNUNG", list(aggregationsbasiswert = strrep("9", 4096L), noch_hinzuzurechnender_unternehmenswert = "1"), fassung)
stopifnot(e$status == "AUSGEWERTET", identical(e$wert, paste0("1", strrep("0", 4096L))))
erneut <- berechne_regel("KMU_VERBUND_HINZURECHNUNG", list(aggregationsbasiswert = e$wert, noch_hinzuzurechnender_unternehmenswert = "0"), fassung)
stopifnot(erneut$status == "EINGABE_UNGUELTIG")
e <- berechne_regel("KMU_PARTNER_HINZURECHNUNG", list(aggregationsbasiswert = "0.00000000000000000001", noch_hinzuzurechnender_unternehmenswert = "0.00000000000000000002", hinzurechnungsquote = "0.25"), fassung)
stopifnot(identical(e$wert, "0.000000000000000000015"), identical(e$rechenschritte[[1L]]$wert, "0.000000000000000000005"))
cat("Native exakte Aggregationsgrenzen bestanden\n")
# (10^4096-1)*(1-10^-4094) = 10^4096-101+10^-4094.
e <- berechne_regel("KMU_PARTNER_HINZURECHNUNG", list(aggregationsbasiswert = "0", noch_hinzuzurechnender_unternehmenswert = strrep("9", 4096L), hinzurechnungsquote = paste0("0.", strrep("9", 4094L))), fassung)
stopifnot(e$status == "AUSGEWERTET", identical(e$wert, paste0(strrep("9", 4093L), "899.", strrep("0", 4093L), "1")))
