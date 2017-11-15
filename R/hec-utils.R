#' @title List Available Time Series Data
#' @description list available time series in the model that can be extracted with 
#' one of the extract_* functions
#' @param f a hec_collection object read in with hec_file()
#' @param area_name the flow area name defined in the model 
#' @param domain either 'one' or 'two' corresponding to one-d or two-d domains
#' @export 
available_time_series <- function(f, area_name, domain = NULL, ...) {
  
  do_list_data <- function(.f) {
    hdf5r::list.datasets(.f[[hdf_paths$RES_2D_FLOW_AREAS]][[area_name]], recursive = FALSE)
    
  }
  
  if (is_hec_collection(f)) {
    purrr::map(f$collection, ~do_list_data(.))
  } else {
    do_list_data(f)
  }
}
