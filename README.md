# hecr 

# Currently rewritting entire package to use new HDF interface

A simple R package for interacting with hdf5 files resulting from a HEC-RAS 
model run. `hecr` uses the `h5` package and wraps around it functions that enable 
a user to quickly query out desired data in a tidy dataframe format.

## Installation 

The install requires `devtools`, install with `install.packages("devtools")`.
To install `hecr`:

```r 
devtools::install_github("flowwest/hecr")
```

Installing hecr will install as dependencies: h5, dplyr, purrr and config. If detected
on the system these will not install, but an update might be required. Both purrr and dplyr
need to be in the latest version for hecr to work.

## Usage 

The main goal of hecr is to allow a user to obtain and automate to process
of obtaining time series data from an hdf file resulting from a HEC-RAS model run.
hecr makes it easy to query data from an hdf by giving the user a consistent approach
to querying the data. Both time series from cross sections and 2d portions of a model
run can be obtained using the hecr package.

Below we walk through simple examples of queries, more complex examples and real world
applications can be found in the [Tutorial (Coming Soon)](#)


```r
# load in the library
library(hecr)

# first read in the file
f <- hecr::hec_file("inst/raw-data/ArdenwoodCreek.p50.hdf")

# extract a cross section portion of the model. 
water_surface <- hecr::extract_ts1(f, 6863.627, ts_type = "Water Surface")

# plot
water_surface %>% ggplot(aes(datetime, values, color = plan_name)) + geom_line()
```

![](images/cross_section_single_file.png)

