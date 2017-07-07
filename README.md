# hecr 

A simple R package for interacting with hdf5 files resulting from a HEC-RAS 
model run. `hecr` uses the `h5` package and wraps around it functions that enable 
a user to quickly query out desired data in a tidy dataframe format.

## Installtion 

The install required `devtools`, install with `install.packages("devtoosl")`.
To install `hecr` do the following:

```r 
devtools::install_github("flowwest/hecr", auth_token = <AUTH_TOKEN_HERE>)
```

Currently `hecr` is internal to FlowWest, so an auth token is required to install, 
email [erodriguez@flowwest.com](erodriguez@flowwest.com) for one.

