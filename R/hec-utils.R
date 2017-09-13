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
#' @param .f an hdf object read in with hec_file or hdf_corpus
get_plan_attributes <- function(.f) {
  
  fplan <- .f[hdf_paths$PLAN_INFORMATION]
  
  plan_name <- h5::h5attr(fplan, 'Plan Name')
  plan_file <- h5::h5attr(fplan, 'Plan File')
  plan_short_id <- h5::h5attr(fplan, 'Plan ShortID')
  time_window <- h5::h5attr(fplan, 'Time Window')
  
  list(
    "plan_short_id" = plan_short_id, 
    "plan_name" = plan_name, 
    "plan_file" = plan_file,
    "time_window" = time_window
  )
}

#' Function takes in a hec file or a collection of these and forms a metadata
#' dataframe from them. 
#' @param f a hec file object or collection of these
#' @export
hec_metadata <- function(f) {
  
  do_extract <- function(.f) {
    plan_attrs <- get_plan_attributes(.f)
    tibble::tibble(
      "short_id" = plan_attrs$plan_short_id, 
      "plan_name" = plan_attrs$plan_name, 
      "plan_file" = plan_attrs$plan_file, 
      "time_window" = plan_attrs$time_window
    )
  }
  purrr::map_dfr(f, ~do_extract(.))
} 



