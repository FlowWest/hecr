#' List Available data
#' @description list the data that is avaialble to query on. This values
#' depends on whether a query is set to 'one' or 'two' dimensional domains
#' @param hc a hec object
#' @param domain which domain to list data for, will default to both options are 'one' or 'two'
#' @export 
hec_datasets <- function(hc, domain=NULL) {
  one_path <- "Results/Unsteady/Output/Output Blocks/Base Output/Unsteady Time Series/Cross Sections"
  two_path <- glue::glue(
    "Results/Unsteady/Output/Output Blocks/Base Output/Unsteady Time Series/2D Flow Areas/{area}", 
    area = get_plan_area(hc)
    )
  
  cat(two_path, "\n")
  one <- NULL
  two <- NULL
  
  if (is.null(domain)) {
    one <- hc$object[[one_path]]$ls()
    two <- hc$object[[two_path]]$ls()
  } else if (domain == 'one') {
    one <- hc$object[[one_path]]$ls()
  } else if (domain == 'two') {
    two <- hc$object[[two_path]]$ls()
  }
  structure(
    list(
      'one' = one,
      'two' = two
    ), 
    class="hec_datasets"
  )
}


#' Print datasets
#' @export
print.hec_datasets <- function(x, ...) {
  if (!is.null(x$one)) {
    cat('One Dim ------\n')
    print(dplyr::select(x$one, name, "dim" = dataset.dims))
  }
  if (!is.null(x$two)) {
    cat('Two Dim ------\n')
    print(dplyr::select(x$two, name, "dim" = dataset.dims))
  }
}

has_crossections <- function(h) {
  "Cross Sections" %in% names(h$object[["Geometry"]])
}

hec_timestamps_ <- function(h) {
  as.POSIXct(h$object[["Results/Unsteady/Output/Output Blocks/Base Output/Unsteady Time Series/Time Date Stamp"]]$read(), 
             format = "%d%b%Y %H:%M:%S")
}


get_plan_area <- function(hc) {
  trimws(hc$object[["Results/Unsteady/Output/Output Blocks/Base Output/Unsteady Time Series/2D Flow Areas/"]]$ls()$name[1])
}









