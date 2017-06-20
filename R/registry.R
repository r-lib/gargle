#' Environment used for gargle global state.
#'
#' Unfortunately, we're stuck having at least some state, in order to maintain a
#' list of credentials functions to try.
#'
#' This environment contains:
#' * `$credfuns` is the ordered list of credential methods to use when trying
#'   to fetch credentials.
#'
#' @format An environment.
#' @keywords internal
gargle_env <- new.env(parent = emptyenv())
gargle_env$credfuns <- list()

#' Check that f is a viable credential fetching function.
#'
#' In the abstract, a credential fetching function is any function which takes a
#' set of scopes and any number of additional arguments, and returns either a
#' valid [httr::Token()] or `NULL`.
#'
#' Here we say that a function is valid if its first argument is named
#' `scopes`, and it includes `...` as an argument, since it's
#' difficult to actually check the behavior of the function.
#'
#' @param f A function to check.
#' @keywords internal
is_credfun <- function(f) {
  if (!is.function(f)) {
    return(FALSE)
  }
  args <- names(formals(f))
  args[1] == "scopes" && args[length(args)] == "..."
}

#' Add a new credential fetching function.
#'
#' Function(s) are added to the *front* of the list.
#'
#' @param ... One or more functions with the right signature. See
#'   [is_credfun()].
#' @family registration
#' @export
#' @examples
#' creds_one <- function(scopes, ...) {}
#' credfuns_add(creds_one)
#' credfuns_add(one = creds_one)
#' credfuns_add(one = creds_one, two = creds_one)
#' credfuns_add(one = creds_one, creds_one)
credfuns_add <- function(...) {
  dots <- list(...)
  stopifnot(all(vapply(dots, is_credfun, TRUE)))
  gargle_env$credfuns <- c(dots, gargle_env$credfuns)
  invisible(NULL)
}

#' Get the list of all credential functions.
#'
#' @return A list of credential functions.
#' @family registration
#' @export
credfuns_list <- function() {
  gargle_env$credfuns
}

#' Set the list of all credential functions.
#'
#' @param ls A list of credential functions.
#' @family registration
#' @export
credfuns_set <- function(ls) {
  stopifnot(all(vapply(ls, is_credfun, TRUE)))
  gargle_env$credfuns <- ls
  invisible(NULL)
}

#' Clear the list of credential functions.
#'
#' @family registration
#' @export
credfuns_clear <- function() {
  gargle_env$credfuns <- list()
  invisible(NULL)
}

#' Set the default credential functions.
#' @export
credfuns_set_default <- function() {
  credfuns_add(user_oath2 = get_user_oauth2_credentials)
  credfuns_add(gce = get_gce_credentials)
  credfuns_add(application_default = get_application_default_credentials)
  credfuns_add(travis = get_travis_credentials)
  credfuns_add(service_acount = get_service_account_credentials)
}
