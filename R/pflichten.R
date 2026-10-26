# Strukturierte sachliche Pflichtausloesung, kein Erfuellungsurteil.
.pflichtendaten <- local({
  katalog <- NULL
  function() {
    if (is.null(katalog)) {
      daten <- jsonlite::fromJSON(system.file("extdata", "pflichten.json", package = "euaiact"), simplifyVector = FALSE)
      katalog <<- stats::setNames(daten$pflichten, vapply(daten$pflichten, function(p) p$pflicht_id, character(1)))
    }
    katalog
  }
})

pflicht_katalog <- function() {
  unname(.pflichtendaten())
}

ermittle_pflicht <- function(pflicht_id, eingaben, quellenfassung) {
  if (!.textskalar(pflicht_id) || !pflicht_id %in% names(.pflichtendaten())) {
    ergebnis <- .umschlag(NULL, eingaben, quellenfassung)
    ergebnis$ergebnistyp <- "OBJEKT"
    ergebnis$hinweise <- list("Unbekannte Pflicht-ID")
    return(ergebnis)
  }
  pflicht <- .pflichtendaten()[[pflicht_id]]
  ergebnis <- pruefe_tatbestand(pflicht$ausloeser_regel, eingaben, quellenfassung)
  ergebnis$ergebnistyp <- "OBJEKT"
  if (ergebnis$status == "EINGABE_UNGUELTIG") return(ergebnis)
  ausgeloest <- ergebnis$wert
  ergebnis$wert <- pflicht[c("pflicht_id", "pflichtversion", "adressat", "gegenstand", "ausnahmen", "fundstellen", "fristregel_ids", "rechtsfolge", "zeitbezug", "nachweisanforderungen", "erfuellungskriterien")]
  ergebnis$wert["ausloeser_erfuellt"] <- list(ausgeloest)
  ergebnis$wert$erfuellung <- "NICHT_GEPRUEFT"
  ergebnis$hinweise <- c(ergebnis$hinweise, list(
    "Bedingte Rechtsfolge; Erf\u00fcllung und allgemeine Anwendbarkeit nicht gepr\u00fcft",
    paste0("Pflichtkatalogstatus: ", pflicht$status), pflicht$automatisierungsgrenze))
  ergebnis
}
