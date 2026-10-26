library(euaiact)
refs <- jsonlite::fromJSON("fixtures/verjaehrung_referenzen.json",simplifyVector=FALSE)
for(fall in refs$faelle) {
  result <- do.call(berechne_verjaehrung,fall$eingaben)
  stopifnot(identical(result$status,fall$erwartung$status))
  if(is.null(fall$erwartung$wert)) stopifnot(is.null(result$wert)) else {
    for(key in names(fall$erwartung$wert)) if(!identical(result$wert[[key]],fall$erwartung$wert[[key]])) stop(paste(fall$fall_id,key,fall$herleitung))
  }
}
cat(length(refs$faelle),"qualified limitation timelines passed\n")
