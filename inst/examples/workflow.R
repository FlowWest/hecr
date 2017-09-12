# Single file use  --------------------------

# First read in the hdf file with hec_file 
f <- hec_file("inst/raw-data/ArdenwoodCreek.p50.hdf")

# For 2d portion of the model
# If we know what coordinate we wish to pull a time series for we do
coord <-c(6104710.42127651, 2025864.2835155)
ws_ts <- extract_ts2(f, coord, ts_type = "Water Surface")

# For 1d portion of the mode
xs_ts <- extract_ts1(f, station_name = 6863.627, ts_type = "Water Surface")
xs_ts <- extract_ts1(f, station_name = river_stations[1:2], ts_type = "Water Surface")


river_stations <- get_xs_river_stations(f)
library(purrr)

# here i query for all cross sections into a sinle dataframe using purrr
# at the moment this is the preffered way of querying multiple stations
d <- map_dfr(river_stations, ~extract_ts1(f, ., ts_type = "Water Surface"))

l <- list("one"=1:10, 
          "two"=11:20, 
          "three"=21:30)

z <- modify_depth(x, 0, ~get_xs_river_stations(.))


# corpus approach 
f <- hec_file("inst/raw-data/ArdenwoodCreek.p80.hdf")

x <- extract_ts1(f, 6863.627, "Water Surface")

corp <- create_hdf_corpus("inst/raw-data")

x <- extract_ts1(corp, 6863.627, "Water Surface")









