library(euaiact)
f <- "EUAIACT_2026_07_27"
daten <- list(verfahren_nach_anhang_vii_einschlaegig=TRUE,stelle_hat_ergaenzungsweg_fuer_konkrete_systemaenderungen_festgelegt=TRUE)
mitteilung <- ermittle_pflicht("P_AIA_ANH_VII_4_7_ERGAENZUNGSBEWERTUNG",daten,f)
daten$stelle_hat_systemaenderungen_im_ergaenzungsweg_genehmigt <- FALSE
ausstellung <- ermittle_pflicht("P_AIA_ANH_VII_4_7_ERGAENZUNG",daten,f)
stopifnot(isTRUE(mitteilung$wert$ausloeser_erfuellt),identical(ausstellung$wert$ausloeser_erfuellt,FALSE),mitteilung$wert$erfuellung=="NICHT_GEPRUEFT",identical(mitteilung$wert$erfuellungskriterien,list("AIA_ANH_VII_4_7_ERGAENZUNGSMITTEILUNG")),identical(ausstellung$wert$erfuellungskriterien,list("AIA_ANH_VII_4_7_ERGAENZUNGSAUSSTELLUNG")))
daten <- list(verfahren_nach_anhang_vii_einschlaegig=TRUE,ergebnis_abschnitt_2_stellenbewertung="NICHT_KONFORM")
allgemein <- ermittle_pflicht("P_AIA_ANH_VII_4_6_ABLEHNUNG",daten,f)
daten$system_erfuellt_anforderung_an_trainingsdaten_nicht <- FALSE
training <- ermittle_pflicht("P_AIA_ANH_VII_4_6_TRAININGBEGRUENDUNG",daten,f)
stopifnot(isTRUE(allgemein$wert$ausloeser_erfuellt),identical(training$wert$ausloeser_erfuellt,FALSE),identical(training$wert$erfuellungskriterien,list("AIA_ANH_VII_4_6_TRAININGABLEHNUNGSKRITERIEN")))
cat("2 Anhang-VII-Verfahrenskompositionen bestanden\n")
