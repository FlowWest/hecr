#' Get Plan Information
#' @description Given a plan or a collection of these return a set of metadata attributes
#' defined for each plan.
#' @param hc a set of hec files read in with hec_file()
#' @return tibble with attributes as columns and unique plans as rows
#' @export
hec_info <- function(hc) {
  
  if (!is_hec_collection(hc)) {
    stop("argument is not a hec_collection")
  }
  
  purrr::map_df(hc$collection, ~hec_info_(.))
}


# all hec*_ function operate inside the hec_collection, rather than on the 
# collection itself, intended for internal use
# sometimes these are called through an exported function to surface the 
# funcionality to the user as is the case with hec_info_

has_crossections <- function(h) {
  "Cross Sections" %in% names(h[["Geometry"]])
}

hec_timestamps_ <- function(h) {
  as.POSIXct(h[["Results/Unsteady/Output/Output Blocks/Base Output/Unsteady Time Series/Time Date Stamp"]]$read(), 
             format = "%d%b%Y %H:%M:%S")
}

hec_info_ <- function(h) {
  list(
    plan_short_id = hdf5r::h5attr(h[["Plan Data/Plan Information"]], 
                                  which = "Plan ShortID"),
    plan_name = hdf5r::h5attr(h[["Plan Data/Plan Information"]], 
                              which = "Plan Name"), 
    plan_file = stringr::str_extract(hdf5r::h5attr(h[["Plan Data/Plan Information"]], 
                                                   which = "Plan File"), 
                                     "[A-Za-z0-9_-]+\\.[a-z0-9]+$"), 
    computation_time_step = hdf5r::h5attr(h[["Plan Data/Plan Information"]], 
                                          which = "Computation Time Step"), 
    geometry_name = stringr::str_extract(hdf5r::h5attr(h[["Plan Data/Plan Information"]], 
                                                       which = "Geometry Name"), "[A-Za-z0-9_-]+\\.[a-z0-9]+$"), 
    geometry_title = hdf5r::h5attr(h[["Plan Data/Plan Information"]], 
                                   which = "Geometry Title"), 
    output_interval = hdf5r::h5attr(h[["Plan Data/Plan Information"]], 
                                    which = "Output Interval")
  )
}



