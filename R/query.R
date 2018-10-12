#' @title Query coordinate 2d data
#' @description Function extracts a time series from a 2D portion of hec ras model.
#' @param f an hdf file read in with the hec_file() function
#' @param ts_type the time series to extract, option defaults to Water Surface
#' @param xy a coordinate or set of coordinates either in a dataframe or matrix 
#' @param time_stamp return only values with this timestamp
#' with columns x and y
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
hec_query2 <- function(f, xy, ts_type = "Water Surface", time_stamp = NULL) {
  
  timestamps <- hec_timestamps_(f)
  attrs <- hec_info(f) 
  area_name <- hec_flow_area_(f)
  model_center_coordinates <- hec_center_coords_(f, area_name)
  
  # if stamp is supplied make sure it exists, other use all timestamps
  # in the model as the timestamp
  if (!is.null(time_stamp)) {
    time_idx <- which(timestamps == time_stamp)
    if (length(time_idx) == 0) stop("supplied value for time_stamp was not found in the model", 
                                    call. = FALSE)
  } else {
    time_idx <- seq_len(length(timestamps))
  }
  
  input_coordinates <- make_coordinate_df(xy)
  # colnames(input_coordinates) <- c("V1", "V2")
  
  coordinates_df <- input_coordinates %>% 
    dplyr::mutate(
      nearest_cell_index = 
        purrr::map2_dbl(V1, V2, ~get_nearest_cell_center_index(c(.x, .y), model_center_coordinates))
    ) %>% 
    dplyr::distinct(nearest_cell_index, .keep_all = TRUE) %>% 
    dplyr::arrange(nearest_cell_index)
  
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

#' @title Query one dimensional domains
#' @description provide station(s), a type of time series and optionally a timestamp
#' to query out data from an hdf5 file resulting from a HEC-RAS model run
#' @param hc a hec object. See ?hec_file for more.
#' @param station_name name(s) for station(s) defined in the model run. See ?hec_crosssections for more.
#' @param ts_type a valid time series type defined in the model run
#' @export 
#' @examples 
#' \dontrun{
#' h <- hec_file("~/Docs/hec-model-run.hdf")
#' data <- hec_one(hc=h, station="19135.6", ts_type="Water Surface")
#' }
hec_query <- function(hc, station_name, ts_type, time_stamp=NULL) {
  
  if (!inherits(hc, "hec")) {
    stop("hc is not an object of type 'hec', use hec_file() to read in data", 
         call. = FALSE)
  }
  
  model_timestamps <- hec_timestamps_(hc) 
  model_stations <- hec_crosssections(hc)
  
  # when user supplied a timestamp
  if (!is.null(time_stamp)) {
    time_idx <- which(model_timestamps == time_stamp)
    if (length(time_idx) == 0) stop("supplied value for time_stamp was not found in the model", 
                                    call. = FALSE)
  } else {
    time_idx <- seq_len(length(model_timestamps))
  }
  
  
  cross_section_index <- cross_section_index(model_stations, station_name)
  cross_section_reach <- trimws(hc$object[[hdf_paths$GEOM_CROSS]][["Reach Names"]]$read()[cross_section_index])[1]
  cross_section_river <- trimws(hc$object[[hdf_paths$GEOM_CROSS]][["River Names"]]$read()[cross_section_index])[1]
  
  time_series <- hc$object[[hdf_paths$RES_CROSS_SECTIONS]][[ts_type]][cross_section_index, time_idx]
  other_attr_lengths <- length(station_name) * length(time_idx)
  time_series_stacked <- matrix(t(time_series[]), ncol = 1, byrow = TRUE)
  
  tibble::tibble(
    "datetime" = rep(model_timestamps[time_idx], length(cross_section_index)), 
    "plan_id" = hc$attrs$plan_short_id, 
    "plan_name" = hc$attrs$plan_name,
    "plan_file" = hc$attrs$plan_file,
    "cross_section_reach" = cross_section_reach, 
    "cross_section_river" = cross_section_river, 
    "station" = rep(station_name, each = length(time_idx)),
    "values" = as.vector(time_series_stacked)
  )
  
}

#' Plan Cross Sections
#' @description Extract the crossections for a given hec collection
#' @param hc a hec_collection
#' @return data frame 
#' @export
hec_crosssections <- function(hc) {
  if (!inherits(hc, "hec")) {
    stop("supplied argument is not a 'hec' object", call. = FALSE)
  }
  
  trimws(hc$object[['Geometry/Cross Sections/River Stations']]$read())
}

# INTERNALS 

cross_section_index <- function(model_stations, station) {
  cross_section_idx <- which(model_stations %in% station)
  
  if (is_empty(cross_section_idx)) {
    stop(sprintf("supplied station '%s' not found in model", station), call. = FALSE)
  }
  
  cross_section_idx
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