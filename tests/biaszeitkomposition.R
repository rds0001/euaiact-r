library(euaiact)
f <- "EUAIACT_2026_07_27"
rid <- "AIA_004A_001_VORAUSSETZUNGEN"
data <- setNames(rep(list(TRUE),length(eingabevertrag(rid)$felder)),names(eingabevertrag(rid)$felder))
substance <- pruefe_tatbestand(rid,data,f)
timing <- pruefe_anwendungsbeginn("ARTIKEL_4A","2026-10-25",quellenfassung=f)
stopifnot(isTRUE(substance$wert),substance$anwendbarkeit=="UNBEKANNT",timing$status=="REGEL_UNGEKLAERT",is.null(timing$wert))
result <- pruefe_tatbestand("AIA_004A_LOESCHUNG",list(besondere_personendaten_fuer_biaspruefung_verarbeitet=TRUE,bias_korrektur_abgeschlossen=FALSE,aufbewahrungszeitraum_besonderer_daten_beendet=TRUE),f)
stopifnot(isTRUE(result$wert),result$anwendbarkeit=="UNBEKANNT")
cat("Two substantive/time boundary compositions passed\n")
