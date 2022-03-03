#!/bin/sh

### This script is used to merge the bands/layers of the ASDAF Smoke Data into a single netCDF.
### It will then compress the merged file using d9 compression, then update the file metadata to
### ensure CF compliance.

filename_1="active_fires_2001_2020.nc"
filename_2="active_fires_2001_2020_compressed.nc"

# Merging different bands/layers into a single file
cdo merge *2001_2020.nc $filename_1

# Compressing the file
nccopy -d9 $filename_1 $filename_2

# Removing Unncessary Attributes from Latitute and Longitude Variables
ncatted -h -a _CoordinateAxisType,lon,d,, $filename_2
ncatted -h -a _CoordinateAxisType,lat,d,, $filename_2

# Updating the long_name for each Band
ncatted -h -a long_name,active_fires_10000,o,c,"active_fires: 10000 m resolution" $filename_2
ncatted -h -a long_name,active_fires_25000,o,c,"active_fires: 25000 m resolution" $filename_2
ncatted -h -a long_name,active_fires_50000,o,c,"active_fires: 50000 m resolution" $filename_2
ncatted -h -a long_name,active_fires_100000,o,c,"active_fires: 100000 m resolution" $filename_2
ncatted -h -a long_name,active_fires_500000,o,c,"active_fires: 500000 m resolution" $filename_2

# Updating the attributes in the Global Section
#ncatted -h -a title,global,c,c,"ASDAF Smoke Data" $filename_2
ncatted -h -a institution,global,o,c,"Curtin University" $filename_2
ncatted -h -a source,global,c,c,"Description of how the data was generated" $filename_2
#ncatted -h -a project,global,d,, $filename_2
ncatted -h -a references,global,o,c,"Insert reference here" $filename_2
ncatted -h -a comment,global,c,c,"Miscellaneous comments" active_fires_2001_2020_compressed.nc