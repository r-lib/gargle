#' @keywords internal
#' @import fs
#' @importFrom glue glue glue_data glue_collapse
#' @import rlang
"_PACKAGE"

# The following block is used by usethis to automatically manage
# roxygen namespace tags. Modify with care!
## usethis namespace: start
#' @importFrom lifecycle deprecated
## usethis namespace: end
NULL

#' Options consulted by gargle
#'
#' @description
#' Wrapper functions around options consulted by gargle, which provide:
#'   * A place to hang documentation.
#'   * The mechanism for setting a default.
#'
#' If the built-in defaults don't suit you, set one or more of these options.
#' Typically, this is done in the `.Rprofile` startup file, with code along
#' these lines:
#' ```
#' options(
#'   gargle_oauth_email = "jane@example.com",
#'   gargle_oauth_cache = "/path/to/folder/that/does/not/sync/to/cloud"
#' )
#' ```
#'
#' @name gargle_options
#' @examples
#' gargle_oauth_email()
#' gargle_oob_default()
#' gargle_oauth_cache()
#' gargle_verbosity()
NULL

#' @rdname gargle_options
#' @export
#' @section `gargle_oauth_email`:
#' `gargle_oauth_email()` returns the option named "gargle_oauth_email", which
#' is undefined by default. If set, this option should be one of:
#'   * An actual email address corresponding to your preferred Google identity.
#'     Example:`janedoe@gmail.com`.
#'   * A glob pattern that indicates your preferred Google domain.
#'     Example:`*@example.com`.
#'   * `TRUE` to allow email and OAuth token auto-discovery, if exactly one
#'     suitable token is found in the cache.
#'   * `FALSE` or `NA` to force the OAuth dance in the browser.
gargle_oauth_email <- function() {
  getOption("gargle_oauth_email")
}

#' @rdname gargle_options
#' @export
#' @section `gargle_oob_default`:
#' `gargle_oob_default()` returns `TRUE` unconditionally on RStudio Server,
#' Posit Workbench, Posit Cloud, or Google Colab, since it is not possible to
#' launch a local web server in these contexts. In this case, for the final step
#' of the OAuth dance, the user is redirected to a specific URL where they must
#' copy a code and paste it back into the R session.
#'
#' In all other contexts, `gargle_oob_default()` consults the option named
#' `"gargle_oob_default"`, then the option named `"httr_oob_default"`, and
#' eventually defaults to `FALSE`.
#'
#' "oob" stands for out-of-band. Read more about out-of-band authentication in
#' the vignette `vignette("auth-from-web")`.
gargle_oob_default <- function() {
  if (is_rstudio_server() || is_google_colab()) {
    # TODO: Is there a better, more general condition we could use to detect
    # whether OOB is necessary?
    # Idea from @jcheng: check if it's an SSH session?
    # e.g. https://unix.stackexchange.com/questions/9605/how-can-i-detect-if-the-shell-is-controlled-from-ssh/9607#9607
    TRUE
  } else {
    getOption("gargle_oob_default") %||%
      getOption("httr_oob_default") %||%
      FALSE
  }
}

#' @rdname gargle_options
#' @export
#' @section `gargle_oauth_cache`:
#' `gargle_oauth_cache()` returns the option named "gargle_oauth_cache",
#' defaulting to `NA`. If defined, the option must be set to a logical value or
#' a string. `TRUE` means to cache using the default user-level cache file,
#' `~/.R/gargle/gargle-oauth`, `FALSE` means don't cache, and `NA` means to
#' guess using some sensible heuristics.
gargle_oauth_cache <- function() {
  getOption("gargle_oauth_cache", default = NA)
}

#' @rdname gargle_options
#' @export
#' @section `gargle_oauth_client_type`:
#' `gargle_oauth_client_type()` returns the option named
#' "gargle_oauth_client_type", if defined. If defined, the option must be either
#' "installed" or "web". If the option is not defined, the function returns:
#' * "web" on RStudio Server, Posit Workbench, Posit Cloud, or Google
#'   Colaboratory
#' * "installed" otherwise
#' Primarily intended to help infer the most suitable OAuth client when a user
#' is relying on a built-in client, such as the tidyverse client used by
#' packages like bigrquery, googledrive, and googlesheets4.
gargle_oauth_client_type <- function() {
  opt <- getOption("gargle_oauth_client_type")
  if (is.null(opt)) {
    if(is_rstudio_server() || is_google_colab()) "web" else "installed"
  } else {
    check_string(opt)
    arg_match(opt, values = c("installed", "web"))
  }
}
