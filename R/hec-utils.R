has_crossections <- function(h) {
  "Cross Sections" %in% names(h$object[["Geometry"]])
}

hec_timestamps_ <- function(h) {
  as.POSIXct(h$object[["Results/Unsteady/Output/Output Blocks/Base Output/Unsteady Time Series/Time Date Stamp"]]$read(), 
             format = "%d%b%Y %H:%M:%S")
}




