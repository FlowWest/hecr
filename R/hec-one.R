#' @title Query one dimensional domains
#' @description provide station(s), a type of time series and optionally a timestamp
#' to query out data from an hdf5 file resulting from a HEC-RAS model run
#' @param hc a hec_collection object produced by calling hec_file()
#' @param station_name name(s) for station(s) defined in the model run
#' @param ts_type a valid time series type defined in the model run
#' @export 
hec_one <- function(hc, station_name=NULL, ts_type=NULL, time_stamp=NULL) {
  
  if (!is_hec_collection(hc)) {
    stop(sprintf("supplied 'f' is not a valid hec_collection"))
  }
  
  # if no arguments supplied return object with appended "hec_one" class
  if (is.null(c(station_name, ts_type, time_stamp))) {
    class(hc) <- append(class(hc), "hec_one")
    return(hc)
  }
  
  # ts type is required when station name is supplied
  if (is.null(ts_type)) {
    stop("a time series type is required to query, use hec_one(hc) %>% hec_ls() to list available", 
         call. = FALSE)
  }
  
  df <- hec_extract.hec_one(hc, station_name, ts_type, time_stamp)
  class(df) <- append(class(df), "hec_one")
  df
}

#' Extract a time series from One D
#' @description describe this
#' @param hc a hec one collection
#' @param station_name one or more stations names
#' @param ts_type a time series type
#' @param time_stamp optional timestamp to filter query by
#' @export
hec_extract.hec_one <- function(hc, station_name, ts_type, time_stamp = NULL) {
  do_extract <- function(.f) {
    
    model_timestamps <- hec_timestamps_(.f) 
    model_attributes <- hec_info_(.f)
    model_stations <- hec_crosssections_(.f)
    
    # when user supplied a timestamp
    if (!is.null(time_stamp)) {
      time_idx <- which(model_timestamps == time_stamp)
      if (length(time_idx) == 0) stop("supplied value for time_stamp was not found in the model", 
                                      call. = FALSE)
    } else {
      time_idx <- seq_len(length(model_timestamps))
    }
    
    
    cross_section_index <- cross_section_index(model_stations, station_name)
    cross_section_reach <- trimws(.f[[hdf_paths$GEOM_CROSS]][["Reach Names"]]$read()[cross_section_index])[1]
    cross_section_river <- trimws(.f[[hdf_paths$GEOM_CROSS]][["River Names"]]$read()[cross_section_index])[1]
    
    time_series <- .f[[hdf_paths$RES_CROSS_SECTIONS]][[ts_type]][cross_section_index, time_idx]
    other_attr_lengths <- length(station_name) * length(time_idx)
    #on.exit(time_series$close())
    time_series_stacked <- matrix(t(time_series[]), ncol = 1, byrow = TRUE)
    
    tibble::tibble(
      "datetime" = rep(model_timestamps[time_idx], length(cross_section_index)), 
      "plan_id" = model_attributes$plan_short_id, 
      "plan_name" = model_attributes$plan_name,
      "plan_file" = model_attributes$plan_file,
      "cross_section_reach" = cross_section_reach, 
      "cross_section_river" = cross_section_river, 
      "station" = rep(station_name, each = length(time_idx)),
      "values" = as.vector(time_series_stacked)
    )
    
  }
  
  purrr::map_dfr(f$collection, ~do_extract(.))
}

#' List Cross Section Data
#' @description list all data available to query from either one or two dimensional domain
#' @param hc a hec file
#' @return vector of data names
#' @export
hec_ls.hec_one <- function(hc) {
  path_to_ls <- "Results/Unsteady/Output/Output Blocks/Base Output/Unsteady Time Series/Cross Sections"
  ls_ <- function(h) {
    names(h[[path_to_ls]])
  }
  
  purrr::map(hc$collection, ~ls_(.)) %>% purrr::set_names(hc$files)
}

# INTERNALS 

cross_section_index <- function(model_stations, station) {
  cross_section_idx <- which(model_stations %in% station)
  
  if (is_empty(cross_section_idx)) {
    stop(sprintf("supplied station '%s' not found in model", station), call. = FALSE)
  }
  
  cross_section_idx
}












