# Native Article 111(2) event and deadline evaluation.
.pruefe_hochrisikobestand <- function(fallgruppe, stichtag, ereignisse, quellenfassung) {
  fassungen <- list(EUAIACT_2024_08_01 = "2024-08-01", EUAIACT_2026_07_27 = "2026-07-27")
  ergebnis <- .umschlag("AIA_111_BESTANDSFRIST", list(fallgruppe=fallgruppe, stichtag=stichtag, ereignisse=ereignisse), quellenfassung)
  ergebnis$regelversion <- "0.1.0"
  ergebnis$ergebnistyp <- "OBJEKT"
  fehler <- character()
  if (!.textskalar(quellenfassung) || !quellenfassung %in% names(fassungen)) fehler <- c(fehler, "Quellenfassung f\u00fcr diese Regel nicht verf\u00fcgbar")
  datum <- NULL
  if (!.fehlend(stichtag)) {
    datum <- tryCatch(.iso_datum(stichtag), error=function(e) NULL)
    if (is.null(datum)) fehler <- c(fehler, "Ung\u00fcltiger stichtag") else if (.textskalar(quellenfassung) && quellenfassung %in% names(fassungen) && datum < .iso_datum(fassungen[[quellenfassung]])) fehler <- c(fehler, "Stichtag liegt vor Inkrafttreten der gew\u00e4hlten Quellenfassung")
  }
  objekt <- function(x) is.list(x) && (length(x)==0 || (!is.null(names(x)) && all(nzchar(names(x))) && !anyDuplicated(names(x))))
  daten <- if (is.null(ereignisse)) list() else ereignisse
  namen <- c("inverkehrbringen", "inbetriebnahme")
  flags <- c("aenderungshistorie_vollstaendig", "fuer_behoerden_bestimmt", "anbieter_oder_betreiber")
  boolpruefung <- function(wert, pfad) {
    if (!.fehlend(wert) && !(is.logical(wert) && length(wert)==1L)) fehler <<- c(fehler, paste0("Boolescher Wert erforderlich: ", pfad))
  }
  datumspruefung <- function(wert, pfad) {
    if (!.fehlend(wert)) {
      tag <- tryCatch(.iso_datum(wert), error=function(e) NULL)
      if (is.null(tag)) fehler <<- c(fehler, paste0("Ung\u00fcltiges Ereignisdatum: ", pfad)) else if (!is.null(datum) && tag > datum) fehler <<- c(fehler, paste0("Ereignis nach Stichtag: ", pfad))
    }
  }
  if (!objekt(daten)) fehler <- c(fehler, "ereignisse muss ein Objekt sein") else {
    if (any(!names(daten) %in% c(namen, flags, "aenderungen"))) fehler <- c(fehler, "Unbekanntes Ereignisfeld")
    for (name in namen) {
      e <- daten[[name]]
      if (is.null(e)) next
      if (!objekt(e) || any(!names(e) %in% c("erfolgt", "datum"))) {
        fehler <- c(fehler, paste0("Ung\u00fcltiges Ereignisobjekt: ", name)); next
      }
      boolpruefung(e$erfolgt, paste0(name, ".erfolgt"))
      if (!.fehlend(e$datum) && !identical(e$erfolgt, TRUE)) fehler <- c(fehler, paste0("Ereignisdatum verlangt erfolgt=true: ", name))
      datumspruefung(e$datum, name)
    }
    for (name in flags) boolpruefung(daten[[name]], name)
    aenderungen <- daten$aenderungen
    if (!is.null(aenderungen)) {
      if (!is.list(aenderungen) || !is.null(names(aenderungen))) fehler <- c(fehler, "aenderungen muss eine Liste sein") else {
        for (i in seq_along(aenderungen)) {
          e <- aenderungen[[i]]; pfad <- paste0("aenderungen[", i-1L, "]")
          if (!objekt(e) || any(!names(e) %in% c("datum", "erheblich"))) {
            fehler <- c(fehler, paste0("Ung\u00fcltiges \u00c4nderungsobjekt: ", pfad)); next
          }
          boolpruefung(e$erheblich, paste0(pfad, ".erheblich"))
          datumspruefung(e$datum, pfad)
        }
      }
    }
  }
  if (length(fehler)) { ergebnis$hinweise <- as.list(fehler); return(ergebnis) }
  ergebnis$anwendbarkeit <- "UNBEKANNT"
  ergebnis$entscheidungsstatus <- "UNBESTIMMT"
  ergebnis$status <- "EINGABE_FEHLT"
  if (is.null(datum)) {
    ergebnis$fehlende_angaben <- ergebnis$entscheidungsrelevante_luecken <- list("stichtag")
    return(ergebnis)
  }
  fehlend <- character()
  unbekannt <- function(pfad) { fehlend <<- union(fehlend, pfad); list(wert=NULL, luecken=pfad) }
  fakt <- function(wert, pfad) if (.fehlend(wert)) unbekannt(pfad) else list(wert=wert, luecken=character())
  bekannt <- function(wert) list(wert=wert, luecken=character())
  verknuepfen <- function(werte, und=FALSE) {
    entscheidend <- !und
    if (any(vapply(werte, function(x) identical(x$wert, entscheidend), logical(1)))) return(bekannt(entscheidend))
    if (any(vapply(werte, function(x) is.null(x$wert), logical(1)))) return(list(wert=NULL, luecken=unique(unlist(lapply(werte, function(x) x$luecken), use.names=FALSE))))
    bekannt(!entscheidend)
  }
  oeffentlich <- fakt(daten$fuer_behoerden_bestimmt, "ereignisse.fuer_behoerden_bestimmt")
  rolle <- fakt(daten$anbieter_oder_betreiber, "ereignisse.anbieter_oder_betreiber")
  grenzen <- if (quellenfassung == "EUAIACT_2024_08_01") "2026-08-02" else if (fallgruppe == "HOCHRISIKO_ANHANG_I") "2028-08-02" else if (fallgruppe == "HOCHRISIKO_ANHANG_III") "2027-12-02" else c("2027-12-02", "2028-08-02")
  kandidaten <- list(); relevante <- character()
  for (grenze in grenzen) {
    ereigniswerte <- list()
    for (name in namen) {
      e <- daten[[name]]
      erfolgt <- fakt(e$erfolgt, paste0("ereignisse.", name, ".erfolgt"))
      wert <- if (isTRUE(erfolgt$wert)) {
        if (.fehlend(e$datum)) unbekannt(paste0("ereignisse.", name, ".datum")) else bekannt(e$datum < grenze)
      } else erfolgt
      ereigniswerte[[length(ereigniswerte)+1L]] <- wert
    }
    bestand <- verknuepfen(ereigniswerte)
    wechsel <- list()
    if (stichtag >= grenze) {
      aenderungen <- daten$aenderungen
      if (is.null(aenderungen)) wechsel <- list(unbekannt("ereignisse.aenderungen")) else {
        for (i in seq_along(aenderungen)) {
          e <- aenderungen[[i]]; pfad <- paste0("ereignisse.aenderungen[", i-1L, "]")
          erheblich <- fakt(e$erheblich, paste0(pfad, ".erheblich"))
          tag <- if (.fehlend(e$datum)) unbekannt(paste0(pfad, ".datum")) else bekannt(e$datum >= grenze)
          wechsel[[length(wechsel)+1L]] <- verknuepfen(list(erheblich, tag), und=TRUE)
        }
      }
      if (!identical(daten$aenderungshistorie_vollstaendig, TRUE)) wechsel[[length(wechsel)+1L]] <- unbekannt(if (identical(daten$aenderungshistorie_vollstaendig, FALSE)) "ereignisse.aenderungen" else "ereignisse.aenderungshistorie_vollstaendig")
    }
    aenderung <- verknuepfen(wechsel)
    ausgeloest <- verknuepfen(list(bestand, aenderung), und=TRUE)
    behoerde <- verknuepfen(list(bestand, oeffentlich, rolle), und=TRUE)
    for (wert in list(bestand, ausgeloest, behoerde)) relevante <- union(relevante, wert$luecken)
    lage <- if (is.null(behoerde$wert)) "UNBESTIMMT" else "KEINE_BEHOERDENFRIST"
    if (isTRUE(behoerde$wert)) lage <- if (stichtag < "2030-08-02") "VOR_FRISTTAG" else if (stichtag == "2030-08-02") "FRISTTAG" else "NACH_FRISTTAG"
    kandidaten[[length(kandidaten)+1L]] <- list(bestand=bestand$wert, aenderungsvorbehalt_ausgeloest=ausgeloest$wert, behoerdenfrist_betroffen=behoerde$wert, erfuellungsfrist=if (isTRUE(behoerde$wert)) "2030-08-02" else NULL, friststatus=lage)
  }
  wert <- kandidaten[[1L]]; abweichend <- character()
  for (feld in names(wert)) {
    if (any(vapply(kandidaten, function(k) !identical(k[[feld]], kandidaten[[1L]][[feld]]), logical(1)))) {
      abweichend <- c(abweichend, feld)
      wert[feld] <- list(if (feld == "friststatus") "UNBESTIMMT" else NULL)
    }
  }
  hinweise <- c("Artikel 2, Artikel 5, Artikel 113 und tats\u00e4chliche Pflichterf\u00fcllung separat pr\u00fcfen", "Kein Bestand bedeutet kein Privileg aus Absatz 2; keine Aussage zur allgemeinen Anwendbarkeit")
  if (length(abweichend)) hinweise <- c(hinweise, "Offene Rechtsfrage F004: unterschiedliche Bestandsstichtage bei doppelter Hochrisikoeinstufung")
  ergebnis$wert <- wert
  ergebnis$status <- if (length(abweichend)) "REGEL_UNGEKLAERT" else if (length(relevante)) "EINGABE_FEHLT" else "AUSGEWERTET"
  ergebnis$entscheidungsstatus <- if (length(abweichend) || length(relevante)) "UNBESTIMMT" else "ENTSCHIEDEN"
  ergebnis$fehlende_angaben <- as.list(sort(fehlend, method="radix"))
  ergebnis$entscheidungsrelevante_luecken <- as.list(sort(relevante, method="radix"))
  ergebnis$hinweise <- as.list(hinweise)
  ergebnis$annahmen <- list("Hochrisiko, Akteursbezug und Ausschluss Artikel 111 Absatz 1 qualifiziert", "Ereignisse betreffen denselben Typ und dasselbe Modell bis zum Stichtag")
  ergebnis$entscheidungsschritte <- lapply(seq_along(grenzen), function(i) list(operation="HOCHRISIKO_BESTANDSWEG", bestandsgrenze=grenzen[[i]], stichtag=stichtag, wert=kandidaten[[i]]))
  if (length(abweichend)) ergebnis$entscheidungsschritte <- c(ergebnis$entscheidungsschritte, list(list(operation="OFFENE_RECHTSFRAGE", frage_id="F004", abweichende_felder=as.list(abweichend))))
  ergebnis$nachweise <- list(list(art="RECHTSQUELLE", fundstelle="ART_111/2", quellenfassung=quellenfassung))
  ergebnis
}
