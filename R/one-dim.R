#' Function returns cross section stations defined in the model
#' @param .f an hdf5 file read in with hec_file or h5::h5file
get_xs_river_stations <- function(.f) {
  xs_stations <- .f[hdf_paths$GEOM_CROSS]['River Stations']
  
  return(xs_stations[])
}

#' Function returns the index for a desired station name
#' @param .f an hdf5 file read in with hec_file or h5::h5file
#' @param station_name name of the station to query data for
get_xs_station_index <- function(.f, station_name) {
  xs_stations <- get_xs_river_stations(.f)
  xs_index <- which(xs_stations == station_name)
  
  if (!length(xs_index)) {
    stop(paste0("station name '",station_name,"' not found, check value"))
  }
  
  return(xs_index)
}

#' Function retrives the reach defined by the station name
#' @param .f an hdf5 file read in with hdf_file or h5::h5file
#' @param station_name name of station to query reach name for
get_xs_reach <- function(.f, station_name) {
  station_ind <- get_xs_station_index(.f, station_name)
  xs_reach <- .f[hdf_paths$GEOM_CROSS]['Reach Names'][station_ind, ]
  trimws(xs_reach)
}

#' Function retrives the river name defined by the station name
#' @param .f an hdf5 file read in with hec_file or h5::h5file
#' @param station_name name of the station to query river name for
get_xs_river_name <- function(.f, station_name) {
  station_ind <- get_xs_station_index(.f, station_name) 
  xs_river_name <- .f[hdf_paths$GEOM_CROSS]['River Names'][station_ind, ]
  trimws(xs_river_name)
}

#' Function retrieves a desired time series from a cross section part of a
#' HEC-RAS model
#' @param .f an hdf5 file read in via hec_file or h5::h5file 
#' @param station_name station for the cross section to query time series from 
#' @param ts_type time series to query out (ex 'Water Surface', 'Depth', ...)
#' @export
extract_xs_ts <- function(.f, station_name, ts_type) {
  river_name <- get_xs_river_name(.f, station_name)
  reach_name <- get_xs_reach(.f, station_name)
  xs_index <- get_xs_station_index(.f, station_name)
  xs_datetime <- get_model_timestamps(.f)
  series <- .f[hdf_paths$RES_CROSS_SECTIONS][ts_type][, xs_index]
  d_length <- length(xs_datetime)
  data.frame("datetime" = xs_datetime, 
             "river_name" = rep(river_name, d_length), 
             "reach_name" = rep(reach_name, d_length), 
             "cross_section" = rep(station_name, d_length), 
             "values" = series)
}




