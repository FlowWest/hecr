# functions deal with plan geometry

#' Plan Cross Sections
#' @description Extract the crossections for a given hec collection
#' @param hc a hec_collection
#' @return data frame 
#' @export
hec_crosssections <- function(hc) {
  if (!inherits(hc, "hec")) {
    stop("supplied argument is not a 'hec' object", call. = FALSE)
  }
  
  trimws(hc$object[['Geometry/Cross Sections/River Stations']]$read())
}


has_crossections_ <- function(h) {
  "Cross Sections" %in% names(h$object[["Geometry"]])
}











