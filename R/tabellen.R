# Versionierte lokale Tabellen. Keine Netzabfragen oder fremde Laufzeit.
.tabellen <- local({
  tabellen <- NULL
  function() {
    if (is.null(tabellen)) {
      pfad <- system.file("extdata", "anhangtabellen.json", package = "euaiact", mustWork = TRUE)
      daten <- jsonlite::fromJSON(pfad, simplifyVector = FALSE)
      tabellen <<- stats::setNames(daten$tabellen, vapply(daten$tabellen, function(t) t$tabellen_id, character(1)))
    }
    tabellen
  }
})

tabellen_katalog <- function() {
  unname(lapply(.tabellen(), function(t) list(tabellen_id = t$tabellen_id,
    tabellenversion = t$tabellenversion, quellenfassung = t$quellenfassung,
    bezeichnung = t$bezeichnung, status = t$status, zeilenanzahl = length(t$zeilen))))
}

tabelle_info <- function(tabellen_id) {
  if (!.textskalar(tabellen_id) || !tabellen_id %in% names(.tabellen())) stop("Unbekannte Tabellen-ID")
  .tabellen()[[tabellen_id]]
}
