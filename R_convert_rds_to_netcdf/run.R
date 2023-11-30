## this pipeline is for creating SA1 average bushfire smoke, and aggregations to ABS census boundaries etc
## Lucas Hertzog and Ivan Hanigan and Ben Davies

if(dir.exists("R_convert_rds_to_netcdf/")) setwd("R_convert_rds_to_netcdf/")

## Load packages, or install them if not available
library(targets)
config <- yaml::read_yaml("config.yaml")
# tar_source()
sapply(dir("R", full.names = T, pattern = ".R$"), source)
load_packages(T)
## only use this version of stars (not greater or less than)
require(devtools)
install_version("stars", version = "0.6-1", repos = "http://cran.us.r-project.org")
## The Pipeline
tar_visnetwork(targets_only = T,
                        level_separation = 200)
tar_make()

## EDA

