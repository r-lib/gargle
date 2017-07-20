.onLoad <- function(lib, pkg) {
  cred_funs_set_default()
  gargle_env$auth <- list(
    active = TRUE,
    token = NULL,
    method = NA_character_
  )
}
