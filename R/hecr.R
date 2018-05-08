#' \code{hecr} package
#' 
#' hecr an R interface to HEC-Ras Output
#' 
#' @docType package
#' @name hecr
#' @importFrom dplyr %>%
#' 
NULL

#' Print list of datasets 
#' @description given a hec_collection object passed through one of 'hec_one' or 'hec_two' 
#' print the available data sets to query
#' @export 
hec_ls <- function(x, ...) {
  UseMethod("hec_ls", x)
}

#' Extract a time series
#' @description given a hec_collection object passed through one of 'hec_one' or 'hec_two'
#' extract a time series
#' @export
hec_extract <- function(x, ...) {
  UseMethod("hec_extract", x)
}