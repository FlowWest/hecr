#' Function reads in an hdf5 file resulting from a HecRas model run. This function has been deprecated in favor of hec_file2
#' @param f an hdf5 file resulting from a HecRas model run 
#' @export
hec_file <- function(f) {
  .Deprecated("hec_file2", package = "hecr", msg = "use hec_file2")
  hec_file2(path = f)
}

#' Check whether an object is of hec_file class and not a null pointer
is_hec_file <- function(f) {
  if (attr(f, "class") == "H5File") # if true class check for null pointer
    !identical(f@pointer, new("externalptr"))
  else 
    FALSE
}

#' Function reads in either a single hdf file or a collection of these specified as arguments. 
#' It incorporates both hec_file and hdf_corpus into one function call from previous releases.
#' @param path directory path to either a single hdf file or a directory of a collection of these
#' @param plan_numbers a vector of plan number associated with hdf files. For use when path is a directory.
#' Default action is to read all hdf files in path.
#' @return list of files read in with hec_file
#' @export
hec_file2 <- function(path, plan_numbers = NULL) {
  # first check if path is a directory or single filename 
  is_dir <- dir.exists(path) 
  if (is_dir) { 
    hdf_files <- list.files(path, pattern = ".hdf", full.names = TRUE)
    msg <- paste0("found ", length(hdf_files), " in ", path)
    if (!length(hdf_files)) stop(paste("No hdf files found in:", path))
    # when a directory check if the files vector is not null
    if (!is.null(plan_numbers)) {
      re <- paste(plan_numbers, collapse = "|")
      hdf_files <- hdf_files[stringr::str_detect(hdf_files, re)]
      msg <- paste0("found ", length(hdf_files), " hdf files in ", path, " matching plan names criteria")
      # error when no matches were made
      if (!length(hdf_files)) stop(paste("No hdf files found in:", path, "with plan name(s):", 
                                         paste(plan_numbers, collapse = ", ")))
      # warning when only some matched 
      if (length(hdf_files) != length(plan_numbers)) {
        warning("One or more hdf files were not read in correctly")
      }
    }
  } else {
    hdf_files <- path
    msg <- NULL
  }
  
  if (!is.null(msg)) message(msg)
  
  purrr::map(hdf_files, h5::h5file)
}
