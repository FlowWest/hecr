#' @title Read HEC-RAS Output Data
#' @description Either read or create a "hec" object from an HDF output file from
#' HEC-RAS.
#' @param x path or object
#' @param ... additional arguments
#' @examples 
#' \dontrun{
#' f <- hec_file("~/Documents/ArdenwoodModelRub.p04.hdf") # read from file
#' g <- hec_file(hc) # read from existing h5File object
#' }
#' @rdname hec_file
#' @export
hec_file <- function(x, ...) {
  UseMethod("hec_file", x)
}

#' @return hec object
#' 
#' @rdname hec_file
#' @param plan_numbers refine path to only these plan numbers
#' @param mode read in hdf file in "r" read or "w" write mode ("r" by default)
#' @method hec_file character
#' @export 
hec_file.character <- function(x, plan_numbers = NULL, mode = "r") {
  
  if (is_dir(x)) { 
    hdf_files <- list_hec_files_in_dir(x, plan_numbers)
  } else {
    
    if(!is.null(plan_numbers))
      message("plan number(s) supplied but ignored, since 'x' points to a single file")
    
    file_dir <- dirname(x)
    file_name <- basename(x)
    
    hdf_files <- list.files(path = file_dir, pattern = file_name, full.names = TRUE)
    
    if (!length(hdf_files)) stop(paste0("file: '", file_name, "' was not found in '", file_dir, "'"))
    if (!hdf5r::is_hdf5(hdf_files[1])) stop("Supplied file is not an hdf5 file.")
  }
  
  # map all relevant files onto the h5::h5file read function
  f <- purrr::map_if(hdf_files, hdf5r::is_hdf5, ~hdf5r::H5File$new(., mode = mode)) %>% 
    purrr::set_names(hdf_files)
  
  # return a hec_collection object
  structure(
    list(
      collection = f, 
      files = hdf_files
    ), 
    class = c("hec", "list")
  )
}

#' @rdname hec_file
#' @export
hec_file.H5File <- function(x) {
  structure(
    list(
      collection = list(x), 
      files = x$filename
    ), 
    class = "hec"
  )
}



# INTERNAL 

is_dir <- function(file) {
  dir.exists(file)
}

is_file <- function(file) {
  file.exists(file)
}

list_hec_files_in_dir <- function(path, plan_numbers) {
  hdf_files <- list.files(path, pattern = "p[0-9][0-9].hdf$", full.names = TRUE)
  
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

or_collapse <- function(x) paste(x, collapse = "|")

#' print hec_collection
#' @export 
print.hec <- function(h) {
  items_in_collection <- length(h$collection)
  cat("A hec collection with", items_in_collection, "item(s)\n")
  cat("Files in collection\n", sprintf("name: %s\n", h$files), "\n")
}




