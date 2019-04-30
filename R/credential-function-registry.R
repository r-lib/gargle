#' Environment used for gargle global state
#'
#' Unfortunately, we're stuck having at least some state, in order to maintain a
#' list of credential functions to try.
#'
#' This environment contains:
#' * `$cred_funs` is the ordered list of credential functions to use when trying
#'   to fetch credentials.
#'
#' @noRd
#' @format An environment.
#' @keywords internal
gargle_env <- new.env(parent = emptyenv())
gargle_env$cred_funs <- list()

#' Check that f is a viable credential fetching function
#'
#' In the abstract, a credential fetching function is any function which takes a
#' set of scopes and any number of additional arguments, and returns either a
#' valid [`httr::Token`][httr::Token-class] or `NULL`.
#'
#' Here we say that a function is valid if its first argument is named `scopes`,
#' and it includes `...` as an argument, since it's difficult to actually check
#' the behavior of the function.
#'
#' @param f A function to check.
#' @keywords internal
is_cred_fun <- function(f) {
  if (!is.function(f)) {
    return(FALSE)
  }
  args <- names(formals(f))
  args[1] == "scopes" && args[length(args)] == "..."
}

#' Register a new credential fetching function
#'
#' Function(s) are added to the *front* of the list. So:
#'   * "First registered, last tried."
#'   * "Last registered, first tried."
#'
#' @param ... One or more functions with the right signature. See
#'   [is_cred_fun()].
#' @family registry management
#' @export
#' @examples
#' creds_one <- function(scopes, ...) {}
#' cred_funs_add(creds_one)
#' cred_funs_add(one = creds_one)
#' cred_funs_add(one = creds_one, two = creds_one)
#' cred_funs_add(one = creds_one, creds_one)
cred_funs_add <- function(...) {
  dots <- list(...)
  stopifnot(all(vapply(dots, is_cred_fun, TRUE)))
  gargle_env$cred_funs <- c(dots, gargle_env$cred_funs)
  invisible()
}

#' List the registered credential functions
#'
#' @return A list of credential functions.
#' @family registry management
#' @export
cred_funs_list <- function() {
  gargle_env$cred_funs
}

#' Register a list of credential fetching functions
#'
#' @param ls A list of credential functions.
#' @family registry management
#' @export
cred_funs_set <- function(ls) {
  stopifnot(all(vapply(ls, is_cred_fun, TRUE)))
  gargle_env$cred_funs <- ls
  invisible()
}

#' Clear the credential function registry
#'
#' @family registry management
#' @export
cred_funs_clear <- function() {
  gargle_env$cred_funs <- list()
  invisible()
}

#' Set the default credential functions
#' @export
cred_funs_set_default <- function() {
  cred_funs_add(user_oath2 = credentials_user_oauth2)
  cred_funs_add(gce = credentials_gce)
  cred_funs_add(application_default = credentials_app_default)
  cred_funs_add(service_acount = credentials_service_account)
}
