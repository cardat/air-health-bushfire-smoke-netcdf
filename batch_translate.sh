#!/bin/sh

### This script is used to call netcdf_translate.sh on specific layers of the ASDAF Smoke Data.
### Once the netCDF files are created, they are merged into a single file spanning the entire 2001 to 2020 time period.

# Specifying the layers to convert
for layer_name in active_fires_50000
do
    for year in 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020
    do
        # Merging the layer for each year (Edit the file path to match current data revision date)
        sh netcdf_translate.sh $layer_name $year ""$layer_name"_"$year"0101_v20220211.nc" ""$layer_name"_"$year".nc"
    done
    # Merging the layer across the entire time period
cd $layer_name
ncrcat -4 -h *.nc ""$layer_name"_2001_2020.nc"
# Moving the file to a separate directory
mv ""$layer_name"_2001_2020.nc" ../merged_files/""$layer_name"_2001_2020.nc"
# Removing temporary netCDF files to save space
rm *.nc
cd ..
done

