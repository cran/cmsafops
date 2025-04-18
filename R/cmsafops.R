#'cmsafops: A package for analyzing and manipulating CM SAF NetCDF formatted
#'data.
#'
#'The 'cmsafops' functions are manipulating NetCDF input files and write the
#'result in a separate output file. The functions were designed and tested for
#'CM SAF NetCDF data, but most of the functions can be applied to other NetCDF
#'data, which use the CF convention and time, latitude, longitude dimensions. 
#'As interface to NetCDF data the \link[ncdf4:ncdf4-package]{ncdf4 package} is used.
"_PACKAGE"
#'
#'@section Toolbox: The CM SAF R Toolbox is a user-friendly \link[cmsaf:run_toolbox]{shiny app}
#'in the \link[cmsaf:cmsaf]{cmsaf package}, which helps to apply 'cmsafops' operators.
#'
#'@section Mathematical operators: \code{\link{cmsaf.abs}}, \code{\link{cmsaf.add}},
#'  \code{\link{cmsaf.addc}}, \code{\link{cmsaf.div}}, \code{\link{cmsaf.divc}},
#'  \code{\link{cmsaf.mul}}, \code{\link{cmsaf.mulc}}, \code{\link{cmsaf.sub}},
#'  \code{\link{cmsaf.subc}}, \code{\link{divdpm}}, \code{\link{muldpm}}
#'
#'@section Hourly statistics: \code{\link{hourmean}}, \code{\link{hoursum}}
#'
#'@section Daily statistics: \code{\link{dayavg}}, \code{\link{daymax}}, \code{\link{daymean}}, 
#'  \code{\link{daymin}}, \code{\link{daypctl}}, \code{\link{dayrange}}, 
#'  \code{\link{daysd}}, \code{\link{daysum}}, \code{\link{dayvar}}, \code{\link{ydaymax}},
#'  \code{\link{ydaymean}}, \code{\link{ydaymin}}, \code{\link{ydayrange}}, \code{\link{ydaysd}}, 
#'  \code{\link{ydaysum}}
#'
#'@section Monthly statistics: \code{\link{mon.anomaly}}, \code{\link{monavg}}, \code{\link{mondaymean}}, 
#'  \code{\link{monmax}}, \code{\link{monmean}}, \code{\link{monmin}}, \code{\link{monpctl}}, \code{\link{monsd}},
#'  \code{\link{monsum}}, \code{\link{monvar}}, \code{\link{multimonmean}}, 
#'  \code{\link{multimonsum}}, \code{\link{ymonmax}}, \code{\link{ymonmean}}, 
#'  \code{\link{ymonmin}}, \code{\link{ymonsd}}, \code{\link{ymonsum}}, \code{\link{mon_num_above}},
#'  \code{\link{mon_num_below}}, \code{\link{mon_num_equal}}
#'
#'@section Seasonal statistics: \code{\link{seas.anomaly}},
#'  \code{\link{seasmean}}, \code{\link{seassd}}, \code{\link{seassum}}, 
#'  \code{\link{seasvar}}, \code{\link{yseasmax}}, \code{\link{yseasmean}}, 
#'  \code{\link{yseasmin}}, \code{\link{yseassd}}
#'
#'@section Annual statistics: \code{\link{year.anomaly}},
#'  \code{\link{yearmax}}, \code{\link{yearmean}}, \code{\link{yearmin}}, 
#'  \code{\link{yearrange}}, \code{\link{yearsd}}, \code{\link{yearsum}},
#'  \code{\link{yearvar}}
#'  
#'@section Zonal statistics: \code{\link{zonmean}}, \code{\link{zonsum}}
#'
#'@section Meridional statistics: \code{\link{mermean}} 
#'
#'@section Running statistics: \code{\link{runmax}}, \code{\link{runmean}},
#'  \code{\link{runmin}}, \code{\link{runrange}}, \code{\link{runsd}}, \code{\link{runsum}}, 
#'  \code{\link{ydrunmean}}, \code{\link{ydrunsd}}, \code{\link{ydrunsum}}
#'  
#'@section Grid boxes statistics: \code{\link{gridboxmax}}, \code{\link{gridboxmean}},
#'  \code{\link{gridboxmin}}, \code{\link{gridboxrange}}, \code{\link{gridboxsd}},
#'  \code{\link{gridboxsum}}, \code{\link{gridboxvar}}
#'
#'@section Temporal operators: \code{\link{cmsaf.detrend}}, \code{\link{cmsaf.mk.test}}, \code{\link{cmsaf.regres}}, 
#'  \code{\link{timmax}}, \code{\link{timmean}}, \code{\link{timavg}}, \code{\link{timmin}}, \code{\link{timpctl}}, 
#'  \code{\link{timsd}}, \code{\link{timsum}}, \code{\link{trend_advanced}}, \code{\link{trend}},
#'  \code{\link{num_above}}, \code{\link{num_below}}, \code{\link{num_equal}}
#'  
#'@section Time range statistics: \code{\link{timselmean}}, \code{\link{timselsum}}
#'
#'@section Spatial operators: \code{\link{fldmax}}, 
#'  \code{\link{fldmean}}, \code{\link{fldmin}}, \code{\link{fldrange}}, \code{\link{fldsd}}, 
#'  \code{\link{fldsum}}, \code{\link{wfldmean}}
#'  
#'@section Correlation and covariance: \code{\link{fldcor}}, \code{\link{fldcovar}},
#'  \code{\link{timcor}}, \code{\link{timcovar}}
#'
#'@section Selection and removal functions: \code{\link{extract.level}},
#'  \code{\link{extract.period}}, \code{\link{sellonlatbox}},
#'  \code{\link{selmon}}, \code{\link{selperiod}}, \code{\link{selpoint.multi}},
#'  \code{\link{selpoint}}, \code{\link{seltime}}, \code{\link{selyear}}
#'
#'@section Data manipulation: \code{\link{box_mergetime}}, \code{\link{cmsaf.adjust.two.files}}, \code{\link{cmsaf.transform.coordinate.system}}, 
#'  \code{\link{levbox_mergetime}}, \code{\link{add_grid_info}},
#'  \code{\link{remap}}
#'
#'@section Other functions: \code{\link{cmsaf.cat}}, \code{\link{get_time}},
#'  \code{\link{ncinfo}}, \code{\link{read_ncvar}}
#'
#'
#'@importFrom ncdf4 nc_open nc_close nc_create ncdim_def ncvar_def ncvar_get
#'  ncvar_put ncvar_add ncvar_rename ncvar_change_missval ncatt_get ncatt_put
#'  nc_sync
#'
#'@author Maintainer: Steffen Kothe \email{Steffen.Kothe@dwd.de}
#'
#'  Contact: CM SAF Team \email{contact.cmsaf@dwd.de}
#'
#'@references \url{http://www.cmsaf.eu/R_toolbox}
#'
#'  Kothe, S.; Hollmann, R.; Pfeifroth, U.; Träger-Chatterjee, C.; Trentmann, J.
#'  The CM SAF R Toolbox—A Tool for the Easy Usage of Satellite-Based Climate
#'  Data in NetCDF Format. ISPRS Int. J. Geo-Inf. 2019, 8, 109.
#'  \doi{10.3390/ijgi8030109}
#'
#'@keywords datagen manip package spatial ts univar
NULL
