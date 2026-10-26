library(euaiact)
data <- jsonlite::fromJSON("fixtures/periodenfristen_referenzen.json",simplifyVector=FALSE)
for(case in data$faelle) {
 result <- do.call(berechne_periodenfrist,case$eingaben)
 if(!identical(result$wert,case$erwartung$wert) || !identical(result$status,case$erwartung$status)) stop(paste(case$fall_id,case$herleitung,result$status,result$wert))
}
cat(length(data$faelle),"independent composite period references passed\n")
