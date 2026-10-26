# Exakte Dezimalrechnungen f\u00fcr die spezifizierten gesetzlichen Gr\u00f6\u00dfen.

.dezimaltext <- function(wert) {
  teile <- .dezimalteile(wert)
  paste0(if (teile$negativ) "-" else "", teile$ganz,
    if (nzchar(teile$bruch)) paste0(".", teile$bruch) else "")
}

.prozentanteil <- function(betrag, prozent) {
  # prozent ist hier eine paketinterne kleine ganze Zahl (1, 3, 5 oder 7).
  teile <- .dezimalteile(betrag)
  ziffern <- utf8ToInt(paste0(teile$ganz, teile$bruch)) - 48L
  ergebnis <- integer(length(ziffern))
  uebertrag <- 0L
  for (index in rev(seq_along(ziffern))) {
    produkt <- ziffern[[index]] * prozent + uebertrag
    ergebnis[[index]] <- produkt %% 10L
    uebertrag <- produkt %/% 10L
  }
  text <- paste0(if (uebertrag) as.character(uebertrag) else "", paste0(ergebnis, collapse = ""))
  dezimalstellen <- nchar(teile$bruch) + 2L
  text <- paste0(strrep("0", max(0L, dezimalstellen + 1L - nchar(text))), text)
  trennung <- nchar(text) - dezimalstellen
  ganz <- sub("^0+", "", substr(text, 1L, trennung))
  if (!nzchar(ganz)) ganz <- "0"
  .dezimaltext(paste0(ganz, ".", substr(text, trennung + 1L, nchar(text))))
}

.extremum <- function(werte, minimum = FALSE) {
  ergebnis <- werte[[1L]]
  for (wert in werte) {
    vergleich <- .dezimalvergleich(wert, ergebnis)
    if ((minimum && vergleich < 0L) || (!minimum && vergleich > 0L)) ergebnis <- wert
  }
  .dezimaltext(ergebnis)
}

.ziffern_zu_dezimal <- function(ziffern, nachkomma) {
  # Nichtnegative, bereits normalisierte Dezimalziffern, kleinste Stelle zuerst.
  text <- paste0(rev(ziffern), collapse = "")
  text <- paste0(strrep("0", max(0L, nachkomma + 1L - nchar(text))), text)
  trennung <- nchar(text) - nachkomma
  ganz <- sub("^0+", "", substr(text, 1L, trennung))
  if (!nzchar(ganz)) ganz <- "0"
  bruch <- if (nachkomma) sub("0+$", "", substr(text, trennung + 1L, nchar(text))) else ""
  paste0(ganz, if (nzchar(bruch)) paste0(".", bruch) else "")
}

.nichtnegative_dezimalrechnung <- function(a, b, multiplizieren = FALSE) {
  x <- .dezimalteile(a)
  y <- .dezimalteile(b)
  stopifnot(!x$negativ, !y$negativ)
  if (multiplizieren) {
    az <- rev(utf8ToInt(paste0(x$ganz, x$bruch)) - 48L)
    bz <- rev(utf8ToInt(paste0(y$ganz, y$bruch)) - 48L)
    z <- integer(length(az) + length(bz) + 1L)
    for (j in seq_along(bz)) {
      positionen <- seq_along(az) + j - 1L
      z[positionen] <- z[positionen] + az * bz[[j]]
    }
    stellen <- nchar(x$bruch) + nchar(y$bruch)
  } else {
    stellen <- max(nchar(x$bruch), nchar(y$bruch))
    az <- rev(utf8ToInt(paste0(x$ganz, x$bruch, strrep("0", stellen - nchar(x$bruch)))) - 48L)
    bz <- rev(utf8ToInt(paste0(y$ganz, y$bruch, strrep("0", stellen - nchar(y$bruch)))) - 48L)
    z <- integer(max(length(az), length(bz)) + 1L)
    z[seq_along(az)] <- az
    z[seq_along(bz)] <- z[seq_along(bz)] + bz
  }
  # Bei maximal 4096 Eingabezeichen bleiben alle ganzzahligen Akkumulatoren
  # weit unter dem R-Integerlimit; keine Binaer-Gleitkomma-Dezimalrechnung.
  for (i in seq_len(length(z) - 1L)) {
    z[[i + 1L]] <- z[[i + 1L]] + z[[i]] %/% 10L
    z[[i]] <- z[[i]] %% 10L
  }
  .ziffern_zu_dezimal(z, stellen)
}

berechne_regel <- function(regel_id, eingaben, quellenfassung) {
  ergebnis <- .umschlag(regel_id, eingaben, quellenfassung)
  if (!.textskalar(regel_id) || !regel_id %in% names(.katalog()) ||
      !is.null(.katalog()[[regel_id]]$ausdruck)) {
    ergebnis$hinweise <- list("Unbekannte Rechenregel-ID")
    return(ergebnis)
  }
  regel <- .katalog()[[regel_id]]
  ergebnis$regelversion <- regel$regelversion
  ergebnis$ergebnistyp <- if (is.null(regel$ergebnistyp)) "OBJEKT" else regel$ergebnistyp
  ergebnis["einheit"] <- list(regel$einheit)
  if (!identical(quellenfassung, regel$quellenfassung)) {
    ergebnis$hinweise <- list("Quellenfassung f\u00fcr diese Regel nicht verf\u00fcgbar")
    return(ergebnis)
  }
  fehler <- .eingabefehler(eingaben, regel$eingaben)
  if (length(fehler)) {
    ergebnis$hinweise <- as.list(fehler)
    return(ergebnis)
  }
  fehlend <- names(regel$eingaben)[vapply(names(regel$eingaben), function(name) .fehlend(eingaben[[name]]), logical(1))]
  relevant <- fehlend
  if (regel_id == "AIA_099_OBERGRENZE" && identical(eingaben$akteurklasse, "KEIN_UNTERNEHMEN")) {
    relevant <- setdiff(relevant, "weltweiter_vorjahresumsatz_eur")
  }
  if (identical(regel$operation,"WIDERRUF_WIRKSAMKEIT") && identical(eingaben$widerruf_spaeterer_tag_festgelegt,FALSE)) {
    relevant <- setdiff(relevant,"widerruf_festgelegter_tag")
  }
  wert <- NULL
  schritte <- list()
  if (!length(relevant)) {
    if (identical(regel$operation, "FESTE_DAUER")) {
      wert <- regel$dauer
      schritte <- list(list(operation = "FESTE_DAUER", wert = wert))
    } else if (isTRUE(regel$operation %in% c("RATIONALE_ADDITION","RATIONALE_MULTIPLIKATION","MONATSBRUCH_30_TAGE"))) {
      problem <- NULL
      wert <- tryCatch(.rational_rechnen(regel,eingaben),error=function(e) { problem <<- conditionMessage(e); NULL })
      if(!is.null(problem)) { ergebnis$hinweise <- list(problem); return(ergebnis) }
      schritte <- list(list(operation=regel$operation,wert=wert,rundung="KEINE"))
    } else if (identical(regel$operation,"WIDERRUF_WIRKSAMKEIT")) {
      wert <- tryCatch(.widerruf_wirksamkeit(eingaben),error=function(e)e)
      if (inherits(wert,"error")) {
        ergebnis$hinweise <- list(conditionMessage(wert))
        return(ergebnis)
      }
      schritte <- list(list(operation="WIDERRUF_WIRKSAMKEIT",wert=wert,endverschiebung="KEINE"))
    } else if (identical(regel$operation,"FESTER_PROZENTANTEIL")) {
      betrag <- eingaben[[regel$betragsfeld]]
      wert <- .prozentanteil(betrag,regel$prozent)
      schritte <- list(list(operation="FESTER_PROZENTANTEIL",operanden=list(betrag,regel$satz),wert=wert,rundung="KEINE"))
    } else if (identical(regel$operation, "WIEDERKEHRENDER_KALENDERTERMIN")) {
      index <- eingaben$evaluationszyklus_index;first <- regel$erster_termin;years <- regel$zyklus_jahre
      year <- as.integer(substr(first,1L,4L))+years*index
      wert <- paste0(sprintf("%04d",as.integer(year)),substr(first,5L,10L))
      schritte <- list(list(operation=regel$operation,erster_termin=first,zyklus_jahre=years,zyklus_index=index,wert=wert,endverschiebung="KEINE"))
    } else if (identical(regel$operation, "DATUM_KLEINER_GLEICH_FEST")) {
      links <- eingaben[[regel$datumsfeld]]; rechts <- regel$vergleichsdatum
      wert <- .iso_datum(links) <= .iso_datum(rechts)
      schritte <- list(list(operation = regel$operation, operanden = list(links, rechts),
        vergleichsbasis = "Gregorianische Kalenderdaten, einschliessliche Grenze", wert = wert))
    } else if (isTRUE(regel$operation %in% c("ZEITPUNKT_KLEINER_GLEICH", "ZEITPUNKT_KLEINER"))) {
      links <- eingaben[[regel$frueher]]; rechts <- eingaben[[regel$spaeter]]
      a <- .zeitpunktteile(links); b <- .zeitpunktteile(rechts)
      wert <- a$ganz < b$ganz || (a$ganz == b$ganz && a$mikro < b$mikro) ||
        (identical(regel$operation, "ZEITPUNKT_KLEINER_GLEICH") && a$ganz == b$ganz && a$mikro == b$mikro)
      schritte <- list(list(operation = regel$operation, operanden = list(links, rechts),
        vergleichsbasis = "UTC, Mikrosekunden exakt", wert = wert))
    } else if (identical(regel$operation, "EXAKTE_DEZIMALVERKNUEPFUNG")) {
      a <- eingaben[[regel$links]]; b <- eingaben[[regel$rechts]]
      wert <- .nichtnegative_dezimalrechnung(a, b, identical(regel$verknuepfung, "MULTIPLIKATION"))
      schritte <- list(list(operation = regel$verknuepfung, operanden = list(a, b), wert = wert))
    } else if (identical(regel$operation, "GEWICHTETE_HINZURECHNUNG")) {
      basis <- eingaben$aggregationsbasiswert
      zusatz <- eingaben$noch_hinzuzurechnender_unternehmenswert
      quote <- if (!is.null(regel$quotenfeld)) eingaben$hinzurechnungsquote else regel$feste_quote
      anteil <- .nichtnegative_dezimalrechnung(zusatz, quote, TRUE)
      wert <- .nichtnegative_dezimalrechnung(basis, anteil)
      schritte <- list(list(operation = "MULTIPLIKATION", operanden = list(zusatz, quote), wert = anteil),
        list(operation = "ADDITION", operanden = list(basis, anteil), wert = wert))
    } else if (identical(regel$operation, "NICHTNEGATIVE_GANZZAHL_DIFFERENZ")) {
      minuend <- eingaben[[regel$minuend]]
      subtrahend <- eingaben[[regel$subtrahend]]
      if (subtrahend > minuend) {
        ergebnis$hinweise <- list("Ausgenommene Anhangseiten uebersteigen die Gesamtseiten")
        return(ergebnis)
      }
      wert <- as.integer(minuend - subtrahend)
      schritte <- list(list(operation = "SUBTRAKTION", operanden = list(minuend, subtrahend), wert = wert))
    } else if (identical(regel$operation, "DAUERAUSWAHL")) {
      feld <- regel$auswahlfeld
      auswahl <- eingaben[[feld]]
      wert <- regel$dauerparameter[[auswahl]]
      schritte <- list(list(operation = "DAUERAUSWAHL", auswahlfeld = feld,
        auswahl = auswahl, wert = wert))
    } else if (regel_id %in% c("AIA_099_OBERGRENZE", "AIA_101_OBERGRENZE")) {
      if (regel_id == "AIA_101_OBERGRENZE") {
        festbetrag <- "15000000"
        satz <- "0.03"
        auswahl <- "MAX"
      } else {
        kategorie <- eingaben$verstosskategorie
        parameter <- regel$parameter[[kategorie]]
        festbetrag <- parameter$festbetrag
        satz <- parameter$satz
        klasse <- eingaben$akteurklasse
        auswahl <- if (klasse == "KEIN_UNTERNEHMEN") "FESTBETRAG" else if (
          klasse == "KMU" || (klasse == "SMC" && kategorie != "VERBOT")) "MIN" else "MAX"
      }
      if (auswahl == "FESTBETRAG") {
        wert <- festbetrag
        schritte <- list(list(operation = auswahl, wert = wert))
      } else {
        umsatz <- eingaben$weltweiter_vorjahresumsatz_eur
        prozent <- switch(satz, "0.01" = 1L, "0.03" = 3L, "0.07" = 7L)
        if (is.null(prozent)) stop("Unbekannter paketinterner Prozentsatz")
        anteil <- .prozentanteil(umsatz, prozent)
        wert <- .extremum(list(festbetrag, anteil), auswahl == "MIN")
        schritte <- list(
          list(operation = "MULTIPLIKATION", operanden = list(umsatz, satz), wert = anteil),
          list(operation = auswahl, operanden = list(festbetrag, anteil), wert = wert))
      }
    } else if (regel_id == "AIA_030_EINWANDSPERIODE") {
      wert <- list(anzahl = 2L, einheit = if (eingaben$notifizierungsgrundlage == "AKKREDITIERUNGSBESCHEINIGUNG") "WOCHE" else "MONAT")
      schritte <- list(list(operation = "AUSWAHL_EINWANDSPERIODE", grundlage = eingaben$notifizierungsgrundlage, wert = wert))
    } else if (regel_id == "AIA_100_OBERGRENZE") {
      wert <- if (eingaben$verstosskategorie == "VERBOT") "1500000" else "750000"
      schritte <- list(list(operation = "FESTBETRAG", wert = wert))
    } else if (regel_id == "KMU_PARTNERANTEIL") {
      operanden <- unname(eingaben[names(regel$eingaben)])
      wert <- .extremum(operanden)
      schritte <- list(list(operation = "MAX", operanden = operanden, wert = wert))
    } else if (regel_id == "PANEL_EU_MINDESTZAHL") {
      anzahl <- eingaben$mitgliederzahl
      wert <- as.integer((4L * anzahl + 4L) %/% 5L)
      schritte <- list(list(operation = "AUFRUNDEN_VIER_FUENFTEL", operanden = list(anzahl), wert = wert))
    } else if (regel_id == "AIA_065_005_ZWEIDRITTELMEHRHEIT") {
      anzahl <- eingaben$benannte_mitgliedstaatenvertreter
      wert <- as.integer((2L * anzahl + 2L) %/% 3L)
      schritte <- list(list(operation = "AUFRUNDEN_ZWEI_DRITTEL", operanden = list(anzahl), wert = wert))
    } else if (regel_id == "PANEL_DRITTEL_AUTORISIERUNG") {
      anzahl <- eingaben$mitgliederzahl
      wert <- as.integer((anzahl + 2L) %/% 3L)
      schritte <- list(list(operation = "AUFRUNDEN_EIN_DRITTEL", operanden = list(anzahl), wert = wert))
    } else if (regel_id == "PANEL_EINFACHE_MEHRHEIT") {
      anzahl <- eingaben$mitgliederzahl
      wert <- as.integer(anzahl %/% 2L + 1L)
      schritte <- list(list(operation = "MEHR_ALS_DIE_HAELFTE", operanden = list(anzahl), wert = wert))
    }
  }
  if (regel_id == "AIA_073_MELDEFRISTTAGE") {
    absatz <- NULL
    if (isTRUE(eingaben$weitverbreiteter_verstoss) || isTRUE(eingaben$schwere_irreversible_kritische_infrastrukturstoerung)) {
      wert <- 2L
      absatz <- "ART_073/3"
      relevant <- character()
    } else if (!length(relevant)) {
      wert <- if (isTRUE(eingaben$todesfall)) 10L else 15L
      absatz <- if (isTRUE(eingaben$todesfall)) "ART_073/4" else "ART_073/2"
    }
    schritte <- list(list(operation = "PRIORISIERTE_HOECHSTDAUER", fundstelle = absatz, wert = wert))
  }
  if (regel_id %in% c("KMU_SCHWELLEN","KMU_RATIONALSCHWELLEN")) {
    wert <- list()
    relevant <- character()
    parameter <- list(
      kleinst = c("10", "2000000", "2000000"),
      klein = c("50", "10000000", "10000000"),
      kmu = c("250", "50000000", "43000000"),
      smc_groessenrahmen = c("750", "150000000", "129000000"))
    for (name in names(parameter)) {
      grenzen <- parameter[[name]]
      p <- eingaben$jahresarbeitseinheiten
      u <- eingaben$jahresumsatz_eur
      b <- eingaben$jahresbilanzsumme_eur
      personal <- if (regel_id=="KMU_RATIONALSCHWELLEN") {
        if (.fehlend(eingaben$jae_zaehler) || .fehlend(eingaben$jae_nenner)) NULL else
          .nat_vergleich(eingaben$jae_zaehler,.nichtnegative_dezimalrechnung(grenzen[[1L]],eingaben$jae_nenner,TRUE))<0L
      } else if (.fehlend(p)) NULL else .dezimalvergleich(p, grenzen[[1L]]) < 0L
      finanz <- list(if (.fehlend(u)) NULL else .dezimalvergleich(u, grenzen[[2L]]) <= 0L,
                     if (.fehlend(b)) NULL else .dezimalvergleich(b, grenzen[[3L]]) <= 0L)
      finanzwert <- if (any(vapply(finanz, isTRUE, logical(1)))) TRUE else if (
        any(vapply(finanz, is.null, logical(1)))) NULL else FALSE
      teilwert <- if (identical(personal, FALSE) || identical(finanzwert, FALSE)) FALSE else if (
        is.null(personal) || is.null(finanzwert)) NULL else TRUE
      wert[name] <- list(teilwert)
      if (is.null(teilwert)) {
        if (is.null(personal)) relevant <- union(relevant,if(regel_id=="KMU_RATIONALSCHWELLEN") intersect(c("jae_zaehler","jae_nenner"),fehlend) else "jahresarbeitseinheiten")
        if (is.null(finanzwert)) relevant <- union(relevant, intersect(
          c("jahresumsatz_eur", "jahresbilanzsumme_eur"), fehlend))
      }
    }
    schritte <- list(list(operation = "GROESSENMERKMALE", wert = wert))
  }
  unbekannt <- length(relevant) > 0L
  ergebnis["wert"] <- list(wert)
  ergebnis$status <- if (unbekannt) "EINGABE_FEHLT" else "AUSGEWERTET"
  ergebnis$anwendbarkeit <- "UNBEKANNT"
  ergebnis$entscheidungsstatus <- if (unbekannt) "UNBESTIMMT" else "ENTSCHIEDEN"
  ergebnis$rechenschritte <- schritte
  ergebnis$fehlende_angaben <- as.list(sort(fehlend, method = "radix"))
  ergebnis$entscheidungsrelevante_luecken <- as.list(sort(relevant, method = "radix"))
  ergebnis$annahmen <- list("Rechengr\u00f6\u00dfe; zeitliche und allgemeine rechtliche Anwendbarkeit separat pr\u00fcfen",
    paste0("Katalogstatus: ", regel$status))
  ergebnis$hinweise <- list(regel$automatisierungsgrenze)
  ergebnis$nachweise <- lapply(regel$fundstellen, function(stelle) list(
    art = "RECHTSQUELLE", fundstelle = stelle, quellenfassung = quellenfassung))
  ergebnis
}

berechne_bussgeldobergrenze <- function(eingaben, quellenfassung) {
  berechne_regel("AIA_099_OBERGRENZE", eingaben, quellenfassung)
}
