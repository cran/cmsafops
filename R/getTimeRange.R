getTimeRange <- function(infile, nc = NULL){
  date.time <- ""
  # define standard names of variables and dimensions
  t_name <- TIME_NAMES$DEFAULT
  t_units <- UNDEFINED
  
  # get file information
  if (!is.null(nc)) nc_in <- nc
  else nc_in <- nc_open(infile)
  
  dimnames <- names(nc_in$dim)
  varnames <- names(nc_in$var)
  
  # check standard_names of dimensions
  for (i in seq_along(dimnames)) {
    sn <- ncatt_get(nc_in, dimnames[i], ATTR_NAMES$STANDARD_NAME)
    if (length(sn) > 0) {
      sn <- sn$value
      if (sn == TIME_NAMES$DEFAULT) t_name <- dimnames[i]
    }
  }
  
  for (i in seq_along(dimnames)) {
    if (dimnames[i] == t_name) {
      for (j in seq_along(dimnames)) {
        if (t_name %in% dimnames) {
          attnames <- names(nc_in$dim[[i]])
          if (ATTR_NAMES$UNITS %in% attnames) {
            t_units <- ncatt_get(nc_in, t_name, ATTR_NAMES$UNITS)$value
          }
        }
      }
      time1 <- ncvar_get(nc_in, TIME_NAMES$DEFAULT)
      date.time <- as.Date(get_time(t_units, time1))
    }
  }
  
  if (is.null(nc)) nc_close(nc_in)
  return(format(date.time))
}