#!/bin/sh

### This script is used to bulk convert GeoTIFFs into netCDF format.
### It takes in these positional arguments:

#$sInFolder	$sOutFolder	$sProjection	$iYear	$EndFilename	OldLayername 	NewLayername	Units	LongDescription
#  $1		$2			$3	$4	$5		$6		$7		$8	$9

#Let the user know what is happening
echo "================================================================="
echo "Converting Geotiff to NetCDF"
echo "Tiffs: "$1" NetCDF: "$2" Projection: "$3" Year: "$4
echo "Base_Filename: "$5" Layer_Name: "$6" Renaming to: "$7" Units: "$8
echo $9

#Save the input arguments into variables 
sInFolder=$1		#folder with tiffs
sOutFolder=$2		#folder to save netCDFs
sProjection=$3		#projection
start_year=$4		# Start Year: e.g. "2001"
layer_name=$6		# Band/Layer Name: e.g. active_fires_10000
final_file=$5_$4_$7.nc #base_year_layer	Final File: e.g. active_fires_10000_2001_time.nc
sUnits=$8		#The units
sLongDesc=$9		#The long description 

# Specifying the Directory
cd $sInFolder

# Bulk converting GeoTIFFs into netCDF.
for f in ${layer_name}_${start_year}*.tif; do gdal_translate -q -of netCDF -co WRITE_LONLAT=YES $sProjection $f ${sOutFolder}/tmp_${f%.*}.nc; done

# Adding the time dimension to netCDF from filename	MS tested on AWAP grids using 07*.tif in line above
for f in ${sOutFolder}/tmp_${layer_name}_${start_year}*.nc; do
    date=`echo $f | cut -d'_' -f5`
    year=`echo $date | cut -c1-4`
    month=`echo $date | cut -c5-6`
    day=`echo $date | cut -c7-8`
    fulldate=$year-$month-$day
    cdo -s -setreftime,1900-01-01,00:00:00,1day -setdate,$fulldate -settime,12:00:00 -setcalendar,standard $f ${f%.*}_timestamped.nc; done    

# Merging netCDF files into one single file (netcdf4 format)
cdo -O mergetime ${sOutFolder}/tmp_${layer_name}_${start_year}*_timestamped.nc ${sOutFolder}/tmp_$final_file
rm -rf ${sOutFolder}/tmp_${layer_name}_${start_year}*.nc		#cleanup the temp_layer_year files

# Renaming the Band1 variable to something more meaningful
ncrename -h -v Band1,$7 ${sOutFolder}/tmp_$final_file

# Updating attributes to CF compliance
## Update attributes for the time variable
ncatted -h -a description,time,c,c,"middle of each day" ${sOutFolder}/tmp_$final_file
ncatted -h -a long_name,time,c,c,"time" ${sOutFolder}/tmp_$final_file

## Update attributes for the layer 
ncatted -h -a grid_mapping,$7,o,c,"crs" ${sOutFolder}/tmp_$final_file
ncatted -h -a long_name,$7,o,c,"$sLongDesc" ${sOutFolder}/tmp_$final_file
ncatted -h -a units,$7,c,c,"$sUnits" ${sOutFolder}/tmp_$final_file
#MS set fill an dmissing values?

cd - 		# go back to initial folder 

