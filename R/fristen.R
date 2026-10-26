# Datumbezogene Regeln aus VO 1182/71 mit ausdruecklichem Nutzerkalender.

.iso_datum <- function(text) {
  if (!.textskalar(text) || !grepl("^[0-9]{4}-[0-9]{2}-[0-9]{2}\\z", text, perl = TRUE)) stop("Datum")
  wert <- tryCatch(as.Date(text, format = "%Y-%m-%d"), error = function(e) NA)
  if (is.na(wert) || as.integer(substr(text, 1L, 4L)) < 1L || .datumtext(wert) != text) stop("Datum")
  wert
}

.datumtext <- function(datum) {
  sprintf("%04d-%02d-%02d", as.integer(format(datum, "%Y")),
    as.integer(format(datum, "%m")), as.integer(format(datum, "%d")))
}

.monatsschritt <- function(start, monate) {
  index <- as.integer(format(start, "%Y")) * 12 + as.integer(format(start, "%m")) - 1 + monate
  jahr <- index %/% 12
  monat <- index %% 12 + 1
  if (jahr < 1 || jahr > 9999) stop("DATUMSBEREICH")
  tage_im_monat <- c(31L, 28L, 31L, 30L, 31L, 30L, 31L, 31L, 30L, 31L, 30L, 31L)
  if (jahr %% 4 == 0 && (jahr %% 100 != 0 || jahr %% 400 == 0)) tage_im_monat[[2L]] <- 29L
  tag <- min(as.integer(format(start, "%d")), tage_im_monat[[monat]])
  .iso_datum(sprintf("%04d-%02d-%02d", as.integer(jahr), as.integer(monat), tag))
}

berechne_frist <- function(ereignisdatum, anzahl, einheit, modus, kalender = NULL, quellenfassung) {
  if (identical(einheit,"STUNDE")) return(.stundenfrist(ereignisdatum,anzahl,modus,kalender,quellenfassung))
  eingaben <- list(ereignisdatum = ereignisdatum, anzahl = anzahl, einheit = einheit, modus = modus, kalender = kalender)
  ergebnis <- .umschlag("EU_1182_71_DATUM", eingaben, quellenfassung)
  ergebnis$regelversion <- "0.1.0"
  ergebnis$ergebnistyp <- "DATUM"
  ergebnis$einheit <- "KALENDERTAG"
  if (!identical(quellenfassung, "EUAIACT_2026_07_27")) {
    ergebnis$hinweise <- list("Quellenfassung f\u00fcr diese Regel nicht verf\u00fcgbar")
    return(ergebnis)
  }
  fehlend <- names(eingaben)[vapply(eingaben, .fehlend, logical(1))]
  fehler <- character()
  start <- NULL
  if (!.fehlend(ereignisdatum)) {
    start <- tryCatch(.iso_datum(ereignisdatum), error = function(e) NULL)
    if (is.null(start)) fehler <- c(fehler, "Ung\u00fcltiges ereignisdatum")
  }
  if (!.fehlend(anzahl) && (!.ganze_zahl(anzahl) || anzahl < 1)) {
    fehler <- c(fehler, "anzahl muss eine positive ganze Zahl sein")
  }
  if (!.fehlend(einheit) && (!.textskalar(einheit) || !einheit %in% c("TAG", "ARBEITSTAG", "WOCHE", "MONAT", "JAHR"))) {
    fehler <- c(fehler, "Unzul\u00e4ssige Fristeinheit")
  }
  if (!.fehlend(modus) && (!.textskalar(modus) || !modus %in% c("FRIST", "FESTER_TERMIN", "INKRAFTTRETEN", "RUECKWAERTS", "VERFAHREN_1755_TAGE"))) {
    fehler <- c(fehler, "Unzul\u00e4ssiger Fristmodus")
  }
  if (identical(modus, "VERFAHREN_1755_TAGE") && !.fehlend(einheit) && (!.textskalar(einheit) || !einheit %in% c("TAG", "ARBEITSTAG"))) fehler <- c(fehler, "Verfahrensmodus unterst\u00fctzt nur TAG und ARBEITSTAG")
  von <- bis <- NULL
  feiertage <- character()
  if (!.fehlend(kalender)) {
    if (!is.list(kalender) || length(kalender) != 4L || !setequal(names(kalender), c("von", "bis", "feiertage", "bezug"))) {
      fehler <- c(fehler, "Kalender ben\u00f6tigt genau von, bis, feiertage und bezug")
    } else {
      gueltig <- tryCatch({
        von <- .iso_datum(kalender$von)
        bis <- .iso_datum(kalender$bis)
        if (von > bis || !.textskalar(kalender$bezug) || !nzchar(trimws(kalender$bezug))) stop("Kalender")
        if (!is.list(kalender$feiertage) && !is.character(kalender$feiertage)) stop("Feiertage")
        tage <- lapply(kalender$feiertage, .iso_datum)
        if (anyDuplicated(kalender$feiertage) || any(vapply(tage, function(t) t < von || t > bis, logical(1)))) stop("Feiertage")
        feiertage <- vapply(tage, .datumtext, character(1))
        TRUE
      }, error = function(e) FALSE)
      if (!gueltig) fehler <- c(fehler, "Ung\u00fcltiger oder widerspr\u00fcchlicher Kalender")
    }
  }
  if (length(fehler)) {
    ergebnis$hinweise <- as.list(fehler)
    return(ergebnis)
  }
  kalender_noetig <- identical(modus, "RUECKWAERTS") || identical(modus, "FRIST") || identical(modus, "VERFAHREN_1755_TAGE") || identical(einheit, "ARBEITSTAG")
  relevant <- fehlend[fehlend != "kalender" | kalender_noetig]
  if (length(relevant)) {
    ergebnis$status <- "EINGABE_FEHLT"
    ergebnis$anwendbarkeit <- "UNBEKANNT"
    ergebnis$entscheidungsstatus <- "UNBESTIMMT"
    ergebnis$fehlende_angaben <- as.list(fehlend)
    ergebnis$entscheidungsrelevante_luecken <- as.list(relevant)
    return(ergebnis)
  }
  arbeitstag <- function(tag) {
    if (tag < von || tag > bis) stop("KALENDERLUECKE")
    wochentag <- as.integer(format(tag, "%u"))
    wochentag < 6L && !.datumtext(tag) %in% feiertage
  }
  erhoehte_datum <- function(tag) {
    neu <- tag + 1
    if (neu > .iso_datum("9999-12-31")) stop("DATUMSBEREICH")
    neu
  }
  vermindertes_datum <- function(tag) {
    neu <- tag - 1
    if (neu < .iso_datum("0001-01-01")) stop("DATUMSBEREICH")
    neu
  }
  richtung <- if (modus == "RUECKWAERTS") -1 else 1
  naechstes_datum <- if (richtung == 1) erhoehte_datum else vermindertes_datum
  schritte <- list()
  berechnung <- tryCatch({
    if (modus == "VERFAHREN_1755_TAGE") {
      beginn <- erhoehte_datum(start)
      while (!arbeitstag(beginn)) beginn <- erhoehte_datum(beginn)
      start <- beginn - 1
      schritte <- list(list(operation = "VERFAHRENSBEGINN_ERSTER_ARBEITSTAG", ereignisdatum = ereignisdatum, beginn = .datumtext(beginn), rechenanker = .datumtext(start)))
    }
    if (anzahl > if (richtung == 1) as.numeric(.iso_datum("9999-12-31") - start) else as.numeric(start - .iso_datum("0001-01-01"))) stop("DATUMSBEREICH")
    if (einheit %in% c("TAG", "WOCHE")) {
      ende <- start + richtung * anzahl * if (einheit == "WOCHE") 7 else 1
    } else if (einheit == "ARBEITSTAG") {
      ende <- start
      gezaehlt <- 0L
      while (gezaehlt < anzahl) {
        ende <- naechstes_datum(ende)
        if (arbeitstag(ende)) gezaehlt <- gezaehlt + 1L
      }
    } else {
      monate <- richtung * anzahl * if (einheit == "JAHR") 12 else 1
      ende <- .monatsschritt(start, monate)
    }
    if (ende > .iso_datum("9999-12-31") || ende < .iso_datum("0001-01-01")) stop("DATUMSBEREICH")
    schritte <- c(schritte, list(list(operation = "KALENDARISCHES_ENDE", wert = .datumtext(ende))))
    mindesttage <- if (einheit %in% c("TAG", "ARBEITSTAG")) anzahl >= 2 else TRUE
    if (modus == "RUECKWAERTS") {
      arbeitstage <- 0L
      tag <- start
      if (mindesttage) {
        while (tag > ende && arbeitstage < 2L) {
          tag <- vermindertes_datum(tag)
          if (arbeitstag(tag)) arbeitstage <- arbeitstage + 1L
        }
        while (arbeitstage < 2L) {
          ende <- vermindertes_datum(ende)
          if (arbeitstag(ende)) arbeitstage <- arbeitstage + 1L
        }
      }
      schritte <- c(schritte, list(list(operation = "RUECKWAERTS_MINDESTARBEITSTAGE", wert = .datumtext(ende))))
    }
    if (modus %in% c("FRIST", "VERFAHREN_1755_TAGE")) {
      while (!arbeitstag(ende)) ende <- erhoehte_datum(ende)
      if (mindesttage) {
        tag <- start
        arbeitstage <- 0L
        while (tag < ende && arbeitstage < 2L) {
          tag <- erhoehte_datum(tag)
          if (arbeitstag(tag)) arbeitstage <- arbeitstage + 1L
        }
        while (arbeitstage < 2L) {
          ende <- erhoehte_datum(ende)
          if (arbeitstag(ende)) arbeitstage <- arbeitstage + 1L
        }
      }
      schritte <- c(schritte, list(list(operation = "ARBEITSTAGSREGELN", wert = .datumtext(ende))))
    }
    list(wert = .datumtext(ende), schritte = schritte)
  }, error = function(e) {
    if (!conditionMessage(e) %in% c("DATUMSBEREICH", "KALENDERLUECKE")) stop(e)
    list(fehler = conditionMessage(e))
  })
  if (!is.null(berechnung$fehler)) {
    if (berechnung$fehler == "KALENDERLUECKE") {
      ergebnis$status <- "EINGABE_FEHLT"
      ergebnis$anwendbarkeit <- "UNBEKANNT"
      ergebnis$entscheidungsstatus <- "UNBESTIMMT"
      ergebnis$fehlende_angaben <- list("kalenderdeckung")
      ergebnis$entscheidungsrelevante_luecken <- list("kalenderdeckung")
      ergebnis$hinweise <- list("Der \u00fcbergebene Kalender deckt nicht alle ben\u00f6tigten Tage ab")
    } else {
      ergebnis$hinweise <- list("Zeitraum au\u00dferhalb des unterst\u00fctzten ISO-Datumsbereichs")
    }
    return(ergebnis)
  }
  ergebnis$wert <- berechnung$wert
  ergebnis$status <- "AUSGEWERTET"
  ergebnis$anwendbarkeit <- "UNBEKANNT"
  ergebnis$entscheidungsstatus <- "ENTSCHIEDEN"
  ergebnis$rechenschritte <- berechnung$schritte
  ergebnis$fehlende_angaben <- as.list(fehlend)
  ergebnis$annahmen <- list(if (kalender_noetig) "Expliziter Nutzerkalender" else "Kalenderunabh\u00e4ngiger Datumsmodus", "Fristberechnung; konkrete rechtliche Anwendbarkeit separat pr\u00fcfen")
  ergebnis$hinweise <- list(if (modus == "INKRAFTTRETEN") "Beginn des Ergebnistags" else "Ablauf des Ergebnistags",
    "Eine zus\u00e4tzliche Pflicht zum unverz\u00fcglichen Handeln wird nicht bewertet")
  ergebnis$nachweise <- list(list(art = "RECHTSQUELLE", fundstelle = "31971R1182/ART_2_BIS_5", quellenfassung = quellenfassung))
  if (modus == "VERFAHREN_1755_TAGE") {
    ergebnis$nachweise <- c(ergebnis$nachweise, list(list(art = "RECHTSQUELLE", fundstelle = "32026R1755/ART_012/2", quellenfassung = quellenfassung)))
    ergebnis$hinweise <- c(ergebnis$hinweise, list("Sondermodus nur f\u00fcr einschl\u00e4giges GPAI-Kommissionsverfahren"))
  }
  ergebnis
}
