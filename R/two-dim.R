
extract_ts2 <- function(f, xy, ts_type = "Water Surface", timestamp = NULL) {
  
  do_extract <- function(.f, xy, ts_type) {
    
    # get per plan metadata
    plan_id <- get_plan_attributes(.f)$plan_short_id
    area_name <- get_flow_area_name(.f)
    center_coordinates <- get_center_coordinates(.f, area_name)
    model_datetimes <- get_model_timestamps(.f)
    
    if (!is.null(timestamp)) {
      timestamp_index <- which(model_datetimes == timestamp)
    } else {
      timestamp_index <- seq_len(length(model_datetimes))
    }

    if (!is.null(timestamp) & (length(timestamp_index) == 0)) 
      stop(paste0("timestamp '", timestamp, "' does not match a datetime in the model"))
    
    m <- make_coordinate_matrix(xy)
    
    # TODO: evaluate whether this should be a call to purrr::map
    nearest_cell_index <- sapply(seq_len(nrow(m)), function(i) {
      get_nearest_cell_center_index(m[i,1], m[i,2], center_coordinates)
    }) 
    
    print(timestamp_index)
    print(nearest_cell_index)
    
    # get series from hdf file
    series <- .f[hdf_paths$RES_2D_FLOW_AREAS][area_name][ts_type][timestamp_index, nearest_cell_index]
    series_stacked <- matrix(series, ncol=1, byrow=FALSE)
    
    length_of_timestamps <- length(timestamp_index)
    
    # vector used as columns for cell_index used in data
    # here a subtract one is required to bring the index back to 
    # what is reported by hecRas, which uses a 0 based index
    hdf_cell_index <- rep(nearest_cell_index, each=length_of_timestamps) - 1
    
    
    # build desired tibble
    tibble::tibble("datetime"=rep(model_datetimes[timestamp_index], length(nearest_cell_index)),
                   "plan_id" = plan_id,
                   "time_series_type" = ts_type,
                   "hdf_cell_index" = hdf_cell_index,
                   "values"=series_stacked[, 1])
  } 
  
  #purrr::map_dfr(f, ~do_extract(., xy, ts_type))
  lapply(f, function(x) {
    do_extract(x, xy, ts_type)
  })
} 

## INTERNAL 

make_coordinate_matrix <- function(x) {
  if (is.matrix(x)) {
    if (anyDuplicated(x)) {
      warning("Duplicate values found in coordinate pairs, only unique pairs were kept")
      return(matrix(x[!duplicated(x), ], ncol=2, byrow=TRUE))
    } else 
      return(x) 
  } else { 
    if (length(x) %% 2 != 0) stop("vector must have pairs of coordinates, your vector is of odd length", call. = FALSE)
    m <- matrix(x, ncol=2, byrow=TRUE)
    if (anyDuplicated(m)) {
      warning("Duplicate values found in coodinate pairs, only unique pairs were kept")
      return(matrix(m[!duplicated(m), ], ncol=2, byrow=TRUE))
    } else {
      return(m)
    }
  }
}

get_center_coordinates <- function(f, area_name) {
  f[hdf_paths$GEOM_2D_AREAS][area_name]['Cells Center Coordinate']
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
