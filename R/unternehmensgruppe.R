# Qualified graph components and disjoint data sets; native exact arithmetic.
aggregiere_unternehmensgruppe <- function(stamm_id,unternehmen,beziehungen,datenkreise,groesse,bezugsperiode,kreis_vollstaendig,quellenfassung) {
 inputs <- list(stamm_id=stamm_id,unternehmen=unternehmen,beziehungen=beziehungen,datenkreise=datenkreise,groesse=groesse,bezugsperiode=bezugsperiode,kreis_vollstaendig=kreis_vollstaendig)
 out <- .umschlag("UNTERNEHMENSGRUPPE_AGGREGATION",inputs,quellenfassung)
 out$regelversion <- "0.1.0";out$ergebnistyp <- "OBJEKT"
 scalar <- function(x) is.character(x)&&length(x)==1L&&!is.na(x)
 identity <- function(x) scalar(x)&&grepl("^[A-Za-z0-9][A-Za-z0-9_.:-]{0,127}$",x,perl=TRUE)
 fail <- function(msg) stop(structure(list(message=msg,call=NULL),class=c("gruppenfehler","error","condition")))
 object <- function(x,keys) is.list(x)&&!is.null(names(x))&&!anyDuplicated(names(x))&&setequal(names(x),keys)
 array <- function(x,label) {
  if(!(is.list(x)&&is.null(names(x))) && !(is.character(x)&&is.null(names(x)))) fail(paste0(label,": Liste mit hoechstens10000Eintraegen erforderlich"))
  if(length(x)>10000L) fail(paste0(label,": Liste mit hoechstens10000Eintraegen erforderlich"))
 }
 nat <- function(x) scalar(x)&&grepl("^(0|[1-9][0-9]{0,255})$",x,perl=TRUE)
 decimal <- function(x) {
  if(!scalar(x)||nchar(x)>256L||!grepl("^(0|[1-9][0-9]*)(\\.[0-9]+)?$",x,perl=TRUE)) fail("Nichtnegativer exakter Dezimaltext mit hoechstens256Zeichen erforderlich")
  parts <- strsplit(x,".",fixed=TRUE)[[1]]
  .bruch_kuerzen(.nat_normal(paste0(parts,collapse="")),paste0("1",if(length(parts)==2L) strrep("0",nchar(parts[[2]])) else ""))
 }
 value <- function(x) {
  if(is.null(x)) return(NULL)
  if(groesse!="JAE") return(decimal(x))
  if(!object(x,c("zaehler","nenner"))) fail("JAE verlangt zaehler/nenner als Ganzzahltexte")
  if(!nat(x$zaehler)||!nat(x$nenner)||x$nenner=="0") fail("Ungueltiger JAE-Bruch")
  .bruch_kuerzen(x$zaehler,x$nenner)
 }
 zero <- list(zaehler="0",nenner="1");one <- list(zaehler="1",nenner="1")
 malnat <- function(a,b) .nichtnegative_dezimalrechnung(a,b,TRUE)
 calc <- function(a,b,mul=FALSE) .rational_rechnen(list(operation=if(mul) "RATIONALE_MULTIPLIKATION" else "RATIONALE_ADDITION",zaehler_links="an",nenner_links="ad",zaehler_rechts="bn",nenner_rechts="bd"),list(an=a$zaehler,ad=a$nenner,bn=b$zaehler,bd=b$nenner))
 show <- function(x) {
  if(groesse=="JAE") return(x)
  div <- .nat_divmod(x$zaehler,x$nenner);whole <- div$quotient;rest <- div$rest
  digits <- character()
  while(rest!="0") {
   div <- .nat_divmod(paste0(rest,"0"),x$nenner);digits <- c(digits,div$quotient);rest <- div$rest
  }
  if(length(digits)) paste0(whole,".",paste0(digits,collapse="")) else whole
 }
 evaluate <- function() {
  if(!identical(quellenfassung,"EUAIACT_2026_07_27")) fail("Quellenfassung fuer diese Regel nicht verfuegbar")
  if(!identity(stamm_id)||!identity(bezugsperiode)||!scalar(groesse)||!groesse %in% c("JAE","UMSATZ_EUR","BILANZ_EUR")) fail("Stamm-ID, Bezugsperiode oder Groesse ungueltig")
  if(!is.null(kreis_vollstaendig)&&!(is.logical(kreis_vollstaendig)&&length(kreis_vollstaendig)==1L&&!is.na(kreis_vollstaendig))) fail("kreis_vollstaendig verlangt Boolean oder null")
  array(unternehmen,"unternehmen");array(beziehungen,"beziehungen");array(datenkreise,"datenkreise")
  if(!length(unternehmen)||!all(vapply(unternehmen,identity,logical(1)))||anyDuplicated(unlist(unternehmen))||!stamm_id %in% unlist(unternehmen)) fail("Unternehmens-IDs muessen eindeutig sein und Stamm-ID enthalten")
  ids <- unlist(unternehmen,use.names=FALSE)
  parent <- new.env(hash=TRUE,parent=emptyenv());for(id in ids) parent[[id]] <- id
  root <- function(x) {while(parent[[x]]!=x) {parent[[x]] <- parent[[parent[[x]]]];x <- parent[[x]]};x}
  partners <- list()
  for(edge in beziehungen) {
   if(!is.list(edge)||!scalar(edge$art)||!edge$art %in% c("VERBUND","PARTNER")) fail("Ungueltige qualifizierte Beziehung")
   keys <- c("von","nach","art",if(edge$art=="PARTNER") "quote")
   if(!object(edge,keys)||!identity(edge$von)||!identity(edge$nach)||!edge$von %in% ids||!edge$nach %in% ids||edge$von==edge$nach) fail("Beziehungsfelder oder Unternehmensverweise ungueltig")
   if(edge$art=="VERBUND") {
    ab <- sort(c(root(edge$von),root(edge$nach)),method="radix");parent[[ab[[2]]]] <- ab[[1]]
   } else {
    q <- decimal(edge$quote)
    if(.nat_vergleich(malnat(q$zaehler,"4"),q$nenner)<0L||.nat_vergleich(q$zaehler,q$nenner)>0L) fail("Qualifizierte Partnerquote muss zwischen0.25und1 liegen")
    partners[[length(partners)+1L]] <- list(a=edge$von,b=edge$nach,q=q)
   }
  }
  components <- setNames(vapply(ids,root,character(1)),ids);own <- components[[stamm_id]]
  weights <- setNames(lapply(unique(components),function(x) zero),unique(components));weights[[own]] <- one
  pairs <- character()
  for(edge in partners) {
   a <- components[[edge$a]];b <- components[[edge$b]]
   # Separator cannot appear in the public ASCII identifier contract.
   pair <- paste0(sort(c(a,b),method="radix"),collapse="|")
   if(a==b||pair %in% pairs) fail("Partnerbeziehung innerhalb Verbund oder mehrfach zwischen Verbundgruppen; Gruppenquote zuvor eindeutig qualifizieren")
   pairs <- c(pairs,pair)
   if(a==own) weights[[b]] <- edge$q else if(b==own) weights[[a]] <- edge$q
  }
  coverage <- character();segments <- character();circles <- character();missing <- character();total <- zero;details <- list()
  orderkeys <- vapply(datenkreise,function(x) if(is.list(x)&&scalar(x$kreis_id)) x$kreis_id else "",character(1))
  for(record in datenkreise[order(orderkeys,method="radix")]) {
   keys <- c("kreis_id","unternehmen_ids","wert",if(groesse=="JAE") "personensegmente")
   if(!object(record,keys)||!identity(record$kreis_id)||record$kreis_id %in% circles) fail("Datenkreisfelder oder eindeutige Kreis-ID ungueltig")
   circles <- c(circles,record$kreis_id);members <- record$unternehmen_ids
   array(members,"unternehmen_ids")
   if(!length(members)||!all(vapply(members,function(x) scalar(x)&&x %in% ids,logical(1)))||anyDuplicated(unlist(members))||any(unlist(members) %in% coverage)) fail("Datenkreise ueberlappen oder enthalten ungueltige Unternehmens-IDs")
   members <- unlist(members,use.names=FALSE);coverage <- c(coverage,members)
   ws <- lapply(members,function(x) weights[[components[[x]]]])
   if(!all(vapply(ws,function(x) identical(x,ws[[1]]),logical(1)))) fail("Gemischte Hinzurechnungsquoten in einem Datenkreis; qualifizierte disjunkte Aufteilung erforderlich")
   w <- ws[[1]];v <- value(record$wert)
   if(groesse=="JAE") {
    array(record$personensegmente,"personensegmente")
    for(segment in record$personensegmente) {
     if(!object(segment,c("person_id","segment_id"))||!all(vapply(segment,identity,logical(1)))) fail("Ungueltige Personen-/Segmentidentitaet")
     pair <- paste0(segment$person_id,"|",segment$segment_id)
     if(pair %in% segments) fail("Personensegment mehrfach erfasst; keine doppelte Personalhinzurechnung")
     segments <- c(segments,pair)
    }
    if(!is.null(v)&&v$zaehler!="0"&&!length(record$personensegmente)) fail("Positive JAE erfordern ein identifiziertes qualifiziertes Personensegmentinventar")
   }
   selected <- w$zaehler!="0"
   if(selected&&is.null(v)) missing <- c(missing,paste0("datenkreise.",record$kreis_id,".wert"))
   contribution <- if(is.null(v)) NULL else calc(v,w,TRUE)
   if(!is.null(contribution)) {
    total <- calc(total,contribution)
    if(nchar(total$zaehler)>4096L||nchar(total$nenner)>4096L) fail("Zwischenergebnis ueberschreitet4096Ziffern; Datenkreis fachlich aufteilen")
   }
   details[[length(details)+1L]] <- list(operation="DATENKREIS_GEWICHTEN",kreis_id=record$kreis_id,unternehmen_ids=as.list(sort(members,method="radix")),gewicht=w,beruecksichtigt=selected,beitrag=if(!is.null(contribution)) show(contribution) else if(!selected) show(zero) else NULL)
  }
  for(x in sort(ids,method="radix")) if(weights[[components[[x]]]]$zaehler!="0"&&!x %in% coverage) missing <- c(missing,paste0("datenkreis_fuer.",x))
  if(!isTRUE(kreis_vollstaendig)) missing <- c(missing,"kreis_vollstaendig")
  missing <- sort(unique(missing),method="radix")
  out$status <- if(length(missing)) "EINGABE_FEHLT" else "AUSGEWERTET";out$anwendbarkeit <- "UNBEKANNT";out$entscheidungsstatus <- if(length(missing)) "UNBESTIMMT" else "ENTSCHIEDEN";out$einheit <- groesse
  out["wert"] <- list(if(length(missing)) NULL else list(summe=show(total)))
  out$fehlende_angaben <- as.list(missing);out$entscheidungsrelevante_luecken <- as.list(missing)
  out$entscheidungsschritte <- lapply(sort(ids,method="radix"),function(x) list(operation="VERBUND_UND_PARTNERGEWICHT",unternehmen_id=x,verbund_id=components[[x]],gewicht=weights[[components[[x]]]]))
  out$rechenschritte <- details
  out$annahmen <- list("Beziehungstypen, gruppenbezogene Partnerquoten, Perioden-/Einheitenbasis und disjunkte konsolidierte Datenkreise vorgelagert qualifiziert")
  out$hinweise <- list("Keine automatische Beziehungseinstufung, Konsolidierungsbuchung oder KMU-/SMC-Statusentscheidung; F008/F014 und Investorenausnahmen separat","Personensegment-IDs identifizieren bereits qualifizierte disjunkte Arbeitsanteile; unterschiedliche Arbeitsverhaeltnisse nicht anhand des Personennamens zusammenfassen")
  out$nachweise <- lapply(c("32003H0361/ANH/ART_6","32025H1099/ANH/6"),function(x) list(art="RECHTSQUELLE",fundstelle=x,quellenfassung=quellenfassung))
  out
 }
 tryCatch(evaluate(),gruppenfehler=function(e) {out$hinweise <- list(conditionMessage(e));out})
}
