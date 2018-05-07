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
  
  plan_file_lng_name = hdf5r::h5attr(plan_info, "Plan File")
  plan_file <- stringr::str_extract(plan_file_lng_name, "[A-Za-z]+.p[0-9]+$")
  structure(
    list(
      plan_file = plan_file,
      plan_name = hdf5r::h5attr(plan_info, "Plan Name"), 
      plan_id = hdf5r::h5attr(plan_info, "Plan ShortID"), 
      geometry = hdf5r::h5attr(plan_info, "Geometry Title")
    ), 
    class = "hec_metadata"
  )
}


#' Hec Plan Information
#' @description get plan information for a given hec file or collection of these
#' @param f a hec object 
hec_info <- function(f) {
  do_hec_info <- function(.f) {
    g <- .f[["Plan Data/Plan Information"]]
    list(
    comp_time_step = hdf5r::h5attr(g, "Computation Time Step"),
    geom_name = hdf5r::h5attr(g, "Geometry Name"),
    geom_title = hdf5r::h5attr(g, "Geometry Title"),
    output_int = hdf5r::h5attr(g, "Output Interval"),
    plan_file = hdf5r::h5attr(g, "Plan File"),
    plan_name = hdf5r::h5attr(g, "Plan Name"),
    plan_shorid = hdf5r::h5attr(g, "Plan ShortID"),
    time_window = hdf5r::h5attr(g, "Time Window")
    )
  }
  
  purrr::map(f$collection, ~do_hec_info(.))
}

is_hec_collection <- function(f) {
  !is.atomic(f) & inherits(f, "hec_collection")
}

is_empty <- function(x) length(x) == 0L
