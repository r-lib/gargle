#' Environment used for gargle global state.
#'
#' Unfortunately, we're stuck having at least some state, in order to maintain a
#' list of credentials functions to try.
#'
#' This environment contains:
#' * `$credential_functions` is the ordered list of credential
#'     methods to use when trying to fetch credentials.
#'
#' @format An environment.
#' @keywords internal
gargle_env <- new.env(parent = emptyenv())
gargle_env$credential_functions <- list()

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
is_credential_function <- function(f) {
  if (!is.function(f)) {
    return(FALSE)
  }
  args <- names(formals(f))
  args[1] == "scopes" && args[length(args)] == "..."
}

#' Add a new credential fetching function.
#'
#' Note that this implicitly adds `f` to the \emph{end} of the list.
#'
#' @param f A function with the right signature.
#' @family registration
#' @export
add_credential_function <- function(f) {
  stopifnot(is_credential_function(f))
  gargle_env$credential_functions <- c(f, gargle_env$credential_functions)
  invisible(NULL)
}

#' Get the list of all credential functions.
#'
#' @return A list of credential functions.
#' @family registration
#' @export
all_credential_functions <- function() {
  gargle_env$credential_functions
}

#' Set the list of all credential functions.
#'
#' @param ls A list of credential functions.
#' @family registration
#' @export
set_credential_functions <- function(ls) {
  stopifnot(all(vapply(ls, is_credential_function, TRUE)))
  gargle_env$credential_functions <- ls
  invisible(NULL)
}

#' Set the default credential functions.
#' @export
set_default_credential_functions <- function() {
  add_credential_function(get_user_oauth2_credentials)
  add_credential_function(get_gce_credentials)
  add_credential_function(get_application_default_credentials)
  add_credential_function(get_travis_credentials)
  add_credential_function(get_service_account_credentials)
}
