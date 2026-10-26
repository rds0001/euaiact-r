library(euaiact)
f <- "EUAIACT_2026_07_27"
k <- list(von="2023-01-01",bis="2032-12-31",feiertage=list(),bezug="SYNTHETISCH")
for(row in list(c("2023-07-19","2028-07-19","2027-10-19","2028-04-19"),c("2026-07-27","2031-07-27","2030-10-27","2031-04-27"))) {
    period <- berechne_regel("OMN_003_03_DAUER_PERIODE",list(),f)$wert
    stopifnot(berechne_frist(row[[1]],period$anzahl,period$einheit,modus="FESTER_TERMIN",quellenfassung=f)$wert==row[[2]])
    for(i in 1:2) {
        rid <- c("OMN_003_03_DAUER_BERICHT","OMN_003_03_DAUER_WIDERSPRUCH")[[i]]
        period <- berechne_regel(rid,list(),f)$wert
        stopifnot(berechne_frist(row[[2]],period$anzahl,period$einheit,modus="RUECKWAERTS",kalender=k,quellenfassung=f)$wert==row[[i+2]])
    }
}
timing <- berechne_regel("OMN_003_03_WIRKSAMKEIT",list(widerruf_amtsblattdatum="2026-10-23",widerruf_spaeterer_tag_festgelegt=FALSE,widerruf_prueftag="2026-10-24"),f)
stopifnot(identical(timing$wert,list(wirksam_ab="2026-10-24",am_prueftag_wirksam=TRUE)))
rev <- list(maschinen_delegationsgrundlage="ART_8_3",akteur_ist_europaeisches_parlament=TRUE,widerrufsentscheidung_tatsaechlich_erlassen=TRUE,maschinen_widerruf_erfasst_betrachtete_delegation=TRUE,widerrufsentscheidung_ist_zum_pruefzeitpunkt_wirksam=timing$wert$am_prueftag_wirksam)
stopifnot(identical(pruefe_tatbestand("OMN_003_03_BEFUGNIS",c(rev,list(maschinen_pruefzeitpunkt_in_wirksamer_delegationsperiode=TRUE)),f)$wert,FALSE))
stopifnot(isTRUE(pruefe_tatbestand("OMN_003_03_BESTANDSSCHUTZ",c(rev,list(maschinenakt_beruht_auf_widerrufener_delegation=TRUE,maschinenakt_vor_widerruf_bereits_in_kraft=TRUE)),f)$wert))
cat("Three machine-sector period and revocation compositions passed\n")
