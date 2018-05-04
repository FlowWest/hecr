hdf_paths <- list(
  'GEOM_2D_AREAS' = 'Geometry/2D Flow Areas',
  'GEOM_CROSS' = 'Geometry/Cross Sections',
  'RES_UNSTEADY_TS' = 'Results/Unsteady/Output/Output Blocks/Base Output/Unsteady Time Series',
  'RES_2D_FLOW_AREAS' = 'Results/Unsteady/Output/Output Blocks/Base Output/Unsteady Time Series/2D Flow Areas',
  'RES_CROSS_SECTIONS' = 'Results/Unsteady/Output/Output Blocks/Base Output/Unsteady Time Series/Cross Sections', 
  'PLAN_INFORMATION' = 'Plan Data/Plan Information'
  
)

paths <- c(
  "results"
)

paths <- list(
  'result' = list(
    'unsteady' = list(
      'output' = list(
        'output_blocks' = list(
          'base_output' = list(
            'summary_output' = list(),
            'unsteady_time_series' = list(
              'time' = 'Results/Unsteady/Output/Base Output/Unsteady Time Series/Time',
              'time_date_stamp' = 'Results/Unsteady/Output/Base Output/Unsteady Time Series/Time Date Stamp',
              'time_date_stamp_ms' = 'Results/Unsteady/Output/Base Output/Unsteady Time Series/Time Date Stamp (ms)',
              'time_step' = 'Results/Unsteady/Output/Base Output/Unsteady Time Series/Time Step', 
              '2d_flow_areas' = list(
                'area' = list(
                  'depth' = 'Results/Unsteady/Output/Base Output/Unsteady Time Series/2D Flow Areas/{FLOW_AREA}/Depth',
                  'face_shear_stress' = 'Results/Unsteady/Output/Base Output/Unsteady Time Series/2D Flow Areas/{FLOW_AREA}/Face Shear Stress',
                  'face_velocity' = 'Results/Unsteady/Output/Base Output/Unsteady Time Series/2D Flow Areas/{FLOW_AREA}/Face Velocity',
                  'water_surface' = 'Results/Unsteady/Output/Base Output/Unsteady Time Series/2D Flow Areas/{FLOW_AREA}/Water Surface'
                )
              )
            )
          )
        )
      ),
      'geometry_info' = list()
    )
  ), 
  'plan_data' = list(
    
  ), 
  'geometry' = list(
    
  )
)


