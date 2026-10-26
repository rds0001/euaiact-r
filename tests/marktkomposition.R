library(euaiact)
f <- "EUAIACT_2026_07_27"
inputs <- list(marktaufsicht_quellcodezugang_begruendet_beantragt=TRUE,marktaufsicht_quellcodezugang_fuer_abschnitt_2_bewertung_notwendig=TRUE,marktaufsicht_daten_dokumentbasierte_tests_erschoepft_oder_unzureichend=TRUE)
duty <- ermittle_pflicht("P_AIA_074_013_QUELLCODE",inputs,f)$wert
stopifnot(isTRUE(duty$ausloeser_erfuellt),duty$erfuellung=="NICHT_GEPRUEFT")
stopifnot(identical(pruefe_tatbestand(duty$erfuellungskriterien[[1L]],list(anbieter_hat_qualifiziert_erforderlichen_quellcodezugang_gewaehrt=FALSE),f)$wert,FALSE))
inputs$marktaufsicht_daten_dokumentbasierte_tests_erschoepft_oder_unzureichend <- FALSE
stopifnot(identical(ermittle_pflicht("P_AIA_074_013_QUELLCODE",inputs,f)$wert$ausloeser_erfuellt,FALSE))
duty <- ermittle_pflicht("P_AIA_075_001A_MELDUNG",list(anbieterrolle=TRUE,hochrisikosystem=TRUE,ki_system=TRUE,system_ist_oder_integriert_in_benannte_sehr_grosse_onlineplattform_oder_suchmaschine=TRUE,schwerwiegender_vorfall_identifiziert=TRUE,verletzung_unionsrechtlicher_grundrechtsschutzpflicht=TRUE),f)$wert
stopifnot(isTRUE(duty$ausloeser_erfuellt),identical(duty$erfuellungskriterien,list("AIA_075_001A_EMPFAENGER")))
stopifnot(identical(pruefe_tatbestand("AIA_075_001A_EMPFAENGER",list(marktkooperation_vorfall_tatsaechlich_an_ki_buero_gemeldet=FALSE),f)$wert,FALSE))
stopifnot(!"vorfallmeldung_an_national_gewaehlte_medizinproduktbehoerde" %in% names(eingabevertrag("AIA_075_001A_EMPFAENGER")$felder))
stopifnot(regel_info("AIA_074_007_EZB_KONTEXT")$regelart=="SOLL_MELDEKONTEXT",!any(vapply(pflicht_katalog(),function(p) p$ausloeser_regel=="AIA_074_007_EZB_KONTEXT",logical(1))))
fiction <- pruefe_tatbestand("AIA_079_008",list(massnahme_nach_artikel_79_5_notifiziert=TRUE,einschlaegige_artikel_79_8_einwandfrist_abgelaufen=TRUE,mitgliedstaat_marktueberwachung_hat_fristgerecht_einwand_erhoben=FALSE,kommission_hat_artikel_79_einwand_fristgerecht_erhoben=FALSE),f)
stopifnot(isTRUE(fiction$wert),is.null(pruefe_tatbestand("AIA_081_002_MASSNAHME",list(),f)$wert))
duty <- ermittle_pflicht("P_AIA_081_002_RUECKNAHME",list(kommissionsentscheidung_nationale_massnahme="UNGERECHTFERTIGT"),f)$wert
stopifnot(isTRUE(duty$ausloeser_erfuellt),identical(pruefe_tatbestand(duty$erfuellungskriterien[[1L]],list(marktverfahren_81_ungerechtfertigte_nationale_massnahme_zurueckgenommen=FALSE,marktverfahren_81_kommission_ueber_massnahmenruecknahme_informiert=TRUE),f)$wert,FALSE))
duty <- ermittle_pflicht("P_AIA_075D_004",list(ki_buero_hat_beschluss_nach_75b_erlassen=TRUE),f)$wert
stopifnot(isTRUE(duty$ausloeser_erfuellt),all(c("AIA_075D_004_KRITERIEN","AIA_075D_004_PUBLIKATIONSNACHWEIS") %in% unlist(duty$erfuellungskriterien)))
stopifnot(isTRUE(pruefe_tatbestand("AIA_075D_004_KRITERIEN",list(veroeffentlichung_nennt_parteien=TRUE,veroeffentlichung_enthaelt_wesentlichen_beschlussinhalt=TRUE,veroeffentlichung_beruecksichtigt_rechte_und_berechtigte_geheimhaltungsinteressen=TRUE,sanktion_im_beschluss_verhaengt=FALSE),f)$wert))
stopifnot(identical(pruefe_tatbestand("AIA_075D_004_PUBLIKATIONSNACHWEIS",list(marktvollzug_75b_75c_beschluss_tatsaechlich_veroeffentlicht=FALSE),f)$wert,FALSE))
cat("Four market surveillance compositions passed\n")
