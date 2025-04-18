define_vars_trend_advanced <- function(variable, dims, compression, sig1, sig2) {
  nvar1 <- paste0(variable$name, "_trend1")
  nvar2 <- paste0(variable$name, "_trend2")

  var1 <- ncvar_def(
    name = nvar1,
    units = variable$attributes$units,
    dim = dims[c("x", "y", "t")],
    missval = variable$attributes$missing_value,
    prec = variable$prec,
    compression = compression
  )

  var2 <- ncvar_def(
    name = TIME_BOUNDS_NAMES$DEFAULT,
    units = UNITS$ONE,
    dim = dims[c("tb", "t")],
    prec = PRECISIONS_VAR$DOUBLE
  )

  var3 <- ncvar_def(
    name = sig1$name,
    units = sig1$units,
    dim = dims[c("x", "y", "t")],
    missval = variable$attributes$missing_value,
    prec = "double",
    compression = compression
  )
  
  var4 <- ncvar_def(
    name = sig2$name,
    units = sig2$units,
    dim = dims[c("x", "y", "t")],
    missval = variable$attributes$missing_value,
    prec = "double",
    compression = compression
  )

  var5 <- ncvar_def(
    name = nvar2,
    units = variable$attributes$units,
    dim = dims[c("x", "y", "t")],
    missval = variable$attributes$missing_value,
    prec = variable$prec,
    compression = compression
  )

  vars <- list(var1, var2, var3, var4, var5)

  return(vars)
}
