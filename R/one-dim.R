#' Function returns cross section stations defined in the model
#' @param .f an hdf5 file read in with hec_file or h5::h5file
#' @export
get_xs_river_stations <- function(.f) {
  xs_stations <- .f[hdf_paths$GEOM_CROSS]['River Stations']
  return(xs_stations[])
}

#' Function returns the index for a desired station name
#' @param .f an hdf5 file read in with hec_file or h5::h5file
#' @param station_name name of the station to query data for
get_xs_station_index <- function(.f, station_name) {
  xs_stations <- get_xs_river_stations(.f)
  xs_index <- which(xs_stations %in% station_name)
  
  if (!length(xs_index)) {
    stop(paste0("station name '",station_name,"' not found in hdf5 file"))
  }
  
  return(xs_index)
}

#' Function retrives the reach defined by the station name
#' @param .f an hdf5 file read in with hdf_file or h5::h5file
#' @param station_idx index of station to query reach name for, obtained from get_xs_station_index
get_xs_reach <- function(.f, station_idx) {
  xs_reach <- .f[hdf_paths$GEOM_CROSS]['Reach Names'][station_idx, ]
  trimws(xs_reach)
}

#' Function retrives the river name defined by the station name
#' @param .f an hdf5 file read in with hec_file or h5::h5file
#' @param station_idx index of the station to query river name for, obtained from get_xs_station_index
get_xs_river_name <- function(.f, station_idx) {
  xs_river_name <- .f[hdf_paths$GEOM_CROSS]['River Names'][station_idx, ]
  trimws(xs_river_name)
}

#' Function retrieves a desired time series from a cross section part of a
#' HEC-RAS model
#' @param f an hdf5 file read in via hec_file or a corpus created with create_hdf_corpus
#' @param station_name station for the cross section to query time series from 
#' @param ts_type time series to query out (ex 'Water Surface', 'Depth', ...)
#' @export
extract_ts1 <- function(f, station_name, ts_type) {
  # TODO: @2017-09-18 I think a recent commit solves this issue please look into it
  if (!is.list(f)) f <- list(f) # hack: look for piece below that is affected when 
                                # when we pass either a list or vector
  
  do_extract <- function(.f, station_name, ts) {
    plan_name <- get_plan_attributes(.f)$plan_name
    xs_index <- get_xs_station_index(.f, station_name)
    river_name <- get_xs_river_name(.f, xs_index)
    reach_name <- get_xs_reach(.f, xs_index)
    xs_datetime <- get_model_timestamps(.f)
    d_length <- length(xs_datetime)
    series <- matrix(.f[hdf_paths$RES_CROSS_SECTIONS][ts_type][, xs_index], 
                     ncol=1, byrow=FALSE)
    
    tibble:::tibble("datetime" = rep(xs_datetime, length(xs_index)),
                    "plan_name" = plan_name,
                    "river_name" = rep(river_name, each=d_length), 
                    "reach_name" = rep(reach_name, each=d_length), 
                    "cross_section" = rep(station_name, each=d_length), 
                    "values" = series[,1])  
  }
  
  purrr::map_dfr(f, ~do_extract(., station_name, ts_type))
  
}




