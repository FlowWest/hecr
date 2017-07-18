# General utlity function that do not depend on 1 or 2 dimensional portions
# of an hdf5 file

#' Function retrieves the timestamps defined in the HEC-RAS model run 
#' @param .f an hdf file read in with hec_file or h5::h5file
#' @return a vector of datetimes
get_model_timestamps <- function(.f) {
  dt <- .f[hdf_paths$RES_UNSTEADY_TS]['Time Date Stamp'][]
  lubridate::dmy_hms(dt)
}

#' Function retrieves model attributes embeded in a HEC-RAS result file.
#' @param .f an hdf5 file result from HEC-RAS
#' @export
get_plan_attributes <-function(.f) {
  
  fplan <- .f['Plan Data/Plan Information']
  
  plan_id <- h5::h5attr(fplan, 'Plan Name')
  plan_file <- h5::h5attr(fplan, 'Plan File')
  plan_name <- stringr::str_extract(plan_file, "[A-Za-z]+.p[0-9]+$")
  time_window <- h5::h5attr(fplan, 'Time Window')
  
  list(
    "plan_id" = plan_id, 
    "plan_name" = plan_name, 
    "time_window" = time_window
  )
}



