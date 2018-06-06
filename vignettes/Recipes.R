## ------------------------------------------------------------------------
# devtools::install_github("flowwest/hecr")

library(hecr)

model_data <- hec_file("~/Documents/ardenwood/ArdenwoodCreek.p02.hdf")

## ------------------------------------------------------------------------
print(model_data)

## ---- eval=FALSE---------------------------------------------------------
#  model_data$object # the R representation of hdf file using hdf5r package (hdf5 object)
#  model_data$attrs  # root level attributes associated with the plan (R list)

## ------------------------------------------------------------------------
cs <- hec_crosssections(model_data)

# how many cross sections are defined?
print(length(cs))

# what are the first couple?
print(head(cs))

## ------------------------------------------------------------------------
datasets <-
  hec_datasets(model_data, domain = 'one') # set domain to one

print(datasets)

## ------------------------------------------------------------------------
print(datasets$one)

## ------------------------------------------------------------------------
data <- 
  hec_one(model_data, station_name = cs[300], ts_type = "Water Surface")

print(data)

## ---- warning=FALSE, message=FALSE---------------------------------------
library(ggplot2)
library(dplyr)

data %>% 
  ggplot(aes(datetime, values)) + geom_line() + labs(y="Water Surface (ft)", 
                                                     x="DateTime")

## ---- warning=FALSE------------------------------------------------------
data <- 
  hec_one(model_data, station_name = cs[295:300], ts_type = "Water Surface")

data %>% 
  ggplot(aes(datetime, values, color=station)) + 
  geom_line() + 
  labs(y="Water Surface (ft)", 
       x="DateTime") + 
  scale_color_brewer(palette = "Dark2")

## ------------------------------------------------------------------------
data <- hec_one(model_data, station_name = cs, 
                ts_type = "Water Surface", time_stamp = "2005-12-30 02:15:00")

data %>% 
  ggplot(aes(readr::parse_number(station), values)) + 
  geom_line() +
  labs(x="Station", y="Water Surface (ft)", title="Water Surface on December 30th at 2:15 am")

## ------------------------------------------------------------------------
library(purrr)

plans <- list.files("~/Documents/ardenwood/", full.names = TRUE)

model_collection <- map(plans, hec_file)

print(model_collection) # a list of hec objects

## ------------------------------------------------------------------------
collection_data <- 
  map_df(model_collection, ~hec_one(., station_name = cs[300], ts_type = "Water Surface"))

## ------------------------------------------------------------------------
collection_data %>% 
  ggplot(aes(datetime, values, color=plan_id)) + 
  geom_line() + 
  labs(x="DateTime", y="Water Surface (ft)", color="Plan")

## ------------------------------------------------------------------------
set.seed(3)
# select random datetimes for this example
dts <- sample(collection_data$datetime, 4)

snapshots <- 
  map_df(dts, ~hec_one(model_data, station_name = cs, 
                    ts_type = "Water Surface", time_stamp = .))

## ------------------------------------------------------------------------
snapshots %>% 
  ggplot(aes(readr::parse_number(station), values, color=as.character(datetime))) + 
  geom_line() + 
  labs(x="station", y="Water Surfce (ft)", color="Time")

## ------------------------------------------------------------------------
set.seed(3)
# select random datetimes for this example
dts <- sample(collection_data$datetime, 4)

snapshot_collection <- 
  map_df(model_collection, function(m) {
  map_df(dts, ~hec_one(hc=m, station_name = cs, ts_type = "Water Surface", time_stamp = .))
})

## ------------------------------------------------------------------------
# obviously the plot can be improved but this shows the functionality
snapshot_collection %>% 
  ggplot(aes(readr::parse_number(station), values, color=as.character(datetime))) + 
  geom_line() + 
  facet_grid(. ~ plan_id) + 
  labs(x="station", y="Water Surfce (ft)", color="Time")

