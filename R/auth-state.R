
#' Activate / de-activate auth
#'
#' @return the auth state, invisibly
#' @export
auth_activate <- function(verbose = TRUE) {
  gargle_env$auth$active <- TRUE
  auth_state(verbose)
}

#' @rdname auth_activate
#' @param verbose verbosity!
#' @param clear Logical, whether to clear the cached token
#' @export
auth_deactivate <- function(clear = FALSE, verbose = TRUE) {
  gargle_env$auth$active <- FALSE
  if (clear) {
    token <- gargle_env$auth$token
    if (inherits(token, "Token2.0") &&
        !is.null(token$cache_path) &&
        file.exists(token$cache_path)) {
      message("TO DO: should deactivate cache file right here")
    }
    gargle_env$auth$token <- NULL
    gargle_env$auth$method <- NA_character_
  }
  auth_state(verbose)
}

#' @rdname auth_activate
#' @export
auth_state <- function(verbose = TRUE) {
  if (verbose) {
    cat("auth: ",
        if (gargle_env$auth$active) "ACTIVE" else "INACTIVE", "\n",
        "token state: ",
        if (is.null(gargle_env$auth$token)) "NULL" else "CACHED", "\n",
        "last credential method: ", gargle_env$auth$method, "\n",
        sep = ""
    )
  }
  invisible(gargle_env$auth)
}
