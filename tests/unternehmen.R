library(euaiact)
source(system.file("examples", "unternehmen.R", package = "euaiact"), local = TRUE)
stopifnot(length(ergebnisse) == 31L)
