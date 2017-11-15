# General utlity function that do not depend on 1 or 2 dimensional portions
# of an hdf5 file

#' Function retrieves the timestamps defined in the HEC-RAS model run 
#' @param .f an hdf file read in with hec_file or h5::h5file
#' @return a vector of datetimes
get_model_timestamps <- function(f) {
  dt <- f[hdf_paths$RES_UNSTEADY_TS]['Time Date Stamp'][]
  lubridate::dmy_hms(dt, tz='America/Los_Angeles')
}


#' Function retrieves model attributes embeded in a HEC-RAS result file.
#' @param .f an hdf object read in with hec_file or hdf_corpus
get_plan_attributes <- function(.f) {
  
  fplan <- .f[hdf_paths$PLAN_INFORMATION]
  
  plan_name <- h5::h5attr(fplan, 'Plan Name')
  plan_file <- h5::h5attr(fplan, 'Plan File')
  plan_short_id <- h5::h5attr(fplan, 'Plan ShortID')
  time_window <- h5::h5attr(fplan, 'Time Window')
  geometry_title <- h5::h5attr(fplan, 'Geometry Title')
  output_interval <- h5::h5attr(fplan, 'Output Interval')
  
  # process time window a little more
  time <- trimws(unlist(strsplit(time_window, "to")))
  time <- lubridate::dmy_hms(time)
  
  list(
    "plan_short_id" = plan_short_id, 
    "plan_name" = plan_name, 
    "plan_file" = plan_file,
    "geometry_title" = geometry_title,
    "start_time_window" = time[1],
    "end_time_window" = time[2], 
    "output_interval" = output_interval
  )
}

#' Function takes in a hec file or a collection of these and forms a metadata
#' dataframe from them. 
#' @param f a hec file object or collection of these
#' @export
hec_metadata <- function(f) {
  
  do_extract <- function(.f) {
    plan_attrs <- get_plan_attributes(.f)
    # only add cols worth querying out of the data
    tibble::tibble(
      "plan_id" = plan_attrs$plan_short_id, 
      "plan_name" = plan_attrs$plan_name, 
      "plan_file" = plan_attrs$plan_file, 
      "geometry_title" = plan_attrs$geometry_title,
      "start_time_window" = plan_attrs$start_time_window,
      "end_time_window" = plan_attrs$end_time_window
    )
  }
  purrr::map_dfr(f, ~do_extract(.))
} 


#' Function appends to an existing ts1 or ts2 dataframe with the data queried from hec_metadata
#' @param df a ts1 or ts2 dataframe
#' @export
#' @examples 
#' \dontrun{
#' # assuming x is a dataframe obtained from calling either extract_ts1 or extract_ts2
#' x %>% append_meta()
#' }
append_meta <- function(df) {
  d <- hec_metadata(attr(df, "hec_obj"))
  dplyr::left_join(df, d, by = c("plan_id" = "plan_id"))
}
