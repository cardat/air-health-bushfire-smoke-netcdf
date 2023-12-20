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

DEFAULT_XWIN_SIZE = 2
DEFAULT_YWIN_SIZE = 2


# helper functions
wgs84_to_gda94_coord = functools.partial(warp.transform, WGS84_CRS, GDA94_CRS)


def main(ncpath, latitude, longitude):
    """TODO: docs"""
    dataset = rio.open(ncpath)
    subdatasets = dataset.subdatasets
    selected = None

    print(f"Processing {dataset.name}")

    if verbose:
        print(f"Full NetCDF dataset geotransform\n{dataset.transform}\n")

    if subdatasets:
        # process individual subdatasets within NetCDF
        # each subdataset is one data variable of 365 calendar days
        if subdatasets and verbose:
            print("Dataset contains variables:")
            for i, sd_path in enumerate(subdatasets):
                print(f"{i:>3}: {sd_path}")
            print()

        # examine smoke_p95_v1_3 in this example
        p95 = 14

        if verbose:
            print(f"Processing subdataset {subdatasets[p95]}")

        # FIXME: in real version, loop through sub datasets here
        sd_path = subdatasets[p95]
        sub_dataset = rio.open(sd_path)
        selected = sub_dataset
        _verify_crs(sub_dataset)
        xy_coords_albers, col_row_indices = get_xy_indexes(sub_dataset, latitude, longitude)

        # Use single rasterio window to extract same pixels across all days
        # TODO: merge all subdataset crops into new NC file
        window = rio.windows.Window(*col_row_indices,
                                    DEFAULT_XWIN_SIZE,
                                    DEFAULT_YWIN_SIZE)

        # NB: window cuts across all bands/all included days...
        data = sub_dataset.read(window=window)

        if verbose:
            print("Subdataset/variable window shape", data.shape)
            print(f"Window Transform\n{sub_dataset.window_transform(window)}\n")

        # example code block operating over daily data subset
        ndays, xsize, ysize = data.shape

        for d in range(31):  # TODO: artificially limit data output for example
            daily_data = data[d]
            print(f"Day {d:>3} data\n{daily_data}\n")

        sub_dataset.close()

    else:
        # TODO: Implement handling with no subdatasets
        _verify_crs(dataset)
        selected = dataset
        xy_coords_albers, col_row_indices = get_xy_indexes(dataset, latitude, longitude)

    # output
    print(f"\nUsing {selected.name}")
    print(f"lat/long: {latitude, longitude}")
    print(f"xy_coords_albers: {xy_coords_albers}")
    print(f"col_row_indices: {col_row_indices}")

    dataset.close()


def _verify_crs(dataset):
    if dataset.crs is None:
        msg = f"{dataset.name} has no CRS, cannot do coordinate transforms"
        raise ExtractError(msg)
    elif dataset.crs != GDA94_CRS:
        msg = f"{dataset.name} not in GDA94 CRS (using {dataset.crs})"
        raise ExtractError(msg)


def get_xy_indexes(dataset, latitude, longitude):
    """Returns (X,Y) Albers & (col,row) cell indexes given lat/long to select a grid square."""
    # TODO: handle logic for multiple coords???

    x_albers, y_albers = wgs84_to_gda94_coord([longitude], [latitude])
    xy_coords_albers = tuple(zip(x_albers, y_albers))
    row, col = dataset.index(*xy_coords_albers[0])  # takes individual X,Y coords
    return xy_coords_albers, (col, row)  # reverse order for GDAL tools


class ExtractError(Exception):
    pass


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("ncpath", type=str, help="Path to NetCDF file")
    parser.add_argument("latitude", type=float, help="Latitude (float) of point of interest")
    parser.add_argument("longitude", type=float, help="Longitude (float) of point of interest")
    parser.add_argument("-v", "--verbose", help="Print debug output", action="store_true")
    args = parser.parse_args()

    global verbose
    verbose = args.verbose

    main(args.ncpath, args.latitude, args.longitude)
