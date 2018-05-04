#' @title Query one dimensional domains
#' @description provide station(s), a type of time series and optionally a timestamp
#' to query out data from an hdf5 file resulting from a HEC-RAS model run
#' @param f a hec_collection object produced by calling hec_file()
#' @param station_name name(s) for station(s) defined in the model run
#' @param ts_type a valid time series type defined in the model run
#' @export 
hec_ts1 <- function(f, station_name, ts_type="Water Surface", time_stamp=NULL) {
  
  if (!is_hec_collection(f)) {
    stop(sprintf("supplied 'f' is not a valid hec_collection"))
  }
  
  do_extract <- function(.f) {
    
    model_timestamps <- hec_timestamps_(.f) 
    model_attributes <- hec_info_(.f)
    model_stations <- get_cross_section_stations(.f)
    
    if (!is.null(time_stamp)) {
      time_idx <- which(model_timestamps == time_stamp)
      if (length(time_idx) == 0) stop("supplied value for time_stamp was not found in the model", 
                                      call. = FALSE)
    } else {
      time_idx <- seq_len(length(model_timestamps))
    }

    
    cross_section_index <- get_cross_sections_index(model_stations, station_name)
    cross_section_reach <- get_cross_section_reach(.f, cross_section_index)[1]
    cross_section_river <- get_cross_section_river(.f, cross_section_index)[1]
    
    time_series <- .f[[hdf_paths$RES_CROSS_SECTIONS]][[ts_type]][cross_section_index, time_idx]
    other_attr_lengths <- length(station_name) * length(time_idx)
    #on.exit(time_series$close())
    time_series_stacked <- matrix(t(time_series[]), ncol = 1, byrow = TRUE)
    
    tibble::tibble(
      "datetime" = rep(model_timestamps[time_idx], length(cross_section_index)), 
      "plan_id" = model_attributes$plan_id, 
      "plan_name" = model_attributes$plan_name,
      "plan_file" = model_attributes$plan_file,
      "cross_section_reach" = cross_section_reach, 
      "cross_section_river" = cross_section_river, 
      "station" = rep(station_name, each = length(time_idx)),
      "values" = as.vector(time_series_stacked)
    )
    
  }
  
  df <- purrr::map_dfr(f$collection, ~do_extract(.))
  class(df) <- append(class(df), "hec_oneD")
  df
}

# INTERNALS 

get_cross_section_stations <- function(f) {
  df <- f[[hdf_paths$GEOM_CROSS]][['River Stations']]
  on.exit(df$close())
  
  trimws(df[])
}

get_cross_sections_index <- function(model_stations, station) {
  cross_section_idx <- which(model_stations %in% station)
  
  if (is_empty(cross_section_idx)) {
    stop(sprintf("supplied station '%s' not found in model", station), call. = FALSE)
  }
  
  cross_section_idx
}

get_cross_section_reach <- function(f, station_index) {
  cross_section_reaches <- f[[hdf_paths$GEOM_CROSS]][["Reach Names"]]
  on.exit(cross_section_reaches$close())
  
  trimws(cross_section_reaches[station_index])
}


get_cross_section_river <- function(f, station_index) {
  cross_section_rivers <- f[[hdf_paths$GEOM_CROSS]][["River Names"]]
  on.exit(cross_section_rivers$close())
  
  trimws(cross_section_rivers[station_index])
}











