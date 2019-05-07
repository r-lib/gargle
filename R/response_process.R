#' Process a Google API response
#'
#' @description
#' Intended primarily for internal use in client packages that provide
#' high-level wrappers for users. Typically applied as the final step in this
#' sequence of calls:
#'   * Request prepared with [request_build()].
#'   * Request made with [request_make()].
#'   * Response processed with [response_process()].
#'
#' All that's needed for a successful request is to parse the JSON extracted via
#' `httr::content()`. Therefore, the main point of `response_process()` is to
#' handle less happy outcomes:
#'   * Status code in the 100s (information) or 300s (redirection). These are
#'     unexpected.
#'   * Non-JSON content type, such as HTML.
#'   * Status codes in the 400s (client error) and 500s (server error). The
#'     structure of the error payload varies across Google APIs and we try to
#'     create a useful message for all variants we know about.
#'
#' @details
#' A redacted version of the `resp` input is returned in the condition (auth
#' tokens are removed). Use functions such as `rlang::last_error()` or
#' `rlang::catch_cnd()` to capture the condition and do a more detailed forensic
#' examination.
#'
#' @param resp Object of class `response` from [httr].
#' @param error_message Function that produces an informative error message from
#'   the primary input, `resp`. It should return a character vector. Since
#'   Google APIs generally return JSON, this function should use
#'   `response_as_json()`.
#'
#' @return The content of the request.
#' @family requests and responses
#' @export
response_process <- function(resp, error_message = gargle_error_message) {
  code <- httr::status_code(resp)

  if (code >= 200 && code < 300) {
    if (code == 204) {
      # HTTP status: No content
      TRUE
    } else {
      response_as_json(resp)
    }
  } else {
    stop_request_failed(error_message(resp), resp)
  }
}

#' @export
#' @rdname response_process
response_as_json <- function(resp) {
  check_for_json(resp)

  content <- httr::content(resp, type = "raw")
  jsonlite::fromJSON(rawToChar(content), simplifyVector = FALSE)
}

check_for_json <- function(resp) {
  type <- httr::http_type(resp)
  if (grepl("^application/json", type)) {
    return(invisible(resp))
  }

  content <- httr::content(resp, as = "text")
  message <- glue_lines(c(
    "Expected content type 'application/json' not {sq(type)}.",
    "{obfuscate(content, first = 197, last = 0)}"
  ))

  stop_request_failed(message, resp)
}

stop_request_failed <- function(message, resp) {
  rlang::abort(
    glue_collapse(message, sep = "\n"),
    .subclass = "gargle_error_request_failed",
    resp = redact_response(resp),
  )
}

#' @export
#' @rdname response_process
gargle_error_message <- function(resp) {
  content <- response_as_json(resp)
  error <- content[["error"]]

  # Handle variety of error messages returned by different google APIs
  if (is.null(error)) {
    # developed from test fixture from tokeninfo endpoint
    message <- c(
      httr::http_status(resp)$message,
      glue("  * {content$error_description}")
    )
  } else {
    errors <- error[["errors"]]
    if (is.null(errors)) {
      # developed from test fixture from "sheets.spreadsheets.get" endpoint
      status <- httr::http_status(resp)
      rpc <- rpc_description(error$status)
      message <- c(
        glue("{status$category}: ({error$code}) {error$status}"),
        glue("  * {rpc}"),
        glue("  * {error$message}")
      )
    } else {
      # developed from test fixture from "drive.files.get" endpoint
      errors <- unlist(errors)
      message <- c(
        httr::http_status(resp)$message,
        glue("  * {format(names(errors), justify = 'right')}: {errors}")
      )
    }
  }
  message
}

redact_response <- function(resp) {
  resp$request$auth_token <- "<REDACTED>"
  resp$request$headers["Authorization"] <- "<REDACTED>"
  resp
}

rpc_description <- function(rpc) {
  m <- match(rpc, oops$RPC)
  if (is.na(m)) {
    NULL
  } else {
    oops$Description[[m]]
  }
}

# https://cloud.google.com/apis/design/errors
# @craigcitro says:
# "... a published description of how new APIs do errors, which includes the
# canonical error codes and http mappings. This view of errors is ... what ...
# APIs will ultimately converge on"
# https://github.com/googleapis/googleapis/blob/master/google/rpc/error_details.proto
oops <- read.csv(text = trimws(c('
  HTTP,                   RPC,  Description
   200,                  "OK", "No error."
   400,    "INVALID_ARGUMENT", "Client specified an invalid argument. Check error message and error details for more information."
   400, "FAILED_PRECONDITION", "Request can not be executed in the current system state, such as deleting a non-empty directory."
   400,        "OUT_OF_RANGE", "Client specified an invalid range."
   401,     "UNAUTHENTICATED", "Request not authenticated due to missing, invalid, or expired OAuth token."
   403,   "PERMISSION_DENIED", "Client does not have sufficient permission. This can happen because the OAuth token does not have the right scopes, the client doesn\'t have permission, or the API has not been enabled for the client project."
   404,           "NOT_FOUND", "A specified resource is not found, or the request is rejected by undisclosed reasons, such as whitelisting."
   409,             "ABORTED", "Concurrency conflict, such as read-modify-write conflict."
   409,      "ALREADY_EXISTS", "The resource that a client tried to create already exists."
   429,  "RESOURCE_EXHAUSTED", "Either out of resource quota or reaching rate limiting. The client should look for google.rpc.QuotaFailure error detail for more information."
   499,           "CANCELLED", "Request cancelled by the client."
   500,           "DATA_LOSS", "Unrecoverable data loss or data corruption. The client should report the error to the user."
   500,             "UNKNOWN", "Unknown server error. Typically a server bug."
   500,            "INTERNAL", "Internal server error. Typically a server bug."
   501,     "NOT_IMPLEMENTED", "API method not implemented by the server."
   503,         "UNAVAILABLE", "Service unavailable. Typically the server is down."
   504,   "DEADLINE_EXCEEDED", "Request deadline exceeded. This will happen only if the caller sets a deadline that is shorter than the method\'s default deadline (i.e. requested deadline is not enough for the server to process the request) and the request did not finish within the deadline."
                         ')),
                 stringsAsFactors = FALSE, strip.white = TRUE)
