.onLoad <- function(lib, pkg) {
  cred_funs_set_default()
  debugme::debugme()

  op <- options()
  op.gargle <- list(
    gargle.oauth_cache = NA,
    gargle.oob_default = FALSE
  )
  toset <- !(names(op.gargle) %in% names(op))
  if(any(toset)) options(op.gargle[toset])

  backports::import(pkg, c("dir.exists", "file.size", "startsWith", "endsWith"))

  invisible()
}
