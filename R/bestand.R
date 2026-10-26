# Bestandsfristen nach Artikel 111(1), (3), (4).
pruefe_bestandsfrist <- function(fallgruppe, stichtag, ereignisse, quellenfassung) {
  if (.textskalar(fallgruppe) && fallgruppe %in% c("HOCHRISIKO_ANHANG_I", "HOCHRISIKO_ANHANG_III", "HOCHRISIKO_DOPPELT")) return(.pruefe_hochrisikobestand(fallgruppe, stichtag, ereignisse, quellenfassung))
  gruppen <- list(
    GROSS_IT_ANHANG_X = list(grenze = "2027-08-02", frist = "2030-12-31", namen = c("inverkehrbringen", "inbetriebnahme"), fundstelle = "ART_111/1"),
    GPAI_MODELL = list(grenze = "2025-08-02", frist = "2027-08-02", namen = "inverkehrbringen", fundstelle = "ART_111/3"),
    SYNTHETISCHE_AUSGABEN_ART_50_2 = list(grenze = "2026-08-02", frist = "2026-12-02", namen = "inverkehrbringen", fundstelle = "ART_111/4"))
  fassungen <- list(EUAIACT_2024_08_01 = "2024-08-01", EUAIACT_2026_07_27 = "2026-07-27")
  ergebnis <- .umschlag("AIA_111_BESTANDSFRIST", list(fallgruppe = fallgruppe, stichtag = stichtag, ereignisse = ereignisse), quellenfassung)
  ergebnis$regelversion <- "0.1.0"
  ergebnis$ergebnistyp <- "OBJEKT"
  fehler <- character()
  if (!.textskalar(quellenfassung) || !quellenfassung %in% names(fassungen)) fehler <- c(fehler, "Quellenfassung f\u00fcr diese Regel nicht verf\u00fcgbar")
  if (!.fehlend(fallgruppe) && (!.textskalar(fallgruppe) || !fallgruppe %in% names(gruppen) || (fallgruppe == "SYNTHETISCHE_AUSGABEN_ART_50_2" && identical(quellenfassung, "EUAIACT_2024_08_01")))) fehler <- c(fehler, "Fallgruppe in dieser Quellenfassung nicht verf\u00fcgbar")
  datum <- NULL
  if (!.fehlend(stichtag)) {
    datum <- tryCatch(.iso_datum(stichtag), error = function(e) NULL)
    if (is.null(datum)) fehler <- c(fehler, "Ung\u00fcltiger stichtag") else if (.textskalar(quellenfassung) && quellenfassung %in% names(fassungen) && datum < .iso_datum(fassungen[[quellenfassung]])) fehler <- c(fehler, "Stichtag liegt vor Inkrafttreten der gew\u00e4hlten Quellenfassung")
  }
  daten <- if (is.null(ereignisse)) stats::setNames(list(), character()) else ereignisse
  objekt <- function(x) is.list(x) && (length(x) == 0 || (!is.null(names(x)) && all(nzchar(names(x))) && !anyDuplicated(names(x))))
  if (!objekt(daten)) fehler <- c(fehler, "ereignisse muss ein Objekt sein") else {
    if (any(!names(daten) %in% c("inverkehrbringen", "inbetriebnahme"))) fehler <- c(fehler, "Unbekanntes Ereignisfeld")
    for (name in c("inverkehrbringen", "inbetriebnahme")) {
      ereignis <- daten[[name]]
      if (is.null(ereignis)) next
      if (!objekt(ereignis) || any(!names(ereignis) %in% c("erfolgt", "datum"))) {
        fehler <- c(fehler, paste0("Ung\u00fcltiges Ereignisobjekt: ", name))
        next
      }
      erfolgt <- ereignis$erfolgt
      zeitpunkt <- ereignis$datum
      if (!.fehlend(erfolgt) && !(is.logical(erfolgt) && length(erfolgt) == 1)) fehler <- c(fehler, paste0("Ung\u00fcltiger Ereignisstatus: ", name))
      if (!.fehlend(zeitpunkt)) {
        if (!identical(erfolgt, TRUE)) fehler <- c(fehler, paste0("Ereignisdatum verlangt erfolgt=true: ", name))
        ereignisdatum <- tryCatch(.iso_datum(zeitpunkt), error = function(e) NULL)
        if (is.null(ereignisdatum)) fehler <- c(fehler, paste0("Ung\u00fcltiges Ereignisdatum: ", name)) else if (!is.null(datum) && ereignisdatum > datum) fehler <- c(fehler, paste0("Ereignis nach Stichtag: ", name))
      }
    }
  }
  if (length(fehler)) {
    ergebnis$hinweise <- as.list(fehler)
    return(ergebnis)
  }
  fehlend <- character()
  if (.fehlend(fallgruppe)) fehlend <- c(fehlend, "fallgruppe")
  if (.fehlend(stichtag)) fehlend <- c(fehlend, "stichtag")
  ergebnis$anwendbarkeit <- "UNBEKANNT"
  ergebnis$entscheidungsstatus <- "UNBESTIMMT"
  ergebnis$status <- "EINGABE_FEHLT"
  if (length(fehlend)) {
    ergebnis$fehlende_angaben <- ergebnis$entscheidungsrelevante_luecken <- as.list(fehlend)
    return(ergebnis)
  }
  gruppe <- gruppen[[fallgruppe]]
  werte <- list()
  schritte <- list()
  for (name in gruppe$namen) {
    ereignis <- daten[[name]]
    erfolgt <- ereignis$erfolgt
    zeitpunkt <- ereignis$datum
    if (.fehlend(erfolgt)) erfolgt <- NULL
    if (.fehlend(zeitpunkt)) zeitpunkt <- NULL
    wert <- NULL
    if (identical(erfolgt, FALSE)) wert <- FALSE else if (identical(erfolgt, TRUE) && !is.null(zeitpunkt)) wert <- .iso_datum(zeitpunkt) < .iso_datum(gruppe$grenze) else fehlend <- c(fehlend, paste0("ereignisse.", name, ".", if (is.null(erfolgt)) "erfolgt" else "datum"))
    werte <- c(werte, list(wert))
    schritte <- c(schritte, list(list(operation = "EREIGNIS_VOR_BESTANDSGRENZE", ereignis = name, erfolgt = erfolgt, datum = zeitpunkt, bestandsgrenze = gruppe$grenze, wert = wert)))
  }
  bestand <- if (any(vapply(werte, isTRUE, logical(1)))) TRUE else if (any(vapply(werte, is.null, logical(1)))) NULL else FALSE
  lage <- if (is.null(bestand)) "UNBESTIMMT" else "KEINE_BESTANDSFRIST"
  if (isTRUE(bestand)) lage <- if (datum < .iso_datum(gruppe$frist)) "VOR_FRISTTAG" else if (datum == .iso_datum(gruppe$frist)) "FRISTTAG" else "NACH_FRISTTAG"
  ergebnis$wert <- list(bestand = bestand, erfuellungsfrist = if (isTRUE(bestand)) gruppe$frist else NULL, friststatus = lage)
  ergebnis$status <- if (is.null(bestand)) "EINGABE_FEHLT" else "AUSGEWERTET"
  ergebnis$entscheidungsstatus <- if (is.null(bestand)) "UNBESTIMMT" else "ENTSCHIEDEN"
  ergebnis$fehlende_angaben <- as.list(fehlend)
  ergebnis$entscheidungsrelevante_luecken <- if (is.null(bestand)) as.list(fehlend) else list()
  ergebnis$entscheidungsschritte <- c(schritte, list(list(operation = "BESTAND_ALTERNATIVE", wert = bestand), list(operation = "FESTER_ERFUELLUNGSTERMIN", stichtag = stichtag, fristtag = gruppe$frist, friststatus = lage)))
  ergebnis$annahmen <- list("Fallgruppe ausdr\u00fccklich qualifiziert; Ereignisse gelten zum Stichtag")
  ergebnis$hinweise <- list("Artikel 2, Artikel 5 und tats\u00e4chliche Pflichterf\u00fcllung separat pr\u00fcfen", "Keine Wochenendverschiebung gesetzlicher fester Termine; Artikel 111 Absatz 2 nicht enthalten")
  ergebnis$nachweise <- list(list(art = "RECHTSQUELLE", fundstelle = gruppe$fundstelle, quellenfassung = quellenfassung))
  ergebnis
}
