library(euaiact)
f <- "EUAIACT_2026_07_27"
cases <- jsonlite::fromJSON("fixtures/grundregeln_referenzen.json",simplifyVector=FALSE)$faelle
base <- Filter(function(x) x$fall_id=="REF_NOTIFIZIERUNGSKETTE_GESAMT_JA",cases)[[1L]]$eingaben
period <- berechne_regel("AIA_030_EINWANDSPERIODE",list(notifizierungsgrundlage="AKKREDITIERUNGSBESCHEINIGUNG"),f)$wert
end <- berechne_frist("2026-10-23",period$anzahl,period$einheit,modus="FRIST",kalender=list(von="2026-10-01",bis="2026-12-31",feiertage=list("2026-11-06"),bezug="SYNTHETISCH"),quellenfassung=f)$wert
stopifnot(end=="2026-11-09")
for(day in c("2026-11-09","2026-11-10")) {
    data <- base
    data$einschlaegige_einwandsperiode_abgelaufen <- day>end
    result <- pruefe_tatbestand("AIA_030_TAETIGKEITSWEG",data,f)
    stopifnot(identical(result$wert,day=="2026-11-10"))
}
base$konkrete_stellenbenennung_fuer_betrachtete_taetigkeit_aktuell_wirksam <- FALSE
stopifnot(identical(pruefe_tatbestand("AIA_030_TAETIGKEITSWEG",base,f)$wert,FALSE))
cat("Notification calendar and current-scope composition passed\n")
