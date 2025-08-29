#' Process a Google API response
#'
#' @description
#' `response_process()` is intended primarily for internal use in client
#' packages that provide high-level wrappers for users. Typically applied as the
#' final step in this sequence of calls:
#'   * Request prepared with [request_build()].
#'   * Request made with [request_make()].
#'   * Response processed with `response_process()`.
#'
#' All that's needed for a successful request is to parse the JSON extracted via
#' `httr::content()`. Therefore, the main point of `response_process()` is to
#' handle less happy outcomes:
#'   * Status codes in the 400s (client error) and 500s (server error). The
#'     structure of the error payload varies across Google APIs and we try to
#'     create a useful message for all variants we know about.
#'   * Non-JSON content type, such as HTML.
#'   * Status code in the 100s (information) or 300s (redirection). These are
#'     unexpected.
#'
#' If `process_response()` results in an error, a redacted version of the `resp`
#' input is returned in the condition (auth tokens are removed).
#'
#' @details
#' When `remember = TRUE` (the default), gargle stores the most recently seen
#' response internally, for *post hoc* examination. The stored response is
#' literally just the most recent `resp` input, but with auth tokens redacted.
#' It can be accessed via the unexported function
#' `gargle:::gargle_last_response()`. A companion function
#' `gargle:::gargle_last_content()` returns the content of the last response,
#' which is probably the most useful form for *post mortem* analysis.
#'
#' The `response_as_json()` helper is exported only as an aid to maintainers who
#' wish to use their own `error_message` function, instead of gargle's built-in
#' `gargle_error_message()`. When implementing a custom `error_message`
#' function, call `response_as_json()` immediately on the input in order to
#' inherit gargle's handling of non-JSON input.
#'
#' @param resp Object of class `response` from [httr].
#' @param error_message Function that produces an informative error message from
#'   the primary input, `resp`. It must return a character vector.
#' @param remember Whether to remember the most recently processed response.
#' @inheritParams rlang::abort
#'
#' @return The content of the request, as a list. An HTTP status code of 204 (No
#'   content) is a special case returning `TRUE`.
#' @family requests and responses
#' @export
#' @examples
#' \dontrun{
#' # get an OAuth2 token with 'userinfo.email' scope
#' token <- token_fetch(scopes = "https://www.googleapis.com/auth/userinfo.email")
#'
#' # see the email associated with this token
#' req <- gargle::request_build(
#'   method = "GET",
#'   path = "v1/userinfo",
#'   token = token,
#'   base_url = "https://openidconnect.googleapis.com"
#' )
#' resp <- gargle::request_make(req)
#' response_process(resp)
#'
#' # make a bad request (this token has incorrect scope)
#' req <- gargle::request_build(
#'   method = "GET",
#'   path = "fitness/v1/users/{userId}/dataSources",
#'   token = token,
#'   params = list(userId = 12345)
#' )
#' resp <- gargle::request_make(req)
#' response_process(resp)
#' }
response_process <- function(
  resp,
  error_message = gargle_error_message,
  remember = TRUE,
  call = caller_env()
) {
  if (remember) {
    gargle_env$last_response <- redact_response(resp)
  }
  code <- httr::status_code(resp)

  if (code >= 200 && code < 300) {
    if (code == 204) {
      # HTTP status: No content
      TRUE
    } else {
      response_as_json(resp, call = call)
    }
  } else {
    gargle_abort_request_failed(
      error_message(resp, call = call),
      resp,
      call = call
    )
  }
}

#' @export
#' @rdname response_process
response_as_json <- function(resp, call = caller_env()) {
  check_for_json(resp, call = call)

  content <- httr::content(resp, type = "raw")
  content <- rawToChar(content)
  Encoding(content) <- "UTF-8"
  jsonlite::fromJSON(content, simplifyVector = FALSE)
}

check_for_json <- function(resp, call = caller_env()) {
  type <- httr::http_type(resp)
  if (grepl("^application/json", type)) {
    return(invisible(resp))
  }

  gargle_abort_request_failed(
    "Expected content type {.field application/json}, not {.field {type}}.",
    call = call,
    resp = resp
  )
}

gargle_abort_request_failed <- function(
  message,
  resp,
  .envir = caller_env(),
  call = caller_env()
) {
  gargle_abort(
    message,
    class = c(
      "gargle_error_request_failed",
      glue("http_error_{httr::status_code(resp)}")
    ),
    .envir = .envir,
    call = call,
    resp = redact_response(resp)
  )
}

#' @export
#' @rdname response_process
gargle_error_message <- function(resp, call = caller_env()) {
  type <- httr::http_type(resp)
  if (grepl("^text/html", type)) {
    return(gargle_html_error_message(resp))
  }

  content <- response_as_json(resp, call = call)
  error <- content[["error"]]

  # Handle variety of error messages returned by different google APIs

  # It would be fussy to employ cli styling here, as we would need to
  # pre-interpolate data from `resp`. So we either don't style or we use simple
  # "no color" styles.

  if (identical(names(content), c("error", "error_description"))) {
    # seen when calling userinfo endpoint with an access token obtained via
    # workload identity federation
    message <- c(
      httr::http_status(resp)$message,
      "*" = content$error,
      "*" = content$error_description
    )
    return(message)
  }

  if (is.null(error)) {
    # developed from test fixture from tokeninfo endpoint
    message <- c(
      httr::http_status(resp)$message,
      "*" = content$error_description
    )
    return(message)
  }
  errors <- error[["errors"]]

  if (is.null(errors)) {
    # developed from test fixtures from "sheets.spreadsheets.get" endpoint
    status <- httr::http_status(resp)

    message <- c(
      glue("{status$category}: ({error$code}) {error$status}"),
      "*" = rpc_description(error$status),
      "*" = error$message
    )

    error_details <- error$details
    if (is.null(error_details)) {
      return(message)
    }

    # https://github.com/googleapis/googleapis/blob/master/google/rpc/error_details.proto
    # Look for a localized error message
    # Below, we display it alongside the main message, if it's not identical to
    # the primary message
    # Remove the localized message from error details, regardless
    # Currently ignoring the locale info, because it seems hard to reliably
    # compare to something returned by Sys.getlocale()
    types <- map_chr(error_details, function(x) x[["@type"]])
    lm_index <- match("type.googleapis.com/google.rpc.LocalizedMessage", types)
    localized_message <- error_details[[lm_index]][["message"]]
    if (!is.na(lm_index)) {
      error_details <- error_details[-lm_index]
    }

    if (
      !is.null(localized_message) &&
        !identical(localized_message, error$message)
    ) {
      message <- c(message, "*" = localized_message)
    }

    message <- c(
      message,
      "",
      reveal_details(error_details)
    )
    return(message)
  }

  # developed from
  # - test fixture from "drive.files.get" endpoint
  # - response_process() example of under/mis-scoped token
  errors <- unlist(errors)
  message <- c(
    httr::http_status(resp)$message,
    error$message,
    error$status,
    bulletize(
      # format() has no effect when processed by cli; bring that back later?
      # glue("{format(names(errors), justify = 'right')}: {errors}"),
      glue("{names(errors)}: {errors}"),
      n_show = 10
    )
  )
  message
}

redact_response <- function(resp) {
  resp$request$auth_token <- "<REDACTED>"
  resp$request$headers["Authorization"] <- "<REDACTED>"
  resp$handle <- NULL
  resp
}

rpc_description <- function(rpc) {
  m <- match(rpc, oops$RPC)
  if (is_na(m)) {
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
oops <- read.csv(
  text = trimws(c(
    '
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
                         '
  )),
  stringsAsFactors = FALSE,
  strip.white = TRUE
)

# https://github.com/googleapis/googleapis/blob/master/google/rpc/error_details.proto
reveal_details <- function(details) {
  c("Error details:", unlist(lapply(details, reveal_detail)))
}

# https://github.com/googleapis/googleapis/blob/master/google/rpc/rpc_publish.yaml
# https://github.com/googleapis/googleapis/blob/master/google/rpc/error_details.proto
reveal_detail <- function(x) {
  type <- sub("^type.googleapis.com/", "", x$`@type`)

  rpc_bad_request <- function(e) {
    f <- function(x) {
      c(
        "*" = glue("Field: {x$field}"),
        " " = glue("Description: {x$description}")
      )
    }
    bullets <- unlist(map(e[["fieldViolations"]], f))
    c("Field violations", bullets)
  }
  rpc_help <- function(e) {
    f <- function(x) {
      c(
        "*" = glue("Description: {x$description}"),
        " " = glue("URL: {x$url}")
      )
    }
    bullets <- unlist(map(e[["links"]], f))
    c("Links", bullets)
  }
  rpc_error_info <- function(e) {
    e <- unlist(e)
    e <- e[names(e) != "@type"]
    bulletize(glue_data(as.list(e), "{names(e)}: {e}"), n_show = 10)
  }

  switch(
    type,
    "google.rpc.BadRequest" = rpc_bad_request(x),
    "google.rpc.Help" = rpc_help(x),
    "google.rpc.ErrorInfo" = rpc_error_info(x),
    # must be an unimplemented type, such as RetryInfo, QuotaFailure, etc.
    bulletize(
      map_chr(
        c(
          "Error details of type '{type}' may not be fully revealed.",
          "Workaround: use `gargle:::gargle_last_response()` or \\
           `gargle:::gargle_last_content()` to inspect error payload \\
           yourself.",
          "Consider opening an issue at \\
           <https://github.com/r-lib/gargle/issues.>"
        ),
        # https://github.com/tidyverse/googlesheets4/issues/317
        # this needs to be an anonymous function (as opposed to naked `glue`)
        # in order to capture the value of `type`
        # good write-up in https://stackoverflow.com/a/75247635
        function(x) glue(x)
      )
    )
  )
}

gargle_html_error_message <- function(resp) {
  stopifnot(httr::http_type(resp) == "text/html")

  content <- httr::content(resp, as = "text")
  tmp <- tempfile("gargle-unexpected-html-error-", fileext = ".html")
  writeLines(content, tmp)
  browse_hint <- glue('browseURL("{tmp}")')

  # pre-interpolate, since `tmp` and `browse_hint` are only known here.
  c(
    httr::http_status(resp)$message,
    "x" = "Expected content type {.field application/json}, not \\
           {.field text/html}.",
    "i" = gargle_map_cli(tmp, "See {.file <<x>>} for the html error content."),
    "i" = gargle_map_cli(
      browse_hint,
      "Or execute {.code <<x>>} to view it in your browser."
    )
  )
}
