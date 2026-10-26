# Local Article2/substantive/111/113 workflow. All stages remain separate.
auswerten <- function(daten) {
 apis <- list(pruefe_tatbestand=euaiact::pruefe_tatbestand,pruefe_anwendungsbeginn=euaiact::pruefe_anwendungsbeginn,pruefe_bestandsfrist=euaiact::pruefe_bestandsfrist)
 lapply(daten$faelle,function(case) {
  context <- case$kontext
  stages <- lapply(case$schritte,function(step) {
   api <- step$api
   if(!api %in% names(apis)) stop("Nicht unterstuetzte API im Ablauf")
   params <- step$parameter
   if(any(c("stichtag","quellenfassung") %in% names(params))) stop("Stichtag und Quellenfassung stammen ausschliesslich aus dem gemeinsamen Kontext")
   params$quellenfassung <- context$quellenfassung
   if(api!="pruefe_tatbestand") params$stichtag <- context$stichtag
   list(api=api,ergebnis=do.call(apis[[api]],params))
  })
  list(fall_id=case$fall_id,kontext=context,schritte=stages)
 })
}
if(sys.nframe()==0L) {
 args <- commandArgs(trailingOnly=TRUE)
 if(length(args)!=2L) stop("Rscript geltungsablauf.R lokale_eingabe.json lokale_ausgabe.json")
 euaiact::schreibe_json(auswerten(euaiact::lese_json(args[[1]])),args[[2]])
}
