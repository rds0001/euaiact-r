library(euaiact)
f <- "EUAIACT_2026_07_27"
p <- ermittle_pflicht("P_AIA_ANH_VII_4_6_ERTEILUNG",list(verfahren_nach_anhang_vii_einschlaegig=TRUE,ergebnis_abschnitt_2_stellenbewertung="KONFORM"),f)
ausstellung <- pruefe_tatbestand("AIA_ANH_VII_4_6_AUSSTELLUNG",list(stelle_hat_unions_technikbescheinigung_fuer_bewertetes_system_ausgestellt=FALSE),f)
stopifnot(isTRUE(p$wert$ausloeser_erfuellt),p$wert$erfuellung=="NICHT_GEPRUEFT",identical(p$wert$erfuellungskriterien,list("AIA_ANH_VII_4_6_MITTEILUNG","AIA_ANH_VII_4_6_AUSSTELLUNG","AIA_ANH_VII_4_6_BESCHEINIGUNGSINHALTE")),identical(ausstellung$wert,FALSE))
cat("Bescheinigungskomposition: Bewertung ist keine Ausstellung; bestanden\n")
