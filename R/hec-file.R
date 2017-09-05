#' Function reads in an hdf5 file resulting from a HecRas model run 
#' @param f an hdf5 file resulting from a HecRas model run 
#' @export
hec_file <- function(f) {
  h5::h5file(f)
}

#' 
is_hec_file <- function(f) {
  attr(f, "class") == "H5File"
}
