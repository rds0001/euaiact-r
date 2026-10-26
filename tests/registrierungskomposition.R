library(euaiact)
f <- "EUAIACT_2026_07_27"
refs <- jsonlite::fromJSON("fixtures/grundregeln_referenzen.json", simplifyVector=FALSE)$faelle
case <- function(id) Filter(function(x) identical(x$fall_id,id),refs)[[1L]]
c <- case("REF_REGISTERWEG_035")
content <- pruefe_tatbestand(c$regel_id,c$eingaben,f)
duty <- ermittle_pflicht("P_AIA_049_002",list(anbieterrolle=TRUE,anbieter_hat_nichthochrisiko_nach_artikel_6_3_festgestellt=TRUE),f)
time <- berechne_regel("AIA_049_ANBIETER_VOR_ERSTEREIGNIS",list(registrierungsabschluss_zeitpunkt="2028-01-01T10:00:00Z",erstes_inverkehrbringen_oder_inbetriebnahme_zeitpunkt="2028-01-01T10:00:00Z"),f)
stopifnot(isTRUE(content$wert),isTRUE(duty$wert$ausloeser_erfuellt),duty$wert$erfuellung=="NICHT_GEPRUEFT",identical(duty$wert$erfuellungskriterien,list(c$regel_id)),identical(duty$wert$fristregel_ids,list(time$regel_id)),identical(time$wert,FALSE))
c <- case("REF_REGISTERWEG_021"); data <- c$eingaben; data$registrierte_angaben_a <- list()
upper <- pruefe_tatbestand("AIA_049_004_DATEN_A",list(registrierte_angaben_a=list()),f)
complete <- pruefe_tatbestand(c$regel_id,data,f)
stopifnot(isTRUE(upper$wert),identical(complete$wert,FALSE))
duty <- ermittle_pflicht("P_AIA_043_003_ANTRAG",list(stelle_nach_sektorrecht_anhang_i_a_notifiziert=TRUE),f)
date <- berechne_regel("AIA_043_003_ANTRAGSTERMIN",list(benennungsantrag_datum="2028-01-28"),f)
stopifnot(isTRUE(duty$wert$ausloeser_erfuellt),duty$wert$erfuellung=="NICHT_GEPRUEFT",identical(duty$wert$erfuellungskriterien,list("AIA_043_003_ANTRAGSKRITERIUM")),identical(duty$wert$fristregel_ids,list(date$regel_id)),isTRUE(date$wert))
cat("Three registration/designation compositions passed\n")
