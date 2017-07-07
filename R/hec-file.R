#' Function reads in an hdf5 file resulting from a HecRas model run 
#' @param filename an hdf5 file resulting from a HecRas model run 
#' @export
hec_file <- function(filename) {
  h5::h5file(filename)
}
