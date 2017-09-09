# hecr 

A simple R package for interacting with hdf5 files resulting from a HEC-RAS 
model run. `hecr` uses the `h5` package and wraps around it functions that enable 
a user to quickly query out desired data in a tidy dataframe format.

## Installation 

The install required `devtools`, install with `install.packages("devtools")`.
To install `hecr` do the following:

```r 
devtools::install_github("flowwest/hecr")
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

# plot
water_surface %>% ggplot(aes(datetime, values, color = plan_name)) + geom_line()
```

![](images/cross_section_single_file.png)

The above is useful, the simple fact that data is transformed to a tidy format 
is great. However, much of this work could have been done in hecRas, the more powerful 
aspect of hecr is when start putting together complex queries. 

Here is an example where we create an hdf corpus of files we want to issue queries
on.

```r
# path to directory with hdf files we wish to query on
corp <- hecr::create_hdf_corpus("inst/raw-data/")

water_surface <- hecr::extract_ts1(corp, 6863.627, ts_type = "Water Surface")

# plot
water_surface %>% ggplot(aes(datetime, values, color = plan_name)) + geom_line()
```

![](images/cross_section_corpus.png)

Once again the data is in a tidy form, and so it works great with ggplot or plotly. 
Further more all of dplyr is at your disposal. 



