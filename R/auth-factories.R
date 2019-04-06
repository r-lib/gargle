#' Authorization function factory
#'
#' Create a function in your package for Google authorization.
#'
#' @param pkg_name The name of your package.
#' @param scopes A character vector of the Google api scopes needed by your
#'   package.
#' @param error_message The error message to show users when authorization
#'   fails.
#'
#' @return An authorization function.
#' @export
#'
#' @examples
#' drive_auth <- make_auth(
#'   scopes = "https://www.googleapis.com/auth/drive",
#'   error_message <- "Can't get Google credentials.\\nAre you running googledrive in a non-interactive session? Consider:\\n  * `drive_deauth()` to prevent the attempt to get credentials.\\n  * Call `drive_auth()` directly with all necessary specifics.\\n"
#' )
make_auth <- function(
  pkg_name,
  scopes,
  error_message = "Can't get Google credentials.\nAre you running this package in a non-interactive session? Consider calling this authorization function directly with all necessary specifics.\n"
) {
  auth_function <- function(email = NULL,
                            path = NULL,
                            scopes,
                            cache = getOption("gargle.oauth_cache"),
                            use_oob = getOption("gargle.oob_default")) {
    cred <- gargle::token_fetch(
      scopes = scopes,
      app = .auth$app,
      email = email,
      path = path,
      package = "PKGNAME",
      cache = cache,
      use_oob = use_oob
    )
    if (!gargle::is_legit_token(cred, verbose = TRUE)) {
      error_message <- "Can't get Google credentials."
      stop(
        error_message,
        call. = FALSE
      )
    }
    .auth$set_cred(cred)
    .auth$set_auth_active(TRUE)

    invisible()
  }

  # Updated the package name in the cred object.
  body(auth_function)[[2]][[3]][[6]] <- pkg_name

  # Set the error message for !gargle::is_legit_token.
  body(auth_function)[[3]][[3]][[2]][[3]] <- error_message

  # Set the default scopes.
  formals(auth_function)$scopes <- scopes

  auth_function
}

#' Deauthorization function factory
#'
#' Create a function in your package for Google deauthorization.
#'
#' @return A deauthorization function.
#' @export
#'
#' @examples
#' drive_deauth <- make_deauth()
make_deauth <- function() {
  function() {
    .auth$set_auth_active(FALSE)
    return(invisible())
  }
}
