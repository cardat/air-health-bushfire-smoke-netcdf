#!/bin/bash

### This script is used to convert GeoTiff to NetCDF files
### This file needs to be copied and variables adapted per project

### These variables are specifically for the ASDAF Smoke Data.
sInFolder="/home/289800b/projects/AWAP_GRIDS/data_derived"
sOutFolder="/home/289800b/projects/AWAP_GRIDS/netCDF"
sProjection="-a_srs EPSG:4326"        # Guessing that it is in WGS 84
sFilename="AWAP"

#What years is this for
iYearStart=1900 
iYearEnd=2022
#MS Fix    bSeperatedByYear=false

#How many layers are there? Note array is zero based
nLayers=4

#IH Fix
#What are their filenames?
aLayers=( 'GTif_minave' 'GTif_maxave'  'GTif_totals' 'GTif_vprph09' 'GTif_vprph09' )

#What are we renaming the layers too?  NOTE no spaces here
aNames=( 'Temp_min' 'Temp_max'  'Rain' 'VapPress09' 'VapPress15' )

#Units
aUnits=( '°C' '°C' 'mm/day' 'hPa' 'hPa' )

#Long description of each
aDescription=( 'Daily Minimum Temperature' 'Daily Maximum Temperature' 'Daily Rainfall' 'Vapour Pressure at 9AM' 'Vapour Pressure at 3PM')

#Global attributes to pass
nAtt=2
aAtt_Cat=( 'institution' 'title' 'references' )
aAtt_Desc=( 'Curtin University' 'AWAP Gridded Data' 'BOM')

# CODE BELOW, DO NOT ALTER, No Hard CODING ----------------------------------------------
#Make the output folder
mkdir -p ${sOutFolder}

#Loop for each year and layers 
for iYear in $(seq $iYearStart $iYearEnd); do
#MS fix need an if statement if bSeperatedByYear=true then sIn=$sInFolder/$iYear else sIn=$sInFolder
sIn=${sInFolder}/${iYear}
for iLayer in $(seq 0 $nLayers); do
sh netcdf_translate.sh $sIn $sOutFolder "$sProjection" $iYear $sFilename "${aLayers[$iLayer]}" "${aNames[$iLayer]}" "${aUnits[$iLayer]}" "${aDescription[$iLayer]}" &          
done
wait #run layers in parallel and wait for all layers to finish Note don't do this when testing, screen is confusing

#This is copied and modified from merge

# Merging different bands/layers into a single file
rm -rf ${sOutFolder}/Un_${sFilename}_${iYear}.nc                                                    # cleanup previous file
cdo merge ${sOutFolder}/tmp_${sFilename}_${iYear}_*.nc ${sOutFolder}/Un_${sFilename}_${iYear}.nc     # merge the tmp files
rm -rf ${sOutFolder}/tmp_${sFilename}_${iYear}_*.nc                                                    # cleanup year_layers

echo "Set CF compliance tags"
# Removing Unncessary Attributes from Latitute and Longitude Variables
ncatted -h -a _CoordinateAxisType,lon,d,, ${sOutFolder}/Un_${sFilename}_${iYear}.nc
ncatted -h -a _CoordinateAxisType,lat,d,, ${sOutFolder}/Un_${sFilename}_${iYear}.nc

# Update attributes in the Global Section
ncatted -h -a Conventions,global,o,c,"CF-1.6" ${sOutFolder}/Un_${sFilename}_${iYear}.nc
for iAttrib in $(seq 0 $nArr); do
ncatted -h -a ${aAtt_Cat[$iAttrib]},global,c,c,"${aAtt_Desc[$iAttrib]}" ${sOutFolder}/Un_${sFilename}_${iYear}.nc
done

echo "compacting file: "${sFilename}_${iYear}.nc
nccopy -d9 ${sOutFolder}/Un_${sFilename}_${iYear}.nc ${sOutFolder}/${sFilename}_${iYear}.nc &           # Compressing the file in the background

done
wait	#for all compress actions to finish

rm -rf ${sOutFolder}/Un_${sFilename}_*.nc                                                     # cleanup uncompressed files


