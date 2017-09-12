#' Build a corpus of hdf files to execute queries on 
#' @param path directory path containing hdf files to build corpus from
#' @param files a vector of plan number associated with hdf files. When NULL (default) all hdf files in directory are read.
#' @return list of files read in with hec_file
#' @export 
create_hdf_corpus <- function(path, files = NULL) {
  hdf_files <- list.files(path, pattern = ".hdf", full.names = TRUE)
  
  if (!is.null(files)) {
    re <- paste(files, collapse = "|")
    hdf_files <- hdf_files[stringr::str_detect(hdf_files, re)]
  }
  
  if (!length(hdf_files)) 
    stop(paste("could not find any hdf files in", path))
  
  message(paste("Found", length(hdf_files), "hdf file(s) in path"))

  corp <- purrr::map(hdf_files, ~hec_file(.))

  return(corp)
}

#' Add specified file to an existing corpus
#' @param corpus an existing hdf corpus to add to
#' @param f filename of hdf to be added to corpus
add_to_corpus <- function(corpus, f) {
  l <- length(corpus)
  corpus[l+1] <- hec_file(f)
}

#' Safely close a corpus
#' @param corp corpus of hdf files read in with create_hdf_corpus
#' @export
close_corpus <- function(corp) {
  x <- purrr::map(corp, ~h5::h5close(.))
  
  if (sum(unlist(x)) == 0) 
    stop("error occured in closing corpus, use h5::h5close instead")
  
  return(TRUE)
}
