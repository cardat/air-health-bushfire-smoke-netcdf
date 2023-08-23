#' Title
#'
#' @param indir_rf 
#' @param infile_coords 
#' @param yy 
#'
#' @return
#' @export
#'
#' @examples
# sapply(dir("R", full.names = T, pattern = ".R$"), source)
# load_packages(T)
# config <- yaml::read_yaml("config.yaml")
# tar_load(dat_mrg_shp_pop)

do_convert_rds_to_ncdf <- function(
    indir_rf = file.path(config$rootdir, config$raster_stl)
    ,
    infile_coords = file.path(config$rootdir, config$raster_coords)
    ,
    yy_todo = 2016
) {
  
  for(yy in yy_todo){
    # yy = yy_todo[1]
  ## Convert vector file of coordinates to a df with x and y columns using vect() ##
  dat_coords <- as.data.frame(vect(infile_coords), geom = "XY")
  setDT(dat_coords)
  ## Search for .rds files in the indir_rf and store full paths in fs ##
  fs <- dir(file.path(indir_rf), full.names = T, recursive = T, pattern = "rds$")
  
  ## all available rds files ##
  fs
  
  ## subset the selected year, read selected rds and save in a list ##
  fs_todo <- fs[grep(paste0("_", yy), basename(fs))]
  ls_dat <- lapply(fs_todo, readRDS)
  ## make daily raasters ####
  dat <- rbindlist(ls_dat)
  dates <- sort(unique(dat$date))
  dates
  # convert to raster and store in a big list
  # you will have to do the three components = remainder (this is probably bushfire smoke), trend and seasonal
  # also a good way to save storage is rounding the decimals. one way to do this 
  # TODO REMOVE THIS, ONLY FOR THE OLD EXTRACTION? big_list <- list()
  
  
  ## loop to iterate over the 3 layers ##
  ## for each layer creates a r_dly list of each date ##
  
  for(lyr_type in c("seasonal", "trend", "remainder")) {
    # lyr_type = "remainder"
    print(lyr_type)
    r_dly <- lapply(dates, 
                    function(dd, lyr = lyr_type) {
                      txt <- paste0("rast(
                                          merge(
                                                dat_coords, 
                                                dat[date == dd], 
                                                all.x = T)[, 
                                                    .(x, y, round(",
                                                    lyr,
                                                    ", 1))], 
                                    crs = 'epsg:3577')")
                      eval(parse(text=txt))
                    }
    )
    s_dly <- do.call(c, r_dly)
    time(s_dly) <- dates
   
    #write as netcdf with stars (needs stars > 0.6)
    # more successful than terra at writing out a recognisable CRS
    stars_dly <- stars::st_as_stars(s_dly)
    names(stars_dly) <- lyr_type
    if(!dir.exists("data_derived")) dir.create("data_derived")
    stars::write_mdim(stars_dly, filename = file.path("data_derived", paste0(yy,"_",lyr_type,".nc")))
    ## qc
    # foo <- rast("data_derived/2016_remainder.nc")
    # plot(foo[[1]])
    # finish loop over season etc here
  }
  # finish loop over years here
  }
  return("completed conversion from RDS files into ncdf stored in data_derived")
}
