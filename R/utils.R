
#' Get model timestamps 
#' This should correspond with the width of raw time series dataframes
get_model_timestamps <- function(f) {

  d <- f[[hdf_paths$RES_UNSTEADY_TS]][['Time Date Stamp']]
  on.exit(d$close())
  
  as.POSIXct(trimws(d[]), format = "%d%b%Y %H:%M:%S")
}

#' Get model metadata
get_model_metadata <- function(f) {
  plan_info <- f[[hdf_paths$PLAN_INFORMATION]]
  on.exit(plan_info$close())
  
  structure(
    list(
      plan_file = hdf5r::h5attr(plan_info, "Plan File"),
      plan_name = hdf5r::h5attr(plan_info, "Plan Name"), 
      plan_id = hdf5r::h5attr(plan_info, "Plan ShortID"), 
      geometry = hdf5r::h5attr(plan_info, "Geometry Title")
    ), 
    class = "hec_metadata"
  )
}


is_empty <- function(x) length(x) == 0L
