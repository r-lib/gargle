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
#' @noRd
#' @examples
#' f <- function(scopes, ...) {}
#' is_cred_fun(f)
is_cred_fun <- function(f) {
  if (!is.function(f)) {
    return(FALSE)
  }
  args <- names(formals(f))
  args[1] == "scopes" && "..." %in% args
}

#' Credential function registry
#'
#' Functions to query or manipulate the registry of credential functions
#' consulted by [token_fetch()].
#'
#' @name cred_funs
#' @seealso [token_fetch()], which is where the registry is actually used.
#' @return A list of credential functions or `NULL`.
#' @examples
#' names(cred_funs_list())
#'
#' creds_one <- function(scopes, ...) {}
#' cred_funs_add(creds_one)
#' cred_funs_add(one = creds_one)
#' cred_funs_add(one = creds_one, two = creds_one)
#' cred_funs_add(one = creds_one, creds_one)
#'
#' # undo all of the above and return to default
#' cred_funs_set_default()
NULL

#' @describeIn cred_funs Get the list of registered credential functions.
#' @export
cred_funs_list <- function() {
  gargle_env$cred_funs
}

#' @describeIn cred_funs Register one or more new credential fetching functions.
#'   Function(s) are added to the *front* of the list. So:
#'
#'     * "First registered, last tried."
#'     * "Last registered, first tried."
#'
#' @param ... One or more functions with the right signature: its first argument
#'   is named `scopes`, and it includes `...` as an argument.
#' @export
cred_funs_add <- function(...) {
  dots <- list(...)
  stopifnot(all(map_lgl(dots, is_cred_fun)))
  gargle_env$cred_funs <- c(dots, gargle_env$cred_funs)
  invisible()
}


#' @describeIn cred_funs Register a list of credential fetching functions.
#'
#' @param ls A list of credential functions.
#' @export
cred_funs_set <- function(ls) {
  stopifnot(all(map_lgl(ls, is_cred_fun)))
  gargle_env$cred_funs <- ls
  invisible()
}

#' @describeIn cred_funs Clear the credential function registry.
#' @export
cred_funs_clear <- function() {
  gargle_env$cred_funs <- list()
  invisible()
}

#' @describeIn cred_funs Reset the registry to the gargle default.
#' @export
cred_funs_set_default <- function() {
  cred_funs_clear()
  cred_funs_add(credentials_user_oauth2      = credentials_user_oauth2)
  cred_funs_add(credentials_byo_oauth2       = credentials_byo_oauth2)
  cred_funs_add(credentials_gce              = credentials_gce)
  cred_funs_add(credentials_app_default      = credentials_app_default)
  cred_funs_add(credentials_external_account = credentials_external_account)
  cred_funs_add(credentials_service_account  = credentials_service_account)
}
