% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/multimonsum.R
\name{multimonsum}
\alias{multimonsum}
\title{Determine multi-monthly sums}
\usage{
multimonsum(
  var,
  month = c(1),
  infile,
  outfile,
  nc34 = 4,
  overwrite = FALSE,
  verbose = FALSE,
  nc = NULL
)
}
\arguments{
\item{var}{Name of NetCDF variable (character).}

\item{month}{Months which should be averaged, in form of a comma separated
vector of integer values from 1 to 12 (integer).}

\item{infile}{Filename of input NetCDF file. This may include the directory
(character).}

\item{outfile}{Filename of output NetCDF file. This may include the directory
(character).}

\item{nc34}{NetCDF version of output file. If \code{nc34 = 3} the output file will be
in NetCDFv3 format (numeric). Default output is NetCDFv4.}

\item{overwrite}{logical; should existing output file be overwritten?}

\item{verbose}{logical; if TRUE, progress messages are shown}

\item{nc}{Alternatively to \code{infile} you can specify the input as an
object of class \code{ncdf4} (as returned from \code{ncdf4::nc_open}).}
}
\value{
A NetCDF file including a time series of multi-monthly sums is written.
}
\description{
The function determines multi-monthly sums from data of a single CM SAF NetCDF
input file. The months are given as a vector of integers from 1 to 12. This
allows sums of user-defined seasons.
}
\examples{
## Create an example NetCDF file with a similar structure as used by CM
## SAF. The file is created with the ncdf4 package.  Alternatively
## example data can be freely downloaded here: <https://wui.cmsaf.eu/>

library(ncdf4)

## create some (non-realistic) example data

lon <- seq(10, 15, 0.5)
lat <- seq(50, 55, 0.5)
time <- seq(as.Date("2000-01-01"), as.Date("2010-12-31"), "month")
origin <- as.Date("1983-01-01 00:00:00")
time <- as.numeric(difftime(time, origin, units = "hour"))
data <- array(0:150, dim = c(11, 11, 132))

## create example NetCDF

x <- ncdim_def(name = "lon", units = "degrees_east", vals = lon)
y <- ncdim_def(name = "lat", units = "degrees_north", vals = lat)
t <- ncdim_def(name = "time", units = "hours since 1983-01-01 00:00:00",
 vals = time, unlim = TRUE)
var1 <- ncvar_def("rain", "mm", list(x, y, t), -1, prec = "short")
vars <- list(var1)
ncnew <- nc_create(file.path(tempdir(),"CMSAF_example_file.nc"), vars)
ncvar_put(ncnew, var1, data)
ncatt_put(ncnew, "lon", "standard_name", "longitude", prec = "text")
ncatt_put(ncnew, "lat", "standard_name", "latitude", prec = "text")
nc_close(ncnew)

## Determine the sum of the monsoon seas from June to September of the
## example CM SAF NetCDF file and write the output to a new file.
multimonsum(var = "rain", month = c(6, 7, 8, 9), infile = 
 file.path(tempdir(),"CMSAF_example_file.nc"), outfile =
 file.path(tempdir(),"CMSAF_example_file_multimonsum.nc"))

unlink(c(file.path(tempdir(),"CMSAF_example_file.nc"), 
 file.path(tempdir(),"CMSAF_example_file_multimonsum.nc")))
}
\seealso{
Other monthly statistics: 
\code{\link{mon.anomaly}()},
\code{\link{mon_num_above}()},
\code{\link{mon_num_below}()},
\code{\link{mon_num_equal}()},
\code{\link{monavg}()},
\code{\link{mondaymean}()},
\code{\link{monmax}()},
\code{\link{monmean}()},
\code{\link{monmin}()},
\code{\link{monpctl}()},
\code{\link{monsd}()},
\code{\link{monsum}()},
\code{\link{monvar}()},
\code{\link{multimonmean}()},
\code{\link{ymonmax}()},
\code{\link{ymonmean}()},
\code{\link{ymonmedian}()},
\code{\link{ymonmin}()},
\code{\link{ymonsd}()},
\code{\link{ymonsum}()}
}
\concept{monthly statistics}
