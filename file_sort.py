""" 
file_sort.py
    This script sorts the Bushfire Smoke Data by layer and year as it is initially populated in a flat unstructured format.

    Usage:
        file_sort.py <source_directory> <destination_directory> <layer> <start_year> <end_year>
"""

import os
import sys

if len(sys.argv) != 6:
    print("""
        INCORRECT ARGUMENTS!
        Usage:
        file_sort.py <source_directory> <destination_directory> <layer> <start_year> <end_year>
        """)
else:
    source_directory = sys.argv[1]
    destination_directory = sys.argv[2]
    layers = [sys.argv[3]]
    start_year = sys.argv[4]
    end_year = sys.argv[5]

    # layers = ["active_fires_10000", "active_fires_25000", "active_fires_50000", "active_fires_100000", "active_fires_500000", 
    #         "dust_cams_p50", "dust_cams_p75", "dust_cams_p95",
    #         "dust_merra_2_p50", "dust_merra_2_p75", "dust_merra_2_p95",
    #         "pm25_pred_out_range", "pm25_pred",
    #         "predictor_out_range", "remainder",
    #         "season_plus_trend", "seasonal",
    #         "smoke_2sd", "smoke_p95",
    #         "trend",
    #         "whs_12degreec", "whs_15degreec", "whs_18degreec"]      # Specifying each of the layers/bands in a list

    years = [str(i) for i in range(int(start_year), int(end_year))]     # Specifying start and end year

    # Checking if the Source Directory exists
    if not os.path.exists(source_directory):
        print("Source directory does not exist!")
        sys.exit()
    
    # Checking that the Source Directory is not empty
    if not os.listdir(source_directory):
        print("Source directory is empty!")
        sys.exit()
    
    # Creating Destination Directory and Subfolders
    if not os.path.exists(destination_directory):
        os.mkdir(destination_directory)

    for layer in layers:
        subfolder = os.path.join(destination_directory, layer)
        if not os.path.exists(subfolder):
            os.mkdir(subfolder)

        for year in years:
            subfolder = os.path.join(destination_directory, layer, year)
            if not os.path.exists(subfolder):
                os.mkdir(subfolder)

    # Moving Files from Source Directory to Destination Directory
    for file in os.listdir(source_directory):
        for layer in layers:
            for year in years:
                start_string = layer + "_" + year       # Naming Scheme MUST follow layer_year...
                if file.startswith(start_string):
                    source = os.path.join(source_directory, file)
                    destination = os.path.join(destination_directory, layer, year, file)
                    os.rename(source, destination)
