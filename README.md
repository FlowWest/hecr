# hecr 

A simple R package for interacting with hdf5 files resulting from a HEC-RAS 
model run. `hecr` uses the `h5` package and wraps around it functions that enable 
a user to quickly query out desired data in a tidy dataframe format.

## Installation 

The install required `devtools`, install with `install.packages("devtools")`.
To install `hecr` do the following:

```r 
devtools::install_github("flowwest/hecr", auth_token = <AUTH_TOKEN_HERE>)
```

## Usage 

hecr can be used to query out either time series from a 1d or 2d portion of a 
model file. 

### One Dimension 

A user is required to know the river cross section name from the hdf file. This may
be a bit limiting at the moment, future releases will allow exploration of the 
file via R. A simple example is shown below:

```r
library(hecr)

# first read in the file
f <- hecr::hec_file("inst/raw-data/ArdenwoodCreek.p50.hdf")

# extract a one portion time series of Water Surface
water_surface <- hecr::extract_ts1(f, 6863.627, ts_type = "Water Surface")
```