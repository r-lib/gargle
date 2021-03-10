#' @keywords internal
#' @import fs
#' @importFrom glue glue glue_data glue_collapse
#' @import rlang
"_PACKAGE"

# The following block is used by usethis to automatically manage
# roxygen namespace tags. Modify with care!
## usethis namespace: start
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
#' gargle_quiet()
NULL

#' @rdname gargle_options
#' @export
#' @section `gargle_oauth_email`:
#' `gargle_oauth_email()` returns the option named "gargle_oauth_email", which
#' is undefined by default. If set, this option should be one of:
#'   * An actual email address corresponding to your preferred Google identity.
#'     Example:`janedoe@gmail.com`.
#'   * `TRUE` to allow email and OAuth token auto-discovery, if exactly one
#'     suitable token is found in the cache.
#'   * `FALSE` or `NA` to force the OAuth dance in the browser.
gargle_oauth_email <- function() {
  getOption("gargle_oauth_email")
}

#' @rdname gargle_options
#' @export
#' @section `gargle_oob_default`:
#' `gargle_oob_default()` returns the option named "gargle_oob_default", falls
#' back to the option named "httr_oob_default", and eventually defaults to
#' `FALSE`. This controls whether to prefer "out of band" authentication. We
#' also return `FALSE` unconditionally on RStudio Server or Cloud. This value is
#' ultimately passed to [httr::init_oauth2.0()] as `use_oob`. If `FALSE` (and
#' httpuv is installed), a local webserver is used for the OAuth dance.
#' Otherwise, user gets a URL and prompt for a validation code.
#'
#' Read more about "out of band" authentication in the vignette [Auth when using
#' R in the browser](https://gargle.r-lib.org/articles/auth-from-web.html).
gargle_oob_default <- function() {
  if (is_rstudio_server()) {
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
