""" This script sorts the Smoke Data by layer and year."""

import os

layers = ["active_fires_10000", "active_fires_25000", "active_fires_50000", "active_fires_100000", "active_fires_500000", 
        "dust_cams_p50", "dust_cams_p75", "dust_cams_p95",
        "dust_merra_2_p50", "dust_merra_2_p75", "dust_merra_2_p95",
        "pm25_pred_out_range", "pm25_pred",
        "predictor_out_range", "remainder",
        "season_plus_trend", "seasonal",
        "smoke_2sd", "smoke_p95",
        "trend",
        "whs_12degreec", "whs_15degreec", "whs_18degreec"]

years = [str(i) for i in range(2001, 2021)]

# Creating Subfolders
target_directory = "data"

if not os.path.exists(target_directory):
    os.mkdir(target_directory)

for layer in layers:
    subfolder = os.path.join(target_directory, layer)
    if not os.path.exists(subfolder):
        os.mkdir(subfolder)

    for year in years:
        subfolder = os.path.join(target_directory, layer, year)
        if not os.path.exists(subfolder):
            os.mkdir(subfolder)

# Moving Files
source_directory = "data_derived"

for file in os.listdir(source_directory):
    for layer in layers:
        for year in years:
            start_string = layer + "_" + year
            if file.startswith(start_string):
                source = os.path.join(source_directory, file)
                destination = os.path.join(target_directory, layer, year, file)
                os.rename(source, destination)

