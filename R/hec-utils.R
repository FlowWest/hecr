#' Function retrieves the timestamps defined in the HEC-RAS model run 
#' @param .f an hdf file read in with hec_file or h5::h5file
#' @return a vector of datetimes
get_model_timestamps <- function(.f) {
  dt <- .f[hdf_paths$RES_UNSTEADY_TS]['Time Date Stamp'][]
  lubridate::dmy_hms(dt)
}
