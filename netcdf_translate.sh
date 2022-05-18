#!/bin/sh

### This script is used to bulk convert GeoTIFFs into netCDF format, then merge them into a single CF compliant netCDF file.
### It takes in four positional arguments:
### 1. The name of the layer to be converted.
### 2. The year to be converted.
### 3. The name of a specific netCDF file to copy the metadata from.
### 4. The name of the output netCDF file.

# Band/Layer Name: e.g. active_fires_10000
layer_name=$1
# Start Year: e.g. "2001"
start_year=$2
# Initial File: e.g. active_fires_10000_20010101_v20220211.nc
initial_file=$3
# Final File: e.g. active_fires_10000_2001_time.nc
final_file=$4

# Specifying the Directory
cd $layer_name/$start_year

# Bulk converting GeoTIFFs into netCDF.
for f in *.tif; do gdal_translate -of netCDF -co WRITE_LONLAT=YES -a_srs EPSG:3577 $f ${f%.*}.nc; done

# Renaming albers-conical-equal-area to crs
for f in *.nc; do ncrename -h -v albers_conical_equal_area,crs $f; done

# Merging netCDF files into one single file (netcdf4 format)
ncecat -4 -O -h -x -v crs -u time *.nc $final_file

# Copying the crs variable from a previous netCDF daily file
ncks -h -A -v crs $initial_file $final_file

# Adding the time variable to the netCDF file
# Time step of 0.5 days
ncap2 -O -h -s 'time=array(0.5, 1, $time);' $final_file $final_file

# Renaming the Band1 variable to something more meaningful
ncrename -h -v Band1,$layer_name $final_file

# Updating attributes to CF compliance
## Update attributes for the time variable

ncatted -h -a units,time,c,c,"days since $start_year-01-01 00:00:00" $final_file
ncatted -h -a calendar,time,c,c,"standard" $final_file
ncatted -h -a description,time,c,c,"middle of each day" $final_file
ncatted -h -a long_name,time,c,c,"time" $final_file
ncatted -h -a standard_name,time,c,c,"time" $final_file

## Update attributes for the active_fires_10000 variable
ncatted -h -a grid_mapping,$layer_name,o,c,"crs" $final_file
ncatted -h -a long_name,$layer_name,o,c,"$layer_name m resolution" $final_file
ncatted -h -a units,$layer_name,c,c,"m" $final_file

## Update attributes in the Global Section
ncatted -h -a Conventions,global,o,c,"CF-1.6" $final_file
ncatted -h -a institution,global,c,c,"Curtin University" $final_file
ncatted -h -a title,global,c,c,"ASDAF Smoke Data" $final_file
ncatted -h -a references,global,c,c,"Pang, C." $final_file

# Moving the Final File
mv $final_file ../$final_file

# Clearing Individual netCDF Files
rm *.nc
