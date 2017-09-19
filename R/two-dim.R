#' Function extracts a time series from an hdf file
#' @param .f an hdf file read in with hec_file or h5::h5file
#' @param ts_type the time series to extract
#' @param xy a coordinate or set of coordinates either in a dataframe or matrix with columns x and y 
#' @return dataframe for desired timeseries with relevant column attributes
#' @export
extract_ts2 <- function(.f, xy, ts_type = "Water Surface") {
  
  do_extract <- function(f, xy, ts_type) {
    plan_attributes <- get_plan_attributes(f)
    cc <- get_center_coordinates(f)
    area_name <- get_flow_area_name(f)
    
    m <- make_coord_matrix(xy)
    
    # for set of all pairs (x, y) find the nearest cell index  
    nearest_cell_index <- sapply(seq_len(nrow(m)), function(i) {
      get_nearest_cell_center_index(m[i,1], m[i,2], cc)
    }) 
    
    # get series from hdf file
    series <- f[hdf_paths$RES_2D_FLOW_AREAS][area_name][ts_type][, nearest_cell_index][, seq_len(length(nearest_cell_index))]
    series_stacked <- matrix(series, ncol=1, byrow=FALSE)
    
    # time stamps are constants for the whole model
    # if anything needs to be repeated it should be based
    # on the length of this vector
    datetime <- get_model_timestamps(f)
    
    # vector used as columns for cell_index used in data
    # here a subtract one is required to bring the index back to 
    # what is reported by hecRas, which uses 0 based indexes
    hdf_cell_index <- rep(nearest_cell_index, each=length(datetime)) - 1
    
    # build desired tibble
    tibble::tibble("datetime"=rep(datetime, length(nearest_cell_index)),
                   "plan_id" = rep(plan_attributes$plan_short_id, nrow(series_stacked)),
                   "time_series_type" = rep(ts_type, length(series_stacked)),
                   "hdf_cell_index" = hdf_cell_index,
                   "values"=series_stacked[, 1])
  }
  
  x <- purrr::map_dfr(.f, ~do_extract(., xy, ts_type))
  attr(x, "hec_obj") <- f
  x
}

## INTERNAL 

make_coord_matrix <- function(x) {
  if (is.matrix(x)) return(x) 
  else {
    if (length(x) %% 2 != 0) stop("vector must have pairs of coordinates, your vector is of odd length")
    m <- matrix(x, ncol=2, byrow=TRUE)
    return(m)
  }
}

get_center_coordinates <- function(f) {
  area_name <- get_flow_area_name(f)
  f[hdf_paths$GEOM_2D_AREAS][area_name]['Cells Center Coordinate'][]
}

get_flow_area_name <- function(hf) {
  path <- h5::list.groups(hf[hdf_paths$GEOM_2D_AREAS])[1]
  name <- tail(unlist(strsplit(path, '/')), 1)
  
  return(name)
}

get_nearest_cell_center_index <- function(x, y, nodes) {
  coord <- c(x, y)
  dist <- colSums(sqrt((coord - t(nodes))^2))
  return(which.min(dist))
}
