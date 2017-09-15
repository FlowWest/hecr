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
#' @description Function will read in a single hdf file when the path parameter points to a single
#' file, or a collection of these when the path is directory. User can further specify only a 
#' certain number of these within the directory to be read using the plan_numbers parameter.
#' @param path directory path to either a single hdf file or a directory of a collection of these
#' @param plan_numbers a vector of plan number associated with hdf files. For use when path is a directory.
#' Default action is to read all hdf files in path.
#' @return list of files read in with hec_file
#' @examples 
#' \dontrun{
#' # read in a single hdf file
#' a <- hec_file2("raw-data/ArdenwoodCreek.p50.hdf")
#' # read in a collection of hdf files in this directory
#' b <- hec_file2("raw-data/") 
#' # read in hdf files in this directory matching 50 and 60 plan numbers
#' c <- hec_file2("raw-data/", plan_numbers = c(50, 60))
#' }
#' @export
hec_file2 <- function(path, plan_numbers = NULL) {
  
  # first check if path is a directory or single filename 
  is_dir <- dir.exists(path) 
  # if this is a directory then either read all files in it, or only for given plans
  if (is_dir) { 
    hdf_files <- list.files(path, pattern = ".hdf", full.names = TRUE)
    # create the message that will be shown to the users
    msg <- paste0("found ", length(hdf_files), " in ", path)
    
    # if this vector has 0 elements -> no hdf files were found in the part, error
    if (!length(hdf_files)) stop(paste("No hdf files found in:", path))
    # when a directory check if the files vector is not null, if not then only read for the given plan numbers
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
    file_dir <- dirname(path)
    file_name <- basename(path)
    
    hdf_files <- list.files(path = file_dir, pattern = file_name, full.names = TRUE)
    if (!length(hdf_files)) stop(paste0("file: '", file_name, "' was not found in '", file_dir, "'"))
    msg <- NULL
  }
  
  # show the message?
  if (!is.null(msg)) message(msg)
  
  # map all relevant files onto the h5::h5file read function
  x <- purrr::map(hdf_files, h5::h5file)
  structure(x, class = "hec_collection")
}

#' the print method
#' @export 
print <- function(x, ...) {
  UseMethod("print")
}

#' the print generic
#' @export
print.hec_collection <- function(x, ...) {
  in_collection <- length(x)
  paste0(
    "Hec Collection with ", in_collection, " files in collection." 
  )
}

