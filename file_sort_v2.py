""" This script sorts the Bushfire Smoke Data by layer and year."""

import os
import sys

layers = ["pm25_pred"]

years = [str(i) for i in range(2001, 2021)]

# Creating Subfolders
target_directory = sys.argv[2]

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
source_directory = sys.argv[1]

for file in os.listdir(source_directory):
    for layer in layers:
        for year in years:
            start_string = layer + "_" + year
            if file.startswith(start_string):
                source = os.path.join(source_directory, file)
                destination = os.path.join(target_directory, layer, year, file)
                os.rename(source, destination)

