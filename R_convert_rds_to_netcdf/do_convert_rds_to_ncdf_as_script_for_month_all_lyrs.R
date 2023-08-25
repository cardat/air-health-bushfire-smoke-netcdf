# this is rewritten to avoid targets
# this adds a experiment to have all lyrs per time

if(dir.exists("R_convert_rds_to_netcdf/")) setwd("R_convert_rds_to_netcdf/")
if(!dir.exists("data_derived")) dir.create("data_derived")

sapply(dir("R", full.names = T, pattern = ".R$"), source)
load_packages(T)
config <- yaml::read_yaml("config.yaml")


#do_convert_rds_to_ncdf <- function(
    indir_rf = file.path(config$rootdir, config$raster_stl)
#    ,
    indir_flags = file.path(config$rootdir, config$raster_flags)
#    ,
    infile_coords = file.path(config$rootdir, config$raster_coords)
#    ,
    yy_todo = 2019
#) {
  
  #for(yy in yy_todo){
   yy = yy_todo[1]
  ## Convert vector file of coordinates to a df with x and y columns using vect() ##
  dat_coords <- as.data.frame(vect(infile_coords), geom = "XY")
  setDT(dat_coords)
  
  #### load and convert from stl ####
  ## Search for .rds files in the indir_rf and store full paths in fs ##
  fs <- dir(file.path(indir_rf), full.names = T, recursive = T, pattern = "rds$")
  
  ## all available rds files ##
  fs
  
  ## subset the selected year, read selected rds and save in a list ##
  fs_todo <- fs[grep(paste0("_", yy), basename(fs))]
  ls_dat <- lapply(fs_todo, readRDS)
  ## make daily raasters ####
  dat <- rbindlist(ls_dat)
  dates <- sort(unique(dat$date))
  dates
  
  #### start rewrite ####
  # for(month_i in months){  # TODO NOT COMPLETED
  month_i = 11
  dates_todo <- dates[which(month(dates) == month_i)]
  # convert to raster and store in a big list
  # you will have to do the three components = remainder (this is probably bushfire smoke), trend and seasonal
  # also a good way to save storage is rounding the decimals. one way to do this 
  # TODO REMOVE THIS, ONLY FOR THE OLD EXTRACTION? big_list <- list()
  
  
  ## loop to iterate over the 3 layers ##
  ## for each layer creates a r_dly list of each date ##

  for(date_i in dates_todo[1:3]){
    print(as.Date(date_i))
  #  date_i = dates_todo[1]
  #s_dly_list <- list()
  #for(lyr_type in c("seasonal", "trend", "remainder")) {
    lyr_type <- c("seasonal", "trend", "remainder")
    print(lyr_type)
    # lyr = lyr_type[1]
    r_dly <- lapply(lyr_type, 
                    function(lyr, dd = date_i) {
                      txt <- paste0("rast(
                                          merge(
                                                dat_coords, 
                                                dat[date == '",
                                                as.Date(dd),
                                                "'], 
                                                all.x = T)[, 
                                                    .(x, y, round(
                                                    ",lyr,"
                                                    , 1))], 
                                    crs = 'epsg:3577')")
                      # cat(txt)
                      eval(parse(text=txt))
                    }
    )
    
    s_dly <- do.call(c, r_dly)
    names(s_dly) <- lyr_type
    time(s_dly) <- rep(as.Date(date_i), length(r_dly))
    # terra::writeCDF(s_dly, "data_derived/test2.nc", atts =  c("x=a value", "y=abc", "z=foo"), overwrite=TRUE)
    # foo <- rast(file.path("data_derived/test2.nc"))
    # foo
    # # qc
    # plot(s_dly[[1]])
    # end loop over d????
  #}
    
    
    # s_dly
    
    
    #write as netcdf with stars (needs stars > 0.6)
    # more successful than terra at writing out a recognisable CRS
    stars_dly <- stars::st_as_stars(s_dly)
    str(stars_dly)
    names(stars_dly) <- "stl"
    names(stars_dly$stl) <- lyr_type
    stars::write_mdim(stars_dly, filename = file.path("data_derived", paste0(as.Date(date_i),"_","stl",".nc")))
    
    ## qc
    # date_qc <- "2019-11-01"
    # foo <- rast(file.path("data_derived", paste0(date_qc,"_","stl",".nc")))
    # foo
    # plot(foo[[1]])
    # plot(foo[[2]])
    # plot(foo[[3]])
    # pm25_pred <- foo[[1]]+foo[[2]]+foo[[3]]
    # plot(pm25_pred)
    # # end loop over dates
  }
  
myPlot <- function(date_qc = "2019-11-01"){
  # date_qc = "2019-11-01"
  foo <- rast(file.path("data_derived", paste0(date_qc,"_","stl",".nc")))
  foo
  #names(foo) <- lyr_type
  #foo2 <- stars::st_as_stars(foo)
  #stars::write_mdim(foo2, filename = "data_derived/test3.nc")
  #terra::writeCDF(foo, "data_derived/test3.nc", overwrite=TRUE)
  par(mfrow = c(2,2))
  plot(foo[[1]])
  plot(foo[[2]])
  plot(foo[[3]])
  pm25_pred <- foo[[1]]+foo[[2]]+foo[[3]]
  plot(pm25_pred)
}
myPlot("2019-11-03")  
  

## try
# cdo merge 2019_seasonal.nc 2019_trend.nc test4.nc
foo4 <- rast( "data_derived/test4.nc")
names(foo4)
str(foo4)
r <- foo4[[time(foo4) == as.Date("2019-11-02")]]
r
r2 <- brick(r)
r3 <- sum(r2)
plot(r3)

## try 2
'
conda activate smoke_data

cdo merge 2019_* bushfiresmoke_v1_3_2019_test.nc

ncatted -h -a source,global,c,c,"The data was generated using a random forest model with satellite data, land use and other GIS layers as predictors of particulate matter (PM2.5) air pollution. A method of identifying specific pollution attributable to bushfires was applied that uses the seasonal trend decomposition algorithm (STL)." bushfiresmoke_v1_3_2019_test.nc

ncatted -h -a references,global,o,c,"CAR Firesmoke Project Team 2021. Bushfire specific PM2.5 output from v1.3 based on satellite and other land use and other predictors for Australia 2001-2020 produced for the CAR Bushfire Smoke Exposures project. Downloaded from the Centre for Air pollution, energy and health Research." bushfiresmoke_v1_3_2019_test.nc

ncatted -h -a comment,global,c,c,"This dataset is provided for use in a pilot project looking at building an API to optimise sharing of spatiotemporal gridded data output from satellite and other data modelling.

Please note that this is still a preliminary dataset only as whilst there are several layers here (number predictors out of range, prediction out of range etc) but the pm25_pred is the predicted smoke particles (PM2.5) and future versions will have decomposed that into PM2.5_Bushfire and PM2.5_Background, and a flag for if the pixel was dust or not. Therefore, this dataset is just a demo to see how we store the processed data and the data structures, as well as approximate data size estimates. 

CONDITIONS OF USE:
Please note these data are restricted and may not be on-shared or used for purposes outside the specified project without permission from the data owner. 
" bushfiresmoke_v1_3_2019_test.nc

# Compressing the file
nccopy -d9 bushfiresmoke_v1_3_2019_test.nc bushfiresmoke_v1_3_2019_test_compressed.nc
'
library(terra)
bushfiresmoke <- rast( "data_derived/bushfiresmoke_v1_3_2019_test_compressed.nc")
names(bushfiresmoke)
str(bushfiresmoke)
unique(time(bushfiresmoke))
r <- bushfiresmoke[[time(bushfiresmoke) == as.Date("2019-11-03")]]
nm <- names(r)[grep( 'smoke_2SD', names(r))]
r2 <- r[[nm]]
plot(r2)

# 
#   
#     #stars::write_mdim(stars_dly, filename = file.path("data_derived", paste0(yy,sprintf('%02d',month_i),"_","stl",".nc")))
#     ## qc
#     # foo <- rast("data_derived/201911_stl.nc")
#     # foo
#     # plot(foo[[1]])
#     # finish loop over season etc here
#   #}
#   
#   
#   #### load and convert from flagged ####
#   ## Search for .rds files in the indir_rf and store full paths in fs ##
#   fs <- dir(file.path(indir_flags), full.names = T, recursive = T, pattern = "rds$")
#   
#   ## all available rds files ##
#   fs
#   
#   ## subset the selected year, read selected rds and save in a list ##
#   fs_todo <- fs[grep(paste0("_", yy), basename(fs))]
#   ls_dat <- lapply(fs_todo, readRDS)
#   ## make daily raasters ####
#   dat <- rbindlist(ls_dat)
#   dates <- sort(unique(dat$date))
#   dates
#   # convert to raster and store in a big list
#   # you will have to do the three components = remainder (this is probably bushfire smoke), trend and seasonal
#   # also a good way to save storage is rounding the decimals. one way to do this 
#   # TODO REMOVE THIS, ONLY FOR THE OLD EXTRACTION? big_list <- list()
#   
#   
#   ## loop to iterate over the 3 layers ##
#   ## for each layer creates a r_dly list of each date ##
#   
#   for(lyr_type in c('dust_cams_p50', 
#                     'dust_cams_p75', 
#                     'dust_cams_p95', 
#                     'dust_merra_2_p50', 
#                     'dust_merra_2_p75', 
#                     'dust_merra_2_p95', 
#                     'smoke_p95', 'smoke_2SD', 
#                     'whs_18degreeC', 
#                     'whs_15degreeC', 
#                     'whs_12degreeC', 
#                     'active_fires_10000', 
#                     'active_fires_25000', 
#                     'active_fires_50000', 
#                     'active_fires_100000', 
#                     'active_fires_500000', 
#                     'extrapolated')) {
#     # lyr_type = "dust_cams_p50"
#     print(lyr_type)
#     r_dly <- lapply(dates, 
#                     function(dd, lyr = lyr_type) {
#                       txt <- paste0("rast(
#                                           merge(
#                                                 dat_coords, 
#                                                 dat[date == dd], 
#                                                 all.x = T)[, 
#                                                     .(x, y, round(",
#                                     lyr,
#                                     ", 1))], 
#                                     crs = 'epsg:3577')")
#                       eval(parse(text=txt))
#                     }
#     )
#     s_dly <- do.call(c, r_dly)
#     time(s_dly) <- dates
#     
#     #write as netcdf with stars (needs stars > 0.6)
#     # more successful than terra at writing out a recognisable CRS
#     stars_dly <- stars::st_as_stars(s_dly)
#     names(stars_dly) <- lyr_type
#     if(!dir.exists("data_derived")) dir.create("data_derived")
#     stars::write_mdim(stars_dly, filename = file.path("data_derived", paste0(yy,"_",lyr_type,".nc")))
#     ## qc
#     # foo <- rast("data_derived/2016_remainder.nc")
#     # plot(foo[[1]])
#     # finish loop over season etc here
#   }
#   # finish loop over years here
#   }
# #  return("completed conversion from RDS files into ncdf stored in data_derived")
# #}
