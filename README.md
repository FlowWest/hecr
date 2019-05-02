# hecr 

An R package for interacting with hdf5 files resulting from a HEC-RAS 
model run. `hecr` uses the `hdf5r` package and wraps around it functions that enable 
a user to quickly query out desired data in a tidy dataframe format.

## Installation 

The install requires `devtools`, install with `install.packages("devtools")`.
To install `hecr`:

```r 
devtools::install_github("flowwest/hecr")
```

Installing hecr will install as dependencies: hdf5r, dplyr, and purrr. If detected
on the system these will not install, but an update might be required. Both purrr and dplyr
need to be the latest version.

## Usage 

The main goal of hecr is to allow a user to automate the process
of obtaining time series data from an hdf file resulting from a HEC-RAS model run.
hecr makes it easy to query data from an hdf by giving the user a consistent approach
to querying the data. Both time series from cross sections and 2d portions of a model
run can be obtained using the hecr package.

Here is an example of reading and querying out a time series.


```r
# load in the library
library(hecr)

# first read in the file
f <- hecr::hec_file("inst/raw-data/ArdenwoodCreek.p50.hdf")

# query water surface time series from a cross section 
water_surface <- hecr::hec_one(f, 6863.627, ts_type = "Water Surface")

# plot
water_surface %>% ggplot(aes(datetime, values, color = plan_name)) + geom_line()
```

![](images/cross_section_single_file.png)





