# smoke_data_Ivan

## Installation
Miniforge makes it easier to manage the installation of Python, launch applications and manage packages and environments. To install Miniforge, please follow the most up to date instructions found in https://github.com/conda-forge/miniforge.

## Setting up and updating a conda environment
A conda environment allows you to have multiple sets of packages installed at the same time, making reproducibility and upgrades easier. You can create, export, list, remove and update environments that have different versions of Python and/or packages installed in them.

You can create a conda environment for this project using the following instructions.

Open your terminal and navigate to this repository directory in the terminal. For example, if you have downloaded this repository on your desktop, you could type the following.

On Mac/Linux:
```
% cd Desktop/smoke_data_Ivan
```

On Windows:
```
% cd Desktop\smoke_data_Ivan\
```

To install and activate the required environment, type:
```
% conda create -n smoke_data python=3.8
% conda activate smoke_data
% conda install gdal
% conda install nco
```

To deactivate the environment, type:
```
% conda deactivate smoke_data
```

## Usage
The following files are designed to sort, pre-process and merge the data. In order for this to function, the scripts are required to be run seqentially.
1. file_sort.py - Sorts the ASDAF Smoke Data by layer and year
2. batch_translate.sh - Calls netcdf_translate.sh on specific layers of the ASDAF Smoke Data and merges them into a single file spanning the entire 2001 to 2020 time period.
3. merge_clean.sh - Merges the bands/layers of the ASDAF Smoke data into a single netCDF.
