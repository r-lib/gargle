#' Credential function registry
#'
#' Functions to query or manipulate the registry of credential functions
#' consulted by [token_fetch()].
#'
#' @name cred_funs
#'
#' @seealso [token_fetch()], which is where the registry is actually used.
#' @return A list of credential functions or `NULL`.
#' @examples
#' names(cred_funs_list())
#'
#' creds_one <- function(scopes, ...) {}
#'
#' cred_funs_add(one = creds_one)
#' cred_funs_add(two = creds_one, three = creds_one)
#' names(cred_funs_list())
#'
#' cred_funs_add(two = NULL)
#' names(cred_funs_list())
#'
#' # restore the default list
#' cred_funs_set_default()
#'
#' # remove one specific credential fetcher
#' cred_funs_add(credentials_gce = NULL)
#' names(cred_funs_list())
#'
#' # force the use of one specific credential fetcher
#' cred_funs_set(list(credentials_user_oauth2 = credentials_user_oauth2))
#' names(cred_funs_list())
#'
#' # restore the default list
#' cred_funs_set_default()
NULL

#' @describeIn cred_funs Get the list of registered credential functions.
#' @export
cred_funs_list <- function() {
  gargle_env$cred_funs
}

#' @describeIn cred_funs Register one or more new credential fetching functions.
#'   Function(s) are added to the *front* of the list. So:
#'   * "First registered, last tried."
#'   * "Last registered, first tried."
#'

#' @param ... <[`dynamic-dots`][rlang::dyn-dots]> One or more credential
#'   functions, in `name = value` form. Each credential function is subject to a
#'   superficial check that it at least "smells like" a credential function: its
#'   first argument must be named `scopes`, and its signature must include
#'   `...`. To remove a credential function, you can use a specification like
#'   `name = NULL`.
#' @export
cred_funs_add <- function(...) {
  dots <- dots_list(
    ...,
    .named = NULL,
    .ignore_empty = "all",
    .preserve_empty = FALSE,
    .homonyms = "error",
    .check_assign = TRUE
  )

  cred_funs_check(dots, allow_null = TRUE)

  nms_to_remove <- names(dots)[map_lgl(dots, is.null)]
  cf <- cred_funs_list()
  cf[nms_to_remove] <- NULL
  cred_funs_set(cf)
  dots <- dots[!map_lgl(dots, is.null)]

  dup_nm <- names(dots) %in% names(cred_funs_list())
  if (any(dup_nm)) {
    n_dup_nm <- sum(dup_nm)
    gargle_abort(c(
      "{cli::qty(n_dup_nm)}{?This/These} name{?s} already {?appears/appear} \\
      in the credential function registry:",
      x = "{.field {names(dots)[dup_nm]}}"
    ))
  }

  # add them in reverse order, to mimic what would happen if they'd been added
  # one-at-a-time
  cf <- cred_funs_list()
  cred_funs_set(c(rev(dots), cf))

  invisible(cred_funs_list())
}

#' @describeIn cred_funs Register a list of credential fetching functions.
#'
#' @param ls A named list of credential functions.
#' @export
cred_funs_set <- function(ls) {
  cred_funs_check(ls, allow_null = FALSE)
  gargle_env$cred_funs <- ls
  invisible(cred_funs_list())
}

#' @describeIn cred_funs Clear the credential function registry.
#' @export
cred_funs_clear <- function() {
  gargle_env$cred_funs <- list()
  invisible(cred_funs_list())
}

#' @describeIn cred_funs Reset the registry to the gargle default.
#' @export
cred_funs_set_default <- function() {
  cred_funs_clear()
  l <- list(
    credentials_byo_oauth2       = credentials_byo_oauth2,
    credentials_service_account  = credentials_service_account,
    credentials_external_account = credentials_external_account,
    credentials_app_default      = credentials_app_default,
    credentials_gce              = credentials_gce,
    credentials_user_oauth2      = credentials_user_oauth2
  )
  cred_funs_set(l)
}

cred_funs_check <- function(ls, allow_null = FALSE) {
  if (allow_null) {
    not_cred_fun <- !map_lgl(ls, is.null) & !map_lgl(ls, is_cred_fun)
  } else {
    not_cred_fun <- !map_lgl(ls, is_cred_fun)
  }
  if (any(not_cred_fun)) {
    gargle_abort(c(
      "Not a valid credential function:",
      x = "Element{?s} {as.character(which(not_cred_fun))}"
    ))
  }

  if (!is_dictionaryish(ls)) {
    gargle_abort("Each credential function must have a unique name")
  }

  invisible()
}

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
