#' Function reads in an hdf5 file resulting from a HecRas model run 
#' @param f an hdf5 file resulting from a HecRas model run 
#' @export
hec_file <- function(f) {
  list(h5::h5file(f))
}

#' Check whether an object is of hec_file class and not a null pointer
is_hec_file <- function(f) {
  if (attr(f, "class") == "H5File") # if true class check for null pointer
    !identical(f@pointer, new("externalptr"))
  else 
    FALSE
}
