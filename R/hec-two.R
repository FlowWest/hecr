#' @title Query coordinate 2d data
#' @description Function extracts a time series from a 2D portion of hec ras model.
#' @param .f an hdf file read in with hec_file
#' @param ts_type the time series to extract, option defaults to Water Surface
#' @param xy a coordinate or set of coordinates either in a dataframe or matrix 
#' with columns x and y
#' @examples
#' \dontrun{
#' ## first read in file
#' f <- hec_file("examples/ArdenwoodCreek.p50.hdf")
#' 
#' ## water surface time series at the coordinate 4567654.0, 2167453.0
#' ws <- extract_ts2(f, xy=c(4567654.0, 2167453.0), "Water Surface")
#' 
#' ## water surface time series at multiple coordinates
#' coords <- c(4567654.0, 2167453.0, 3456124.0, 7856124.0)
#' ws <- extract_ts2(f, xy=coords, "Water Surface")
#' 
#' ## water surface for a fixed timestamp, useful when querying for large amounts of coordinates. 
#' ws <- extract_ts2(f, xy=c(4567654.0, 2167453.0), "Water Surface", timestamp="2005-09-12 00:00:00")
#' }
#' @export
hec_two <- function(hc, xy, ts_type = "Water Surface", time_stamp = NULL) {
  
  timestamps <- hec_timestamps_(hc)
  attrs <- hec_info(hc) 
  area_name <- hec_flow_area_(hc)
  model_center_coordinates <- hec_center_coords_(hc, area_name)
  
  if (!is.null(time_stamp)) {
    time_idx <- which(timestamps == time_stamp)
    if (length(time_idx) == 0) stop("supplied value for time_stamp was not found in the model", 
                                    call. = FALSE)
  } else {
    time_idx <- seq_len(length(timestamps))
  }
  
  input_coordinates <- make_coordinate_matrix(xy)
  
  nearest_cell_index <- sapply(seq_len(nrow(input_coordinates)), function(i) {
    get_nearest_cell_center_index(input_coordinates[i,], model_center_coordinates)
  }) 
  
  mapped_to_existing_cell <- duplicated(unlist(nearest_cell_index))
  nearest_cell_index_values <- sort(unique(unlist(nearest_cell_index)))
  
  # Warn the user when some coordinates provided were within the same cell
  if (length(nearest_cell_index) != length(nearest_cell_index_values)) {
    warning("some of the coordinates provided were mapped to the same cell", 
            call. = FALSE)
  }
  
  print(class(nearest_cell_index_values))  
  print(length(nearest_cell_index_values))
  print(nearest_cell_index_values)
  
  time_series <- hc$object[[hdf_paths$RES_2D_FLOW_AREAS]][[area_name]][[ts_type]][nearest_cell_index_values, time_idx]
  
  print(class(time_series))
  print(length(time_series))
  stacked_time_series <- matrix(t(time_series), ncol=1, byrow = TRUE)
  
  hdf_cell_index <- nearest_cell_index_values - 1
  
  tibble::tibble(
    "datetime" = rep(timestamps[time_idx], length(nearest_cell_index_values)), 
    "plan_id" = attrs$plan_short_id,
    "plan_file" = attrs$plan_file,
    "time_series_type" = ts_type, 
    "hdf_cell_index" = rep(hdf_cell_index, each = length(time_idx)), 
    "xin" = rep(input_coordinates[!mapped_to_existing_cell, 1], each = length(time_idx)),
    "yin" = rep(input_coordinates[!mapped_to_existing_cell, 2], each = length(time_idx)),
    "values" = as.vector(stacked_time_series)
  )

}


# INTERNALS

# the structure of the return is a matrix with columns are cells and rows
# are x, y coordinates i.e m[, 1] gives coordinates of cell 1 in column vector form

hec_flow_area_ <- function(f) {
  path_to_areas <- "Results/Unsteady/Output/Output Blocks/Base Output/Unsteady Time Series/2D Flow Areas"
  names(f$object[[path_to_areas]])
}

hec_center_coords_ <- function(f, area_name) {
  d <- f$object[[hdf_paths$GEOM_2D_AREAS]][[area_name]][["Cells Center Coordinate"]]
  on.exit(d$close())
  
  return(d[,])
}

get_nearest_cell_center_index <- function(coords, nodes) {
  dist <- colSums(sqrt((coords - nodes)^2))
  which.min(dist)[1]
}

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
