library(euaiact)
f <- "EUAIACT_2026_07_27"
for (value in list(5L, 5, 5.5, TRUE)) {
  data <- list(ce_hoehe_mm=value)
  result <- pruefe_tatbestand("CE_0765_ANH_II_3_HOEHE", data, f)
  stopifnot(result$status == "EINGABE_UNGUELTIG", identical(data$ce_hoehe_mm, value), identical(result$eingaben$ce_hoehe_mm, value))
}
result <- ermittle_pflicht("P_AIA_048_001", list(anbieterrolle=TRUE,hochrisikosystem=TRUE),f)
stopifnot(isTRUE(result$wert$ausloeser_erfuellt), result$wert$erfuellung == "NICHT_GEPRUEFT", identical(result$wert$erfuellungskriterien,list("AIA_048_001_KRITERIEN")))
cat("CE numeric input rejection and separate duty fulfillment passed\n")
