#### test terra ####
library(terra)
library(data.table)
#### input ####
infile <- "~/cloudstor/Shared/Bushfire_specific_PM25_Aus_2001_2020_v1_3/data_derived/bushfiresmoke_v1_3_2019_compressed_20230825_1.nc"
## show warning from rgdal
var_i <- "pm25_pred"
b <- raster::brick(infile, varname = var_i)
"
Please note that rgdal will be retired during October 2023,
plan transition to sf/stars/terra functions using GDAL and PROJ
at your earliest convenience.
"
rm(b)
## use terra but notice cannot read single layer in terra by name, so get by name second
b1 <- terra::rast(infile)
names(b1)

b <- b1[[grep(var_i, names(b1))]]
# b
## get pixel over belconnen
xy <- cbind(1545315, -3954140)
e <- extract(b, xy)
length(e)
## 365
plot(1:365,e)

## cf sa1
sa1 <- readRDS("~/cloudstor/Shared/DatSci_bushfire_specific_pm25_for_sa1_2016_2001_2020_v1_3/data_derived/dat_extract_rasters_ncdf_act.rds")
setDT(sa1)
sa1 <- sa1[year == 2019 & sa1_7dig16 == 8100101]
sa1v2 <- cbind(sa1, t(e))
plot(sa1v2$pm25_pred, sa1v2$V1)
abline(0,1)
with(sa1v2, plot(date, V1, type = "h"))


## all layers for this pixel
e2 <- extract(b1, xy)
length(e2)
## 8395
23*365
e2_tposed <- data.frame(vname = names(e2), values = t(e2))
## need to transpose so not a wide 'data.frame':	1 obs. of  8395 variables:
head(e2_tposed)
setDT(e2_tposed)
e2_tposed[grep("smoke_2SD", vname)]

## dump to rds
saveRDS(e2_tposed, "data_derived/qc_belconnen_pixel_extraction_for_ben.rds")
