#' @title Read hec file
#' @description read in a hdf file resulting from a hec-ras model run
#' @param path string path to hdf file
#' @export
#' @return a hec object
hec_file <- function(path) {
  filename <- basename(path)
  hec <- hdf5r::H5File$new(path, mode="r")
  info <- hec_info(hec)
  structure(
    list(
      filename=basename(hec$filename),
      attrs=info,
      object=hec
    ), 
    class="hec"
  )
}

#' Print hec 
#' @export
print.hec <- function(hc) {
  cat("A hec object----\n")
  cat("Plan File:", hc$attrs$plan_file, "\n")
  cat("Plan Name:", hc$attrs$plan_name, "\n")
  cat("Geom Name:", hc$attrs$geometry_name, "\n")
}

#' check hecras version 
hecras_version <- function(hdf5_object) {
  x <- stringr::str_match(hdf5r::h5attr(hdf5_object, "File Version"),
              "([0-9]{1})\\.([0-9]{1})\\.([0-9]{1})")
  
  list(full=x[1, 1],first=x[1,2], second=x[1,3], third=x[4])
}



# get all the top level attributes for the hecras hdf5 file
hec_info <- function(hc) {
  
  info_path <- "Plan Data/Plan Information"
  
  hecras_file_version <- hecras_version(hc)
  
  # these new versions have a new names for the attributes 
  if (as.numeric(hecras_file_version$third) >= 6) {
    
    list(
      plan_short_id = hdf5r::h5attr(hc[[info_path]], 
                                    which = "Plan ShortID"),
      plan_name = hdf5r::h5attr(hc[[info_path]], 
                                which = "Plan Title"), 
      plan_file = stringr::str_extract(hdf5r::h5attr(hc[[info_path]], 
                                                     which = "Plan Filename"), 
                                       "[A-Za-z0-9_-]+\\.[a-z0-9]+$"), 
      computation_time_step = hdf5r::h5attr(hc[[info_path]], 
                                            which = "Computation Time Step Base"), 
      geometry_name = stringr::str_extract(hdf5r::h5attr(hc[[info_path]], 
                                                         which = "Geometry Filename"), "[A-Za-z0-9_-]+\\.[a-z0-9]+$"), 
      geometry_title = hdf5r::h5attr(hc[[info_path]], 
                                     which = "Geometry Title"), 
      output_interval = hdf5r::h5attr(hc[[info_path]], 
                                      which = "Base Output Interval")
    )
    
  } else {
    list(
      plan_short_id = hdf5r::h5attr(hc[[info_path]], 
                                    which = "Plan ShortID"),
      plan_name = hdf5r::h5attr(hc[[info_path]], 
                                which = "Plan Name"), 
      plan_file = stringr::str_extract(hdf5r::h5attr(hc[[info_path]], 
                                                     which = "Plan Filename"), 
                                       "[A-Za-z0-9_-]+\\.[a-z0-9]+$"), 
      computation_time_step = hdf5r::h5attr(hc[[info_path]], 
                                            which = "Computation Time Step"), 
      geometry_name = stringr::str_extract(hdf5r::h5attr(hc[[info_path]], 
                                                         which = "Geometry Name"), "[A-Za-z0-9_-]+\\.[a-z0-9]+$"), 
      geometry_title = hdf5r::h5attr(hc[[info_path]], 
                                     which = "Geometry Title"), 
      output_interval = hdf5r::h5attr(hc[[info_path]], 
                                      which = "Output Interval")
    )
   
  }
  
  
}
