# functions deal with plan geometry

#' Plan Cross Sections
#' @description Extract the crossections for a given hec collection
#' @param hc a hec_collection
#' @return data frame 
#' @export
hec_crosssections <- function(hc, flatten=FALSE) {
  if (!is_hec_collection(hc)) {
    stop("supplied argument is not a hec_collection", call. = FALSE)
  }
  
  if (flatten) {
    purrr::map_chr(hc$collection, ~hec_crosssections_(.)) 
  } else {
    purrr::map(hc$collection, ~hec_crosssections_(.))
  }
  
}

hec_crosssections_ <- function(h) {
  if (!has_crossections_(h)) {
    stop("supplied plan has no cross sections defined (has_crosssections)", 
         call. = FALSE)
  }
  trimws(h[['Geometry/Cross Sections/River Stations']]$read())
}


has_crossections_ <- function(h) {
  "Cross Sections" %in% names(h[["Geometry"]])
}











