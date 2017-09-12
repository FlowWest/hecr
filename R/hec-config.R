# Implement the use of config files for creating queries 

#' Function reads in and fills in a query based on a configuration file parameter
#' @param config_file path to config file used to fill query
#' @param type a defined config type in the config file. See README for more information 
#' @return data frame 
#' @export
hec_config <- function(config_file, type = 'default') {
  cfg <- config::get(config = type)
  
  return(cfg)
}