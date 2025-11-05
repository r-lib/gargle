.onLoad <- function(lib, pkg) {
  # nocov start
  otel_cache_tracer()
  cred_funs_set_default()
  invisible()
} # nocov end
