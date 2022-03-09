#!/bin/sh

### This script is used to call netcdf_translate.sh on specific layers of the ASDAF Smoke Data.
### Once the netCDF files are created, they are merged into a single file spanning the entire 2001 to 2020 time period.

# Set the directory where the sorted geoTIFFs are located
directory=$1
cd $directory

# Creating a merged_files directory to store the merged files
mkdir -p merged_files

# Specify the layers to convert in the for loop below.
layer_names=$2 # e.g. "active_fires_10000"

for layer_name in $layer_names
do
    for year in 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020
    do
        # Merging the layer for each year (Edit the file path to match current data revision date yyyymmdd)
        # Current data revision date: 20220211
        sh netcdf_translate.sh $layer_name $year ""$layer_name"_"$year"0101_v20220211.nc" ""$layer_name"_"$year".nc"
    done

# Merging the layer across the 2001 to 2020 time period
cd $layer_name
ncrcat -4 -h *.nc ""$layer_name"_2001_2020.nc"

# Moving the merged file to a separate directory
mv ""$layer_name"_2001_2020.nc" ../merged_files/""$layer_name"_2001_2020.nc"

# Removing temporary netCDF files to save space
rm *.nc
cd ..
done

