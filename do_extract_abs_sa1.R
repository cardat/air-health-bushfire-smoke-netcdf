## aim: extract spatially weighted averages of the bushfire smoke data for Australian Bureau of Statistics SA1s
## ivanhanigan
## version 1: 2022-05-16 / use Tasmania and days from the 2016 January event as an example

##library(terra)
library(raster)
library(ncdf4)
library(exactextractr)
library(sf)
library(data.table)


#### input ####
infile <- "~/ownCloud/Shared/Bushfire_specific_PM25_Aus_2001_2020_v1_2/data_netcdf/merged_files/bushfire_smoke_2001_2020_compressed_20220516.nc"

#### variables ####
r_nc <- ncdf4::nc_open(infile)
r_nc
varlist <- names(r_nc[['var']])
# excclude lon, lat and crs
varlist <- varlist[4:length(varlist)]
varlist

#### load ABS SA1 for TAS ####
indir_sa1 <- "~/ownCloud/Shared/Environment_General/ABS_data/ABS_Census_2016/abs_sa1_2016_data_provided"
## dir(indir_sa1)
infile_sa1 <- "SA1_2016_TAS.shp"
sa1 <- st_read(file.path(indir_sa1, infile_sa1))

#### load and extract for study period ####

study_period <- list(mindate="2016-01-01", maxdate ="2016-01-31")

## raster data for each var
outdat <- list()
for(var_i in varlist){
  ##var_i = varlist[1]
  print(var_i)
  b <- raster::brick(infile, varname = var_i)
  ##b
  b2 <- b[[which(getZ(b) >= as.Date(study_period[["mindate"]]) & getZ(b) <= as.Date(study_period[["maxdate"]]))]]
  b_sa1 <- exact_extract(brick(b2), sa1, progress = FALSE) 
  ## ignoring warning about CRS for now
  b_sa1 <- rbindlist(b_sa1, idcol = "rowid")
  ##b_sa1
  ## make long format from wide
  b_sa1_long <- melt(b_sa1, id.var = c("rowid", "coverage_fraction"))
  ## check a day
  ## b_sa1_long[variable == "X2016.01.19"]
  b_sa1_out <- b_sa1_long[,
                          .(value = sum(value * coverage_fraction, na.rm = T) / sum(coverage_fraction, na.rm = T)),
                          by = .(rowid, variable)
                          ]
  ## checks for one day
  # b_sa1_out2 <- b_sa1_out[variable == "X2016.01.19"]
  # sa1_map <- cbind(sa1, b_sa1_out2)
  # plot(sa1_map["value"])
  names(b_sa1_out) <- c("rowid", "date", "value")
  b_sa1_out$variable <- var_i
  outdat[[var_i]] <- b_sa1_out
}

outdat <- rbindlist(outdat)
outdat$date <- gsub("X","",outdat$date)
outdat$date <- as.Date(gsub("\\.","-",outdat$date))

outdat_wide <- dcast(outdat, rowid + date ~ variable, value.var = "value")

## get sa1 codes
sa1_df <- st_drop_geometry(sa1)
sa1_df$rowid <- 1:nrow(sa1_df)
setDT(sa1_df)

outdat_wide2 <- merge(sa1_df[,.(rowid, SA1_7DIG16, SA4_NAME16, GCC_NAME16)], outdat_wide, by = "rowid")
unique(outdat_wide2$SA4_NAME16)

#### show a time series plot for a single SA1 in launceston ####

sa1_todo <- 6103815
sa1_toplot <- outdat_wide2[SA1_7DIG16 == sa1_todo]

png("do_extract_abs_sa1_launceston.png", width = 1000, height = 700)
# show the pm2.5
with(sa1_toplot, plot(date, pm25_pred, type = "h", ylim = c(0,40)))
# show the background PM
with(sa1_toplot, lines(date, season_plus_trend, col = 'blue'))
# show possible fire days
fire_days <- sa1_toplot[smoke_2sd > 0 & active_fires_50000 > 0 & dust_merra_2_p95 == 0]
with(fire_days, points(date, pm25_pred, col = 'red', pch = 16))
# this filter seems too stringent, relax the active fires flag
fire_days <- sa1_toplot[smoke_2sd > 0 & dust_merra_2_p95 == 0]
with(fire_days, points(date, pm25_pred, col = 'orange', pch = 1))
# show the bushfire specific PM
with(fire_days, segments(date, pm25_pred, date, pm25_pred - remainder, lwd = 2, col = 'red'))
legend("topleft", legend = c("PM2.5", "PM2.5 bushfire", "PM2.5 background", "probable smoke (fires in 50k)", "probable smoke (any non-dust)"), lty = c(1,1,1,NA,NA), pch = c(NA,NA,NA,16,1), col = c('black', 'red', 'blue', 'red', 'orange'))
dev.off()