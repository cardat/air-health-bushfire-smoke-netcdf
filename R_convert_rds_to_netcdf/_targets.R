library(targets)

# Run the R scripts in the R/ folder with custom functions:
# tar_source()
sapply(dir("R", full.names = T, pattern = ".R$"), source)
# load_packages(T)

# Load config.yaml
config <- yaml::read_yaml("config.yaml")

## Set target options:
tar_option_set(
  packages = c("targets",
               "yaml",
               "sf",
               "data.table",
               "terra",
               "sf",
               "raster",
               "exactextractr",
               "lubridate",
               "ncdf4"),
  error = "continue"
)

# the target list 
list(
  #### do_convert_rds_to_ncdf ####
  tar_target(
    dat_convert_rds_to_ncdf,
    do_convert_rds_to_ncdf(
      indir_rf = file.path(config$rootdir, config$raster_stl),
      infile_coords = file.path(config$rootdir, config$raster_coords),
      yy_todo = 2016
    )
  )
)
