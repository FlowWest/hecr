#' Function queries an hdf file read in with hec_file for cross section time series data.
#' @param f an hdf5 file read in via hec_file()
#' @param station_name station(s) for the cross section to query time series from. 
#' Multiple cross sections must be passed as a vector. 
#' @param ts_type time series to query out (ex 'Water Surface', 'Depth', ...)
#' @param timestatmp an optional timestamp to query, default action will not filter for a timestamp.
#' Use this option to speed up long queries when a desired timestamp is known.
#' @examples
#' # first read in hdf file
#' f <- hec_file(examples/ArdenwoodCreek.p50.hdf)
#' 
#' # get a water surface time series for a given cross section
#' ws <- extract_ts1(f, "1456", "Water Surface")
#' 
#' # get water surface elevation for several cross sections
#' ws <- extract_ts1(f, c("1456", "8567", "12322"), "Water Surface")
#' 
#' # get water surface for all cross sections with a fixed timestamp
#' all_cross_sections <- get_xs_river_stations(f)
#' ws <- extract(f, all_cross_sections, "Water Surface", timestamp = "2005-07-01 00:00:00")
#' @export
extract_ts1 <- function(f, station_name, ts_type="Water Surface", timestamp=NULL) {
  # closure for extracting each file in f
  
  do_extract <- function(.f, station_name, ts, timestamp) {
    model_datetimes <- get_model_timestamps(.f)

    # if user specified a timestamp find the index (row in hdf) that correponds
    # Otherwise make this sequence just all the index(es?)
    # lastly check when provided a timestamp it matches with one in hdf error otherwise 
    timestamp_index <- 
      if(!is.null(timestamp)) which(model_datetimes == timestamp) else seq_len(length(model_datetimes))
    if (!is.null(timestamp) & (length(timestamp_index) == 0)) 
      stop(paste0("timestamp '", timestamp, "' does not match a datetime in the model"))
    
    plan_id <- get_plan_attributes(.f)$plan_short_id #one per hdf file
    cross_section_index <- get_xs_station_index(.f, station_name) #one per station
    cross_section_reach <- get_xs_reach(.f, cross_section_index) #one per station
    d_length <- length(timestamp_index)
    series <-matrix(.f[hdf_paths$RES_CROSS_SECTIONS][ts_type][timestamp_index, cross_section_index], 
             ncol=1, byrow=FALSE)
    
    
    tibble:::tibble("datetime" = rep(model_datetimes[timestamp_index], length(cross_section_index)),
                    "plan_id" = plan_id,# reps on its own
                    "cross_section_reach" = rep(cross_section_reach, each=d_length), 
                    "time_series_type" = ts_type,
                    "cross_section" = rep(station_name, each=d_length), 
                    "values" = series[,1])  
  }
  
  x <- purrr::map_dfr(f, ~do_extract(., station_name, ts_type, timestamp))
  attr(x, 'hec_obj') <- f
  x
}

#' Function returns cross section stations defined in the model
#' @param .f an hdf5 file read in with hec_file or h5::h5file
#' @export
get_xs_river_stations <- function(.f) {
  res <- purrr::map(.f, function(x) {
    trimws(x[hdf_paths$GEOM_CROSS]['River Stations'][])  
  })
  
  purrr::flatten_chr(res)
}

### INTERNAL ------------------------------------------------------------------

get_xs_station_index <- function(.f, station_name) {
  xs_stations <- get_xs_river_stations(.f)
  cross_section_index <- which(xs_stations %in% station_name)
  
  if (!length(cross_section_index)) {
    stop(paste0("station name '",station_name,"' not found in hdf5 file"))
  }
  
  return(cross_section_index)
}

get_xs_reach <- function(.f, station_idx) {
  xs_reach <- .f[hdf_paths$GEOM_CROSS]['Reach Names'][station_idx, ]
  trimws(xs_reach)
}

get_xs_river_name <- function(.f, station_idx) {
  xs_river_name <- .f[hdf_paths$GEOM_CROSS]['River Names'][station_idx, ]
  trimws(xs_river_name)
}

