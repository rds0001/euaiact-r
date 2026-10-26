# Allgemeiner Anwendungsbeginn ohne automatische Uebergangsentscheidung.
.zeitkatalog <- local({
  katalog <- NULL
  function() {
    if (is.null(katalog)) katalog <<- jsonlite::fromJSON(system.file("extdata", "anwendungsbeginn.json", package = "euaiact"), simplifyVector = FALSE)
    katalog
  }
})

pruefe_anwendungsbeginn <- function(bereich, stichtag, quellenfassung) {
  katalog <- .zeitkatalog()
  eingaben <- list(bereich = bereich, stichtag = stichtag)
  ergebnis <- .umschlag(katalog$regel_id, eingaben, quellenfassung)
  ergebnis$regelversion <- katalog$regelversion
  if (!.textskalar(quellenfassung) || !quellenfassung %in% names(katalog$fassungen)) {
    ergebnis$hinweise <- list("Quellenfassung f\u00fcr diese Regel nicht verf\u00fcgbar")
    return(ergebnis)
  }
  fassung <- katalog$fassungen[[quellenfassung]]
  fehler <- character()
  if (!.fehlend(bereich) && (!.textskalar(bereich) || !bereich %in% c(names(fassung$bereiche), names(fassung$offene_bereiche)))) fehler <- c(fehler, "Bereich in dieser Quellenfassung nicht verf\u00fcgbar")
  datum <- NULL
  if (!.fehlend(stichtag)) {
    datum <- tryCatch(.iso_datum(stichtag), error = function(e) NULL)
    if (is.null(datum)) fehler <- c(fehler, "Ung\u00fcltiger stichtag") else if (datum < .iso_datum(fassung$fassung_ab)) fehler <- c(fehler, "Stichtag liegt vor Inkrafttreten der gew\u00e4hlten Quellenfassung")
  }
  if (length(fehler)) {
    ergebnis$hinweise <- as.list(fehler)
    return(ergebnis)
  }
  fehlend <- names(eingaben)[vapply(eingaben, .fehlend, logical(1))]
  if (length(fehlend)) {
    ergebnis$status <- "EINGABE_FEHLT"
    ergebnis$anwendbarkeit <- "UNBEKANNT"
    ergebnis$entscheidungsstatus <- "UNBESTIMMT"
    ergebnis$fehlende_angaben <- as.list(fehlend)
    ergebnis$entscheidungsrelevante_luecken <- as.list(fehlend)
    return(ergebnis)
  }
  if (bereich %in% names(fassung$offene_bereiche)) {
    frage <- fassung$offene_bereiche[[bereich]]
    ergebnis$status <- "REGEL_UNGEKLAERT"
    ergebnis$anwendbarkeit <- "UNBEKANNT"
    ergebnis$entscheidungsstatus <- "UNBESTIMMT"
    ergebnis$entscheidungsschritte <- list(list(operation = "OFFENE_RECHTSFRAGE", bereich = bereich, frage_id = frage$frage_id, wert = NULL))
    ergebnis$hinweise <- list(frage$hinweis)
    ergebnis$nachweise <- lapply(frage$fundstellen, function(stelle) list(art = "RECHTSQUELLE", fundstelle = stelle, quellenfassung = quellenfassung))
    return(ergebnis)
  }
  beginn <- fassung$bereiche[[bereich]]
  wert <- datum >= .iso_datum(beginn)
  ergebnis$wert <- wert
  ergebnis$status <- "AUSGEWERTET"
  ergebnis$anwendbarkeit <- "UNBEKANNT"
  ergebnis$entscheidungsstatus <- "ENTSCHIEDEN"
  ergebnis$entscheidungsschritte <- list(list(operation = "STICHTAG_AB_BEGINN", bereich = bereich, anwendungsbeginn = beginn, stichtag = stichtag, wert = wert))
  ergebnis$annahmen <- list("Ausdr\u00fccklich gew\u00e4hlte Quellenfassung und Bereich")
  ergebnis$hinweise <- list("Artikel 111 und sachlicher, pers\u00f6nlicher sowie territorialer Geltungsbereich separat pr\u00fcfen", "KAPITEL_I_II_BESTAND schlie\u00dft Artikel 4a und die neuen Verbote aus")
  ergebnis$nachweise <- list(list(art = "RECHTSQUELLE", fundstelle = "ART_113", quellenfassung = quellenfassung))
  ergebnis
}
