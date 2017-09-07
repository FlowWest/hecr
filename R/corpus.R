#' Build a corpus of hdf files to execute queries on 
#' @param path directory path containing hdf files to build corpus from
#' @return list of files read in with hec_file
#' @export 
create_hdf_corpus <- function(path) {
  hdf_files <- list.files(path, pattern = ".hdf", full.names = TRUE)
  
  if (!length(hdf_files)) 
    stop(paste("could not find any hdf files in", path))
  
  message(paste("Found", length(hdf_files), "hdf file(s) in path"))

  corp <- map(hdf_files, ~hec_file(.))

  return(corp)
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
