% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/box_mergetime.R
\name{box_mergetime}
\alias{box_mergetime}
\title{Function to combine NetCDF files and simultaneously cut a region (and level).}
\usage{
box_mergetime(
  var,
  path,
  pattern,
  outfile,
  lon1 = -180,
  lon2 = 180,
  lat1 = -90,
  lat2 = 90,
  level = NULL,
  nc34 = 4,
  overwrite = FALSE,
  verbose = FALSE
)
}
\arguments{
\item{var}{Name of NetCDF variable (character).}

\item{path}{The directory of input NetCDF files without / at the end
(character).}

\item{pattern}{A part of the filename, which is the same for all desired input
files (character). The pattern has to be a character string containing a
regular expression.}

\item{outfile}{Filename of output NetCDF file. This may include the directory
(character).}

\item{lon1}{Longitude of lower left corner (numeric).}

\item{lon2}{Longitude of upper right left corner (numeric).}

\item{lat1}{Latitude of lower left corner (numeric).}

\item{lat2}{Latitude of upper right corner (numeric).  Longitude of upper
right corner (numeric).}

\item{level}{Number of level that should be extracted (integer) or NULL.}

\item{nc34}{NetCDF version of output file. If \code{nc34 = 3} the output file will be
in NetCDFv3 format (numeric). Default output is NetCDFv4.}

\item{overwrite}{logical; should existing output file be overwritten?}

\item{verbose}{logical; if TRUE, progress messages are shown}
}
\value{
A NetCDF file including the merged time series of the selected region
is written. The resulting file uses the meta data of the first input file.
}
\description{
This function selects a region (and optionally a level) from a bunch of
NetCDF files that match the same pattern of the filename, and writes the
output to a new file. If no longitude and latitude values are given, files are
only merged. All input files have to have the same grid and the same variable.
The reference time of the output file is determined by the first input file.
}
\examples{
## Create an example NetCDF file with a similar structure as used by CM
## SAF. The file is created with the ncdf4 package.  Alternatively
## example data can be freely downloaded here: <https://wui.cmsaf.eu/>

library(ncdf4)

## create some (non-realistic) example data

lon <- seq(5, 15, 0.5)
lat <- seq(45, 55, 0.5)
time <- c(as.Date("2000-01-01"), as.Date("2001-02-01"))
origin <- as.Date("1983-01-01 00:00:00")
time <- as.numeric(difftime(time, origin, units = "hour"))
data1 <- array(250:350, dim = c(21, 21, 1))
data2 <- array(230:320, dim = c(21, 21, 1))

## create two simple example NetCDF files

x <- ncdim_def(name = "lon", units = "degrees_east", vals = lon)
y <- ncdim_def(name = "lat", units = "degrees_north", vals = lat)
t <- ncdim_def(name = "time", units = "hours since 1983-01-01 00:00:00",
 vals = time[1], unlim = TRUE)
var1 <- ncvar_def("SIS", "W m-2", list(x, y, t), -1, prec = "short")
vars <- list(var1)
ncnew <- nc_create(file.path(tempdir(),"CMSAF_example_file_n1.nc"), vars)
ncvar_put(ncnew, var1, data1)
ncatt_put(ncnew, "lon", "standard_name", "longitude", prec = "text")
ncatt_put(ncnew, "lat", "standard_name", "latitude", prec = "text")
nc_close(ncnew)
t <- ncdim_def(name = "time", units = "hours since 1983-01-01 00:00:00",
 vals = time[2], unlim = TRUE)
ncnew <- nc_create(file.path(tempdir(),"CMSAF_example_file_n2.nc"), vars)
ncvar_put(ncnew, var1, data2)
ncatt_put(ncnew, "lon", "standard_name", "longitude", prec = "text")
ncatt_put(ncnew, "lat", "standard_name", "latitude", prec = "text")
nc_close(ncnew)

## Cut a region and merge both example CM SAF NetCDF files into one
## output file.  Get path information of working directory with getwd()
## command.
box_mergetime(var = "SIS", path= tempdir(), pattern = "CMSAF_example_file_n",
 outfile = file.path(tempdir(),"CMSAF_example_file_box_mergetime.nc"), 
 lon1 = 8, lon2 = 12, lat1 = 48, lat2 = 52)

unlink(c(file.path(tempdir(),"CMSAF_example_file_n1.nc"), 
 file.path(tempdir(),"CMSAF_example_file_n2.nc"),
 file.path(tempdir(),"CMSAF_example_file_box_mergetime.nc")))
}
\seealso{
Other data manipulation functions: 
\code{\link{acsaf_box_mergetime}()},
\code{\link{add_grid_info}()},
\code{\link{cmsaf.transform.coordinate.system}()},
\code{\link{levbox_mergetime}()},
\code{\link{map_regular}()},
\code{\link{remap}()}
}
\concept{data manipulation functions}
