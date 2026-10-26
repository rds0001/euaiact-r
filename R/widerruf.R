.widerruf_wirksamkeit <- function(data) {
  publication <- .iso_datum(data$widerruf_amtsblattdatum)
  effect <- publication + 1
  if (effect > .iso_datum("9999-12-31")) stop("Wirksamkeit ausserhalb des ISO-Datumsbereichs")
  if (isTRUE(data$widerruf_spaeterer_tag_festgelegt)) {
    later <- .iso_datum(data$widerruf_festgelegter_tag)
    if (later < effect) stop("Festgelegter Wirksamkeitstag liegt vor dem Tag nach Veroeffentlichung")
    effect <- later
  }
  list(wirksam_ab=.datumtext(effect),am_prueftag_wirksam=.iso_datum(data$widerruf_prueftag)>=effect)
}
