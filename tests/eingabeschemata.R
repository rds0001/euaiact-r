library(euaiact)
for (regel in regel_katalog()) {
  schema <- schema_info(paste0(regel$regel_id, ":EINGABEN"))
  stopifnot(identical(schema$type, "object"), identical(schema$additionalProperties, FALSE),
    identical(names(schema$properties), names(eingabevertrag(regel$regel_id)$felder)))
  for (feld in schema$properties) stopifnot(identical(feld$anyOf[[1L]]$type, "null"))
}
schema <- schema_info("AIA_099_OBERGRENZE:EINGABEN")
dezimal <- schema$properties$weltweiter_vorjahresumsatz_eur$anyOf[[2L]]
stopifnot(identical(dezimal$`x-euaiact-minimum`, "0"),
  grepl(dezimal$pattern, "100.25", perl = TRUE),
  !grepl(dezimal$pattern, "1\n", perl = TRUE),
  !grepl(dezimal$pattern, "1e3", perl = TRUE))
stopifnot(inherits(try(schema_info("KEINE_REGEL:EINGABEN"), silent = TRUE), "try-error"))

feld <- "anzahl_getrennt_bestaetigender_qualifizierter_personen"
vertrag <- eingabevertrag("AIA_014_005_KRITERIUM")$felder[[feld]]
eigenschaft <- schema_info("AIA_014_005_KRITERIUM:EINGABEN")$properties[[feld]]
stopifnot(identical(eigenschaft$description, vertrag$definition),
  identical(eigenschaft$`x-euaiact-bezugszeit`, vertrag$bezugszeit),
  nzchar(schema_info("AIA_003_043:EINGABEN")$properties$ki_system$`x-euaiact-herkunft`))
