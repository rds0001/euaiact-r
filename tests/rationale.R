library(euaiact)
f <- "EUAIACT_2026_07_27"
data <- list(arbeitsanteil_n="2",arbeitsanteil_d="3",zeit_n="3",zeit_d="4")
before <- data
mapped <- ordne_daten_zu(data,list(mappingversion="synthetisch-1",felder=list(pensum_zaehler="arbeitsanteil_n",pensum_nenner="arbeitsanteil_d",jahresabschnitt_zaehler="zeit_n",jahresabschnitt_nenner="zeit_d")))
a <- berechne_regel("KMU_JAE_RATIONALBEITRAG",mapped$eingaben,f)
b <- berechne_regel("JAE_RATIONALSUMME",list(beitrag_links_zaehler="499",beitrag_links_nenner="2",beitrag_rechts_zaehler=a$wert$zaehler,beitrag_rechts_nenner=a$wert$nenner),f)
size <- berechne_regel("KMU_RATIONALSCHWELLEN",list(jae_zaehler=b$wert$zaehler,jae_nenner=b$wert$nenner,jahresumsatz_eur="0"),f)
stopifnot(identical(a$wert,list(zaehler="1",nenner="2")),identical(b$wert,list(zaehler="250",nenner="1")),identical(size$wert,list(kleinst=FALSE,klein=FALSE,kmu=FALSE,smc_groessenrahmen=TRUE)))
a$wert$zaehler <- "999"
stopifnot(a$rechenschritte[[1L]]$wert$zaehler=="1",identical(data,before))
large <- berechne_regel("JAE_RATIONALSUMME",list(beitrag_links_zaehler="9007199254740993",beitrag_links_nenner="9007199254740994",beitrag_rechts_zaehler="1",beitrag_rechts_nenner="9007199254740994"),f)
stopifnot(identical(large$wert,list(zaehler="1",nenner="1")))
cat("Two rational composition and exactness tests passed\n")
