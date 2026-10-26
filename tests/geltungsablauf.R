library(euaiact)
source(system.file("examples/geltungsablauf.R",package="euaiact"))
daten <- lese_json(system.file("examples/geltungsablaeufe.json",package="euaiact"))
actual <- auswerten(daten)
for(i in seq_along(daten$faelle)) {
 case <- daten$faelle[[i]]
 for(j in seq_along(case$schritte)) {
  result <- actual[[i]]$schritte[[j]]$ergebnis
  expected <- case$schritte[[j]]$erwartung
  for(key in names(expected)) if(!identical(result[[key]],expected[[key]])) stop(paste(case$fall_id,j,key,case$herleitung))
  stopifnot(result$anwendbarkeit=="UNBEKANNT")
 }
}
invalid <- daten;invalid$faelle[[1]]$schritte[[3]]$parameter$stichtag <- "2029-01-01"
stopifnot(inherits(try(auswerten(invalid),silent=TRUE),"try-error"))
cat(length(daten$faelle),"scope/time/grandfathering workflows and conflicting-date guard passed\n")
