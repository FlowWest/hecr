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
#' a <- hec_file("raw-data/ArdenwoodCreek.p50.hdf")
#' # read in a collection of hdf files in this directory
#' b <- hec_file("raw-data/") 
#' # read in hdf files in this directory matching 50 and 60 plan numbers
#' c <- hec_file("raw-data/", plan_numbers = c(50, 60))
#' }
#' @export
hec_file <- function(path, plan_numbers = NULL) {

  if (is_url(path)) {
    stop("url paths not yet implemented :(")
  }

  if (is_dir(path)) { 
    hdf_files <- read_files_in_path(path, plan_numbers)
  } else {
    file_dir <- dirname(path)
    file_name <- basename(path)
    
    hdf_files <- list.files(path = file_dir, pattern = file_name, full.names = TRUE)
    if (!length(hdf_files)) stop(paste0("file: '", file_name, "' was not found in '", file_dir, "'"))
  }
  
  # map all relevant files onto the h5::h5file read function
  purrr::map(hdf_files, h5::h5file)
}


# Helpers 

is_url <- function(path) {
  grepl("^((http|ftp)s?|sftp)://", path)
}

is_dir <- function(file) {
  dir.exists(file)
}

read_files_in_path <- function(path, plan_numbers) {
  hdf_files <- list.files(path, pattern = ".hdf", full.names = TRUE)
  if (!length(hdf_files)) stop(paste("No hdf files found in:", path)) # no hdf files found
  
  this_msg <- paste0("found ", length(hdf_files), " in ", path)

    # plan numbers supplied
  if (!is.null(plan_numbers)) {
    re <- paste(plan_numbers, collapse = "|")
    hdf_files <- hdf_files[stringr::str_detect(hdf_files, re)]
    this_msg <- paste0("found ", length(hdf_files), " hdf files in ", path, " matching plan names criteria")
    
    # no matching plan numbers
    if (!length(hdf_files)) stop(paste("No hdf files found in:", path, "with plan name(s):", 
                                       paste(plan_numbers, collapse = ", ")))
    # only some were matched
    if (length(hdf_files) != length(plan_numbers)) {
      warning("One or more hdf files were not read in correctly")
    }
  }
  message(this_msg)
  return(hdf_files)
}













