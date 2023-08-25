load_packages <- function(do_it = T){
  pkgs <- c("targets",
            "yaml",
            "sf",
            "data.table",
            "terra",
            "sf",
            "raster",
            "exactextractr",
            "lubridate",
            "ncdf4")
  ipak <- function(pkg){
    new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
    if (length(new.pkg)) 
      install.packages(new.pkg, dependencies = TRUE)
    sapply(pkg, require, character.only = TRUE)
  }
  ipak(pkgs)
}