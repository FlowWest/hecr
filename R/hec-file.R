#' Function reads in an hdf5 file resulting from a HecRas model run 
#' @param filename an hdf5 file resulting from a HecRas model run 
#' @export
hec_file <- function(filename) {
  h5::h5file(filename)
}

#' Function retrieves top level metadata associated with a hec ras file
#' @param hf a \code{hec_file} object 
#' @return list of attributes associated with hecras output file
#' @export
hec_attributes <- function(hf) {
  file_type <- h5::h5attr(hf, 'File Type')
  file_version <- h5::h5attr(hf, 'File Version')
  file_projection <- h5::h5attr(hf, 'Projection')
  file_units <- h5::h5attr(hf, 'Units System')
  
  list('file_type' = file_type, 
       'file_version' = file_version, 
       'file_projection' = file_projection, 
       'file_units' = file_units)
}