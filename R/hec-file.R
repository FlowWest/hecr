#' @title Read hec file
#' @description read in a hdf file resulting from a hec-ras model run
#' @param path string path to hdf file
#' @export
#' @return a hec object
hec_file <- function(path, mode="r") {
  filename <- basename(path)
  hec <- hdf5r::H5File$new(path, mode=mode)
  info <- hec_info_(hec)
  structure(
    list(
      filename=basename(hec$filename),
      attrs=info,
      object=hec
    ), 
    class="hec"
  )
}


#' @title Hec attributes
#' @description get all attributes relating to a hec object
#' @param hc a hec objet
#' @return list of attributes
#' @export
hec_info <- function(hc) {
  return(hc$attr)
}

#' Print hec 
#' @export
print.hec <- function(f) {
  cat("A hec object ----\n")
  cat("  Plan File:", f$attrs$plan_file, "\n")
  cat("  Plan Name:", f$attrs$plan_name, "\n")
  cat("  Geom Name:", f$attrs$geometry_name, "\n")
  cat("  Out Inteval:", f$attrs$output_interval, "\n")
}

#' Show tree directory of hdf file
#' @export
tree <- function(f, depth=2) {
  is_dataset <- function(x) {
    inherits(x, "H5D")
  }
  
  if (!inherits(f, "hec")) {
    stop("argument is not a 'hec' object")
  }
  
  for (i in f$object$ls()$name) {
    cat("*Group: ", i, "\n")
    for (j in f$object[[i]]$ls()$name) {
      if (depth==1) next
      if (is.null(j)) next
      cat("\t|\n")
      cat("\t--", j, "\n")
      for (z in f$object[[i]][[j]]$ls()$name) {
        if (depth==2) next
        if (is.null(z)) next
        cat("\t\t|\n")
        cat("\t\t--", z)
        if (is_dataset(f$object[[i]][[j]][[z]])) {
          cat(" (dataset)*\n")
          next
        } 
        cat("\n")
        for (w in f$object[[i]][[j]][[z]]$ls()$name) {
          if (depth==3) next
          if (is.null(w)) next
          cat("\t\t\t|\n")
          cat("\t\t\t--", w, "\n")
        }
      }
    }
    cat("\n")
  }
}


#' Get Plan Information
hec_info_ <- function(hc) {
  
  # if (!inherits(hc, "hec")) {
  #   stop("argument is not a 'hec' object")
  # }
  
  info_path <- "Plan Data/Plan Information"
  
  list(
    plan_short_id = hdf5r::h5attr(hc[[info_path]], 
                                  which = "Plan ShortID"),
    plan_name = hdf5r::h5attr(hc[[info_path]], 
                              which = "Plan Name"), 
    plan_file = stringr::str_extract(hdf5r::h5attr(hc[[info_path]], 
                                                   which = "Plan File"), 
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
