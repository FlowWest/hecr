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

