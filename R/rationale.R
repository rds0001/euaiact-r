# Nonnegative integer strings; arithmetic does not use double-valued quantities.
.nat_normal <- function(a) { a <- sub("^0+","",a); if (nzchar(a)) a else "0" }
.nat_vergleich <- function(a,b) {
  if (nchar(a)!=nchar(b)) return(if(nchar(a)<nchar(b)) -1L else 1L)
  .ziffernvergleich(a,b)
}
.nat_minus <- function(a,b) {
  stopifnot(.nat_vergleich(a,b)>=0L)
  x <- rev(utf8ToInt(a)-48L); y <- rev(utf8ToInt(b)-48L)
  y <- c(y,rep(0L,length(x)-length(y))); borg <- 0L
  for(i in seq_along(x)) {
    z <- x[[i]]-y[[i]]-borg; borg <- if(z<0L) 1L else 0L
    x[[i]] <- if(z<0L) z+10L else z
  }
  .nat_normal(paste0(rev(x),collapse=""))
}
.nat_divmod <- function(a,b) {
  stopifnot(b!="0")
  rest <- "0"; quotient <- character(nchar(a))
  for(i in seq_len(nchar(a))) {
    rest <- .nat_normal(paste0(rest,substr(a,i,i))); z <- 0L
    while(.nat_vergleich(rest,b)>=0L) { rest <- .nat_minus(rest,b); z <- z+1L }
    quotient[[i]] <- as.character(z)
  }
  list(quotient=.nat_normal(paste0(quotient,collapse="")),rest=rest)
}
.bruch_kuerzen <- function(n,d) {
  if(n=="0") return(list(zaehler="0",nenner="1"))
  a <- n; b <- d
  while(b!="0") { rest <- .nat_divmod(a,b)$rest; a <- b; b <- rest }
  list(zaehler=.nat_divmod(n,a)$quotient,nenner=.nat_divmod(d,a)$quotient)
}
.rational_rechnen <- function(regel,eingaben) {
  if(identical(regel$operation,"MONATSBRUCH_30_TAGE")) {
    n <- eingaben$monatsbruch_zaehler; d <- eingaben$monatsbruch_nenner
    if(.nat_vergleich(n,d)>=0L) stop("Monatsbruch muss kleiner als eins sein; ganze Monate kalendarisch behandeln")
    return(.bruch_kuerzen(.nichtnegative_dezimalrechnung(n,"30",TRUE),d))
  }
  an <- eingaben[[regel$zaehler_links]]; ad <- eingaben[[regel$nenner_links]]
  bn <- eingaben[[regel$zaehler_rechts]]; bd <- eingaben[[regel$nenner_rechts]]
  if(isTRUE(regel$anteile_beide) && (.nat_vergleich(an,ad)>0L || .nat_vergleich(bn,bd)>0L)) stop("JAE-Anteile duerfen eins nicht ueberschreiten")
  if(isTRUE(regel$anteil_rechts) && .nat_vergleich(bn,bd)>0L) stop("Hinzurechnungsquote darf eins nicht ueberschreiten")
  # Common-denominator sums need only one reduction; do not run Euclid on
  # both unreduced inputs first (especially costly for Fibonacci operands).
  if(identical(regel$operation,"RATIONALE_ADDITION") && identical(ad,bd)) {
    return(.bruch_kuerzen(.nichtnegative_dezimalrechnung(an,bn),ad))
  }
  # Cancel input fractions before the cross products; avoids needless growth.
  a <- .bruch_kuerzen(an,ad); b <- .bruch_kuerzen(bn,bd)
  mal <- function(x,y) .nichtnegative_dezimalrechnung(x,y,TRUE)
  if(identical(regel$operation,"RATIONALE_ADDITION")) {
    n <- .nichtnegative_dezimalrechnung(mal(a$zaehler,b$nenner),mal(b$zaehler,a$nenner))
  } else n <- mal(a$zaehler,b$zaehler)
  .bruch_kuerzen(n,mal(a$nenner,b$nenner))
}
