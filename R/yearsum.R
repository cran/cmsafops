#'Determine annual sums
#'
#'The function determines annual sums from data of a single CM SAF NetCDF input
#'file.
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
#'@return A NetCDF file including a time series of annual sums is written.
#'@export
#'
#'@family annual statistics
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
#'## Determine the annual sums of the example CM SAF NetCDF file and write
#'## the output to a new file.
#'yearsum(var = "SIS", infile = file.path(tempdir(),"CMSAF_example_file.nc"), 
#'  outfile = file.path(tempdir(),"CMSAF_example_file_yearsum.nc"))
#'
#'unlink(c(file.path(tempdir(),"CMSAF_example_file.nc"), 
#'  file.path(tempdir(),"CMSAF_example_file_yearsum.nc")))
yearsum <- function(var, infile, outfile, nc34 = 4, overwrite = FALSE, verbose = FALSE, nc = NULL) {
  calc_time_start <- Sys.time()

  check_variable(var)
  if (is.null(nc)) check_infile(infile)
  check_outfile(outfile)
  outfile <- correct_filename(outfile)
  check_overwrite(outfile, overwrite)
  check_nc_version(nc34)

  ##### extract data from file #####
  file_data <- read_file(infile, var, nc = nc)
  file_data$variable$prec <- "float"
  years_all <- get_date_time(file_data$dimension_data$t, file_data$time_info$units)$years
  years_unique <- sort(unique(years_all))

  # Use placeholder for result so that it can be calculated later without the
  # need to have all input data in memory concurrently.
  data_placeholder <- array(
    file_data$variable$attributes$missing_value,
    dim = c(length(file_data$dimension_data$x),
            length(file_data$dimension_data$y),
            length(years_unique))
  )
  time_bnds <- get_time_bounds_year(
    file_data$dimension_data$t, years_all, years_unique
  )
  vars_data <- list(result = data_placeholder, time_bounds = time_bnds)

  nc_format <- get_nc_version(nc34)
  cmsaf_info <- paste0("cmsafops::yearsum for variable ",
                       file_data$variable$name)

  time_data <- time_bnds[1, ]

  ##### prepare output #####
  global_att_list <- names(file_data$global_att)
  global_att_list <- global_att_list[toupper(global_att_list) %in% toupper(GLOBAL_ATT_DEFAULT)]
  global_attributes <- file_data$global_att[global_att_list]

  dims <- define_dims(file_data$grid$is_regular,
                      file_data$dimension_data$x,
                      file_data$dimension_data$y,
                      time_data,
                      NB2,
                      file_data$time_info$units)

  vars <- define_vars(file_data$variable, dims, nc_format$compression)

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
    global_attributes
  )

  ##### calculate and write result #####
  nc_out <- nc_open(outfile, write = TRUE)
  dummy_vec <- seq_along(years_all)

  for (i in seq_along(years_unique)) {
    year_dummy <- which(years_all == years_unique[i])
    startt <- min(dummy_vec[year_dummy])
    countt <- length(year_dummy)
    if (!is.null(nc)) nc_in <- nc
    else nc_in <- nc_open(infile)
    dum_dat <- ncvar_get(
      nc_in,
      file_data$variable$name,
      start = c(1, 1, startt),
      count = c(-1, -1, countt),
      collapse_degen = FALSE
    )
    if (is.null(nc)) nc_close(nc_in)

    if (verbose) message(paste0("apply annual sum ", i,
                   " of ", length(years_unique)))

    sum_data <- rowSums(dum_dat, dims = 2, na.rm = TRUE) *
      ifelse(rowSums(is.na(dum_dat), dims = 2) == dim(dum_dat)[3], NA, 1)
    sum_data[is.na(sum_data)] <- file_data$variable$attributes$missing_value
    ncvar_put(nc_out, vars[[1]], sum_data, start = c(1, 1, i), count = c(-1, -1, 1))
  }

  nc_close(nc_out)

  calc_time_end <- Sys.time()
  if (verbose) message(get_processing_time_string(calc_time_start, calc_time_end))
}
