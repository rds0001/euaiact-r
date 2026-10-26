# Explizite Offset-Zeitpunkte, unabhaengig von Systemzeitzone und POSIXct.
.zeitpunktmuster <- paste0(
  "^([0-9]{4})-([0-9]{2})-([0-9]{2})T([0-9]{2}):([0-9]{2}):([0-9]{2})",
  "(?:\\.([0-9]{1,6}))?(Z|[+-][0-9]{2}:[0-9]{2})$(?![\\s\\S])")

.zeitpunktteile <- function(wert) {
  if (!.textskalar(wert) || nchar(wert) > 32L) return(NULL)
  treffer <- regmatches(wert, regexec(.zeitpunktmuster, wert, perl = TRUE))[[1L]]
  if (!length(treffer)) return(NULL)
  zahlen <- as.integer(treffer[2:7])
  jahr <- zahlen[[1L]]; monat <- zahlen[[2L]]; tag <- zahlen[[3L]]
  stunde <- zahlen[[4L]]; minute <- zahlen[[5L]]; sekunde <- zahlen[[6L]]
  if (jahr < 1L || monat < 1L || monat > 12L || stunde > 23L || minute > 59L || sekunde > 59L) return(NULL)
  schaltjahr <- jahr %% 4L == 0L && (jahr %% 100L != 0L || jahr %% 400L == 0L)
  monatslaengen <- c(31L, if (schaltjahr) 29L else 28L, 31L, 30L, 31L, 30L, 31L, 31L, 30L, 31L, 30L, 31L)
  if (tag < 1L || tag > monatslaengen[[monat]]) return(NULL)
  zone <- treffer[[9L]]
  offset <- 0
  if (zone != "Z") {
    oh <- as.integer(substr(zone, 2L, 3L)); om <- as.integer(substr(zone, 5L, 6L))
    if (oh > 23L || om > 59L || zone == "-00:00") return(NULL)
    offset <- (oh * 3600 + om * 60) * if (substr(zone, 1L, 1L) == "+") 1 else -1
  }
  vorher <- as.numeric(jahr) - 1
  tage <- 365 * vorher + floor(vorher / 4) - floor(vorher / 100) + floor(vorher / 400) +
    sum(monatslaengen[seq_len(monat - 1L)]) + tag - 1
  # Nur ganze Sekunden (< 2^39) als exakt darstellbare R-Zahl; Bruchteile separat.
  ganz <- tage * 86400 + stunde * 3600 + minute * 60 + sekunde - offset
  bruch <- treffer[[8L]]
  mikro <- as.integer(paste0(bruch, strrep("0", 6L - nchar(bruch))))
  list(ganz = ganz, mikro = mikro)
}
