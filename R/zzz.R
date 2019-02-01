.onLoad <- function(lib, pkg) { # nocov start
  cred_funs_set_default()
  debugme::debugme()

  op <- options()
  op.gargle <- list(
    gargle.oauth_cache = NA,
    gargle.oob_default = FALSE
  )
  toset <- !(names(op.gargle) %in% names(op))
  if (any(toset)) options(op.gargle[toset])

  invisible()
} # nocov end
