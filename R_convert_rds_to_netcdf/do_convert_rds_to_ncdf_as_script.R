# this is rewritten to avoid using R-targets overkill
if(!dir.exists("data_derived")) dir.create("data_derived")
if(dir.exists("R_convert_rds_to_netcdf/")) setwd("R_convert_rds_to_netcdf/")
sapply(dir("R", full.names = T, pattern = ".R$"), source)
load_packages(T)
config <- yaml::read_yaml("config.yaml")


#do_convert_rds_to_ncdf <- function(
    indir_rf = file.path(config$rootdir, config$raster_stl)
#    ,
    indir_flags = file.path(config$rootdir, config$raster_flags)
#    ,
    indir_pm = file.path(config$rootdir, config$raster_pm_pred)
#    ,
    infile_coords = file.path(config$rootdir, config$raster_coords)
#    ,
    yy_todo = 2019
#) {
  
  for(yy in yy_todo){
  # yy = yy_todo[1]
  ## Convert vector file of coordinates to a df with x and y columns using vect() ##
  dat_coords <- as.data.frame(vect(infile_coords), geom = "XY")
  setDT(dat_coords)
  
  #### load pm ####
  fs <- dir(file.path(indir_pm), full.names = T, recursive = T, pattern = "rds$")
  ## all available rds files ##
  fs

  ## subset the selected year, read selected rds and save in a list ##
  fs_todo <- fs[grep(paste0("_", yy), basename(fs))]
  ls_dat <- lapply(fs_todo, readRDS)
  ## make daily raasters ####
  dat <- rbindlist(ls_dat)
  dates <- sort(unique(dat$date))
  dates

  ## for each layer creates a r_dly list of each date ##

  for(lyr_type in c("pm25_pred", "predictor_out_range", "pm25_pred_out_range")){
   # lyr_type = "pm25_pred"
    print(lyr_type)
    r_dly <- lapply(dates,
                    function(dd, lyr = lyr_type) {
                      txt <- paste0("rast(
                                          merge(
                                                dat_coords,
                                                dat[date == dd],
                                                all.x = T)[,
                                                    .(x, y, round(",
                                    lyr,
                                    ", 1))],
                                    crs = 'epsg:3577')")
                      eval(parse(text=txt))
                    }
    )
    s_dly <- do.call(c, r_dly)
    time(s_dly) <- dates

    #write as netcdf with stars (needs stars > 0.6)
    # more successful than terra at writing out a recognisable CRS
    stars_dly <- stars::st_as_stars(s_dly)
    lyr_type2 <- ifelse(lyr_type == 'pm25_pred_out_range', 'prediction_out_range', lyr_type)
    names(stars_dly) <- lyr_type2

    stars::write_mdim(stars_dly, filename = file.path("data_derived", paste0(yy,"_",lyr_type2,".nc")))
    ## qc
    # foo <- rast("data_derived/2019_pm25_pred.nc")
    # time(foo)
    # plot(foo[[1]])
    # finish loop over lyrs etc here
  }

  # #### load and convert from stl ####
  # ## Search for .rds files in the indir_rf and store full paths in fs ##
  # fs <- dir(file.path(indir_rf), full.names = T, recursive = T, pattern = "rds$")
  # 
  # ## all available rds files ##
  # fs
  # 
  # ## subset the selected year, read selected rds and save in a list ##
  # fs_todo <- fs[grep(paste0("_", yy), basename(fs))]
  # ls_dat <- lapply(fs_todo, readRDS)
  # ## make daily raasters ####
  # dat <- rbindlist(ls_dat)
  # dates <- sort(unique(dat$date))
  # dates
  # 
  # ## loop to iterate over the 3 layers ##
  # ## for each layer creates a r_dly list of each date ##
  # 
  # for(lyr_type in c("seasonal", "trend", "remainder")) {
  #   # lyr_type = "remainder"
  #   print(lyr_type)
  #   r_dly <- lapply(dates, 
  #                   function(dd, lyr = lyr_type) {
  #                     txt <- paste0("rast(
  #                                         merge(
  #                                               dat_coords, 
  #                                               dat[date == dd], 
  #                                               all.x = T)[, 
  #                                                   .(x, y, round(",
  #                                                   lyr,
  #                                                   ", 1))], 
  #                                   crs = 'epsg:3577')")
  #                     eval(parse(text=txt))
  #                   }
  #   )
  #   s_dly <- do.call(c, r_dly)
  #   time(s_dly) <- dates
  #  
  #   #write as netcdf with stars (needs stars > 0.6)
  #   # more successful than terra at writing out a recognisable CRS
  #   stars_dly <- stars::st_as_stars(s_dly)
  #   names(stars_dly) <- lyr_type
  #   stars::write_mdim(stars_dly, filename = file.path("data_derived", paste0(yy,"_",lyr_type,".nc")))
  #   ## qc
  #   # foo <- rast("data_derived/2019_remainder.nc")
  #   # plot(foo[[1]])
  #   # finish loop over lyrs here
  # }
  # 
  
  # #### load and convert from flagged ####
  # ## Search for .rds files in the indir_rf and store full paths in fs ##
  # fs <- dir(file.path(indir_flags), full.names = T, recursive = T, pattern = "rds$")
  # 
  # ## all available rds files ##
  # fs
  # 
  # ## subset the selected year, read selected rds and save in a list ##
  # fs_todo <- fs[grep(paste0("_", yy), basename(fs))]
  # ls_dat <- lapply(fs_todo, readRDS)
  # ## make daily raasters ####
  # dat <- rbindlist(ls_dat)
  # rm(ls_dat)
  # dates <- sort(unique(dat$date))
  # dates
  # 
  # ## loop to iterate over the 3 layers ##
  # ## for each layer creates a r_dly list of each date ##
  # 
  # # 'dust_cams_p50', 
  # # 'dust_cams_p75', 
  # # 'dust_cams_p95', 
  # # 'dust_merra_2_p50', 
  # # 'dust_merra_2_p75', 
  # # 'dust_merra_2_p95', 
  # # 
  # # 'smoke_p95', 'smoke_2SD', 
  # # 'whs_18degreeC', 
  # # 'whs_15degreeC', 
  # # 'whs_12degreeC', 
  # # 'active_fires_10000', 
  # # 'active_fires_25000', 
  # 
  # for(lyr_type in c(
  #                   'active_fires_50000', 
  #                   'active_fires_100000', 
  #                   'active_fires_500000', 
  #                   'extrapolated')) {
  #   # lyr_type = "dust_cams_p50"
  #   print(lyr_type)
  #   r_dly <- lapply(dates, 
  #                   function(dd, lyr = lyr_type) {
  #                     txt <- paste0("rast(
  #                                         merge(
  #                                               dat_coords, 
  #                                               dat[date == dd], 
  #                                               all.x = T)[, 
  #                                                   .(x, y, round(",
  #                                   lyr,
  #                                   ", 1))], 
  #                                   crs = 'epsg:3577')")
  #                     eval(parse(text=txt))
  #                   }
  #   )
  #   s_dly <- do.call(c, r_dly)
  #   time(s_dly) <- dates
  #   
  #   #write as netcdf with stars (needs stars > 0.6)
  #   # more successful than terra at writing out a recognisable CRS
  #   stars_dly <- stars::st_as_stars(s_dly)
  #   names(stars_dly) <- lyr_type
  #   stars::write_mdim(stars_dly, filename = file.path("data_derived", paste0(yy,"_",lyr_type,".nc")))
  #   ## qc
  #   # foo <- rast("data_derived/2019_dust_cams_p50.nc")
  #   # plot(foo[[1]])
  #   # finish loop over lyrs here
  #   rm(list = c("s_dly", "r_dly", "stars_dly"))
  #   gc()
  # }
  # finish loop over years here
  }
#  return("completed conversion from RDS files into ncdf stored in data_derived")
#}

    
#### cdo ####
'
conda activate smoke_data

cdo merge 2019_* bushfiresmoke_v1_3_2019.nc

nccopy -d9 bushfiresmoke_v1_3_2019.nc bushfiresmoke_v1_3_2019_compressed.nc

ncatted -h -a source,global,c,c,"The data was generated using a random forest model with satellite data, land use and other GIS layers as predictors of particulate matter (PM2.5) air pollution. A method of identifying specific pollution attributable to bushfires was applied that uses the seasonal trend decomposition algorithm (STL)." bushfiresmoke_v1_3_2019.nc

ncatted -h -a references,global,o,c,"CAR Firesmoke Project Team 2021. Bushfire specific PM2.5 output from v1.3 based on satellite and other land use and other predictors for Australia 2001-2021 produced for the CAR Bushfire Smoke Exposures project. Downloaded from the Centre for Air pollution, energy and health Research." bushfiresmoke_v1_3_2019.nc

ncatted -h -a comment,global,c,c,"This dataset is provided for use in a pilot project looking at building an API to optimise sharing of spatiotemporal gridded data output from satellite and other data modelling.

Please note that this is still a preliminary dataset only as whilst there are several layers here (number predictors out of range, prediction out of range etc) but the pm25_pred is the predicted smoke particles (PM2.5) and future versions will have decomposed that into PM2.5_Bushfire and PM2.5_Background, and a flag for if the pixel was dust or not. Therefore, this dataset is just a demo to see how we store the processed data and the data structures, as well as approximate data size estimates. 
 
CONDITIONS OF USE:
Please note these data are restricted and may not be on-shared or used for purposes outside the specified project without permission from the data owner." bushfiresmoke_v1_3_2019.nc

'
    
    
#### example R extract ####   
    
library(terra)
if(dir.exists("R_convert_rds_to_netcdf/")) setwd("R_convert_rds_to_netcdf/")
dir("data_derived")
bushfiresmoke <- rast( "data_derived/bushfiresmoke_v1_3_2019_compressed.nc")
names(bushfiresmoke)
str(bushfiresmoke)
unique(time(bushfiresmoke))
r <- bushfiresmoke[[time(bushfiresmoke) == as.Date("2019-11-03")]]
r
nm <- names(r)[grep('pm25_pred', names(r))]
nm <- names(r)[grep('pm25_pred', names(r))][1]
nm
r2 <- r[[nm]]
plot(r2)

nms <- unique(substr(names(bushfiresmoke), 1, 9))
nms[-grep("trend", nms)]
names(bushfiresmoke)[grep("pm25_pred", names(bushfiresmoke))]

# to get the list of only pm25_pred (not pm25_pred_out_of_range etc
r_pm <- bushfiresmoke[[substr(names(bushfiresmoke),1,9) == "pm25_pred"]]
r_pm
plot(r_pm)
