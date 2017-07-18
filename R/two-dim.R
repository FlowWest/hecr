#' Function retrieves the center coordinates for a given hec_file
#' @param .f a hdf file read in with \code{hec_file}
get_center_coordinates <- function(.f) {
  area_name <- get_flow_area_name(.f)
  .f[hdf_paths$GEOM_2D_AREAS][area_name]['Cells Center Coordinate'][]
}


#' Function returns the path to 2D flow area defined in the hdf file.
#' @param hf a hdf file read in with hec_file
#' @return a slash delmited path to the 2D flow area
get_flow_area_name <- function(hf) {
  path <- h5::list.groups(hf[hdf_paths$GEOM_2D_AREAS])[1]
  name <- tail(unlist(strsplit(path, '/')), 1)
  
  return(name)
}

#' Function returns the column index of the cell center coordinate nearest (x, y)
#' @param x coordinate 
#' @param y coordinate 
#' @param nodes set of nodes to calculate distance from
get_nearest_cell_center <- function(x, y, nodes) {
  coord <- c(x, y)
  dist <- colSums(sqrt((coord - t(nodes))^2))
  return(which.min(dist))
}

#' Function extracts a time series from an hdf file resulting 
#' from a HecRas model run. ts2 version is used for 2D portions of a Hec-Ras model.
#' @param .f an hdf file read in with hec_file or h5::h5file
#' @param x coordinate to query for
#' @param y coordinate to query for
#' @param ts_type the time series to extract
#' @return dataframe for desired timeseries with relevant column attributes
#' @export
extract_ts2 <- function(.f, x, y, ts_type = "Water Surface") {
  plan_attributes <- get_plan_attributes(.f)
  cc <- get_center_coordinates(.f)
  area_name <- get_flow_area_name(.f)
  nearest_cell_index <- get_nearest_cell_center(x, y, cc)
  series <- f[hdf_paths$RES_2D_FLOW_AREAS][area_name][ts_type][, nearest_cell_index]
  datetime <- get_model_timestamps(.f)
  
  # build desired dataframe 
  data.frame("datetime"=datetime,
             "cell_index" = rep(nearest_cell_index, length(datetime)),
             plan_name = rep(plan_attributes$plan_name, length(datetime)),
             "values"=series)
}