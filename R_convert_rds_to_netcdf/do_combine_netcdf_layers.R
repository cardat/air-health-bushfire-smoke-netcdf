library(terra)

#### set up ####
rootdir <- "~/cloudstor/Shared/Bushfire_specific_PM25_Aus_2001_2020_v1_3/data_derived"
flist <- dir(rootdir, full.names = T)

#### extract the layer ####
for(fi in flist[4:length(flist)]){
# fi <- flist[1]
print(fi)

# system(sprintf("gdalinfo %s", fi))
# system2("gdalinfo", fi)

var_i <- "remainder"
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
          file.path(rootdir, "bushfiresmoke_v1_3_2001_2020_remainder_out.nc"), 
          file.path(rootdir, "bushfiresmoke_v1_3_2001_2020_remainder_min.nc")
  )
)
system(
  sprintf("cdo timmax %s %s", 
          file.path(rootdir, "bushfiresmoke_v1_3_2001_2020_remainder_out.nc"), 
          file.path(rootdir, "bushfiresmoke_v1_3_2001_2020_remainder_max.nc")
  )
)
system(
  sprintf("cdo timpctl,99 %s %s %s %s", 
          file.path(rootdir, "bushfiresmoke_v1_3_2001_2020_remainder_out.nc"), 
          file.path(rootdir, "bushfiresmoke_v1_3_2001_2020_remainder_min.nc"), 
          file.path(rootdir, "bushfiresmoke_v1_3_2001_2020_remainder_max.nc"),
          file.path(rootdir, "bushfiresmoke_v1_3_2001_2020_remainder_p99.nc")
  )
)

infile <- file.path(rootdir, "bushfiresmoke_v1_3_2001_2020_remainder_p99.nc")
system2("gdalinfo", infile)
r99 <- terra::rast(infile)
r99
plot(r99)

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
# writeCDF(r1, filename = outfile)
stars_r1 <- stars::st_as_stars(r1, ignore_file = T)
dim(stars_r1)
names(stars_r1) <- var_i
stars::write_mdim(stars_r1, file.path(rootdir, paste0("bushfiresmoke_v1_3_2001_2020_",var_i,"_trimmed_2.nc")))


plot(r1[[1:4]])
xy <- cbind(1545315, -3954140)
e <- extract(r1, xy)
len <- length(e)
len
20*365.25
plot(1:len,e)
outfile <- file.path(rootdir, paste0("bushfiresmoke_v1_3_2001_2020_", var_i, "_trimmed_p99.rds"))
saveRDS(r0, outfile)