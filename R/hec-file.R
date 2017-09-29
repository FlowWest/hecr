#' Function reads in either a single hdf file or a collection of these specified as arguments. 
#' @description Function will read in a single hdf file when the path parameter points to a single
#' file, or a collection of these when the path is directory. User can further specify only a 
#' certain number of these within the directory to be read using the plan_numbers parameter.
#' @param path directory path to either a single hdf file or a directory of a collection of these
#' @param plan_numbers a vector of plan number associated with hdf files. For use when path is a directory.
#' Default action is to read all hdf files in path.
#' @param ... additional options.
#' @return list of files read in with hec_file
#' @examples 
#' \dontrun{
#' # read in a single hdf file
#' a <- hec_file("examples/ArdenwoodCreek.p50.hdf")
#' 
#' # read in a collection of hdf files in this directory
#' b <- hec_file("examples/") 
#' 
#' # read in hdf files in this directory matching 50 and 60 plan numbers
#' c <- hec_file("examples/", plan_numbers = c(50, 60))
#' }
#' @export
hec_file <- function(path, plan_numbers = NULL, ...) {

  if (is_url(path)) {
    hdf_files <- read_files_in_url(path)
  }

  if (is_dir(path)) { 
    hdf_files <- read_files_in_dir(path, plan_numbers)
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

is_file <- function(file) {
  file.exists(file)
}

read_files_in_dir <- function(path, plan_numbers) {
  hdf_files <- list.files(path, pattern = ".hdf$", full.names = TRUE)
  
  if (!length(hdf_files)) stop(paste("No hdf files found in:", path)) # no hdf files found
  
  msg <- paste0("found ", length(hdf_files), " hdf file(s) in ", path) # helpful msg

  # plan numbers supplied
  if (!is.null(plan_numbers)) {
    re <- or_collapse(plan_numbers)
    hdf_files <- hdf_files[stringr::str_detect(hdf_files, re)]
    msg <- paste0("found ", length(hdf_files), " hdf files in ", path, " matching plan numbers criteria")
    
    # no matching plan numbers
    if (!length(hdf_files)) stop(paste("No hdf files found in:", path, "with plan numbers(s):", 
                                       paste(plan_numbers, collapse = ", ")))
    # only some were matched
    if (length(hdf_files) != length(plan_numbers)) {
      warning("One or more hdf files were not read in correctly")
    }
  }
  message(msg)
  return(hdf_files)
}

read_files_in_url <- function(path, ...) {
  dots <- list(...)
  name <- basename(path)
  temp_file <- tempfile(pattern = name, tmpdir = tempdir())
  
  download.file(path, destfile = temp_file, ...)
  return(temp_file)
}

or_collapse <- function(x) paste(x, collapse = "|")