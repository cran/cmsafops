#'Determine correlations in grid space.
#'
#'The function determines correlations in grid space from data of two CM SAF
#'NetCDF input files. This function is applicable to 3-dimensional NetCDF data.
#'
#'@param var1 Name of NetCDF variable of the first data set (character).
#'@param infile1 Filename of first input NetCDF file. This may include the directory
#'  (character).
#'@param var2 Name of NetCDF variable of the second data set (character).
#'@param infile2 Filename of second input NetCDF file. This may include the directory
#'  (character).
#'@param outfile Filename of output NetCDF file. This may include the directory
#'  (character).
#'@param nc34 NetCDF version of output file. If \code{nc34 = 3} the output file will be
#'  in NetCDFv3 format (numeric). Default output is NetCDFv4.
#'@param overwrite logical; should existing output file be overwritten?
#'@param verbose logical; if TRUE, progress messages are shown
#'@param nc1 Alternatively to \code{infile1} you can specify the input as an
#'  object of class `ncdf4` (as returned from \code{ncdf4::nc_open}).
#'@param nc2 Alternatively to \code{infile2} you can specify the input as an
#'  object of class `ncdf4` (as returned from \code{ncdf4::nc_open}).
#'
#'@return A NetCDF file including a time series of correlations in grid space is written.
#'@export
#'
#'@family correlation and covariance
#'
#' @examples
#'## Create two example NetCDF files with a similar structure as used by CM
#'## SAF. The files are created with the ncdf4 package.  Alternatively
#'## example data can be freely downloaded here: <https://wui.cmsaf.eu/>
#'
#'library(ncdf4)
#'
#'## create some (non-realistic) example data
#'lon <- seq(5, 15, 0.5)
#'lat <- seq(45, 55, 0.5)
#'time <- as.Date("2000-05-31")
#'origin <- as.Date("1983-01-01 00:00:00")
#'time <- as.numeric(difftime(time, origin, units = "hour"))
#'data1 <- array(250:350, dim = c(21, 21, 1))
#'data2 <- array(230:320, dim = c(21, 21, 1))
#'
#'## create example NetCDF
#'x <- ncdim_def(name = "lon", units = "degrees_east", vals = lon)
#'y <- ncdim_def(name = "lat", units = "degrees_north", vals = lat)
#'t <- ncdim_def(name = "time", units = "hours since 1983-01-01 00:00:00",
#'              vals = time, unlim = TRUE)
#'var1 <- ncvar_def("SIS", "W m-2", list(x, y, t), -999, prec = "float")
#'vars <- list(var1)
#'ncnew_1 <- nc_create(file.path(tempdir(), "CMSAF_example_file_1.nc"), vars)
#'ncnew_2 <- nc_create(file.path(tempdir(), "CMSAF_example_file_2.nc"), vars)
#'
#'ncvar_put(ncnew_1, var1, data1)
#'ncvar_put(ncnew_2, var1, data2)
#'
#'ncatt_put(ncnew_1, "lon", "standard_name", "longitude", prec = "text")
#'ncatt_put(ncnew_1, "lat", "standard_name", "latitude", prec = "text")
#'
#'ncatt_put(ncnew_2, "lon", "standard_name", "longitude", prec = "text")
#'ncatt_put(ncnew_2, "lat", "standard_name", "latitude", prec = "text")
#'nc_close(ncnew_1)
#'nc_close(ncnew_2)
#'
#'## Determine the correlations in grid space of the example CM SAF NetCDF files and
#'## write the output to a new file.
#'fldcor(var1 = "SIS", infile1 = file.path(tempdir(),"CMSAF_example_file_1.nc"), 
#'       var2 = "SIS", infile2 = file.path(tempdir(), "CMSAF_example_file_2.nc"),
#'       outfile = file.path(tempdir(),"CMSAF_example_file_fldcor.nc"))
#'
#'unlink(c(file.path(tempdir(),"CMSAF_example_file_1.nc"), 
#'       file.path(tempdir(),"CMSAF_example_file_2.nc"),
#'       file.path(tempdir(),"CMSAF_example_file_fldcor.nc")))

fldcor <- function(var1, infile1, var2, infile2, outfile, nc34 = 4, overwrite = FALSE, verbose = FALSE, nc1 = NULL, nc2 = NULL) {
  fld_cor_covar_wrapper("fldcor", var1, infile1, var2, infile2, outfile, nc34, overwrite, verbose, nc1 = nc1, nc2 = nc2)
}