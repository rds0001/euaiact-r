library(euaiact)
f <- "EUAIACT_2026_07_27"
basis <- ermittle_pflicht("P_DVO_0454_012_BASIS",list(akteur_ist_sekretariat_des_wissenschaftlichen_gremiums=TRUE),f)
stellungnahme <- ermittle_pflicht("P_DVO_0454_012_STELLUNGNAHME",list(akteur_ist_sekretariat_des_wissenschaftlichen_gremiums=TRUE,panel_stellungnahme_oder_empfehlung_in_erfuellung_artikel_68_3=TRUE,panel_veroeffentlichung_offenbart_geschaeftsgeheimnisse=TRUE),f)
ort <- pruefe_tatbestand("DVO_0454_012_PUBLIKATIONSWEG",list(panel_informationen_auf_eigens_vorgesehener_kommissionswebsite=FALSE,panel_informationen_ohne_unangemessene_verzoegerung_bereitgestellt=TRUE),f)
stopifnot(isTRUE(basis$wert$ausloeser_erfuellt),identical(stellungnahme$wert$ausloeser_erfuellt,FALSE),length(stellungnahme$entscheidungsrelevante_luecken)==0L,basis$wert$erfuellung=="NICHT_GEPRUEFT",identical(basis$wert$erfuellungskriterien,list("DVO_0454_012_BASISINHALTE","DVO_0454_012_PUBLIKATIONSWEG")),identical(ort$wert,FALSE))
cat("Paneltransparenz: Schutzumfang und getrennte Erfuellung bestanden\n")
