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
#  hdf_obj <- h$object

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
#  data %>% ggplot(aes(datetime, values)) + geom_line()

## ----eval=FALSE----------------------------------------------------------
#  coords <- c(6570468.12123,	1881034.38489,
#              6570186.03222,	1880216.19001,
#              6570167.9381,	1879820.21836,
#              6570141.81282,	1879703.42988,
#              6570114.02745,	1879601.38152,
#              6570108.19281,	1879582.69751,
#              6569969.28791,	1879291.13936
#  )
#  
#  data <- hec_two(h, coords)

