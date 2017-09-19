#' Function retrieves a desired time series from a cross section part of a
#' HEC-RAS model
#' @param f an hdf5 file read in via hec_file or a corpus created with create_hdf_corpus
#' @param station_name station for the cross section to query time series from 
#' @param ts_type time series to query out (ex 'Water Surface', 'Depth', ...)
#' @param timestatmp an optional timestamp to query, default action will not filter for a timestamp
#' @export
extract_ts1 <- function(f, station_name, ts_type="Water Surface", timestamp=NULL) {
  # closure for extracting each file in f
  
  do_extract <- function(.f, station_name, ts, timestamp) {
    xs_datetime <- get_model_timestamps(.f)
    # if user supplied timestamp argument then find its index else return all indexes
    # TODO: case when timestamp was not found needs to have stop(ERROR)
    timestamp_idx <- if(!is.null(timestamp)) which(xs_datetime == timestamp) else seq_len(length(xs_datetime))
    plan_id <- get_plan_attributes(.f)$plan_short_id
    xs_index <- get_xs_station_index(.f, station_name)
    river_name <- get_xs_river_name(.f, xs_index)
    reach_name <- get_xs_reach(.f, xs_index)
    d_length <- length(timestamp_idx)
    series <-matrix(.f[hdf_paths$RES_CROSS_SECTIONS][ts_type][timestamp_idx, xs_index], 
             ncol=1, byrow=FALSE)
    
    
    tibble:::tibble("datetime" = rep(xs_datetime[timestamp_idx], length(xs_index)),
                    "plan_id" = plan_id,# reps on its own
                    #"river_name" = rep(river_name, each=d_length), #might want to delete this 
                    #"reach_name" = rep(reach_name, each=d_length), 
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
  xs_stations <- .f[hdf_paths$GEOM_CROSS]['River Stations'][]
  return(trimws(xs_stations))
}

### INTERNAL ------------------------------------------------------------------

get_xs_station_index <- function(.f, station_name) {
  xs_stations <- get_xs_river_stations(.f)
  xs_index <- which(xs_stations %in% station_name)
  
  if (!length(xs_index)) {
    stop(paste0("station name '",station_name,"' not found in hdf5 file"))
  }
  
  return(xs_index)
}

get_xs_reach <- function(.f, station_idx) {
  xs_reach <- .f[hdf_paths$GEOM_CROSS]['Reach Names'][station_idx, ]
  trimws(xs_reach)
}

get_xs_river_name <- function(.f, station_idx) {
  xs_river_name <- .f[hdf_paths$GEOM_CROSS]['River Names'][station_idx, ]
  trimws(xs_river_name)
}

