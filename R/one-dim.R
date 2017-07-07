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


