library(euaiact)
f <- "EUAIACT_2026_07_27"
inputs <- function(id,data) data[intersect(names(data),names(eingabevertrag(id)$felder))]
t <- function(id,data) {
  rid <- paste0("DVO_1755_",id)
  pruefe_tatbestand(rid,inputs(rid,data),f)
}
p <- function(id,data) {
  pid <- paste0("P_DVO_1755_",id)
  rid <- Filter(function(x) x$pflicht_id==pid,pflicht_katalog())[[1]]$ausloeser_regel
  ermittle_pflicht(pid,inputs(rid,data),f)
}
data <- list(verfahrensdokument_oder_information_digital_uebermittelt=TRUE,verfahrensdokument_tatsaechlich_per_einschreiben_an_kommission_uebermittelt=FALSE,verfahrensdokument_tatsaechlich_von_hand_an_kommission_uebermittelt=FALSE,uebermittlung_betrifft_dokument=TRUE,anzahl_eidas_konformer_qualifizierter_signaturen=1L,digitale_uebermittlung_an_kommission=TRUE,kommission_hat_empfangsbestaetigung_abgesandt=TRUE,dokument_oder_teil_nicht_funktionsfaehig_oder_unbrauchbar=TRUE,dokument_enthaelt_viren_schadsoftware_oder_andere_bedrohungen=FALSE,dokument_enthaelt_elektronische_signatur=TRUE,signaturgueltigkeit_durch_kommission_verifizierbar=TRUE)
stopifnot(isTRUE(t("014_UEBERMITTLUNGSWEG",data)$wert),identical(t("014_003_EMPFANGSVORAUSSETZUNG",data)$wert,FALSE),isTRUE(p("014_006_MANGELMITTEILUNG",data)$wert$ausloeser_erfuellt))
data <- list(sanktionsverfahren_nach_dvo_artikel_5_eroeffnet=TRUE,kommission_hat_fehlende_gruende_fuer_101_1_entscheidung_festgestellt=TRUE,verfahren_auf_beschwerde_nachgelagerter_anbieter_89_2_eroeffnet=TRUE)
stopifnot(isTRUE(p("006_001_EINSTELLUNG",data)$wert$ausloeser_erfuellt),isTRUE(p("006_001_BESCHWERDEANHOERUNG",data)$wert$ausloeser_erfuellt),identical(t("006_001_EINSTELLUNGSNACHWEIS",list(gpai_sanktionsverfahren_tatsaechlich_durch_kommissionsbeschluss_eingestellt=FALSE))$wert,FALSE),t("006_001_ANHOERUNGSNACHWEIS",list(nachgelagerter_beschwerdefuehrer_hat_vor_einstellungsbeschluss_aeusserungsmoeglichkeit_erhalten=NULL))$status=="EINGABE_FEHLT")
request <- t("013_002_VERLAENGERUNGSANTRAG",list(frist_von_kommission_gesetzt=TRUE,verlaengerung_vom_betroffenen_anbieter_beantragt=TRUE,verlaengerungsantrag_vor_fristablauf=TRUE,verlaengerungsantrag_begruendet=TRUE,fristverlaengerung_angemessen=TRUE))
granted <- t("013_002_BEWILLIGUNG",list(kommission_hat_konkrete_fristverlaengerung_tatsaechlich_gewaehrt=FALSE))
stopifnot(isTRUE(request$wert),identical(granted$wert,FALSE))
duty <- p("008_003_BEZIEHUNGSMELDUNG",list(benannter_externer_berater_oder_experte_mit_aktenzugang=TRUE,nachtraeglich_beschaeftigungsbeziehung_oder_vergleichbares_eingegangen=TRUE,neue_beziehung_zum_adressaten=TRUE,neue_beziehung_zu_unternehmen_auf_selben_maerkten=FALSE,beziehung_waehrend_untersuchung_eingegangen=FALSE,beziehung_innerhalb_drei_jahren_nach_untersuchungsende_eingegangen=TRUE))
actual <- t("008_003_MELDUNGSNACHWEIS",list(berater_hat_neue_beziehungsbedingungen_unverzueglich_kommission_mitgeteilt=TRUE,adressat_hat_neue_beraterbeziehungsbedingungen_unverzueglich_kommission_mitgeteilt=FALSE))
stopifnot(isTRUE(duty$wert$ausloeser_erfuellt),"DVO_1755_008_003_MELDUNGSNACHWEIS" %in% unlist(duty$wert$erfuellungskriterien),duty$wert$erfuellung=="NICHT_GEPRUEFT",identical(actual$wert,FALSE))
cat("Four GPAI actual-procedure compositions passed\n")
