#' Function extracts a time series from 2D portion of hec ras model.
#' @param .f an hdf file read in with hec_file or h5::h5file
#' @param ts_type the time series to extract, option defaults to 'Water Surface'
#' @param xy a coordinate or set of coordinates either in a dataframe or matrix with columns x and y 
#' @return dataframe for desired timeseries with relevant column attributes
#' @export
extract_ts2 <- function(.f, xy, ts_type = "Water Surface", timestamp = NULL) {
  
  do_extract <- function(f, xy, ts_type) {
    
    plan_id <- get_plan_attributes(f)$plan_short_id
    center_coordinates <- get_center_coordinates(f)
    area_name <- get_flow_area_name(f)
    model_datetimes <- get_model_timestamps(f)
    
    index_for_timestamp <- {
      if(!is.null(timestamp)) which(model_datetimes == timestamp)
      else seq_len(length(model_datetimes))
    }
    
    if (!is.null(timestamp) & (length(index_for_timestamp) == 0)) 
      stop(paste0("timestamp '", timestamp, "' does not match a datetime in the model"))
    
    m <- make_coord_matrix(xy)
    
    # TODO: evaluate whether this should be a call to purrr::map
    nearest_cell_index <- sapply(seq_len(nrow(m)), function(i) {
      get_nearest_cell_center_index(m[i,1], m[i,2], center_coordinates)
    }) 
    
    # get series from hdf file
    series <- f[hdf_paths$RES_2D_FLOW_AREAS][area_name][ts_type][index_for_timestamp, nearest_cell_index]
    series_stacked <- matrix(series, ncol=1, byrow=FALSE)
    
    length_of_timestamps <- length(index_for_timestamp)
    
    # vector used as columns for cell_index used in data
    # here a subtract one is required to bring the index back to 
    # what is reported by hecRas, which uses a 0 based index
    hdf_cell_index <- rep(nearest_cell_index, each=length_of_timestamps) - 1
    
    
    # build desired tibble
    tibble::tibble("datetime"=rep(model_datetimes[index_for_timestamp], length(nearest_cell_index)),
                   "plan_id" = plan_id,
                   "time_series_type" = ts_type,
                   "hdf_cell_index" = hdf_cell_index,
                   "values"=series_stacked[, 1])
  } 
  
  x <- purrr::map_dfr(.f, ~do_extract(., xy, ts_type))
  attr(x, "hec_obj") <- f
  x
} 

## INTERNAL 

make_coord_matrix <- function(x) {
  if (is.matrix(x)) {
    if (anyDuplicated(x)) {
      warning("Duplicate values found in coordinate pairs, only unique pairs were kept")
      return(matrix(x[!duplicated(x), ], ncol=2, byrow=TRUE))
    } else 
      return(x) 
  } else { 
    if (length(x) %% 2 != 0) stop("vector must have pairs of coordinates, your vector is of odd length")
    m <- matrix(x, ncol=2, byrow=TRUE)
    if (anyDuplicated(m)) {
      warning("Duplicate values found in coodinate pairs, only unique pairs were kept")
      return(matrix(m[!duplicated(m), ], ncol=2, byrow=TRUE))
    } else {
      return(m)
    }
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
