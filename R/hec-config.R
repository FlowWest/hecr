# Implement the use of config files for creating queries 

#' Create a new configuration file can be used to automate alot of the work 
#' done by the hecr package. 
#' @param name name to be given to the configuration
#' @param template template to use for the configuration, defaults to a 'default' template
#' @export
new_config <- function(name, template = 'default', in_wd = TRUE) {
  # first we need to create the file 
  filename <- if (in_wd) paste0(getwd(), "/", name, ".yml") else paste0(name, ".yml")
  if (file.create(filename)) {
    switch (template,
      'default' = {
        file.copy(system.file("config-templates", "default.yml", package = "hecr"), filename, overwrite = TRUE)
      }
    )
  } else {
    stop("Error creating config file")
  }
  
}

#' Function reads in and fills in a query based on a configuration file parameter
#' @param config_file path to config file used to fill query
#' @param config the config to use within the configuration file. Defaults to 'default'  
#' @return data frame 
#' @export
hec_config <- function(config_file, config = 'default') {
  cfg <- config::get(config = config, file = config_file)
  
  f <- hec_file2(path = cfg$hdf_directory, plan_numbers = cfg$hdf_numbers)
  return(f)
}



run_confg <- function(config) {
  
}