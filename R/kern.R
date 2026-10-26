.ganze_zahl <- function(wert) {
  (is.integer(wert) || is.double(wert)) && !is.object(wert) &&
    length(wert) == 1L && is.finite(wert) &&
    abs(wert) <= 9007199254740991 && wert == floor(wert)
}

# Native Dreiwertlogik. Keine Netzwerkzugriffe und kein Python-Aufruf.

.katalog <- local({
  katalog <- NULL
  function() {
    if (is.null(katalog)) {
      pfad <- system.file("extdata", "regeln.json", package = "euaiact")
      if (!nzchar(pfad)) stop("Paketinterner Regelkatalog fehlt")
      daten <- jsonlite::fromJSON(pfad, simplifyVector = FALSE)
      rechenregeln <- jsonlite::fromJSON(system.file("extdata", "rechenregeln.json", package = "euaiact"), simplifyVector = FALSE)
      ergaenzung <- lapply(rechenregeln$regeln, function(regel) {
        regel$quellenfassung <- rechenregeln$quellenfassung
        regel$status <- rechenregeln$status
        regel
      })
      daten$regeln <- c(daten$regeln, ergaenzung)
      katalog <<- stats::setNames(daten$regeln,
        vapply(daten$regeln, function(r) r$regel_id, character(1)))
    }
    katalog
  }
})

regel_info <- function(regel_id) {
  if (!is.character(regel_id) || length(regel_id) != 1L ||
      is.na(regel_id) || !regel_id %in% names(.katalog())) stop("Unbekannte Regel-ID")
  .katalog()[[regel_id]]
}

regel_katalog <- function() {
  unname(lapply(.katalog(), function(r) r[c("regel_id", "regelversion",
    "bezeichnung", "quellenfassung", "status")]))
}

schema_info <- function(schema_id = "ERGEBNIS_0_1_0") {
  if (.textskalar(schema_id) && endsWith(schema_id, ":EINGABEN")) {
    vertrag <- eingabevertrag(substr(schema_id, 1L, nchar(schema_id) - 9L))
    eigenschaften <- stats::setNames(list(), character())
    for (name in names(vertrag$felder)) {
      feld <- vertrag$felder[[name]]
      domain <- switch(feld$typ,
        BOOLEAN = list(type = "boolean"),
        ENUM = list(type = "string", enum = feld$werte),
        ENUMMENGE = list(type = "array", items = list(type = "string", enum = feld$werte),
          uniqueItems = TRUE, maxItems = length(feld$werte)),
        NATURZAHLTEXT = list(type="string",pattern="^(0|[1-9][0-9]*)$(?![\\s\\S])",maxLength=256L,
          description="Nichtnegative ganze Zahl als kanonischer Zifferntext; Nennerminimum prueft der native Kern."),
        DATUM = list(type = "string", pattern = "^[0-9]{4}-[0-9]{2}-[0-9]{2}$(?![\\s\\S])", maxLength = 10L,
          description = "Gregorianisches Datum YYYY-MM-DD, Jahre 0001-9999; Kalendergueltigkeit prueft der native Kern."),
        DATUMZEIT = list(type = "string", pattern = .zeitpunktmuster, maxLength = 32L,
          description = "Expliziter Offset, Jahre 0001\u20139999, maximal sechs Nachkommastellen; Kalendergueltigkeit und Offset prueft der native Kern."),
        GANZZAHL = list(type = "integer"),
        DEZIMAL = list(type = "string",
          pattern = "^-?(0|[1-9][0-9]*)(\\.[0-9]+)?$(?![\\s\\S])",
          maxLength = 4096L,
          description = "Exakte Dezimalgrenzen prueft die native Regelauswertung."),
        stop("Unbekannter interner Feldtyp"))
      for (grenze in c("minimum", "maximum")) {
        if (!is.null(feld[[grenze]])) {
          if (identical(feld$typ, "GANZZAHL")) domain[[grenze]] <- as.numeric(feld[[grenze]])
          if (feld$typ %in% c("DEZIMAL", "NATURZAHLTEXT")) domain[[paste0("x-euaiact-", grenze)]] <- feld[[grenze]]
        }
      }
      eigenschaften[[name]] <- list(anyOf = list(list(type = "null"), domain))
      metadaten <- c(definition = "description", herkunft = "x-euaiact-herkunft", bezugszeit = "x-euaiact-bezugszeit")
      for (quelle in names(metadaten)) {
        if (!is.null(feld[[quelle]])) eigenschaften[[name]][[metadaten[[quelle]]]] <- feld[[quelle]]
      }
    }
    return(list(`$schema` = "https://json-schema.org/draft/2020-12/schema",
      `$id` = paste0("urn:euaiact:", schema_id), type = "object",
      additionalProperties = FALSE, properties = eigenschaften))
  }
  if (!identical(schema_id, "ERGEBNIS_0_1_0")) stop("Unbekannte Schema-ID")
  jsonlite::fromJSON(system.file("extdata", "ergebnis.schema.json", package = "euaiact"), simplifyVector = FALSE)
}

.fehlend <- function(wert) {
  is.null(wert) || (is.atomic(wert) && length(wert) == 1L &&
    is.na(wert) && !is.nan(wert))
}

.textskalar <- function(wert) {
  is.character(wert) && length(wert) == 1L && !is.na(wert)
}

.felder_bauen <- function(regel_id, pfad = character()) {
  if (regel_id %in% pfad) stop("Zyklischer paketinterner Regelverweis")
  regel <- .katalog()[[regel_id]]
  felder <- regel$eingaben
  besuchen <- function(knoten) {
    if (!is.null(knoten$regel)) {
      weitere <- .felder_bauen(knoten$regel, c(pfad, regel_id))
      for (name in names(weitere)) {
        if (name %in% names(felder) && !identical(felder[[name]], weitere[[name]])) {
          stop("Widerspruechlicher paketinterner Feldvertrag")
        }
        felder[[name]] <<- weitere[[name]]
      }
    }
    for (argument in knoten$argumente) besuchen(argument)
  }
  besuchen(regel$ausdruck)
  felder
}

.felder <- local({
  cache <- new.env(parent = emptyenv())
  function(regel_id) {
    if (!exists(regel_id, envir = cache, inherits = FALSE)) {
      assign(regel_id, .felder_bauen(regel_id), envir = cache)
    }
    get(regel_id, envir = cache, inherits = FALSE)
  }
})

eingabevertrag <- function(regel_id) {
  regel <- regel_info(regel_id)
  felder <- if (is.null(regel$ausdruck)) regel$eingaben else .felder(regel_id)
  list(regel_id = regel_id, regelversion = regel$regelversion,
    quellenfassung = regel$quellenfassung, schemaversion = "0.1.0",
    felder = if (!length(felder)) stats::setNames(list(), character()) else
      felder[sort(names(felder), method = "radix")],
    unbekannt = "Fehlende Felder und null bleiben unbekannt; keine stillen Defaults",
    zusaetzliche_felder = "UNZULAESSIG")
}

.ziffernvergleich <- function(a, b) {
  abweichung <- which(utf8ToInt(a) != utf8ToInt(b))
  if (!length(abweichung)) return(0L)
  index <- abweichung[[1L]]
  if (utf8ToInt(a)[[index]] < utf8ToInt(b)[[index]]) -1L else 1L
}

.dezimalteile <- function(wert) {
  negativ <- startsWith(wert, "-")
  wert <- sub("^-", "", wert)
  teile <- strsplit(wert, ".", fixed = TRUE)[[1L]]
  ganz <- teile[[1L]]
  bruch <- if (length(teile) == 2L) sub("0+$", "", teile[[2L]]) else ""
  list(negativ = negativ && !(ganz == "0" && bruch == ""), ganz = ganz, bruch = bruch)
}

.dezimalvergleich <- function(a, b) {
  x <- .dezimalteile(a)
  y <- .dezimalteile(b)
  if (x$negativ != y$negativ) return(if (x$negativ) -1L else 1L)
  vorzeichen <- if (x$negativ) -1L else 1L
  if (nchar(x$ganz) != nchar(y$ganz)) {
    return(vorzeichen * if (nchar(x$ganz) < nchar(y$ganz)) -1L else 1L)
  }
  ganzvergleich <- .ziffernvergleich(x$ganz, y$ganz)
  if (ganzvergleich != 0L) return(vorzeichen * ganzvergleich)
  laenge <- max(nchar(x$bruch), nchar(y$bruch))
  vorzeichen * .ziffernvergleich(
    paste0(x$bruch, strrep("0", laenge - nchar(x$bruch))),
    paste0(y$bruch, strrep("0", laenge - nchar(y$bruch))))
}

.eingabefehler <- function(eingaben, felder) {
  if (!is.list(eingaben) || (length(eingaben) &&
      (is.null(names(eingaben)) || anyNA(names(eingaben)) ||
       any(!nzchar(names(eingaben))) || anyDuplicated(names(eingaben))))) {
    return("eingaben muss eine Liste mit eindeutigen Textschluesseln sein")
  }
  fehler <- character()
  for (name in names(eingaben)) {
    wert <- eingaben[[name]]
    if (!name %in% names(felder)) {
      fehler <- c(fehler, paste0("Unbekanntes Eingabefeld: ", name))
      next
    }
    if (.fehlend(wert)) next
    vertrag <- felder[[name]]
    if (vertrag$typ == "BOOLEAN") {
      if (!is.logical(wert) || length(wert) != 1L) {
        fehler <- c(fehler, paste0("Boolean oder null erforderlich: ", name))
      }
    } else if (vertrag$typ == "DEZIMAL") {
      if (!.textskalar(wert) || nchar(wert) > 4096L ||
          !grepl("^-?(0|[1-9][0-9]*)(\\.[0-9]+)?\\z", wert, perl = TRUE)) {
        fehler <- c(fehler, paste0("Kanonische Dezimalzeichenfolge erforderlich: ", name))
      } else if (!is.null(vertrag$minimum) && .dezimalvergleich(wert, vertrag$minimum) < 0L) {
        fehler <- c(fehler, paste0("Unter Minimum: ", name))
      } else if (!is.null(vertrag$maximum) && .dezimalvergleich(wert, vertrag$maximum) > 0L) {
        fehler <- c(fehler, paste0("\u00dcber Maximum: ", name))
      }
    } else if (vertrag$typ == "ENUM") {
      if (!.textskalar(wert) || !wert %in% unlist(vertrag$werte)) {
        fehler <- c(fehler, paste0("Unzul\u00e4ssige Kategorie: ", name))
      }
    } else if (vertrag$typ == "ENUMMENGE") {
      if (!is.list(wert) || !is.null(names(wert)) || length(wert) > length(vertrag$werte) ||
          !all(vapply(wert, function(x) .textskalar(x) && x %in% unlist(vertrag$werte), logical(1))) ||
          anyDuplicated(unlist(wert, use.names = FALSE))) {
        fehler <- c(fehler, paste0("Eindeutige Liste zul\u00e4ssiger Kategorien erforderlich: ", name))
      }
    } else if (vertrag$typ == "NATURZAHLTEXT") {
      if (!.textskalar(wert) || nchar(wert)>256L || !grepl("^(0|[1-9][0-9]*)\\z",wert,perl=TRUE)) {
        fehler <- c(fehler,paste0("Kanonischer Ganzzahltext mit maximal256Stellen erforderlich: ",name))
      } else if (!is.null(vertrag$minimum) && .nat_vergleich(wert,vertrag$minimum)<0L) {
        fehler <- c(fehler,paste0("Ganzzahltext unter dem erlaubten Minimum: ",name))
      }
    } else if (vertrag$typ == "DATUM") {
      if (is.null(tryCatch(.iso_datum(wert), error = function(e) NULL))) {
        fehler <- c(fehler, paste0("Gueltiges Kalenderdatum YYYY-MM-DD erforderlich: ", name))
      }
    } else if (vertrag$typ == "DATUMZEIT") {
      if (is.null(.zeitpunktteile(wert))) {
        fehler <- c(fehler, paste0("Gueltiger Zeitpunkt mit explizitem Offset erforderlich: ", name))
      }
    } else if (vertrag$typ == "GANZZAHL") {
      if (!.ganze_zahl(wert)) {
        fehler <- c(fehler, paste0("Ganze Zahl erforderlich: ", name))
      } else if (wert < as.numeric(vertrag$minimum) || wert > as.numeric(vertrag$maximum)) {
        fehler <- c(fehler, paste0("Au\u00dferhalb Wertebereich: ", name))
      }
    } else stop("Unbekannter paketinterner Feldtyp")
  }
  fehler
}

.umschlag <- function(regel_id, eingaben, quellenfassung) {
  list(wert = NULL, ergebnistyp = "WAHRHEITSWERT", einheit = NULL,
    status = "EINGABE_UNGUELTIG", anwendbarkeit = NULL, entscheidungsstatus = NULL,
    regel_id = if (.textskalar(regel_id)) regel_id else NULL, regelversion = NULL,
    quellenfassung = if (.textskalar(quellenfassung)) quellenfassung else NULL,
    schemaversion = "0.1.0", eingaben = if (is.list(eingaben) && length(eingaben) && !is.null(names(eingaben)) && all(nzchar(names(eingaben))) && !anyNA(names(eingaben)) && !anyDuplicated(names(eingaben))) eingaben else stats::setNames(list(), character()),
    nutzervorgaben = stats::setNames(list(), character()), entscheidungsschritte = list(), rechenschritte = list(),
    annahmen = list(), hinweise = list(), fehlende_angaben = list(),
    entscheidungsrelevante_luecken = list(), nachweise = list())
}

pruefe_tatbestand <- function(regel_id, eingaben, quellenfassung) {
  ergebnis <- .umschlag(regel_id, eingaben, quellenfassung)
  if (!.textskalar(regel_id) || !regel_id %in% names(.katalog())) {
    ergebnis$hinweise <- list("Unbekannte Regel-ID")
    return(ergebnis)
  }
  regel <- .katalog()[[regel_id]]
  ergebnis$regelversion <- regel$regelversion
  if (is.null(regel$ausdruck)) {
    ergebnis$hinweise <- list("Rechenregel erfordert berechne_regel")
    return(ergebnis)
  }
  if (!identical(quellenfassung, regel$quellenfassung)) {
    ergebnis$hinweise <- list("Quellenfassung f\u00fcr diese Regel nicht verf\u00fcgbar")
    return(ergebnis)
  }
  felder <- .felder(regel_id)
  fehler <- .eingabefehler(eingaben, felder)
  if (length(fehler)) {
    ergebnis$hinweise <- as.list(fehler)
    return(ergebnis)
  }
  fehlend <- names(felder)[vapply(names(felder), function(name) .fehlend(eingaben[[name]]), logical(1))]
  schritte <- list()
  beteiligte <- regel_id
  rechtsfragen <- list()
  datenluecken <- function(x) sort(x[!startsWith(x, "RECHTSFRAGE:")], method = "radix")
  fragen <- function(x) sort(sub("^RECHTSFRAGE:", "", x[startsWith(x, "RECHTSFRAGE:")]), method = "radix")
  auswerten <- function(knoten, kennung, pfad = "0") {
    if (!is.null(knoten$rechtsfrage)) {
      frage <- knoten$rechtsfrage
      rechtsfragen[[frage]] <<- knoten$hinweis
      schritte[[length(schritte) + 1L]] <<- list(schritt = length(schritte) + 1L,
        regel_id = kennung, bedingung_id = paste0(kennung, ":K", pfad),
        operator = "OFFENE_RECHTSFRAGE", frage_id = frage, wert = NULL,
        entscheidungsrelevante_luecken = list(), offene_rechtsfragen = list(frage))
      return(list(wert = NULL, luecken = paste0("RECHTSFRAGE:", frage)))
    }
    if (!is.null(knoten$feld)) {
      name <- knoten$feld
      wert <- eingaben[[name]]
      if (.fehlend(wert)) wert <- NULL
      schritte[[length(schritte) + 1L]] <<- list(schritt = length(schritte) + 1L,
        regel_id = kennung, bedingung_id = paste0(kennung, ":K", pfad),
        operator = "EINGABEFELD", eingabefeld = name, wert = wert,
        entscheidungsrelevante_luecken = if (is.null(wert)) list(name) else list())
      if (.fehlend(wert)) return(list(wert = NULL, luecken = name))
      return(list(wert = wert, luecken = character()))
    }
    if (!is.null(knoten$dezimal)) return(list(wert = knoten$dezimal, luecken = character()))
    if (!is.null(knoten$text)) return(list(wert = knoten$text, luecken = character()))
    if (!is.null(knoten$menge)) return(list(wert = knoten$menge, luecken = character()))
    if (!is.null(knoten$regel)) {
      if (!knoten$regel %in% beteiligte) beteiligte <<- c(beteiligte, knoten$regel)
      return(auswerten(.katalog()[[knoten$regel]]$ausdruck, knoten$regel))
    }
    paare <- lapply(seq_along(knoten$argumente), function(index)
      auswerten(knoten$argumente[[index]], kennung, paste0(pfad, ".", index - 1L)))
    werte <- lapply(paare, function(p) p$wert)
    luecken <- unique(unlist(lapply(paare, function(p) p$luecken), use.names = FALSE))
    unbekannt <- any(vapply(werte, is.null, logical(1)))
    op <- knoten$op
    if (op == "UND") {
      wert <- if (any(vapply(werte, identical, logical(1), FALSE))) FALSE else if (unbekannt) NULL else TRUE
    } else if (op == "ODER") {
      wert <- if (any(vapply(werte, identical, logical(1), TRUE))) TRUE else if (unbekannt) NULL else FALSE
    } else if (op == "NICHT") {
      wert <- if (unbekannt) NULL else !werte[[1L]]
    } else if (op == "TEILMENGE") {
      wert <- if (unbekannt) NULL else all(unlist(werte[[1L]], use.names = FALSE) %in% unlist(werte[[2L]], use.names = FALSE))
    } else if (op == "GLEICH") {
      wert <- if (unbekannt) NULL else identical(werte[[1L]], werte[[2L]])
    } else if (op %in% c("GROESSER", "GROESSER_GLEICH", "KLEINER_GLEICH")) {
      wert <- NULL
      if (!unbekannt) {
        zahlen <- lapply(werte, function(x) {
          if (is.numeric(x)) sprintf("%.0f", x) else x
        })
        vergleich <- .dezimalvergleich(zahlen[[1L]], zahlen[[2L]])
        wert <- switch(op, GROESSER = vergleich > 0L,
          GROESSER_GLEICH = vergleich >= 0L, KLEINER_GLEICH = vergleich <= 0L)
      }
    } else stop("Unbekannter paketinterner Operator")
    if (!is.null(wert)) luecken <- character()
    schritte[[length(schritte) + 1L]] <<- list(schritt = length(schritte) + 1L,
      regel_id = kennung, bedingung_id = paste0(kennung, ":K", pfad), operator = op, wert = wert,
      entscheidungsrelevante_luecken = as.list(datenluecken(luecken)))
    if (length(fragen(luecken))) schritte[[length(schritte)]]$offene_rechtsfragen <<- as.list(fragen(luecken))
    list(wert = wert, luecken = luecken)
  }
  paar <- auswerten(regel$ausdruck, regel_id)
  schritte[[length(schritte) + 1L]] <- list(schritt = length(schritte) + 1L,
    regel_id = regel_id, operator = "REGELERGEBNIS", wert = paar$wert,
    entscheidungsrelevante_luecken = as.list(datenluecken(paar$luecken)))
  if (length(fragen(paar$luecken))) schritte[[length(schritte)]]$offene_rechtsfragen <- as.list(fragen(paar$luecken))
  ergebnis["wert"] <- list(paar$wert)
  ergebnis$status <- if (length(fragen(paar$luecken))) "REGEL_UNGEKLAERT" else if (is.null(paar$wert)) "EINGABE_FEHLT" else "AUSGEWERTET"
  ergebnis$anwendbarkeit <- "UNBEKANNT"
  ergebnis$entscheidungsstatus <- if (is.null(paar$wert)) "UNBESTIMMT" else "ENTSCHIEDEN"
  ergebnis$entscheidungsschritte <- schritte
  ergebnis$fehlende_angaben <- as.list(sort(fehlend, method = "radix"))
  ergebnis$entscheidungsrelevante_luecken <- as.list(datenluecken(paar$luecken))
  ergebnis$annahmen <- list("Sachlicher Tatbestand; zeitliche und allgemeine rechtliche Anwendbarkeit separat pr\u00fcfen",
    paste0("Katalogstatus: ", regel$status))
  ergebnis$hinweise <- list(regel$automatisierungsgrenze)
  ergebnis$hinweise <- c(ergebnis$hinweise, lapply(fragen(paar$luecken), function(frage) paste0("Offene Rechtsfrage ", frage, ": ", rechtsfragen[[frage]])))
  if (length(beteiligte) > 1L) ergebnis$hinweise <- c(ergebnis$hinweise,
    lapply(beteiligte[-1L], function(kennung) paste0(kennung, ": ", .katalog()[[kennung]]$automatisierungsgrenze)))
  ergebnis$nachweise <- list()
  for (kennung in beteiligte) {
    teilregel <- .katalog()[[kennung]]
    ergebnis$nachweise <- c(ergebnis$nachweise, lapply(teilregel$fundstellen, function(stelle) list(
      art = "RECHTSQUELLE", fundstelle = stelle, quellenfassung = quellenfassung,
      regel_id = kennung, regelversion = teilregel$regelversion)))
  }
  ergebnis
}

pruefe_stapel <- function(faelle, quellenfassung) {
  if (!is.list(faelle)) stop("faelle muss eine Liste sein")
  kennungen <- character(length(faelle))
  for (index in seq_along(faelle)) {
    fall <- faelle[[index]]
    if (!is.list(fall) || length(fall) != 3L ||
        !setequal(names(fall), c("fall_id", "regel_id", "eingaben"))) {
      stop("Jeder Fall benoetigt genau fall_id, regel_id und eingaben")
    }
    kennung <- fall$fall_id
    if (!.textskalar(kennung) || !nzchar(trimws(kennung))) {
      stop("Fall-IDs muessen nichtleere, eindeutige Texte sein")
    }
    kennungen[[index]] <- kennung
  }
  if (anyDuplicated(kennungen)) stop("Fall-IDs muessen nichtleere, eindeutige Texte sein")
  lapply(faelle, function(fall) list(fall_id = fall$fall_id,
    ergebnis = pruefe_tatbestand(fall$regel_id, fall$eingaben, quellenfassung)))
}
