# Lokale JSON-Dateien und reine Feldzuordnung.

.lokaler_pfad <- function(pfad) {
  if (!.textskalar(pfad) || !nzchar(trimws(pfad)) || startsWith(pfad, "//") || startsWith(pfad, "\\\\")) {
    stop("Lokaler Dateipfad erforderlich")
  }
  if (grepl("^[a-zA-Z][a-zA-Z0-9+.-]*:", pfad) && !grepl("^[a-zA-Z]:[/\\\\]", pfad)) {
    stop("URI und URLs sind keine lokalen Dateipfade")
  }
  pfad
}

.jsonwert <- function(wert, tiefe = 0L) {
  if (tiefe > 100L) stop("JSON-Verschachtelung \u00fcberschreitet 100 Ebenen")
  if (is.null(wert)) return(NULL)
  if (is.list(wert)) {
    schluessel <- names(wert)
    if (!is.null(schluessel) && (anyNA(schluessel) || any(!nzchar(schluessel)) || anyDuplicated(schluessel))) {
      stop("JSON-Objektschl\u00fcssel m\u00fcssen eindeutig und nichtleer sein")
    }
    if (is.object(wert)) stop("Nicht unterst\u00fctzter JSON-Datentyp")
    return(lapply(wert, .jsonwert, tiefe = tiefe + 1L))
  }
  if (is.object(wert) || length(wert) != 1L || !is.null(names(wert))) stop("JSON-Skalar oder Liste erforderlich")
  if (is.logical(wert) && !is.na(wert)) return(wert)
  if (is.character(wert) && !is.na(wert) && !is.na(iconv(wert, from = "", to = "UTF-8", sub = NA))) return(enc2utf8(wert))
  if (is.numeric(wert) && is.finite(wert) && wert == floor(wert) && abs(wert) <= 9007199254740991) return(wert)
  stop("JSON-Zahlen m\u00fcssen interoperable ganze Zahlen sein; fehlend als NULL, Dezimalwerte als Text")
}

lese_json <- function(pfad) {
  verbindung <- file(.lokaler_pfad(pfad), open = "rb")
  on.exit(close(verbindung))
  roh <- readBin(verbindung, what = "raw", n = 16 * 1024 * 1024 + 1)
  if (length(roh) > 16 * 1024 * 1024) stop("JSON-Datei \u00fcberschreitet 16 MiB")
  if (any(roh == as.raw(0))) stop("Ung\u00fcltiges UTF-8 JSON")
  text <- rawToChar(roh)
  if (is.na(iconv(text, from = "UTF-8", to = "UTF-8", sub = NA))) stop("Ung\u00fcltiges UTF-8 JSON")
  if (!jsonlite::validate(text)) stop("Ung\u00fcltiges JSON")
  ohne_texte <- gsub('"(?:[^"\\\\]|\\\\.)*"', '""', text, perl = TRUE)
  if (grepl("[0-9][.eE]", ohne_texte)) stop("JSON-Zahlen ohne Bruchteil und Exponent erforderlich; sonst Text verwenden")
  .jsonwert(jsonlite::fromJSON(text, simplifyVector = FALSE))
}

schreibe_json <- function(daten, pfad) {
  ziel <- .lokaler_pfad(pfad)
  wert <- .jsonwert(daten)
  kodieren <- function(x) {
    if (is.null(x)) return("null")
    if (is.list(x)) {
      if (!length(x)) return(if (is.null(names(x))) "[]" else "{}")
      teile <- vapply(x, kodieren, character(1))
      if (is.null(names(x))) return(paste0("[", paste(teile, collapse = ","), "]"))
      namen <- vapply(names(x), function(n) as.character(jsonlite::toJSON(n, auto_unbox = TRUE)), character(1))
      return(paste0("{", paste(paste0(namen, ":", teile), collapse = ","), "}"))
    }
    if (is.numeric(x)) return(sprintf("%.0f", x))
    as.character(jsonlite::toJSON(x, auto_unbox = TRUE))
  }
  text <- paste0(kodieren(wert), "\n")
  roh <- charToRaw(enc2utf8(text))
  if (length(roh) > 16 * 1024 * 1024) stop("JSON-Datei \u00fcberschreitet 16 MiB")
  verbindung <- file(ziel, open = "wxb")
  on.exit(close(verbindung))
  writeBin(roh, verbindung)
  invisible(NULL)
}

ordne_daten_zu <- function(datensatz, zuordnung) {
  objekt <- function(x) is.list(x) && !is.null(names(x)) && !anyNA(names(x)) && !any(!nzchar(names(x))) && !anyDuplicated(names(x))
  if (!objekt(datensatz)) stop("datensatz muss ein Objekt mit nichtleeren Textschl\u00fcsseln sein")
  if (!objekt(zuordnung) || !setequal(names(zuordnung), c("mappingversion", "felder"))) stop("Zuordnung ben\u00f6tigt genau mappingversion und felder")
  version <- zuordnung$mappingversion
  felder <- zuordnung$felder
  if (!.textskalar(version) || !nzchar(trimws(version)) || !objekt(felder)) stop("Ung\u00fcltige Mappingversion oder Feldzuordnung")
  for (ziel in names(felder)) {
    quelle <- felder[[ziel]]
    if (!grepl("^[a-z][a-z0-9_]*\\z", ziel, perl = TRUE) || !.textskalar(quelle) || !nzchar(quelle)) stop("Ung\u00fcltiger Ziel- oder Quellfeldname")
  }
  ziele <- sort(names(felder), method = "radix")
  eingaben <- stats::setNames(lapply(ziele, function(ziel) datensatz[[felder[[ziel]]]]), ziele)
  herkunft <- lapply(ziele, function(ziel) list(zielfeld = ziel, quellfeld = felder[[ziel]], vorhanden = felder[[ziel]] %in% names(datensatz)))
  list(mappingversion = version, eingaben = eingaben, herkunft = herkunft)
}
