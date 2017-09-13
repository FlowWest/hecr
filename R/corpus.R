#' Build a corpus of hdf files to execute queries on. This function has been deprecated use hec_file2() instead
#' @param path directory path containing hdf files to build corpus from
#' @param files a vector of plan number associated with hdf files. When NULL (default) all hdf files in directory are read.
#' @return list of files read in with hec_file
#' @export 
create_hdf_corpus <- function(path, files = NULL) {
  .Deprecated("hdf_corpus", package = "hecr", msg = "Function deprecated, use `hec_file2()` instead")
  hec_file2(path=path, files = files)
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
