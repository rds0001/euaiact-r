library(euaiact)
cases <- jsonlite::fromJSON("fixtures/unternehmensgruppe_referenzen.json",simplifyVector=FALSE)$faelle
for(case in cases) {
 result <- do.call(aggregiere_unternehmensgruppe,case$eingaben)
 stopifnot(identical(result$status,case$erwartung$status),identical(result$wert,case$erwartung$wert))
}
a <- do.call(aggregiere_unternehmensgruppe,cases[[1]]$eingaben)
b <- do.call(aggregiere_unternehmensgruppe,cases[[4]]$eingaben)
a$eingaben <- NULL;b$eingaben <- NULL
stopifnot(identical(a,b))
cat(length(cases),"independent group references and permutation passed\n")

f <- "EUAIACT_2026_07_27"
data <- list(stamm_id="A",unternehmen=list("A","B"),beziehungen=list(list(von="A",nach="B",art="PARTNER",quote="0.25")),datenkreise=lapply(c("A","B"),function(id) {n <- if(id=="A") 6L else 8L;list(kreis_id=id,unternehmen_ids=list(id),wert=list(zaehler=as.character(n),nenner="1"),personensegmente=lapply(seq_len(n),function(i) list(person_id=paste0(id,i),segment_id="Jahr")))}),groesse="JAE",bezugsperiode="2025",kreis_vollstaendig=TRUE,quellenfassung=f)
before <- do.call(aggregiere_unternehmensgruppe,data)$wert$summe
data$beziehungen <- list(list(von="A",nach="B",art="VERBUND"))
after <- do.call(aggregiere_unternehmensgruppe,data)$wert$summe
stopifnot(identical(before,list(zaehler="8",nenner="1")),identical(after,list(zaehler="14",nenner="1")))
size <- function(v) berechne_regel("KMU_RATIONALSCHWELLEN",list(jae_zaehler=v$zaehler,jae_nenner=v$nenner,jahresumsatz_eur="100",jahresbilanzsumme_eur="100"),f)$wert$kleinst
old <- size(before);current <- size(after);stopifnot(isTRUE(old),identical(current,FALSE))
state <- list(regulaere_groessenfortschreibung_ohne_strukturwechsel_oder_neugruendung=FALSE,groessenrahmen_in_aktueller_abschlussperiode_erfuellt=current,groessenrahmen_in_unmittelbarer_vorperiode_erfuellt=old,groessenrahmenstatus_vor_aktueller_periodenpruefung=TRUE)
stopifnot(pruefe_tatbestand("KMU_ZWEIPERIODEN_GROESSENRAHMEN",state,f)$status=="REGEL_UNGEKLAERT")
state$regulaere_groessenfortschreibung_ohne_strukturwechsel_oder_neugruendung <- TRUE
stopifnot(isTRUE(pruefe_tatbestand("KMU_ZWEIPERIODEN_GROESSENRAHMEN",state,f)$wert))
state$groessenrahmen_in_unmittelbarer_vorperiode_erfuellt <- FALSE
stopifnot(identical(pruefe_tatbestand("KMU_ZWEIPERIODEN_GROESSENRAHMEN",state,f)$wert,FALSE))
cat("Group, threshold and transaction/ordinary-history composition passed\n")
