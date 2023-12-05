library(data.table)
library(sf)
library(terra)
library(ncdf4)

#### set up ####
rootdir_OLD <- "~/cloudstor/Shared/Bushfire_specific_PM25_Aus_2001_2020_v1_3/data_derived"
flist <- dir(rootdir, full.names = T, pattern = "_1.nc")

#### extract the layer ####
for(fi in flist[2:length(flist)]){
# fi <- flist[1]
print(fi)

# system(sprintf("gdalinfo %s", fi))
# system2("gdalinfo", fi)

var_i <- "pm25_pred" # "remainder"
system(
  sprintf("cdo select,name=%s %s %s",
        var_i,
        fi,  
        gsub(".nc$", paste0("_", var_i, ".nc"), fi)
  )
)

}

system(
  sprintf("cdo mergetime %s %s",
          file.path(rootdir, paste0("*_", var_i, ".nc")),
          file.path(rootdir, paste0("bushfiresmoke_v1_3_2001_2020_", var_i, "_out.nc"))          
          )
)


#### qc ####
dir()
infile <- file.path(rootdir, paste0("bushfiresmoke_v1_3_2001_2020_", var_i, "_out.nc"))
system2("gdalinfo", infile)
r <- terra::rast(infile)
r
plot(r[[1]])
xy <- cbind(1545315, -3954140)
e <- extract(r, xy)
len <- length(e)
len
20*365.25
plot(1:len,e)
p99 <- quantile(t(e), 0.99)
abline(p99,0)


#### extract the SD ####
## but first the 99th

system(
  sprintf("cdo timmin %s %s", 
          file.path(rootdir, paste0("bushfiresmoke_v1_3_2001_2020_",var_i,"_out.nc")), 
          file.path(rootdir, paste0("bushfiresmoke_v1_3_2001_2020_",var_i,"_min.nc"))
  )
)
system(
  sprintf("cdo timmax %s %s", 
          file.path(rootdir, paste0("bushfiresmoke_v1_3_2001_2020_",var_i,"_out.nc")), 
          file.path(rootdir, paste0("bushfiresmoke_v1_3_2001_2020_",var_i,"_max.nc"))
  )
)
system(
  sprintf("cdo timpctl,99 %s %s %s %s", 
          file.path(rootdir, paste0("bushfiresmoke_v1_3_2001_2020_",var_i,"_out.nc")), 
          file.path(rootdir, paste0("bushfiresmoke_v1_3_2001_2020_",var_i,"_min.nc")), 
          file.path(rootdir, paste0("bushfiresmoke_v1_3_2001_2020_",var_i,"_max.nc")),
          file.path(rootdir, paste0("bushfiresmoke_v1_3_2001_2020_",var_i,"_p99.nc"))
  )
)

infile <- file.path(rootdir, paste0("bushfiresmoke_v1_3_2001_2020_",var_i,"_p99.nc"))
system2("gdalinfo", infile)
r99 <- terra::rast(infile)
r99
plot(r99)

#### and 95th ####
system(
  sprintf("cdo timpctl,95 %s %s %s %s", 
          file.path(rootdir, paste0("bushfiresmoke_v1_3_2001_2020_",var_i,"_out.nc")), 
          file.path(rootdir, paste0("bushfiresmoke_v1_3_2001_2020_",var_i,"_min.nc")), 
          file.path(rootdir, paste0("bushfiresmoke_v1_3_2001_2020_",var_i,"_max.nc")),
          file.path(rootdir, paste0("bushfiresmoke_v1_3_2001_2020_",var_i,"_p95.nc"))
  )
)

infile <- file.path(rootdir, paste0("bushfiresmoke_v1_3_2001_2020_",var_i,"_p95.nc"))
system2("gdalinfo", infile)
r95 <- terra::rast(infile)
r95
plot(r95)

# # this seems high
# infile <-     file.path(rootdir, paste0("bushfiresmoke_v1_3_2001_2020_",var_i,"_out.nc"))
# r1 <- terra::rast(infile)
# r1
# r95_2 <- quantile(r1, 0.95) # this fell over
# plot(r95_2)

infile <- file.path(rootdir, paste0("bushfiresmoke_v1_3_2001_2020_", var_i, "_out.nc"))
system2("gdalinfo", infile)
r0 <- terra::rast(infile)
r0
plot(r0[[1:4]])
r1_95_flagged <- ifel(r0 > r95, 1, 0)
plot(r1_95_flagged[[1:4]])
outfile <- file.path(rootdir, paste0("bushfiresmoke_v1_3_2001_2020_", var_i, "_smoke_p95v2.nc"))
writeCDF(r1_95_flagged, filename = outfile)




#### smoke_2SD_trimmed ####
system(
  sprintf("nccopy -d9 %s %s",
          file.path(rootdir, paste0("bushfiresmoke_v1_3_2001_2020_", var_i, "_out.nc")),
          file.path(rootdir, paste0("bushfiresmoke_v1_3_2001_2020_", var_i, "_compressed.nc"))
  )
)


infile <- file.path(rootdir, paste0("bushfiresmoke_v1_3_2001_2020_", var_i, "_out.nc"))
system2("gdalinfo", infile)
r0 <- terra::rast(infile)
r0
plot(r0[[1:4]])
r1 <- ifel(r0 > r99, r99, r0)
outfile <- file.path(rootdir, paste0("bushfiresmoke_v1_3_2001_2020_", var_i, "_trimmed.rds"))
saveRDS(r1, outfile)
r1 <- readRDS(outfile)
r1
outfile <- file.path(rootdir, paste0("bushfiresmoke_v1_3_2001_2020_", var_i, "_trimmed.nc"))
writeCDF(r1, filename = outfile)
# nccopy -d9 bushfiresmoke_v1_3_2001_2020_remainder_trimmed.nc bushfiresmoke_v1_3_2001_2020_remainder_trimmed_compressed.nc
# NOTE using the compressed netcdf takes a MUCH longer time for terra stdev than the uncompressed file
outfile <- file.path(rootdir, paste0("bushfiresmoke_v1_3_2001_2020_", var_i, "_trimmed.nc"))
r1 <- terra::rast(outfile)
r1
r1_sd <- stdev(r1)
outfile <- file.path(rootdir, paste0("bushfiresmoke_v1_3_2001_2020_", var_i, "_trimmed_stdev.nc"))
writeCDF(r1_sd, filename = outfile)


# qc
plot(r1_sd)
plot(r1[[1:4]])
xy <- cbind(1545315, -3954140)
e <- extract(r1, xy)
len <- length(e)
len
20*365.25
plot(1:len,e)
e_sd <- extract(r1_sd, xy)
abline(as.numeric(2*e_sd), 0)
points(1:len,e, col = e > as.numeric(2*e_sd), pch = 16)

# now do the main calculation for the flag
r1_flagged <- ifel(r1 > 2*r1_sd, 1, 0)
outfile <- file.path(rootdir, paste0("bushfiresmoke_v1_3_2001_2020_", var_i, "_trimmed_smoke_2SDv2.nc"))
writeCDF(r1_flagged, filename = outfile)
plot(r1_flagged[[1:4]])
plot(1:len,e)
e_flag <- extract(r1_flagged, xy)
points(1:len, e, col = t(e_flag), pch = 16)

#stars_r1 <- stars::st_as_stars(r1, ignore_file = T)
#stars_r1 <- stars::st_as_stars(qc, ignore_file = T)

# dim(stars_r1)
# names(stars_r1) <- var_i
# stars::write_mdim(stars_r1, file.path(rootdir, paste0("bushfiresmoke_v1_3_2001_2020_",var_i,"_trimmed_2.nc")))

#outfile <- file.path(rootdir, paste0("bushfiresmoke_v1_3_2001_2020_", var_i, "_trimmed_p99.rds"))
#saveRDS(r0, outfile)












#### split p95 and 2SD to yearly ####
# fix up issue where I was  doing everything in data_derived, and I renamed OLD
rootdir_OLD <- "~/cloudstor/Shared/Bushfire_specific_PM25_Aus_2001_2020_v1_3/data_derived_OLD_wrong_flags"
rootdir2 <- gsub("data_derived", "working_ivan", rootdir)

var_i = "smoke_p95"

for(yy in 2002:2020){
  #yy = 2001
  system(
    sprintf("cdo selyear,%s %s %s",
            yy,
            file.path(rootdir2, paste0("bushfiresmoke_v1_3_2001_2020_", var_i, "_smoke_p95v2.nc")),
            file.path(rootdir2, paste0("bushfiresmoke_v1_3_",yy,"_", var_i, "_smoke_p95_v1_3.nc"))
    )
  )
  
}
# qc
r <- terra::rast(file.path(rootdir2, paste0("bushfiresmoke_v1_3_",yy,"_", var_i, "_smoke_p95_v1_3.nc")))
r
plot(r[[1:4]])

var_k = "remainder_trimmed"
for(yy in 2002:2020){
  #yy = 2001
  system(
    sprintf("cdo selyear,%s %s %s",
            yy,
            file.path(rootdir2, paste0("bushfiresmoke_v1_3_2001_2020_", var_k, "_smoke_2SDv2.nc")),
            file.path(rootdir2, paste0("bushfiresmoke_v1_3_",yy,"_", var_k, "_smoke_2SD_v1_3.nc"))
    )
  )
  
}

#### remove old both p95 and 2sd flag yearly ####
# fix up issue where I was  doing everything in data_derived
#rootdir2 <- gsub("data_derived", "working_ivan", rootdir)
for(yy in 2004:2020){
  #yy = 2001
  var_i = "smoke_p95"
  var_j = "smoke_2SD"
   # remove the layer
  system(
    sprintf("ncks -L 0 %s %s",
            file.path(rootdir_OLD, paste0("bushfiresmoke_v1_3_",yy,"_compressed_20230825_1.nc")),
            file.path(rootdir2, paste0("bushfiresmoke_v1_3_",yy,"_uncompressed_20230825_1.nc"))
    )
  )
  system(
    sprintf("ncks -C -O -x -v %s %s %s",
            var_i,
            file.path(rootdir2, paste0("bushfiresmoke_v1_3_",yy,"_uncompressed_20230825_1.nc")),
            file.path(rootdir2, paste0("bushfiresmoke_v1_3_",yy,"_uncompressed_20230825_2.nc"))
    )
  )
  system(
    sprintf("ncks -C -O -x -v %s %s %s",
            var_j,
            file.path(rootdir2, paste0("bushfiresmoke_v1_3_",yy,"_uncompressed_20230825_2.nc")),
            file.path(rootdir2, paste0("bushfiresmoke_v1_3_",yy,"_uncompressed_20230825_3.nc"))
    )
  )
  
  # ## qc
  # r_nc <- ncdf4::nc_open(file.path(rootdir2, paste0("bushfiresmoke_v1_3_",yy,"_uncompressed_20230825_3.nc")))
  # r_nc
  # varlist <- names(r_nc[['var']])
  # varlist
  # ncdf4::nc_close(r_nc)
  # # cf
  # r_nc <- ncdf4::nc_open(file.path(rootdir2, paste0("bushfiresmoke_v1_3_",yy,"_uncompressed_20230825_1.nc")))
  # r_nc
  # varlist2 <- names(r_nc[['var']])
  # varlist; varlist2
  # ncdf4::nc_close(r_nc)
  
  ## NOT DONE test with compression 
  # system(
  #   sprintf("nccopy -d7 %s %s",
  #           file.path(rootdir2, paste0("bushfiresmoke_v1_3_",yy,"_uncompressed_20230825_3.nc")),
  #           file.path(rootdir2, paste0("bushfiresmoke_v1_3_",yy,"_compressed_20230825_3.nc"))
  #   )
  # )
  
  # NOT DONE test to put together first split appart
  # var_ix <- "pm25_pred" # "remainder"
  # system(
  #   sprintf("cdo select,name=%s %s %s",
  #           var_ix,
  #           file.path(rootdir2, paste0("bushfiresmoke_v1_3_",yy,"_uncompressed_20230825_3.nc")),
  #           gsub(".nc$", paste0("_", var_ix, ".nc"),
  #                file.path(rootdir2, paste0("bushfiresmoke_v1_3_",yy,"_compressed_20230825_3.nc"))
  #                )
  #   )
  # )

  system(
    sprintf("cdo merge %s %s %s",
            file.path(rootdir2, paste0("bushfiresmoke_v1_3_",yy,"_uncompressed_20230825_3.nc")),
            file.path(rootdir2, paste0("bushfiresmoke_v1_3_",yy,"_pm25_pred_", var_i, "_v1_3.nc")),
            file.path(rootdir2, paste0("bushfiresmoke_v1_3_",yy,"_uncompressed_20230825_4.nc"))
    )
  )
  ## NB cat fails with different number of variables, use merge
  system(
    sprintf('ncrename -h -O -v bushfiresmoke_v1_3_2001_2020_pm25_pred_smoke_p95v2,smoke_p95_v1_3 %s',
            file.path(rootdir2, paste0("bushfiresmoke_v1_3_",yy,"_uncompressed_20230825_4.nc"))
            )
  )
  
  ### now do the other flags
  system(
    sprintf("cdo merge %s %s %s",
            file.path(rootdir2, paste0("bushfiresmoke_v1_3_",yy,"_uncompressed_20230825_4.nc")),
            file.path(rootdir2, paste0("bushfiresmoke_v1_3_",yy,"_remainder_trimmed_", var_j, "_v1_3.nc")),
            file.path(rootdir2, paste0("bushfiresmoke_v1_3_",yy,"_uncompressed_20230825_5.nc"))
    )
  )

  system(
    sprintf('ncrename -h -O -v bushfiresmoke_v1_3_2001_2020_remainder_trimmed_smoke_2SDv2,trimmed_smoke_2SD_v1_3 %s',
            file.path(rootdir2, paste0("bushfiresmoke_v1_3_",yy,"_uncompressed_20230825_5.nc"))
    )
  )
  
  # final step: compress and publish the result

  system(
    sprintf("nccopy -d7 %s %s",
            file.path(rootdir2, paste0("bushfiresmoke_v1_3_",yy,"_uncompressed_20230825_5.nc")),
            file.path("~/cloudstor/Shared/Bushfire_specific_PM25_Aus_2001_2020_v1_3/data_derived", paste0("bushfiresmoke_v1_3_",yy,"_compressed_20230825_6.nc"))
    )
  )

  
  # clean up 
  system(
    sprintf("rm %s",
            file.path(rootdir2, paste0("bushfiresmoke_v1_3_",yy,"_uncompressed_20230825_1.nc"))
    )
  )
  system(
    sprintf("rm %s",
            file.path(rootdir2, paste0("bushfiresmoke_v1_3_",yy,"_uncompressed_20230825_2.nc"))
    )
  )
  system(
    sprintf("rm %s",
            file.path(rootdir2, paste0("bushfiresmoke_v1_3_",yy,"_uncompressed_20230825_3.nc"))
    )
  )
  system(
    sprintf("rm %s",
            file.path(rootdir2, paste0("bushfiresmoke_v1_3_",yy,"_uncompressed_20230825_4.nc"))
    )
  )
  system(
    sprintf("rm %s",
            file.path(rootdir2, paste0("bushfiresmoke_v1_3_",yy,"_uncompressed_20230825_5.nc"))
    )
  )

  
}

#### qc v6 ####
qc <- FALSE
if(qc){
  shpdir <- "~/cloud-car-dat/Environment_General/ABS_data/ABS_Census_2016/abs_sa1_2016_data_provided"
  shpfile <- "SA1_2016_AUST.shp"
  sa1_todo_shp <- terra::vect(file.path(shpdir, shpfile))
  unique(sa1_todo_shp$GCC_CODE16)[grep("G", unique(sa1_todo_shp$GCC_CODE16))]
  sa1_todo_shp <- sa1_todo_shp[sa1_todo_shp$GCC_CODE16 %in% c("1GSYD", "2GMEL", "3GBRI", "4GADE", "5GPER", "6GHOB", "7GDAR", "8ACTE"),]
  sa1_todo_shp <- st_as_sf(sa1_todo_shp)
  sa1_todo_shpv2 <- st_transform(sa1_todo_shp, crs = "EPSG:3577")
  xy <- st_coordinates(st_centroid(sa1_todo_shpv2))
  str(xy)
  sa1_todo_shpv3 <- data.table(st_drop_geometry(sa1_todo_shpv2), xy)
  xy1 <- sa1_todo_shpv3[,.(GCC_CODE16, X = mean(X), Y = mean(Y)), by = "GCC_CODE16"]
  # I suspect Brisbane and Hobart are xy in the ocean
  write.csv(xy1, "working_ivan/qc_gcc_xy.csv", row.names = F)
  # yes that is the case so add a few 1000 m to northing 
  xy1 <- sa1_todo_shpv3[,.(GCC_CODE16, X = mean(X), Y = mean(Y)+6000), by = "GCC_CODE16"]
  xy <- cbind(xy1[,c("X", "Y")])
  setDF(xy)
  fs <- dir("~/cloudstor/Shared/Bushfire_specific_PM25_Aus_2001_2020_v1_3/data_derived", full.names = T)

  r_nc <- ncdf4::nc_open(fs[3])
  r_nc
  varlist <- names(r_nc[['var']])
  # excclude lon, lat and crs
  varlist <- varlist[3:length(varlist)]
  varlist
  ncdf4::nc_close(r_nc)
  r1 <- terra::rast(fs, subds="pm25_pred")
  r2 <- terra::rast(fs, subds="trimmed_smoke_2SD_v1_3")
  #names(r1)
  
  #plot(r2[[1]])
  #xy <- cbind(1545315, -3954140)# this is canberra
  pm25_pred <- extract(r1, as.matrix(xy))# c(1747771, -3821204)) #xy[1,])
  length(pm25_pred)
  pm25_pred0 <- data.table(t(pm25_pred))
  names(pm25_pred0) <- paste0(xy1$GCC_CODE16, "_pm25_pred")
  head(pm25_pred0)
  # pm25_pred <- as.numeric(pm25_pred)
  pm25_pred0[pm25_pred0 == 0] <- NA
  
  trimmed_smoke_2SD_v1_3 <- extract(r2, as.matrix(xy))# c(1747771, -3821204)) #xy[1,])
  length(trimmed_smoke_2SD_v1_3)
  trimmed_smoke_2SD_v1_3 <- data.table(t(trimmed_smoke_2SD_v1_3))
  names(trimmed_smoke_2SD_v1_3) <- paste0(xy1$GCC_CODE16, "_trimmed_smoke_2SD_v1_3")
  
  # trimmed_smoke_2SD_v1_3 <- extract(r2, xy)
  # trimmed_smoke_2SD_v1_3 <- as.numeric(trimmed_smoke_2SD_v1_3)
  s1_toplot <- data.frame(date = time(r1), pm25_pred0, trimmed_smoke_2SD_v1_3)
  head(s1_toplot); tail(s1_toplot)
  #table(s1_toplot$trimmed_smoke_2SD_v1_3)
  
  par(mfrow = c(2,4))
  
  for(ii in 2:9){#c(2,3,5,6,8,9)){
    #ii = 7
    i <- names(s1_toplot)[ii]
    i2 <- names(s1_toplot)[ii + 8]
    idx <- substr(s1_toplot$date, 1, 4) == 2004
    plot(s1_toplot[idx,"date"], s1_toplot[idx,i], type = "l")
    points(s1_toplot[,"date"], s1_toplot[,i], col = s1_toplot[,i2]+1, pch = 16)
    title(i)
    }
  
  
}

#### fix missings appearing as zero ####
## cdo -setctomiss,0 input output
## https://code.mpimet.mpg.de/boards/1/topics/8452
fs <- dir("~/cloudstor/Shared/Bushfire_specific_PM25_Aus_2001_2020_v1_3/data_derived", full.names = T)
for(i in length(fs)){
#i = 1
  fname_in <- basename(fs[i])
  print(fname_in)
  yy <- as.integer(sub("bushfiresmoke_v1_3_([0-9]{4})_.+", "\\1", fname_in))
  # yy
  file.copy(fs[i], file.path("data_derived", fname_in))
  
  # set up variables
  # we will extrapolate on flags by taking max in focal window (adjacent cells)
  #   and coerce to integer
  # extrapolate on pm2.5 values by taking mean in focal window
  # do nothing to 'other' except merge it back
  # also set fill/missing value for all
  
  if(yy >= 2003){
    flags_todo <- c("active_fires_10000", "active_fires_100000", "active_fires_25000",
                    "active_fires_50000", "active_fires_500000", 
                    "dust_cams_p50", "dust_cams_p75", "dust_cams_p95",
                    "dust_merra_2_p50", "dust_merra_2_p75", "dust_merra_2_p95",
                    "extrapolated", "whs_12degreeC", "whs_15degreeC", "whs_18degreeC",
                    "smoke_p95_v1_3", "trimmed_smoke_2SD_v1_3")
  } else {
    flags_todo <- c("active_fires_10000", "active_fires_100000", "active_fires_25000",
                    "active_fires_50000", "active_fires_500000", 
                    "dust_merra_2_p50", "dust_merra_2_p75", "dust_merra_2_p95",
                    "extrapolated", "whs_12degreeC", "whs_15degreeC", "whs_18degreeC",
                    "smoke_p95_v1_3", "trimmed_smoke_2SD_v1_3")
  }
  pm25_todo <- c("pm25_pred", "remainder", "seasonal", "trend")
  other_todo <- c("prediction_out_range", "predictor_out_range")
  
  ## set all missing value to NaN so it can be read correctly by GIS programs and terra
  # https://code.mpimet.mpg.de/projects/cdo/wiki/FAQ#How-can-I-set-or-change-the-missing-value-or-change-NaN-to-missing-value
  f_setmissing <- file.path("data_derived", 
                            gsub("compressed_20230825_6.nc", 
                                 "uncompressed_20231130_6_a_setmissval.nc", 
                                 fname_in))
  system(
    ##  cat(
    sprintf('cdo setmissval,nan %s %s',
            file.path("data_derived", fname_in),
            f_setmissing
    )
  )
  
  ## iterate over flags, extrapolate and set to integer
  # for the extrapolated flag, don't use max, just flag if any adjacent cell not NA
  r_flags_extrap <- lapply(flags_todo, function(i){
    # i <- flags_todo[1]
    r <- terra::rast(f_setmissing, i)
    # extrapolate NA cells with focal window
    if(i == "extrapolated"){
      # take sum of adjacent cells (return NA if all adjacent are NA)
      r_extrap_sum <- focal(r, 3, "sum", na.rm = T, na.policy = "only")
      # convert all non-NA to 1 and merge with original
      r_extrap_sum <- r_extrap_sum %/% 10 + 1
      r_extrap <- merge(r, r_extrap_sum)
    } else {
      r_extrap <- focal(r, 3, "max", na.policy = "only")
    }
    
    stars_r <- stars::st_as_stars(r_extrap)
    names(stars_r) <- i
    
    outf <- file.path("data_derived", gsub("compressed_20230825_6.nc", 
                                           paste0("uncompressed_20231130_6_b_", i, ".nc"), fname_in))
    write_mdim(stars_r, filename = outf)
    
    cat(sprintf("Saving %s %i with missing value and type integer\n", i, yy))
    # set missing value and coerce to integer
    outf2 <- file.path("data_derived", gsub("compressed_20230825_6.nc", 
                                           paste0("uncompressed_20231130_6_b_", i, "_nonan.nc"), fname_in))
    system(
      ##  cat(
      sprintf('cdo -setmissval,127 -setmissval,nan %s %s',
              outf,
              outf2
      )
    )
    
    outf3 <- file.path("data_derived", gsub("compressed_20230825_6.nc",
                                            paste0("uncompressed_20231130_6_b_", i, "_nonan_int.nc"), fname_in))
    system(
      ##  cat(
      sprintf("ncap2 -s '%s=byte(%s)' %s %s",
              i, i,
              outf2,
              outf3
      )
    )
    return(outf3)
  })
  # r_flags_extrap
  
  ## iterate over pm2.5 variables, extrapolate and set to integer
  r_pm25_extrap <- lapply(pm25_todo, function(i){
    # i <- pm25_todo[1]
    r <- terra::rast(f_setmissing, i)
    # extrapolate NA cells with focal window
    r_extrap <- focal(r, 3, "mean", na.policy = "only")
    stars_r <- stars::st_as_stars(r_extrap)
    names(stars_r) <- i
    
    cat(sprintf("Saving %s %i extrapolation\n", i, yy))
    outf <- file.path("data_derived", gsub("compressed_20230825_6.nc", 
                                           paste0("uncompressed_20231130_6_b_", i, ".nc"), fname_in))
    write_mdim(stars_r, filename = outf)
    
    # set missing value
    cat(sprintf("Saving %s %i with missing value\n", i, yy))
    outf2 <- file.path("data_derived", gsub("compressed_20230825_6.nc", 
                                            paste0("uncompressed_20231130_6_b_", i, "_nonan.nc"), fname_in))
    system(
      ##  cat(
      sprintf('cdo setmissval,nan %s %s',
              outf,
              outf2
      )
    )
    return(outf2)
  })
  # r_pm25_extrap
  
  ## merge everything back together
  # select other (unchanged) vars
  system(
    ##  cat(
    sprintf('cdo select,name=%s %s %s',
            paste(other_todo, collapse = ","),
            file.path("data_derived", fname_in),
            file.path("data_derived", gsub("compressed_20230825_6.nc", 
                                           "uncompressed_20231130_6_b_other_nonan.nc",
                                           fname_in))
    )
  )
  # and merge with fixed rasters
  system(
    ##  cat(
    sprintf('cdo merge %s %s %s %s',
            file.path("data_derived", gsub("compressed_20230825_6.nc", 
                                           "uncompressed_20231130_6_b_other_nonan.nc",
                                           fname_in)),  #unchanged
            paste(r_flags_extrap, collapse = " "),  # extrapolated flags
            paste(r_pm25_extrap, collapse = " "),  # extrapolated pm2.5
            file.path("data_derived", gsub("compressed_20230825_6.nc", 
                                           "uncompressed_20231130_7.nc",
                                           fname_in))  #output
    )
  )
  
  ## compress
  system(
    ##  cat(
    sprintf("nccopy -d7 %s %s",
            file.path("data_derived", gsub("compressed_20230825_6.nc", 
                                           "uncompressed_20231130_7.nc",
                                           fname_in)),
            file.path("data_derived", gsub("compressed_20230825_6.nc", 
                                           "compressed_20231130_7.nc",
                                           fname_in))
            )
    )
        
}
