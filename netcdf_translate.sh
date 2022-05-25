#!/bin/sh

### This script is used to bulk convert GeoTIFFs into netCDF format.
### It takes in these positional arguments:

#$sInFolder	$sOutFolder	$sProjection	$iYear	$EndFilename	OldLayername 	NewLayername	Units	LongDescription
#  $1		$2			$3				$4		$5				$6				$7				$8		$9

#Let the user know what is happening
echo "================================================================="
echo "Converting Geotiff to NetCDF"
echo "Tiffs: "$1" NetCDF: "$2" Projection: "$3" Year: "$4
echo "Base_Filename: "$5" Layer_Name: "$6" Renaming to: "$7" Units: "$8
echo $9
echo "_________________________________________________________________"

#Save the input arguments into variables 
sInFolder=$1	#folder with tiffs
sOutFolder=$2	#folder to save netCDFs
sProjection=$3	#projection
start_year=$4	# Start Year: e.g. "2001"
layer_name=$6	# Band/Layer Name: e.g. active_fires_10000
final_file=$5_$4_$7.nc 		#base_year_layer	Final File: e.g. active_fires_10000_2001_time.nc
sUnits=$8		#The units
sLongDesc=$9	#The long description 

#MS Fix We don't have an existing NetCDF file only TIFFs!!! Why is this required?
#initial_file=$3	# Initial File: e.g. active_fires_10000_20010101_v20220211.nc	

# Specifying the Directory
cd $sInFolder

# Bulk converting GeoTIFFs into netCDF.
echo "converting "${layer_name}_${start_year}
for f in ${layer_name}_${start_year}*.tif; do gdal_translate -of netCDF -co WRITE_LONLAT=YES $sProjection $f ${sOutFolder}/tmp_${f%.*}.nc; done

# Renaming albers-conical-equal-area to crs
for f in ${sOutFolder}/tmp_${layer_name}_${start_year}*.nc; do ncrename -h -v albers_conical_equal_area,crs $f; done

# Merging netCDF files into one single file (netcdf4 format)
ncecat -4 -O -h -x -v crs -u time ${sOutFolder}/tmp_${layer_name}_${start_year}*.nc ${sOutFolder}/tmp_$final_file
rm -rf ${sOutFolder}/tmp_${layer_name}_${start_year}*.nc		#cleanup the temp_layer_year files

# Copying the crs variable from a previous netCDF daily file
#MS ncks -h -A -v crs $initial_file $final_file

# Adding the time variable to the netCDF file
# Time step of 0.5 days
#MS this is an error date should be picked up from the filename
ncap2 -O -h -s 'time=array(0.5, 1, $time);' ${sOutFolder}/tmp_$final_file ${sOutFolder}/tmp_$final_file

# Renaming the Band1 variable to something more meaningful
ncrename -h -v Band1,$7 ${sOutFolder}/tmp_$final_file

# Updating attributes to CF compliance
## Update attributes for the time variable
ncatted -h -a units,time,c,c,"days since $start_year-01-01 00:00:00" ${sOutFolder}/tmp_$final_file
ncatted -h -a calendar,time,c,c,"standard" ${sOutFolder}/tmp_$final_file
ncatted -h -a description,time,c,c,"middle of each day" ${sOutFolder}/tmp_$final_file
ncatted -h -a long_name,time,c,c,"time" ${sOutFolder}/tmp_$final_file
ncatted -h -a standard_name,time,c,c,"time" ${sOutFolder}/tmp_$final_file

## Update attributes for the layer 
ncatted -h -a grid_mapping,$7,o,c,"crs" ${sOutFolder}/tmp_$final_file
ncatted -h -a long_name,$7,o,c,$sLongDesc ${sOutFolder}/tmp_$final_file
ncatted -h -a units,$7,c,c,$sUnits ${sOutFolder}/tmp_$final_file


# Clearing Individual netCDF Files
#rm *.nc  #MS No not  aglobal delete

cd - 		# go back to initial folder 

