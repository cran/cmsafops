#'Linear detrending of time series
#'
#'The function determines detrended values from data of a single NetCDF input file.
#'All time steps should be equidistantly distributed.
#'
#'@param var Name of NetCDF variable (character).
#'@param infile Filename of input NetCDF file. This may include the directory
#'  (character).
#'@param outfile Filename of output NetCDF file. This may include the directory
#'  (character).
#'@param nc34 NetCDF version of output file. If \code{nc34 = 3} the output file will be
#'  in NetCDFv3 format (numeric). Default output is NetCDFv4.
#'@param overwrite logical; should existing output file be overwritten?
#'@param verbose logical; if TRUE, progress messages are shown
#'@param nc Alternatively to \code{infile} you can specify the input as an
#'  object of class `ncdf4` (as returned from \code{ncdf4::nc_open}).
#'
#'@return A NetCDF file including a time series of linear detrended values 
#'is written.
#'@export
#'
#'@family temporal operators
#'
#' @examples
#'## Create an example NetCDF file with a similar structure as used by CM
#'## SAF. The file is created with the ncdf4 package.  Alternatively
#'## example data can be freely downloaded here: <https://wui.cmsaf.eu/>
#'
#'library(ncdf4)
#'
#'## create some (non-realistic) example data
#'
#'lon <- seq(5, 15, 0.5)
#'lat <- seq(45, 55, 0.5)
#'time <- seq(as.Date("2000-01-01"), as.Date("2010-12-31"), "month")
#'origin <- as.Date("1983-01-01 00:00:00")
#'time <- as.numeric(difftime(time, origin, units = "hour"))
#'data <- array(250:350, dim = c(21, 21, 132))
#'
#'## create example NetCDF
#'
#'x <- ncdim_def(name = "lon", units = "degrees_east", vals = lon)
#'y <- ncdim_def(name = "lat", units = "degrees_north", vals = lat)
#'t <- ncdim_def(name = "time", units = "hours since 1983-01-01 00:00:00",
#'  vals = time, unlim = TRUE)
#'var1 <- ncvar_def("SIS", "W m-2", list(x, y, t), -1, prec = "short")
#'vars <- list(var1)
#'ncnew <- nc_create(file.path(tempdir(),"CMSAF_example_file.nc"), vars)
#'ncvar_put(ncnew, var1, data)
#'ncatt_put(ncnew, "lon", "standard_name", "longitude", prec = "text")
#'ncatt_put(ncnew, "lat", "standard_name", "latitude", prec = "text")
#'nc_close(ncnew)
#'
#'## Determine the detrend values of the example CM SAF NetCDF file and write
#'## the output to a new file.
#'cmsaf.detrend(var = "SIS", infile = file.path(tempdir(),"CMSAF_example_file.nc"), 
#'  outfile = file.path(tempdir(),"CMSAF_example_file_detrend.nc"))
#'
#'unlink(c(file.path(tempdir(),"CMSAF_example_file.nc"), 
#'  file.path(tempdir(),"CMSAF_example_file_detrend.nc")))

cmsaf.detrend <- function(var, infile, outfile, nc34 = 4, overwrite = FALSE, verbose = FALSE,
                          nc = NULL) {
  calc_time_start <- Sys.time()
  gc()
  check_variable(var)
  if (is.null(nc)) check_infile(infile)
  check_outfile(outfile)
  outfile <- correct_filename(outfile)
  check_overwrite(outfile, overwrite)
  check_nc_version(nc34)

  ##### extract data from file #####
  file_data <- read_file(infile, var, nc = nc)
  file_data$variable$prec <- "float"

  # Use placeholder for result so that it can be calculated later without the
  # need to have all input data in memory concurrently.
  length.dimension.x <- length(file_data$dimension_data$x)
  length.dimension.y <- length(file_data$dimension_data$y)
  length.dimension.t <- length(file_data$dimension_data$t)
  # data_placeholder <- array(
  #   file_data$variable$attributes$missing_value,
  #   dim = c(length.dimension.x,
  #           length.dimension.y,
  #           length.dimension.t)
  # )

  vars_data <- list(time_bounds = file_data$dimension_data$t)

  nc_format <- get_nc_version(nc34)
  cmsaf_info <- paste0("cmsafops::cmsaf.detrend for variable ",
                       file_data$variable$name)

  time_data <- file_data$dimension_data$t

  ##### prepare output #####
  global_att_list <- names(file_data$global_att)
  global_att_list <- global_att_list[toupper(global_att_list) %in% toupper(GLOBAL_ATT_DEFAULT)]
  global_attributes <- file_data$global_att[global_att_list]

  dims <- define_dims(file_data$grid$is_regular,
                      file_data$dimension_data$x,
                      file_data$dimension_data$y,
                      time_data,
                      NB2,
                      file_data$time_info$units,
                      with_time_bnds = FALSE)

  vars <- define_vars(file_data$variable, dims, nc_format$compression, with_time_bnds = FALSE)

  write_output_file(
    outfile,
    nc_format$force_v4,
    vars,
    vars_data,
    file_data$variable$name,
    file_data$grid$vars, file_data$grid$vars_data,
    cmsaf_info,
    file_data$time_info$calendar,
    file_data$variable$attributes,
    global_attributes,
    write_result = FALSE,
    with_time_bnds = FALSE
  )
  
  ##### calculate and write result #####
  nc_out <- nc_open(outfile, write = TRUE)
  
  if (!is.null(nc)) nc_in <- nc
  else nc_in <- nc_open(infile)
  
  dum_dat <- array(NA, dim = c(length.dimension.x,
                               length.dimension.y,
                               length.dimension.t))
  
  limit <- 2601 * 2601 * 31  # limit to avoid vector memory exhaustion, Can be adjust
  dimensionality <- as.double(length.dimension.x) *
    as.double(length.dimension.y) * as.double(length.dimension.t)
  
  if(limit < dimensionality){
    warning("The calculation takes a long time due to the large amount of data!")
    
    if(limit*2 < dimensionality){
      stop("Too many parameters in the model. Please select a file with less dimensions")
    }
  
    for (i in seq_along(file_data$dimension_data$t)) {
      dum_dat_t <- ncvar_get(
        nc_in,
        file_data$variable$name,
        start = c(1, 1, i), count = c(-1, -1, 1),
        collapse_degen = FALSE
      )
      dum_dat[,,i] <- dum_dat_t
    }
  }else{
    
    dum_dat <- ncvar_get(
      nc_in,
      file_data$variable$name,
      collapse_degen = FALSE
    )
  }
  
  if (is.null(nc)) nc_close(nc_in)
  
  coef.a <- apply(dum_dat, c(1, 2), calc_regres_coef_a)
  data_a <- coef.a
  coef.b <- apply(dum_dat, c(1, 2), calc_regres_coef_b)
  data_b <- coef.b

  for (i in seq_along(file_data$dimension_data$t)) {
    
    temp.matrix <- dum_dat[,,i]
    dum_dat[,,i] <- temp.matrix-(data_a+data_b*i)

    if (verbose) message(paste0("apply detrend values ", i,
                                " of ", length(file_data$dimension_data$t)))

    data <- dum_dat[,,i]
    data[is.na(data)] <- file_data$variable$attributes$missing_value
    ncvar_put(nc_out, vars[[1]], data, start = c(1, 1, i), count = c(-1, -1, 1))
  }
  nc_close(nc_out)

  calc_time_end <- Sys.time()
  if (verbose) message(get_processing_time_string(calc_time_start, calc_time_end))
}
  