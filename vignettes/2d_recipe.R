## ----eval=FALSE----------------------------------------------------------
#  library(hecr)
#  h <- hec_file("../inst/examples/LowerDeerCreek_2018.p10.hdf")
#  
#  print(h)
#  
#  # A hec object----
#  # Plan File: LowerDeerCreek_2018.p10
#  # Plan Name: Existing_LidarCalib_20180830
#  # Geom Name: LowerDeerCreek_2018.g13
#  # Out Inteval: 15MIN

## ----eval=FALSE----------------------------------------------------------
#  tree(h)
#  
#  # *Group:  Event Conditions
#  # 	|
#  # 	-- Unsteady
#  #
#  # *Group:  Geometry
#  # 	|
#  # 	-- 2D Flow Area Break Lines
#  # 	|
#  # 	-- 2D Flow Areas
#  # 	|
#  # 	-- Boundary Condition Lines
#  # 	|
#  # 	-- Land Cover (Manning's n)
#  # 	|
#  # 	-- River Bank Lines
#  # 	|
#  # 	-- River Edge Lines
#  # 	|
#  # 	-- River Flow Paths
#  # 	|
#  # 	-- River Stationing
#  # 	|
#  # 	-- Structures
#  #
#  # *Group:  Plan Data
#  # 	|
#  # 	-- Plan Information
#  # 	|
#  # 	-- Plan Parameters
#  #
#  # *Group:  Results
#  # 	|
#  # 	-- Summary
#  # 	|
#  # 	-- Unsteady

## ----eval=FALSE----------------------------------------------------------
#  # h is still the 'hec-file' object from above
#  hdf_obj <- h$object
#  
#  print(hdf_obj)
#  
#  # Class: H5File
#  # Filename: /home/emanuel/Projects/hecr/inst/examples/LowerDeerCreek_2018.p10.hdf
#  # Access type: H5F_ACC_RDONLY
#  # Attributes: File Type, Units System, File Version, Projection
#  # Listing:
#  #              name  obj_type dataset.dims dataset.type_class
#  #  Event Conditions H5I_GROUP         <NA>               <NA>
#  #          Geometry H5I_GROUP         <NA>               <NA>
#  #         Plan Data H5I_GROUP         <NA>               <NA>
#  #           Results H5I_GROUP         <NA>               <NA>

## ----eval=FALSE----------------------------------------------------------
#  coord <- c(6570468.12123, 1881034.38489)
#  data <- hec_two(h, coord)
#  
#  glimpse(data)
#  
#  # Observations: 97
#  # Variables: 8
#  # $ datetime         <dttm> 2018-02-07 00:00:00, 2018-02-...
#  # $ plan_id          <chr> "Existing_LidarCalib_20180830"...
#  # $ plan_file        <chr> "LowerDeerCreek_2018.p10", "Lo...
#  # $ time_series_type <chr> "Water Surface", "Water Surfac...
#  # $ hdf_cell_index   <dbl> 445700, 445700, 445700, 445700...
#  # $ xin              <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, ...
#  # $ yin              <dbl> 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, ...
#  # $ values           <dbl> 196.020980834961, 196.02098083...

## ----eval=FALSE----------------------------------------------------------
#  library(ggplot2)
#  data %>% ggplot(aes(datetime, values)) + geom_line()

## ----eval=FALSE----------------------------------------------------------
#  # define a vector of coordinates
#  coords_vs <- c(6570468.12123,	1881034.38489,
#              6570186.03222,	1880216.19001,
#              6570167.9381,	1879820.21836,
#              6570141.81282,	1879703.42988,
#              6570114.02745,	1879601.38152,
#              6570108.19281,	1879582.69751,
#              6569969.28791,	1879291.13936
#  )
#  
#  # you can also supply a matrix
#  coords_m <- matrix(coords_vs, ncol=2, byrow = TRUE)
#  
#  data <- hec_two(h, coords_m)
#  
#  dplyr::glimpse(data)
#  
#  # Observations: 679
#  # Variables: 8
#  # $ datetime         <dttm> 2018-02-07 00:00:00, 2018-02-07 00:15:00, 2018-02-07 00:30:00, ...
#  # $ plan_id          <chr> "Existing_LidarCalib_20180830", "Existing_LidarCalib_20180830", ...
#  # $ plan_file        <chr> "LowerDeerCreek_2018.p10", "LowerDeerCreek_2018.p10", "LowerDeer...
#  # $ time_series_type <chr> "Water Surface", "Water Surface", "Water Surface", "Water Surfac...
#  # $ hdf_cell_index   <dbl> 391410, 391410, 391410, 391410, 391410, 391410, 391410, 391410, ...
#  # $ xin              <dbl> 6570468.12123, 6570468.12123, 6570468.12123, 6570468.12123, 6570...
#  # $ yin              <dbl> 1881034.38489, 1881034.38489, 1881034.38489, 1881034.38489, 1881...
#  # $ values           <dbl> 403.998809814453, 403.998809814453, 403.998809814453, 403.998809...

## ----eval=FALSE----------------------------------------------------------
#  data %>% ggplot(aes(datetime, values, color=as.factor(hdf_cell_index))) +
#    geom_line()

## ----eval=FALSE----------------------------------------------------------
#  coords_m
#  
#  tstamp <- "2018-02-07 01:15:00"
#  
#  data <- hec_two(f, coords_m, time_stamp = tstamp)
#  
#  glimpse(data)
#  
#  # Observations: 7
#  # Variables: 8
#  # $ datetime         <dttm> 2018-02-07 01:15:00, 2018-02-07 01:15:00, 2018-02-07 01:15:00, ...
#  # $ plan_id          <chr> "Existing_LidarCalib_20180830", "Existing_LidarCalib_20180830", ...
#  # $ plan_file        <chr> "LowerDeerCreek_2018.p10", "LowerDeerCreek_2018.p10", "LowerDeer...
#  # $ time_series_type <chr> "Water Surface", "Water Surface", "Water Surface", "Water Surfac...
#  # $ hdf_cell_index   <dbl> 391410, 391542, 391596, 391612, 391626, 391628, 391674
#  # $ xin              <dbl> 6570468.12123, 6570186.03222, 6570167.93810, 6570141.81282, 6570...
#  # $ yin              <dbl> 1881034.38489, 1880216.19001, 1879820.21836, 1879703.42988, 1879...
#  # $ values           <dbl> 403.998809814453, 396.334991455078, 395.906250000000, 395.625000...

## ----eval=FALSE----------------------------------------------------------
#  data %>%
#    ggplot(aes(hdf_cell_index, values)) + geom_point()

