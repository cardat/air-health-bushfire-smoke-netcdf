## this pipeline is for creating SA1 average bushfire smoke, and aggregations to ABS census boundaries etc
## Lucas Hertzog and Ivan Hanigan and Ben Davies

if(dir.exists("R_convert_rds_to_netcdf/")) setwd("R_convert_rds_to_netcdf/")

## Load packages, or install them if not available
library(targets)
config <- yaml::read_yaml("config.yaml")
# tar_source()
sapply(dir("R", full.names = T, pattern = ".R$"), source)
load_packages(T)

## The Pipeline
tar_visnetwork(targets_only = T,
                        level_separation = 200)
tar_make()

## EDA

do_eda <- FALSE
if(do_eda){
tar_load(dat_convert_and_extract_rasters)
dat_convert_and_extract_rasters
dat <- readRDS("data_derived/2016.rds")
dat
qc <- dat[date == "2019-12-10"] # "2019-12-27"]
tar_load(dat_sa1_shp)
qc2 <- merge(dat_sa1_shp, qc, by = c("sa1_7dig16", "gcc_code16"))
unique(qc2$gcc_code16)
qc2 <- qc2[qc2$gcc_code16 == "1GSYD",]
## NB this takes a long time to draw all the polygons
plot(qc2["pm25_pred"], border =  T)# NA)

# TODO make a good looking plot From top to bottom: seasonal, trend, remainder, full PM2.5.
plot(qc2[c("seasonal", "trend", "remainder", "pm25_pred")], border = NA)
# legend is missing?
plot(qc2["seasonal"], border = NA)
plot(qc2["trend"], border = NA)
plot(qc2["remainder"], border = NA)

qc3 <- dat[gcc_code16 == "1GSYD",.(pm25_pred = mean(pm25_pred, na.rm = T),
                                   remainder = mean(remainder, na.rm = T),
                                   seasonal = mean(seasonal, na.rm = T),
                                   trend = mean(trend, na.rm = T)), by = c("gcc_code16", "date")]

threshold <- sd(qc3$remainder) * 2
qc3$extreme_smoke_day <- ifelse(qc3$pm25_pred >= (qc3$seasonal + qc3$trend + threshold), 1, 0)
setDF(qc3)
qc3$extreme_smoke <- ifelse(qc3$extreme_smoke_day == 1, qc3$remainder, NA)

with(qc3, plot(date, pm25_pred, type = 'b', ylim = c(0,100)))
with(qc3, lines(date, seasonal + trend, lwd = 2))
lines(qc3$date, qc3$seasonal + qc3$trend + threshold, col = 'blue')
with(qc3[qc3$extreme_smoke_day == 1,], segments(date, seasonal + trend + remainder, date, seasonal + trend, col = 'red'))
dev.off()

}


