library(euaiact)
f <- "EUAIACT_2026_07_27"
refs <- jsonlite::fromJSON("fixtures/grundregeln_referenzen.json",simplifyVector=FALSE)$faelle
t <- function(id,d) pruefe_tatbestand(id,d[intersect(names(d),names(eingabevertrag(id)$felder))],f)
sample <- function(id,suffix) Filter(function(x) x$fall_id==paste0("REF_BIOMETRIEABLAUF_",id,"_",suffix),refs)[[1]]$eingaben
compare <- function(art,stamp) berechne_regel(paste0("AIA_",art,"_BIOMETRIE_ZEITPUNKT_BIS_FRISTENDE"),list(biometrie_gepruefter_zeitpunkt=stamp,biometrie_qualifiziertes_antragsfristende="2026-10-25T02:00:00+01:00"),f)$wert
for(art in c("005","026")) {
 id <- paste0("AIA_",art,"_BIOMETRIE_ANTRAGSFRISTSTAND"); d <- sample(id,"LAUFEND")
 hours <- if(art=="005") "24" else "48"
 key <- paste0("biometrie_",hours,"_stunden_frist_zum_stichtag_abgelaufen")
 d[[key]] <- !compare(art,"2026-10-25T01:00:00Z")
 stopifnot(isTRUE(t(id,d)$wert),identical(d$biometrie_genehmigungsantrag_zum_stichtag_tatsaechlich_gestellt,FALSE))
 d[[key]] <- !compare(art,"2026-10-25T01:00:00.000001Z")
 stopifnot(identical(t(id,d)$wert,FALSE))
 d[[paste0("biometrie_",hours,"_stunden_fristvergleich_rechtlich_qualifiziert")]] <- FALSE
 stopifnot(t(id,d)$status=="REGEL_UNGEKLAERT")
}
id <- "AIA_005_001_H_LAUFENDER_VERLAUF"; d <- sample(id,"QUALIFIZIERTER_LAUF")
stopifnot(identical(t(id,d)$wert,FALSE));d$genehmigung_abgelehnt <- TRUE
stopifnot(isTRUE(t(id,d)$wert));d$echtzeiteinsatz_nach_genehmigungsablehnung_sofort_gestoppt <- TRUE
d$alle_daten_ergebnisse_und_ausgaben_des_abgelehnten_echtzeiteinsatzes_sofort_verworfen_und_geloescht <- FALSE
stopifnot(isTRUE(t("AIA_005_003_ABLEHNUNG",d)$wert),identical(t("AIA_005_003_ABLEHNUNGSKRITERIEN",d)$wert,FALSE),identical(t("AIA_026_010_ABLEHNUNGSKRITERIEN",list(personenbezogene_daten_des_abgelehnten_einsatzes_geloescht=FALSE,zur_abgelehnten_genehmigung_gehoeriger_einsatz_sofort_gestoppt=TRUE))$wert,FALSE))
d <- sample(id,"QUALIFIZIERTER_LAUF")
stopifnot(isTRUE(t("AIA_005_H_REGISTRIERUNG_LAUFEND",d)$wert),identical(t("AIA_005_002_REG_NACHWEIS",d)$wert,FALSE))
d$grundrechtefolgenabschaetzung_abgeschlossen <- FALSE
stopifnot(isTRUE(t(id,d)$wert))
pre <- berechne_regel("AIA_026_010_ANTRAG_VOR_EINSATZ",list(biometrie_genehmigungsantrag_zeitpunkt="2026-10-25T02:30:00+02:00",nachtraegliche_fernidentifizierung_einsatzbeginn_zeitpunkt="2026-10-25T02:15:00+01:00"),f)
stopifnot(isTRUE(pre$wert));d <- sample("AIA_026_010_ANTRAG_VOLLZUG","GESTELLT")
d$genehmigungsantrag_vor_einsatz <- pre$wert; d$genehmigungsantrag_unverzueglich_nach_einsatz <- FALSE;d$genehmigungsantrag_spaetestens_innerhalb_gesetzlicher_48_stunden <- FALSE
stopifnot(isTRUE(t("AIA_026_010_ANTRAG_VOLLZUG",d)$wert));d$biometrie_genehmigungsantrag_zum_stichtag_tatsaechlich_gestellt <- FALSE
stopifnot(identical(t("AIA_026_010_ANTRAG_VOLLZUG",d)$wert,FALSE))
cat("Five biometric workflow compositions passed\n")
