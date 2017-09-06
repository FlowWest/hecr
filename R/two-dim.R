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

#' Function returns the column index of the cell center coordinate nearest to (x, y)
#' @param x coordinate 
#' @param y coordinate 
#' @param nodes set of nodes to calculate distance from
get_nearest_cell_center <- function(x, y, nodes) {
  coord <- c(x, y)
  dist <- colSums(sqrt((coord - t(nodes))^2))
  return(which.min(dist))
}

#' Function extracts a time series from an hdf file
#' @param .f an hdf file read in with hec_file or h5::h5file
#' @param x coordinate(s) to query for, if a vector it must be the same length as y argument
#' @param y coordinate(s) to query for, if a vector it must be the same length as x argument
#' @param ts_type the time series to extract
#' @return dataframe for desired timeseries with relevant column attributes
#' @export
extract_ts2 <- function(.f, x, y, ts_type = "Water Surface") {
  # check for a valid hec file object
  if (!is_hec_file(f)) 
    stop(".f argument passed in is not a valid hec file")
  
  # check for proper dimensions on x, y coords
  if (length(x) != length(y))
    stop("'x' and 'y' are of different lengths")
  
  m <- matrix(cbind(x, y), ncol = 2)
  
  plan_attributes <- get_plan_attributes(.f)
  cc <- get_center_coordinates(.f)
  area_name <- get_flow_area_name(.f)
  
  # for set of all pairs (x, y) find the nearest cell index  
  nearest_cell_index <- sapply(seq_len(nrow(m)), function(i) {
    get_nearest_cell_center(m[i,1], m[i,2], cc)
  }) 
  
  # get series from hdf file
  series <- f[hdf_paths$RES_2D_FLOW_AREAS][area_name][ts_type][, nearest_cell_index][, seq_len(length(nearest_cell_index))]
  series_stacked <- matrix(series, ncol=1, byrow=FALSE)

  # time stamps are constants for the whole mode
  # this should be used as length of each time series
  datetime <- get_model_timestamps(.f)
  
  # vector used as columns for cell_index used in data
  hdf_cell_index <- rep(nearest_cell_index, each=length(datetime))
  
  # build desired dataframe
  # cell_index below returns the value reported on the hecRas file (which is 1 minus R's)
  tibble::tibble("datetime"=rep(datetime, length(nearest_cell_index)),
                 plan_name = rep(plan_attributes$plan_name, nrow(series_stacked)),
                 "time_series_type" = rep(ts_type, length(series_stacked)),
                 "hdf_cell_index" = hdf_cell_index,
                 "values"=series_stacked[, 1])
} 