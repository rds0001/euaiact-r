# Explicit whole-hour periods, independent of POSIXct/system timezone.
.stunden_utc_text <- function(sekunden) {
  maximal <- 3652059 * 86400
  if (sekunden < 0 || sekunden >= maximal) stop("Datumsbereich")
  tage <- floor(sekunden / 86400); rest <- sekunden %% 86400
  datum <- .iso_datum("0001-01-01") + tage
  stunde <- as.integer(floor(rest / 3600)); rest <- rest %% 3600
  minute <- as.integer(floor(rest / 60)); sekunde <- as.integer(rest %% 60)
  sprintf("%sT%02d:%02d:%02dZ", .datumtext(datum),stunde,minute,sekunde)
}
.stundenfrist <- function(ereignisdatum,anzahl,modus,kalender,quellenfassung) {
  eingaben <- list(ereignisdatum=ereignisdatum,anzahl=anzahl,einheit="STUNDE",modus=modus,kalender=kalender)
  ergebnis <- .umschlag("EU_1182_71_STUNDE",eingaben,quellenfassung)
  ergebnis$regelversion <- "0.1.0"; ergebnis$ergebnistyp <- "OBJEKT"; ergebnis$einheit <- "STUNDE"
  if (!identical(quellenfassung,"EUAIACT_2026_07_27")) {
    ergebnis$hinweise <- list("Quellenfassung fuer diese Regel nicht verfuegbar"); return(ergebnis)
  }
  fehler <- character(); teile <- NULL
  if (!is.null(ereignisdatum)) {
    teile <- .zeitpunktteile(ereignisdatum)
    if (is.null(teile)) fehler <- c(fehler,"Gueltiger Ereigniszeitpunkt mit explizitem Offset erforderlich")
  }
  if (!is.null(anzahl) && (!.ganze_zahl(anzahl) || anzahl<1 || anzahl>3652059*24)) fehler <- c(fehler,"anzahl muss eine positive ganze Stundenzahl im Datumsbereich sein")
  if (!is.null(modus) && !identical(modus,"FRIST")) fehler <- c(fehler,"Stundenvertrag unterstuetzt nur den allgemeinen Modus FRIST")
  if (!is.null(kalender)) {
    test <- berechne_frist("2000-01-01",1L,"TAG","FESTER_TERMIN",kalender,quellenfassung)
    if (identical(test$status,"EINGABE_UNGUELTIG")) fehler <- c(fehler,unlist(test$hinweise,use.names=FALSE))
  }
  if (length(fehler)) { ergebnis$hinweise <- as.list(fehler); return(ergebnis) }
  felder <- c("ereignisdatum","anzahl","modus")
  fehlend <- felder[vapply(eingaben[felder],is.null,logical(1))]
  if (length(fehlend)) {
    ergebnis$status <- "EINGABE_FEHLT"; ergebnis$anwendbarkeit <- "UNBEKANNT"; ergebnis$entscheidungsstatus <- "UNBESTIMMT"
    ergebnis$fehlende_angaben <- as.list(fehlend); ergebnis$entscheidungsrelevante_luecken <- as.list(fehlend); return(ergebnis)
  }
  beginn <- teile$ganz-as.integer(substr(ereignisdatum,15L,16L))*60-as.integer(substr(ereignisdatum,18L,19L))+3600
  ende <- beginn+anzahl*3600
  texte <- tryCatch(list(.stunden_utc_text(beginn),.stunden_utc_text(ende)),error=function(e)NULL)
  if (is.null(texte)) { ergebnis$hinweise <- list("Zeitraum ausserhalb des unterstuetzten ISO-Datumsbereichs"); return(ergebnis) }
  ergebnis$nachweise <- list(list(art="RECHTSQUELLE",fundstelle="31971R1182/ART_2_BIS_5",quellenfassung=quellenfassung))
  if (anzahl>=48) {
    ergebnis$status <- "REGEL_UNGEKLAERT"; ergebnis$anwendbarkeit <- "UNBEKANNT"; ergebnis$entscheidungsstatus <- "UNBESTIMMT"
    ergebnis$entscheidungsschritte <- list(list(operation="OFFENE_RECHTSFRAGE",frage_id="F011",wert=NULL))
    ergebnis$hinweise <- list("F011: Wechselwirkung von Stundenperioden ab48Stunden mit mindestens zwei Arbeitstagen offen; kein rechtliches Fristende ausgegeben.")
    return(ergebnis)
  }
  ergebnis$wert <- list(beginn=texte[[1L]],ende_exklusiv=texte[[2L]])
  ergebnis$status <- "AUSGEWERTET"; ergebnis$anwendbarkeit <- "UNBEKANNT"; ergebnis$entscheidungsstatus <- "ENTSCHIEDEN"
  ergebnis$rechenschritte <- list(list(operation="EREIGNISSTUNDE_AUSSCHLIESSEN",ereigniszeitpunkt=ereignisdatum,beginn=texte[[1L]]),list(operation="VOLLE_STUNDEN",anzahl=anzahl,ende_exklusiv=texte[[2L]]))
  ergebnis$annahmen <- list("Allgemeine Stundenfrist nach1182/71; keine automatische Wahl fuer spezielle AI-Act-Hoechstgrenzen")
  ergebnis$hinweise <- list("Endgrenze exklusiv; an diesem Zeitpunkt ist die Frist abgelaufen","Keine Wochenend-Endverschiebung bei Stundenfristen","Zusaetzliche Pflicht zum unverzueglichen Handeln separat")
  ergebnis
}
