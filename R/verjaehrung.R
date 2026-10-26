# Qualified whole-day limitation timelines; no invented legal start rule.
.verj_unterbrechungen <- list(
  GPAI_VERFOLGUNG=c("DOKUMENTENANFRAGE","MODELLZUGANG","DIALOGEINLADUNG","VERFAHRENSEROEFFNUNG","SONSTIGE_KOMMISSIONSERMITTLUNG"),
  GPAI_VOLLSTRECKUNG=c("MITGETEILTE_BETRAGSAENDERUNG","MITGETEILTE_AENDERUNGSABLEHNUNG","KOMMISSIONSVOLLSTRECKUNG","STAATLICHE_VOLLSTRECKUNG_AUF_KOMMISSIONSERSUCHEN"),
  KI_BUERO_VERFOLGUNG="FOLGEAKT_75D3_ZU_QUALIFIZIEREN", KI_BUERO_VOLLSTRECKUNG="FOLGEAKT_75D3_ZU_QUALIFIZIEREN")
.verj_hemmungen <- list(GPAI_VERFOLGUNG="EUGH_ANHAENGIGKEIT",
  GPAI_VOLLSTRECKUNG=c("ZAHLUNGSAUFSCHUB","EUGH_VOLLSTRECKUNGSHEMMUNG","NATIONALE_GERICHTLICHE_VOLLSTRECKUNGSHEMMUNG"),
  KI_BUERO_VERFOLGUNG="FOLGEAKT_75D3_ZU_QUALIFIZIEREN", KI_BUERO_VOLLSTRECKUNG="FOLGEAKT_75D3_ZU_QUALIFIZIEREN")
.verj_objekt <- function(x,felder) is.list(x) && !is.object(x) && length(x)==length(felder) && !anyDuplicated(names(x)) && setequal(names(x),felder)
.verj_tag <- function(x) tryCatch(as.numeric(.iso_datum(x)),error=function(e) stop("Gueltiges Datum YYYY-MM-DD erforderlich",call.=FALSE))
.verj_text <- function(x) .datumtext(as.Date(x,origin="1970-01-01"))
.verj_vereinigen <- function(intervalle) {
  if (!length(intervalle)) return(list())
  ord <- order(vapply(intervalle,function(x)x[[1L]],numeric(1)),vapply(intervalle,function(x)x[[2L]],numeric(1)))
  out <- list()
  for (x in intervalle[ord]) {
    if (x[[1L]]==x[[2L]]) next
    n <- length(out)
    if (n && x[[1L]]<=out[[n]][[2L]]) out[[n]][[2L]] <- max(out[[n]][[2L]],x[[2L]]) else out[[n+1L]] <- x
  }
  out
}

berechne_verjaehrung <- function(verfahren,ereignisdatum,unterbrechungen,hemmungen,stichtag,
    kalender,quellenfassung,beginnkonvention=NULL,beginnbegruendung=NULL) {
  inputs <- list(verfahren=verfahren,ereignisdatum=ereignisdatum,unterbrechungen=unterbrechungen,
    hemmungen=hemmungen,stichtag=stichtag,kalender=kalender,beginnkonvention=beginnkonvention,beginnbegruendung=beginnbegruendung)
  result <- .umschlag("VERJAEHRUNGSVERLAUF",inputs,quellenfassung)
  result$regelversion <- "0.1.0"; result$ergebnistyp <- "OBJEKT"; result$einheit <- "KALENDERTAG"
  if (!identical(quellenfassung,"EUAIACT_2026_07_27")) { result$hinweise <- list("Quellenfassung fuer diese Regel nicht verfuegbar"); return(result) }
  required <- c("verfahren","ereignisdatum","unterbrechungen","hemmungen","stichtag","kalender")
  missing <- required[vapply(inputs[required],is.null,logical(1))]
  if (length(missing)) {
    result$status <- "EINGABE_FEHLT"; result$anwendbarkeit <- "UNBEKANNT";result$entscheidungsstatus <- "UNBESTIMMT"
    result$fehlende_angaben <- as.list(missing);result$entscheidungsrelevante_luecken <- as.list(missing);return(result)
  }
  problem <- tryCatch({
    if (!.textskalar(verfahren) || !verfahren %in% names(.verj_unterbrechungen)) stop("Unzulaessiges Verjaehrungsverfahren")
    start <- .verj_tag(ereignisdatum);cutoff <- .verj_tag(stichtag)
    if (start>cutoff) stop("Ereignisdatum liegt nach Stichtag")
    if (!is.list(unterbrechungen) || is.object(unterbrechungen) || !is.list(hemmungen) || is.object(hemmungen) || max(length(unterbrechungen),length(hemmungen))>1000L) stop("Ereignisse muessen Listen mit jeweils hoechstens1000 Eintraegen sein")
    if (!.verj_objekt(kalender,c("von","bis","feiertage","bezug"))) stop("Kalender benoetigt genau von, bis, feiertage und bezug")
    first <- .verj_tag(kalender$von);last <- .verj_tag(kalender$bis)
    if (first>last || !.textskalar(kalender$bezug) || !nzchar(trimws(kalender$bezug)) || !is.list(kalender$feiertage) || is.object(kalender$feiertage)) stop("Ungueltiger Kalender")
    holidays <- vapply(kalender$feiertage,.verj_tag,numeric(1))
    if (anyDuplicated(holidays) || any(holidays<first | holidays>last)) stop("Ungueltige Feiertagsliste")
    resets <- numeric()
    for (record in unterbrechungen) {
      if (!.verj_objekt(record,c("datum","art")) || !.textskalar(record$art) || !record$art %in% .verj_unterbrechungen[[verfahren]]) stop("Unzulaessiger Unterbrechungseintrag fuer dieses Verfahren")
      day <- .verj_tag(record$datum)
      if (day>cutoff) stop("Unterbrechung liegt nach Stichtag")
      resets <- c(resets,day)
    }
    intervals <- list();ongoing <- list()
    for (index in seq_along(hemmungen)) {
      record <- hemmungen[[index]]
      if (!.verj_objekt(record,c("von","bis_exklusiv","art")) || !.textskalar(record$art) || !record$art %in% .verj_hemmungen[[verfahren]]) stop("Unzulaessiger Hemmungseintrag fuer dieses Verfahren")
      a <- .verj_tag(record$von);b <- if (is.null(record$bis_exklusiv)) cutoff else .verj_tag(record$bis_exklusiv)
      if (a>cutoff || b>cutoff || b<a || (a==b && !is.null(record$bis_exklusiv))) stop("Ungueltige oder zukuenftige Hemmungsgrenzen")
      intervals[[length(intervals)+1L]] <- c(a,b)
      if (is.null(record$bis_exklusiv)) ongoing[[length(ongoing)+1L]] <- c(index-1L,a)
    }
    if (!is.null(beginnkonvention) && (!.textskalar(beginnkonvention) || !beginnkonvention %in% c("EREIGNISTAG","BEGINNTAG","VORTAG_DES_BEGINNS"))) stop("Unzulaessige Beginnkonvention")
    if (!is.null(beginnbegruendung) && (!.textskalar(beginnbegruendung) || !nzchar(trimws(beginnbegruendung)))) stop("Beginnbegruendung muss nichtleerer Text sein")
    if (!startsWith(verfahren,"GPAI_") && (!is.null(beginnkonvention) || !is.null(beginnbegruendung))) stop("1755-Beginnkonvention ist im75c-Verfahren unzulaessig")
    NULL
  },error=function(e)conditionMessage(e))
  if (!is.null(problem)) {result$hinweise <- list(problem);return(result)}
  sources <- if (verfahren=="GPAI_VERFOLGUNG") c("32026R1755/ART_10","32026R1755/ART_12") else if (verfahren=="GPAI_VOLLSTRECKUNG") c("32026R1755/ART_11","32026R1755/ART_12") else c("ART_075c/8","ART_075d/3")
  result$anwendbarkeit <- "UNBEKANNT"
  result$nachweise <- lapply(sources,function(s)list(art="RECHTSQUELLE",fundstelle=s,quellenfassung=quellenfassung))
  result$annahmen <- list("Vollstaendige lokal qualifizierte Ereignisakte; keine automatische rechtliche Ereigniserkennung","Hemmungen sind halboffene Intervalle qualifizierter ganzer Kalendertage","Ablauf_vor_stichtag bezieht sich auf den Beginn des Stichtagsdatums")
  if (startsWith(verfahren,"GPAI_") && (is.null(beginnkonvention) || is.null(beginnbegruendung))) {
    result$status <- "REGEL_UNGEKLAERT";result$entscheidungsstatus <- "UNBESTIMMT";result$hinweise <- list("F007: Beginn langer1755-Perioden ungeklart; ausdruecklich begruendete Nutzervorgabe erforderlich");return(result)
  }
  if (startsWith(verfahren,"KI_BUERO_") && (length(resets) || length(intervals))) {
    result$status <- "REGEL_UNGEKLAERT";result$entscheidungsstatus <- "UNBESTIMMT";result$hinweise <- list("Konkrete75d(3)-Folgeregeln fuer Unterbrechung/Hemmung fehlen; keine Uebernahme1755");return(result)
  }
  if (startsWith(verfahren,"GPAI_")) result$nutzervorgaben <- list(beginnkonvention=beginnkonvention,beginnbegruendung=beginnbegruendung)
  convention <- if (is.null(beginnkonvention)) "EREIGNISTAG" else beginnkonvention
  merged <- .verj_vereinigen(intervals)
  ends <- vapply(merged,function(x)x[[2L]],numeric(1))
  prefix <- c(0,cumsum(vapply(merged,function(x)x[[2L]]-x[[1L]],numeric(1))))
  covered <- function(day) {
    index <- findInterval(day,ends)
    total <- prefix[[index+1L]]
    if(index<length(merged) && merged[[index+1L]][[1L]]<day) total <- total+day-merged[[index+1L]][[1L]]
    total
  }
  working <- function(day) {
    if (day<first || day>last) stop("KALENDERLUECKE")
    ((day+3)%%7)<5 && !day %in% holidays
  }
  shift <- function(day) {while(!working(day)) day<-day+1;day}
  anchor <- function(event) {
    if (convention=="EREIGNISTAG") return(event)
    begin <- shift(event+1)
    if(convention=="BEGINNTAG") begin else begin-1
  }
  deadline <- function(event,years,horizon) {
    origin <- anchor(event);text <- .verj_text(origin)
    year <- as.integer(substr(text,1,4))+years;month <- as.integer(substr(text,6,7));day <- as.integer(substr(text,9,10))
    if (year>9999L) stop("Datumsbereich0001bis9999 ueberschritten")
    leap <- year%%4L==0L && (year%%100L!=0L || year%%400L==0L)
    days <- c(31L,if(leap)29L else 28L,31L,30L,31L,30L,31L,31L,30L,31L,30L,31L)
    raw <- .verj_tag(sprintf("%04d-%02d-%02d",year,month,min(day,days[[month]])))
    count_from <- if(convention=="BEGINNTAG") origin else origin+1
    if(horizon<=raw) {
      raw <- raw+max(0,covered(horizon)-covered(count_from))
      return(shift(raw))
    }
    for (interval in merged) {
      if(interval[[1L]]>=horizon) break
      a <- max(interval[[1L]],count_from);b <- min(interval[[2L]],horizon)
      if (b<=a) next
      adjusted <- shift(raw)
      if (raw<a && a<=adjusted) stop("OFFENE_ENDVERSCHIEBUNG")
      if (a>raw) break
      raw <- raw+b-a
    }
    shift(raw)
  }
  problem <- tryCatch({
    working(start)
    trace <- list();current <- start
    for(event in sort(unique(resets))) {
      end <- deadline(current,5L,event);limit <- if(verfahren=="GPAI_VERFOLGUNG") deadline(start,10L,event) else NULL
      effective <- if(is.null(limit)) end else min(end,limit)
      if(event<start) state <- "VOR_AUSGANGSEREIGNIS_OHNE_NEUSTART" else if(event>effective) state <- "NACH_ABLAUF_OHNE_WIEDERBELEBUNG" else {current<-event;state<-"FUENFJAHRESFRIST_NEU"}
      trace[[length(trace)+1L]] <- list(ereignisdatum=.verj_text(event),wirkung=state)
    }
    end <- deadline(current,5L,cutoff);limit <- if(verfahren=="GPAI_VERFOLGUNG") deadline(start,10L,cutoff) else NULL
    effective <- if(is.null(limit)) end else min(end,limit)
    relevant_open <- vapply(ongoing,function(x)x[[2L]]<=effective && cutoff>=x[[2L]] && (is.null(limit)||x[[2L]]<=limit),logical(1))
    indices <- vapply(ongoing[relevant_open],function(x)as.integer(x[[1L]]),integer(1))
    value <- list(verfahren=verfahren,letztes_neustartereignis=.verj_text(current),
      regulaeres_fristende=if(length(indices))NULL else .verj_text(end),
      hoechstfristende=if(length(indices)||is.null(limit))NULL else .verj_text(limit),
      wirksames_fristende=if(length(indices))NULL else .verj_text(effective),
      ablauf_vor_stichtag=if(length(indices))FALSE else effective<cutoff,
      laufende_hemmung=length(indices)>0L,
      vereinigte_bekannte_hemmungstage=as.integer(sum(vapply(merged,function(x)x[[2L]]-x[[1L]],numeric(1)))),
      hemmungs_berechnungsstand_bis_exklusiv=stichtag,unterbrechungsschritte=trace)
    gaps <- if(length(indices))as.list(paste0("hemmungen[",indices,"].bis_exklusiv")) else list()
    result$wert <- value;result$status <- if(length(gaps))"EINGABE_FEHLT" else "AUSGEWERTET"
    result$entscheidungsstatus <- if(length(gaps))"UNBESTIMMT" else "ENTSCHIEDEN"
    result$fehlende_angaben <- gaps;result$entscheidungsrelevante_luecken <- gaps
    result$rechenschritte <- list(list(operation="VERJAEHRUNGSVERLAUF",wert=value))
    result$hinweise <- list("Nur unter dokumentierter Ereignis- und Beginnqualifikation; kein behoerdlicher Verjaehrungsbescheid")
    NULL
  },error=function(e)conditionMessage(e))
  if(!is.null(problem)) {
    if(problem=="KALENDERLUECKE") {
      result$status<-"EINGABE_FEHLT";result$entscheidungsstatus<-"UNBESTIMMT";result$fehlende_angaben<-list("kalender.deckung");result$entscheidungsrelevante_luecken<-list("kalender.deckung");result$hinweise<-list("Kalender deckt erforderlichen Zeitraum nicht")
    } else if(problem=="OFFENE_ENDVERSCHIEBUNG") {
      result$status<-"REGEL_UNGEKLAERT";result$entscheidungsstatus<-"UNBESTIMMT";result$hinweise<-list("Hemmungsbeginn waehrend Endverschiebung: rechtliche Anrechnung offen")
    } else {
      result$status<-"EINGABE_UNGUELTIG";result["anwendbarkeit"]<-list(NULL);result["entscheidungsstatus"]<-list(NULL);result$hinweise<-list(problem)
    }
  }
  result
}
