#' Function retrieves the center coordinates for a given hec_file
#' @param hf a hdf file read in with \code{hec_file}
#' @export
get_center_coordinates <- function(hf) {
  area_path <- get_flow_area_path(hf)
  hf[area_path]['Cells Center Coordinate']
}


#' Function returns the path to 2D flow area defined in the hdf file.
#' @param hf a hdf file read in with hec_file
#' @return a slash delmited path to the 2D flow area
#' @export
get_flow_area_path <- function(hf) {
  h5::list.groups(hf[hdf_paths$GEOM_2D_AREAS])[1]
}

#' Function returns the column index of the cell center coordinate nearest (x, y)
#' @param x coordinate 
#' @param y coordinate 
#' @param nodes set of nodes to calculate distance from
#' @export 
get_nearest_cell_center <- function(x, y, nodes) {
  coord <- c(x, y)
  dist <- colSums(sqrt((coord - t(nodes))^2))
  return(which.min(dist))
}