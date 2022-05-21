#!/bin/bash

### This script is used to convert GeoTiff to NetCDF files
### This file needs to be copied and variables adapted per project

### These variables are specifically for the ASDAF Smoke Data.
sInFolder="./ASDAF/working_miles/"
sOutFolder="/mnt/c/tmp/Curtin/ASDAF/netCDF"
sProjection="-a_srs EPSG:3577"
sFilename="ASDAF"

#What years is this for
iYearStart=2019		#2001
iYearEnd=2019
#MS Fix	bSeperatedByYear=false

#How many layers are there? Note array is zero based
nLayers=22

#IH Fix
#What are their filenames?
aLayers=( 'active_fires_10000' 'active_fires_25000' 'active_fires_50000' 'active_fires_100000' 'active_fires_500000' 'dust_cams_p50' 'dust_cams_p75' 'dust_cams_p95' 'dust_merra_2_p50' 'dust_merra_2_p75' 'dust_merra_2_p95' 'pm25_pred_out_range' 'pm25_pred' 'predictor_out_range' 'remainder' 'season_plus_trend' 'seasonal' 'smoke_2sd' 'smoke_p95' 'trend' 'whs_12degreec' 'whs_15degreec' 'whs_18degreec' )

#What are we renaming the layers too?  NOTE no spaces here
aNames=( 'active_fires_10km' 'active_fires_25km' 'active_fires_50km' 'active_fires_100km' 'active_fires_500km' 'dust_cams_p50' 'dust_cams_p75' 'dust_cams_p95' 'dust_merra_2_p50' 'dust_merra_2_p75' 'dust_merra_2_p95' 'pm25_pred_out_range' 'pm25_pred' 'predictor_out_range' 'remainder' 'season_plus_trend' 'seasonal' 'smoke_2sd' 'smoke_p95' 'trend' 'whs_12degreec' 'whs_15degreec' 'whs_18degreec' )

#Units
aUnits=( 'm' 'm' 'm' 'm' 'm' 'm' 'm' 'm' 'm' 'm' 'm' 'm' 'm' 'm' 'm' 'm' 'm' 'm' 'm' 'm' 'm' 'm' 'm' )

#Long description of each
aDescription=( 'active_fires_10km' 'active_fires_25000' 'active_fires_50000' 'active_fires_100000' 'active_fires_500000' 'dust_cams_p50' 'dust_cams_p75' 'dust_cams_p95' 'dust_merra_2_p50' 'dust_merra_2_p75' 'dust_merra_2_p95' 'pm25_pred_out_range' 'pm25_pred' 'predictor_out_range' 'remainder' 'season_plus_trend' 'seasonal' 'smoke_2sd' 'smoke_p95' 'trend' 'whs_12degreec' 'whs_15degreec' 'whs_18degreec' )

#Global attributes to pass
nAtt=2
aAtt_Cat=( 'institution' 'title' 'references' )
aAtt_Desc=( 'Curtin University' 'ASDAF Smoke Data' 'Pang, C.')

# CODE BELOW, DO NOT ALTER, No Hard CODING ----------------------------------------------
#Make the output folder
mkdir -p ${sOutFolder}

#Loop for each year and layers 
for iYear in $(seq $iYearStart $iYearEnd); do
#MS fix need an if statement if bSeperatedByYear=true then sIn=$sInFolder/$iYear else sIn=$sInFolder
	sIn=$sInFolder
	for iLayer in $(seq 0 $nLayers); do
		sh netcdf_translate.sh $sIn $sOutFolder "$sProjection" $iYear $sFilename "${aLayers[$iLayer]}" "${aNames[$iLayer]}" "${aUnits[$iLayer]}" "${aDescription[$iLayer]}" & 		
	done
	wait #run layers in parallel and wait for all layers to finish
	
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
#MS why are some o,c and others just c,c ?
ncatted -h -a Conventions,global,o,c,"CF-1.6" ${sOutFolder}/Un_${sFilename}_${iYear}.nc
for iAttrib in $(seq 0 $nArr); do
ncatted -h -a ${aAtt_Cat[$iAttrib]},global,c,c,"${aAtt_Desc[$iAttrib]}" ${sOutFolder}/Un_${sFilename}_${iYear}.nc
done

nccopy -d9 ${sOutFolder}/Un_${sFilename}_${iYear}.nc ${sOutFolder}/${sFilename}_${iYear}.nc &           # Compressing the file in the background

done
wait	#for all compress actions to finish

rm -rf ${sOutFolder}/Un_${sFilename}_*.nc                                                     # cleanup uncompressed files




