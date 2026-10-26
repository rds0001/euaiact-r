library(euaiact)
f <- "EUAIACT_2026_07_27"
cases <- jsonlite::fromJSON("fixtures/grundregeln_referenzen.json",simplifyVector=FALSE)$faelle
period <- berechne_regel("AIA_097_002_DELEGATIONSDAUER",list(),f)$wert
end <- berechne_frist("2024-08-01",period$anzahl,period$einheit,modus="FESTER_TERMIN",quellenfassung=f)
stopifnot(end$wert=="2029-08-01")
for(suffix in c("051_003","052_004","053_005","053_006")) {
    id <- paste0("REF_GPAIDELEGATION_",suffix,"_WEG_JA")
    data <- Filter(function(x) x$fall_id==id,cases)[[1L]]$eingaben
    data$widerrufsentscheidung_ist_zum_pruefzeitpunkt_wirksam <- TRUE
    result <- pruefe_tatbestand(paste0("AIA_",suffix,"_DELEGATIONSWEG"),data,f)
    stopifnot(identical(result$wert,FALSE))
}
cat("Four GPAI cohort/revocation compositions passed\n")
