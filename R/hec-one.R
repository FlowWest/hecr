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
  
  model_timestamps <- hec_timestamps(hc) 
  model_stations <- trimws(hc$object[['Geometry/Cross Sections/River Stations']]$read())
  
  # when user supplied a timestamp
  if (!is.null(time_stamp)) {
    time_idx <- which(model_timestamps == time_stamp)
    if (length(time_idx) == 0) stop("supplied value for time_stamp was not found in the model", 
                                    call. = FALSE)
  } else {
    time_idx <- seq_len(length(model_timestamps))
  }
  
  
  cross_section_index <- which(model_stations %in% station_name)
  
  if (length(cross_section_index) == 0L) {
    stop("supplied stations were not found in the model")
  }
  
  valid_stations <- station_name[which(station_name %in% model_stations)]
  
  if (length(cross_section_index) != length(station_name)) {
    warning("not all stations supplied were found in the model, using valid stations only. \n", 
            "The following were not found and ignored:\n- ", 
            paste(station_name[which(!(station_name %in% model_stations))], collapse = "\n- "),
            call. = FALSE)
  }
  
  
  cross_section_reach <- trimws(hc$object[[hdf_paths$GEOM_CROSS]][["Reach Names"]]$read()[cross_section_index])
  cross_section_river <- trimws(hc$object[[hdf_paths$GEOM_CROSS]][["River Names"]]$read()[cross_section_index])
  
  time_series <- hc$object[[hdf_paths$RES_CROSS_SECTIONS]][[ts_type]][cross_section_index, time_idx]
  other_attr_lengths <- length(station_name) * length(time_idx)
  time_series_stacked <- matrix(t(time_series[]), ncol = 1, byrow = TRUE)
  
  tibble::tibble(
    "datetime" = rep(model_timestamps[time_idx], length(cross_section_index)), 
    "plan_id" = hc$attrs$plan_short_id, 
    "plan_name" = hc$attrs$plan_name,
    "plan_file" = hc$attrs$plan_file,
    "cross_section_reach" = rep(cross_section_reach, each = length(time_idx)), 
    "cross_section_river" = rep(cross_section_river, each=length(time_idx)), 
    "station" = rep(valid_stations, each = length(time_idx)),
    "values" = as.vector(time_series_stacked)
  )
  
}
