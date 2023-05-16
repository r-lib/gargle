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
#'
#' # run some code with a temporary change to the registry
#' # creds_one ONLY
#' with_cred_funs(
#'   list(one = creds_one),
#'   names(cred_funs_list())
#' )
#' # add creds_one to the list
#' with_cred_funs(
#'   list(one = creds_one),
#'   names(cred_funs_list()),
#'   action = "modify"
#' )
#' # remove credentials_gce
#' with_cred_funs(
#'   list(credentials_gce = NULL),
#'   names(cred_funs_list()),
#'   action = "modify"
#' )
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
#' Can also be used to *remove* a function from the registry.
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
#' @param funs A named list of credential functions.
#' @param ls `r lifecycle::badge("deprecated")` This argument has been renamed
#'   to `funs`.
#' @export
cred_funs_set <- function(funs, ls = deprecated()) {
  if (lifecycle::is_present(ls)) {
    lifecycle::deprecate_warn(
      when = "1.3.0",
      what = "cred_funs_set(ls)",
      with = "cred_funs_set(funs)",
    )
    funs = ls
  }

  cred_funs_check(funs, allow_null = FALSE)
  gargle_env$cred_funs <- funs
  invisible(cred_funs_list())
}

#' @describeIn cred_funs Clear the credential function registry.
#' @export
cred_funs_clear <- function() {
  gargle_env$cred_funs <- list()
  invisible(cred_funs_list())
}

#' @describeIn cred_funs Return the default list of credential functions.
#' @export
cred_funs_list_default <- function() {
  list(
    credentials_byo_oauth2       = credentials_byo_oauth2,
    credentials_service_account  = credentials_service_account,
    credentials_external_account = credentials_external_account,
    credentials_app_default      = credentials_app_default,
    credentials_gce              = credentials_gce,
    credentials_user_oauth2      = credentials_user_oauth2
  )
}

#' @describeIn cred_funs Reset the registry to the gargle default.
#' @export
cred_funs_set_default <- function() {
  cred_funs_set(cred_funs_list_default())
}

#' @describeIn cred_funs Modify the credential function registry in the current
#'   scope. It is an example of the `local_*()` functions in \pkg{withr}.
#' @param action Whether to use `funs` to replace or modify the registry with
#'   funs:
#'   * `"replace"` does `cred_funs_set(funs)`
#'   * `"modify"` does `cred_funs_add(!!!funs)`
#' @param .local_envir The environment to use for scoping. Defaults to current
#'   execution environment.
#' @export
local_cred_funs <- function(funs = cred_funs_list_default(),
                            action = c("replace", "modify"),
                            .local_envir = caller_env()) {
  action <- arg_match(action)

  cred_funs_orig <- cred_funs_list()
  withr::defer(cred_funs_set(cred_funs_orig), envir = .local_envir)

  switch(
    action,
    replace = cred_funs_set(funs),
    modify = cred_funs_add(!!!funs)
  )
}

#' @describeIn cred_funs Evaluate `code` with a temporarily modified credential
#'   function registry. It is an example of the `with_*()` functions in
#'   \pkg{withr}.
#' @param code Code to run with temporary credential function registry.
#' @export
with_cred_funs <- function(funs = cred_funs_list_default(),
                           code,
                           action = c("replace", "modify")) {
  local_cred_funs(funs = funs, action = action)
  force(code)
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
