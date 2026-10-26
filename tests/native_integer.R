library(euaiact)
f <- "EUAIACT_2026_07_27"
a <- berechne_regel("PANEL_EU_MINDESTZAHL",list(mitgliederzahl=60),f)
b <- berechne_regel("PANEL_EU_MINDESTZAHL",list(mitgliederzahl=60L),f)
stopifnot(a$wert==48L,a$status=="AUSGEWERTET",identical(jsonlite::toJSON(a,auto_unbox=TRUE,null="null"),jsonlite::toJSON(b,auto_unbox=TRUE,null="null")))
a <- pruefe_tatbestand("DVO_0454_003_002_GROESSENGRENZE",list(anzahl_bestellter_panel_experten=60),f)
stopifnot(isTRUE(a$wert))
for (value in list(TRUE,"5",5.5,Inf,NaN,9007199254740992,5+0i)) {
  stopifnot(berechne_regel("PANEL_EU_MINDESTZAHL",list(mitgliederzahl=value),f)$status=="EINGABE_UNGUELTIG")
  stopifnot(berechne_frist("2026-01-01",value,"MONAT",modus="FESTER_TERMIN",quellenfassung=f)$status=="EINGABE_UNGUELTIG")
  stopifnot(berechne_frist("2026-01-01T12:30:00Z",value,"STUNDE",modus="FRIST",quellenfassung=f)$status=="EINGABE_UNGUELTIG")
}
for (unit in c("MONAT","STUNDE")) {
  start <- if(unit=="MONAT") "2026-01-31" else "2026-01-01T12:30:00Z"
  mode <- if(unit=="MONAT") "FESTER_TERMIN" else "FRIST"
  a <- berechne_frist(start,1,unit,modus=mode,quellenfassung=f)
  b <- berechne_frist(start,1L,unit,modus=mode,quellenfassung=f)
  stopifnot(a$status=="AUSGEWERTET",identical(jsonlite::toJSON(a,auto_unbox=TRUE,null="null"),jsonlite::toJSON(b,auto_unbox=TRUE,null="null")))
}
stopifnot(berechne_regel("AIA_075C_005_TAGESEINKOMMEN",list(qualifiziertes_durchschnittliches_tageseinkommen_eur=5),f)$status=="EINGABE_UNGUELTIG")
cat("Native integer contracts passed\n")
