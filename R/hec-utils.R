

#' Get Plan Information
#' @description Given a plan or a collection of these return a set of metadata attributes
#' defined for each plan.
#' @param hc a set of hec files read in with hec_file()
#' @return tibble with attributes as columns and unique plans as rows
#' @export
plan_info <- function(hc) {
  
  if (!is_hec_collection(hc)) {
    stop("argument is not a hec_collection")
  }
  
  do_get_plan_info <- function(.f) {
    tibble::tibble(
      plan_short_id = hdf5r::h5attr(.f[["Plan Data/Plan Information"]], 
                                    which = "Plan ShortID"),
      plan_name = hdf5r::h5attr(.f[["Plan Data/Plan Information"]], 
                                which = "Plan Name"), 
      plan_file = stringr::str_extract(hdf5r::h5attr(.f[["Plan Data/Plan Information"]], 
                                                     which = "Plan File"), 
                                       "[A-Za-z0-9_-]+\\.[a-z0-9]+$"), 
      computation_time_step = hdf5r::h5attr(.f[["Plan Data/Plan Information"]], 
                                            which = "Computation Time Step"), 
      geometry_name = stringr::str_extract(hdf5r::h5attr(.f[["Plan Data/Plan Information"]], 
                                    which = "Geometry Name"), "[A-Za-z0-9_-]+\\.[a-z0-9]+$"), 
      geometry_title = hdf5r::h5attr(.f[["Plan Data/Plan Information"]], 
                                     which = "Geometry Title"), 
      output_interval = hdf5r::h5attr(.f[["Plan Data/Plan Information"]], 
                                      which = "Output Interval")
      )
  }
  
  purrr::map_df(hc$collection, ~do_get_plan_info(.))
}
