# Composite periods: calendar corrections once, explicit F007 start profiles.
berechne_periodenfrist <- function(ereignisdatum,anzahl,einheit,modus,kalender=NULL,monatsbruch=NULL,beginnkonvention=NULL,beginnbegruendung=NULL,quellenfassung) {
  inputs <- list(ereignisdatum=ereignisdatum,anzahl=anzahl,einheit=einheit,modus=modus,kalender=kalender,monatsbruch=monatsbruch,beginnkonvention=beginnkonvention,beginnbegruendung=beginnbegruendung)
  out <- .umschlag("EU_1182_71_GESAMTPERIODE",inputs,quellenfassung)
  out$regelversion <- "0.1.0"; out$ergebnistyp <- "DATUM"; out$einheit <- "KALENDERTAG"
  if (!identical(quellenfassung,"EUAIACT_2026_07_27")) {out$hinweise<-list("Quellenfassung fuer diese Regel nicht verfuegbar");return(out)}
  errors <- character(); event <- NULL
  if (!is.null(ereignisdatum)) {
    event <- tryCatch(.iso_datum(ereignisdatum),error=function(e) NULL)
    if(is.null(event)) errors<-c(errors,"Gueltiges Ereignisdatum YYYY-MM-DD erforderlich")
  }
  if (!is.null(anzahl) && (!.ganze_zahl(anzahl) || anzahl<0 || anzahl>1000000)) errors<-c(errors,"anzahl muss eine ganze Zahl zwischen 0 und 1000000 sein")
  if (!is.null(einheit) && (!.textskalar(einheit) || !einheit %in% c("WOCHE","MONAT","JAHR"))) errors<-c(errors,"Gesamtperiodenvertrag erfordert WOCHE, MONAT oder JAHR")
  if (!is.null(modus) && (!.textskalar(modus) || !modus %in% c("FRIST","FESTER_TERMIN","INKRAFTTRETEN","RUECKWAERTS","VERFAHREN_1755"))) errors<-c(errors,"Unzulaessiger Gesamtperiodenmodus")
  if (!is.null(beginnkonvention) && (!.textskalar(beginnkonvention) || !beginnkonvention %in% c("EREIGNISTAG","BEGINNTAG","VORTAG_DES_BEGINNS"))) errors<-c(errors,"Unzulaessige Beginnkonvention")
  if (!is.null(beginnbegruendung) && (!.textskalar(beginnbegruendung) || !nzchar(trimws(beginnbegruendung)))) errors<-c(errors,"Nichtleere lokale Begruendung der Beginnkonvention erforderlich")
  if (!identical(modus,"VERFAHREN_1755") && (!is.null(beginnkonvention) || !is.null(beginnbegruendung))) errors<-c(errors,"Beginnprofil nur im Modus VERFAHREN_1755 zulaessig")
  if (!is.null(kalender)) {
    check<-berechne_frist("2000-01-01",1L,"TAG",modus="FESTER_TERMIN",kalender=kalender,quellenfassung=quellenfassung)
    if(check$status=="EINGABE_UNGUELTIG") errors<-c(errors,"Ungueltiger Kalender")
  }
  fraction<-NULL; fraction_missing<-character()
  if (!is.null(monatsbruch)) {
    if(!identical(einheit,"MONAT")) errors<-c(errors,"Monatsbruch nur mit Einheit MONAT zulaessig")
    if(!is.list(monatsbruch) || length(monatsbruch)!=2L || !setequal(names(monatsbruch),c("zaehler","nenner"))) errors<-c(errors,"Monatsbruch benoetigt genau zaehler und nenner als Ganzzahltexte") else {
      check<-berechne_regel("EU_1182_MONATSBRUCH_TAGE",list(monatsbruch_zaehler=monatsbruch$zaehler,monatsbruch_nenner=monatsbruch$nenner),quellenfassung)
      if(check$status=="EINGABE_UNGUELTIG") errors<-c(errors,"Ungueltiger echter Monatsbruch") else if(check$status=="EINGABE_FEHLT") fraction_missing<-paste0("monatsbruch.",c("zaehler","nenner")[vapply(monatsbruch[c("zaehler","nenner")],is.null,logical(1))]) else fraction<-check$wert
    }
  }
  if(!length(errors) && !is.null(anzahl) && anzahl==0 && !length(fraction_missing) && (is.null(fraction) || fraction$zaehler=="0")) errors<-c(errors,"Gesamtperiode muss positiv sein")
  if(length(errors)) {out$hinweise<-as.list(errors);return(out)}
  needs_calendar<-!is.null(modus) && modus %in% c("FRIST","RUECKWAERTS","VERFAHREN_1755")
  keys<-c("ereignisdatum","anzahl","einheit","modus")
  missing<-c(keys[vapply(inputs[keys],is.null,logical(1))],fraction_missing)
  if(needs_calendar && is.null(kalender)) missing<-c(missing,"kalender")
  if(length(missing)) {
    out$status<-"EINGABE_FEHLT";out$anwendbarkeit<-"UNBEKANNT";out$entscheidungsstatus<-"UNBESTIMMT";out$fehlende_angaben<-as.list(sort(missing));out$entscheidungsrelevante_luecken<-as.list(sort(missing));return(out)
  }
  out$nachweise<-list(list(art="RECHTSQUELLE",fundstelle="31971R1182/ART_2_BIS_5",quellenfassung=quellenfassung))
  if(!is.null(monatsbruch)) out$nachweise<-c(out$nachweise,list(list(art="RECHTSQUELLE",fundstelle="31971R1182/ART_3/2/d",quellenfassung=quellenfassung)))
  if(modus=="VERFAHREN_1755") {
    out$nachweise<-c(out$nachweise,list(list(art="RECHTSQUELLE",fundstelle="32026R1755/ART_12/2",quellenfassung=quellenfassung)))
    if(is.null(beginnkonvention) || is.null(beginnbegruendung)) {
      out$status<-"REGEL_UNGEKLAERT";out$anwendbarkeit<-"UNBEKANNT";out$entscheidungsstatus<-"UNBESTIMMT";out$hinweise<-list("F007: Langperiodenbeginn erfordert ausdruecklich begruendete Nutzervorgabe");return(out)
    }
    out$nutzervorgaben<-list(beginnkonvention=beginnkonvention,beginnbegruendung=beginnbegruendung)
  }
  if(!is.null(fraction) && fraction$nenner!="1") {
    out$status<-"REGEL_UNGEKLAERT";out$anwendbarkeit<-"UNBEKANNT";out$entscheidungsstatus<-"UNBESTIMMT";out$hinweise<-list("Monatsbruch ergibt nichtganze Tage; untertaegige Endkonvention nicht qualifiziert. Keine Rundung.");out$rechenschritte<-list(list(operation="EXAKTER_MONATSBRUCH_TAGE",wert=fraction));return(out)
  }
  calculate<-function() {
    anchor<-count_anchor<-event;steps<-list()
    if(modus=="VERFAHREN_1755") {
      first<-berechne_frist(ereignisdatum,1L,"ARBEITSTAG",modus="FESTER_TERMIN",kalender=kalender,quellenfassung=quellenfassung)
      if(first$status!="AUSGEWERTET") {transfer <- first[c("status","anwendbarkeit","entscheidungsstatus","hinweise","fehlende_angaben","entscheidungsrelevante_luecken")]; out[names(transfer)] <- transfer; return(out)}
      begin<-.iso_datum(first$wert);count_anchor<-begin-1
      anchor<-if(beginnkonvention=="EREIGNISTAG") event else if(beginnkonvention=="BEGINNTAG") begin else count_anchor
      steps<-list(list(operation="QUALIFIZIERTER_VERFAHRENSBEGINN",beginn=.datumtext(begin),rechenanker=.datumtext(anchor),zaehlanker=.datumtext(count_anchor)))
    }
    direction<-if(modus=="RUECKWAERTS") -1 else 1
    whole<-if(einheit=="WOCHE") anchor+direction*anzahl*7 else .monatsschritt(anchor,direction*anzahl*if(einheit=="JAHR") 12 else 1)
    if(whole<.iso_datum("0001-01-01") || whole>.iso_datum("9999-12-31")) stop("DATUMSBEREICH")
    steps<-c(steps,list(list(operation="GANZE_KALENDERPERIODE",anzahl=anzahl,einheit=einheit,wert=.datumtext(whole))))
    extra<-if(is.null(fraction)) 0L else as.integer(fraction$zaehler)
    nominal<-whole+direction*extra
    if(nominal<.iso_datum("0001-01-01") || nominal>.iso_datum("9999-12-31")) stop("DATUMSBEREICH")
    if(!is.null(fraction)) steps<-c(steps,list(list(operation="MONATSBRUCH_NACH_GANZEN_MONATEN",tage=fraction,wert=.datumtext(nominal))))
    if(needs_calendar) {
      distance<-max(if(anzahl>0 || extra>=2) 2 else 1,direction*as.numeric(nominal-count_anchor))
      final<-berechne_frist(.datumtext(count_anchor),distance,"TAG",modus=if(direction<0) "RUECKWAERTS" else "FRIST",kalender=kalender,quellenfassung=quellenfassung)
      if(final$status!="AUSGEWERTET") {transfer <- final[c("status","anwendbarkeit","entscheidungsstatus","hinweise","fehlende_angaben","entscheidungsrelevante_luecken")]; out[names(transfer)] <- transfer; return(out)}
      end<-final$wert;steps<-c(steps,list(list(operation="ARBEITSTAGSREGELN_NUR_GESAMTPERIODE",wert=end)))
    } else end<-.datumtext(nominal)
    list(end=end,steps=steps)
  }
  result<-tryCatch(calculate(),error=function(e) {if(conditionMessage(e)=="DATUMSBEREICH") NULL else stop(e)})
  if(!is.null(result$status)) return(result)
  if(is.null(result)) {out$hinweise<-list("Gesamtperiode ausserhalb Datumsbereich oder ohne positive Laufzeit ab qualifiziertem Beginn");return(out)}
  out$wert<-result$end;out$status<-"AUSGEWERTET";out$anwendbarkeit<-"UNBEKANNT";out$entscheidungsstatus<-"ENTSCHIEDEN";out$rechenschritte<-result$steps
  out$annahmen<-list("Normmodus, Beginnprofil und Monatsbruch ausdruecklich qualifiziert; kein Systemdatum")
  out$hinweise<-list(if(modus=="INKRAFTTRETEN") "Beginn des Ergebnistags" else "Ablauf des Ergebnistags","Keine Aussage zur unverzueglichen Handlungspflicht oder allgemeinen Anwendbarkeit")
  out
}
