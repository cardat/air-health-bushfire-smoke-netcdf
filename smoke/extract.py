import sys
import argparse
import functools

import rasterio as rio
import rasterio.warp as warp


# constants
WGS84_EPSG_CODE = 4326
GDA94_EPSG_CODE = 3577

WGS84_CRS = rio.crs.CRS.from_epsg(WGS84_EPSG_CODE)
GDA94_CRS = rio.crs.CRS.from_epsg(GDA94_EPSG_CODE)


# helper functions
wgs84_to_gda94_coord = functools.partial(warp.transform, WGS84_CRS, GDA94_CRS)


def main(ncpath, latitude, longitude):
    """TODO: docs"""
    dataset = rio.open(ncpath)
    subdatasets = dataset.subdatasets

    selected = None

    if subdatasets:
        # process individual datasets
        # push processing out to func to work specifically with one datasets?

        sd_path = subdatasets[0]  # TODO: loop through sub datasets
        sub_dataset = rio.open(sd_path)
        selected = sub_dataset
        _verify_crs(sub_dataset)
        xy_coords_albers, xy_indices = get_xy_indexes(sub_dataset, latitude, longitude)
        sub_dataset.close()
    else:
        # TODO: Implement handling with no subdatasets
        _verify_crs(dataset)
        selected = dataset
        xy_coords_albers, xy_indices = get_xy_indexes(dataset, latitude, longitude)

    # output
    print(f"Using {selected.name}")
    print(f"lat/long: {latitude, longitude}")
    #print(f"\nx & y albers: {x_albers, y_albers}")
    print(f"xy_coords_albers: {xy_coords_albers}")
    print(f"xy_indices: {xy_indices}")

    dataset.close()


def _verify_crs(dataset):
    if dataset.crs is None:
        msg = f"{dataset.name} has no CRS, cannot do coordinate transforms"
        raise ExtractError(msg)
    elif dataset.crs != GDA94_CRS:
        msg = f"{dataset.name} not in GDA94 CRS (using {dataset.crs})"
        raise ExtractError(msg)


def get_xy_indexes(dataset, latitude, longitude):
    """Returns (X,Y) Albers & cell indexes given lat/long to select a grid square."""
    # TODO: handle logic for multi coords???

    x_albers, y_albers = wgs84_to_gda94_coord([longitude], [latitude])
    xy_coords_albers = tuple(zip(x_albers, y_albers))
    xy_indices = dataset.index(*xy_coords_albers[0])  # takes individual X,Y coords
    return xy_coords_albers, xy_indices


class ExtractError(Exception):
    pass


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("ncpath", type=str, help="Path to NetCDF file")
    parser.add_argument("latitude", type=float, help="Latitude (float) of point of interest")
    parser.add_argument("longitude", type=float, help="Longitude (float) of point of interest")
    args = parser.parse_args()

    main(args.ncpath, args.latitude, args.longitude)
