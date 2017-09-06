# hecr 

A simple R package for interacting with hdf5 files resulting from a HEC-RAS 
model run. `hecr` uses the `h5` package and wraps around it functions that enable 
a user to quickly query out desired data in a tidy dataframe format.

**List of current features** 

1. Extract a time series from 2d portion of model run using a hecras coordinate of choice.
2. Extract a time series from 1d portion of model run using a hecras defined station.


## Installation 

The install required `devtools`, install with `install.packages("devtools")`.
To install `hecr` do the following:

```r 
devtools::install_github("flowwest/hecr", auth_token = <AUTH_TOKEN_HERE>)
```

Currently `hecr` is internal to FlowWest, so an auth token is required to install, 
email [erodriguez@flowwest.com](erodriguez@flowwest.com) for one.

## Usage 

Currently `hecr` is limited to extracting already embeded time series from 
an hdf5 file. Below are several examples for querying data. 

### Query Water Surface Elevation from 2D Area

```r 
library(hecr) 

f <- hec_file("raw-data/ardenwoodcreek.p50.hdf") # read in an hdf file 

d <- extract_ts2(f, x=123, y=123, ts_type = "Water Surface")
```

If you like the pipe you can use it in `hecr`

```r
d <- hec_file("raw-data/ardenwoodcreek.p50.hdf") %>% 
  extract_ts(x=123, y=123, ts_type = "Water Surface")
```

### Query Water Surface Elevation from Cross Sections 

```r
xs <- extract_ts1(f, "7405.382", ts_type = "Water Surface")
```

