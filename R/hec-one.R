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
hec_one <- function(hc, station_name, ts_type, time_stamp=NULL) {
  
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



