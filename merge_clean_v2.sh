#!/bin/sh

### This script is used to merge the bands/layers of the ASDAF Smoke Data into a single netCDF.
### It will then compress the merged file using d9 compression, then update the file metadata to
### ensure CF compliance.

### Current version only handles active_fires_10000, active_fires_25000, active_fires_50000, active_fires_100000, active_fires_500000.
### Update code for additional bands.

# Set directory where the merged_files are located
directory=$1
cd $directory

filename_1="bushfiresmoke_v1_3_2015.nc"
filename_2="bushfiresmoke_v1_3_2015_compressed.nc"

# Merging different bands/layers into a single file
cdo merge 2015_* $filename_1

# Compressing the file
nccopy -d9 $filename_1 $filename_2

# Removing Unncessary Attributes from Latitute and Longitude Variables
#ncatted -h -a _CoordinateAxisType,lon,d,, $filename_2
#ncatted -h -a _CoordinateAxisType,lat,d,, $filename_2

# Updating the long_name for each Band
#ncatted -h -a long_name,active_fires_10000,o,c,"active_fires: 10000 m resolution" $filename_2
#ncatted -h -a long_name,active_fires_25000,o,c,"active_fires: 25000 m resolution" $filename_2
#ncatted -h -a long_name,active_fires_50000,o,c,"active_fires: 50000 m resolution" $filename_2
#ncatted -h -a long_name,active_fires_100000,o,c,"active_fires: 100000 m resolution" $filename_2
#ncatted -h -a long_name,active_fires_500000,o,c,"active_fires: 500000 m resolution" $filename_2

# Updating the attributes in the Global Section
ncatted -h -a source,global,c,c,"The data was generated using a random forest model with satellite data, land use and other GIS layers as predictors of particulate matter (PM2.5) air pollution. A method of identifying specific pollution attributable to bushfires was applied that uses the seasonal trend decomposition algorithm (STL)." $filename_2
ncatted -h -a references,global,o,c,"CAR Firesmoke Project Team. Bushfire specific PM2.5 output from v1.3 based on satellite and other land use and other predictors for Australia 2001-2020 produced for the ARDC and CAR Bushfire Smoke Exposures project. Funding supported by CAR and the ARDC’s Bushfire Data Challenges Project. Assessing the impact of bushfire smoke on health. A collaboration between the National Air Quality Technical Advisory Group (NATAG) and CAR. DOI: https://doi.org/10.47486/DC008. Downloaded from the Centre for Air pollution, energy and health Research." $filename_2
ncatted -h -a comment,global,c,c,"This dataset is provided for use in a pilot project looking at building an API to optimise sharing of spatiotemporal gridded data output from satellite and other data modelling.

Please note that this is still a preliminary dataset only as whilst there are several layers here (number predictors out of range, prediction out of range etc) but the pm25_pred is the predicted smoke particles (PM2.5) and future versions will have decomposed that into PM2.5_Bushfire and PM2.5_Background, and a flag for if the pixel was dust or not. Therefore, this dataset is just a demo to see how we store the processed data and the data structures, as well as approximate data size estimates.

CONDITIONS OF USE:
Please note these data are restricted and may not be on-shared or used for purposes outside the specified project without permission from the data owner." $filename_2