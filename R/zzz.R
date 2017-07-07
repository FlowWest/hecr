.onLoad <- function(libname, pkgname) {
  op <- options()
  op.hecr <- list(
    hecr.digits = 20
  )
  toset <- !(names(op.hecr) %in% names(op))
  if(any(toset)) options(op.hecr[toset])
  
  invisible()
}

.onLoad()