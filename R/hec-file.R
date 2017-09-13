#' Function reads in an hdf5 file resulting from a HecRas model run. This function has been deprecated in favor of hec_file2
#' @param f an hdf5 file resulting from a HecRas model run 
#' @export
hec_file <- function(f) {
  list(h5::h5file(f))
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
#' @param files a vector of plan number associated with hdf files. For use when path is a directory.
#' Default action is to read all hdf files in path.
#' @return list of files read in with hec_file
#' @export
hec_file2 <- function(path, files = NULL) {
  # first check if path is a directory or single filename 
  is_dir <- dir.exists(path) 
  if (is_dir) { 
    hdf_files <- list.files(path, pattern = ".hdf", full.names = TRUE)
    # when a directory check if the files vector is not null
    if (!is.null(files)) {
      re <- paste(files, collapse = "|")
      hdf_files <- hdf_files[stringr::str_detect(hdf_files, re)]
    }
  } else {
    hdf_files <- path
  }
  
  purrr::map(hdf_files, h5::h5file)
}