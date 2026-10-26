library(euaiact)
f <- jsonlite::fromJSON("fixtures/grundregeln_referenzen.json", simplifyVector = FALSE)$faelle
fall <- Filter(function(x) x$fall_id == "REF_BEZIEHUNG_SMC_INVESTORENAUSNAHME_ANGEL_GRENZE", f)[[1L]]
pruefen <- function(x) pruefe_tatbestand("SMC_INVESTORENAUSNAHME", x, "EUAIACT_2026_07_27")
e <- pruefen(fall$eingaben)
stopifnot(e$status == "REGEL_UNGEKLAERT", is.null(e$wert), length(e$entscheidungsrelevante_luecken) == 0L,
  identical(tail(e$entscheidungsschritte, 1L)[[1L]]$offene_rechtsfragen, list("F015")))
x <- fall$eingaben
x$business_angel_gesamtinvestition_im_selben_unternehmen_eur <- NULL
e <- pruefen(x)
stopifnot(e$status == "REGEL_UNGEKLAERT", identical(e$entscheidungsrelevante_luecken, list("business_angel_gesamtinvestition_im_selben_unternehmen_eur")))
x <- fall$eingaben
x$investor_universitaet_oder_nichtgewinnorientiertes_forschungszentrum <- TRUE
e <- pruefen(x)
stopifnot(e$status == "AUSGEWERTET", isTRUE(e$wert), is.null(tail(e$entscheidungsschritte, 1L)[[1L]]$offene_rechtsfragen))
x <- fall$eingaben
x$rechtsfrage_f015 <- FALSE
stopifnot(pruefen(x)$status == "EINGABE_UNGUELTIG")
cat("Offene Rechtsfragen von Datenluecken getrennt geprueft\n")
