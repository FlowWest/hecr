## ----eval=FALSE----------------------------------------------------------
#  library(hecr)
#  h <- hec_file("../inst/examples/DeerCreek.p01.hdf")
#  
#  print(h)
#  
#  # A hec object ----
#  #   Plan File: DeerCreek.p01
#  #   Plan Name: Existing Conditions
#  #   Geom Name: DeerCreek.g01
#  #   Out Inteval: 1HOUR

## ----eval=FALSE----------------------------------------------------------
#  tree(h)
#  
#  # *Group:  Event Conditions
#  # 	|
#  # 	-- Steady
#  #
#  # *Group:  Geometry
#  # 	|
#  # 	-- Cross Section Interpolation Surfaces
#  # 	|
#  # 	-- Cross Sections
#  # 	|
#  # 	-- Junctions
#  # 	|
#  # 	-- Land Cover (Manning's n)
#  # 	|
#  # 	-- River Bank Lines
#  # 	|
#  # 	-- River Centerlines
#  # 	|
#  # 	-- River Edge Lines
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
#  # 	-- Steady
#  # 	|
#  # 	-- Summary

## ----eval=FALSE----------------------------------------------------------
#  coord <- c(1, 2)
#  hec_two(h, coord)

