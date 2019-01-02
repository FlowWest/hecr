#' @title Query 2d Model Results
#' @description hec_two allows you query a time series from a hec-ras model result
#' using one more coordinates and an optional time stamp.
#' @param f an hdf file read in with the hec_file() function
#' @param ts_type the time series to extract, option defaults to Water Surface
#' @param xy a coordinate or set of coordinates either in a dataframe, matrix, or vector form. See
#' details below for more information. 
#' @param time_stamp return only values with this timestamp
#' @details 
#' You can supply the coordinate(s) to hec_two in a number of ways. A vector with even length, 
#' here it is assumed that subsequent pairs are coordinates (i.e c(1, 2, 3, 4) is two coordinates
#' (1, 2) and (3, 4)). You can also supply coordinates in as a matrix. The matrix must have two columns, 
#' the first corresponding to the x the second to y. Lastly you can supply a dataframe with any number 
#' columns as long as the coordinates columns are labeled 'x' and 'y'.
#' @examples
#' \dontrun{
#' ## first read in file
#' f <- hec_file("examples/ArdenwoodCreek.p50.hdf")
#' 
#' ## water surface time series at the coordinate 4567654.0, 2167453.0
#' ws <- hec_two(f, xy=c(4567654.0, 2167453.0), "Water Surface")
#' 
#' ## water surface time series at multiple coordinates
#' coords <- c(4567654.0, 2167453.0, 3456124.0, 7856124.0)
#' ws <- hec_two(f, xy=coords, "Water Surface")
#' 
#' ## water surface for a fixed timestamp, useful when querying for large amounts of coordinates. 
#' ws <- hec_two(f, xy=c(4567654.0, 2167453.0), "Water Surface", timestamp="2005-09-12 00:00:00")
#' }
#' @export
hec_two <- function(f, xy, ts_type = "Water Surface", time_stamp = NULL) {
  
  timestamps <- hec_timestamps_(f)
  attrs <- hec_info(f$object) 
  area_name <- hec_flow_area_(f)
  model_center_coordinates <- hec_center_coords_(f, area_name)
  
  # if stamp is supplied make sure it exists, otherwise use all timestamps
  # in the model as the timestamp
  if (!is.null(time_stamp)) {
    time_idx <- which(timestamps == time_stamp)
    if (length(time_idx) == 0) stop("supplied value for time_stamp was not found in the model", 
                                    call. = FALSE)
  } else {
    time_idx <- seq_len(length(timestamps))
  }
  
  input_coordinates <- make_coordinate_df(xy)
  colnames(input_coordinates) <- c("V1", "V2")
  
  cat("number of rows after transformation: ", nrow(input_coordinates), "\n")
  coordinates_df <- input_coordinates %>% 
    dplyr::mutate(
      nearest_cell_index = 
        purrr::map2_dbl(V1, V2, ~get_nearest_cell_center_index(c(.x, .y), model_center_coordinates))
    ) %>% 
    dplyr::distinct(nearest_cell_index, .keep_all = TRUE) %>% 
    dplyr::arrange(nearest_cell_index)
  
  cat("no rows after center cell mapping", nrow(coordinates_df), "\n")

  time_series <- f$object[[hdf_paths$RES_2D_FLOW_AREAS]][[area_name]][[ts_type]][coordinates_df[["nearest_cell_index"]], time_idx]

  stacked_time_series <- matrix(t(time_series), ncol=1, byrow = TRUE)
  
  hdf_cell_index <- coordinates_df[["nearest_cell_index"]] - 1
  
  tibble::tibble(
    "datetime" = rep(timestamps[time_idx], nrow(coordinates_df)), 
    "plan_id" = attrs$plan_short_id,
    "plan_file" = attrs$plan_file,
    "time_series_type" = ts_type, 
    "hdf_cell_index" = rep(hdf_cell_index, each = length(time_idx)), 
    "xin" = rep(coordinates_df$V1, each = length(time_idx)),
    "yin" = rep(coordinates_df$V2, each = length(time_idx)),
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

make_coordinate_df <- function(x) {
  if (is.matrix(x)) {
    if (anyDuplicated(x)) {
      warning("Duplicate values found in coordinate pairs, only unique pairs were kept")
      return(as.data.frame(matrix(x[!duplicated(x), ], ncol=2, byrow=TRUE), col.names = c("x", "y")))
    } else 
      return(as.data.frame(x, col.names = c("x", "y"))) 
  } else { 
    if (length(x) %% 2 != 0) stop("vector must have pairs of coordinates, your vector is of odd length", call. = FALSE)
    m <- matrix(x, ncol=2, byrow=TRUE)
    if (anyDuplicated(m)) {
      warning("Duplicate values found in coodinate pairs, only unique pairs were kept")
      return(as.data.frame(matrix(m[!duplicated(m), ], ncol=2, byrow=TRUE)), col.names=c("x", "y"))
    } else {
      return(as.data.frame(m, col.names=c("x", "y")))
    }
  }
}