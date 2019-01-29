#' Build a Google API request
#'
#' Intended primarily for internal use in client packages that provide
#' high-level wrappers for users.
#'
#' @param endpoint List of information about the target endpoint. Presumably
#'   prepared from the [Discovery
#'   Document](https://developers.google.com/discovery/v1/getting_started#background-resources)
#'   for the target API.
#' @param params Named list. Values destined for URL substitution, the query,
#'   or, for `request_develop()` only, the body.
#' @param base_url Character.
#' @param method Character. An HTTP verb, such as `GET` or `POST`.
#' @param path Character. Path to the resource, not including API's `base_url`.
#'   Examples: `drive/v3/about` or `drive/v3/files/{fileId}`. If `path` includes
#'   variables inside curly brackets, these are substituted using named
#'   parameters found in `params` by `request_build()`.
#' @param body List. Values to send in the API request body.
#' @param key API key. Needed for requests that don't contain a token. For more,
#'   see Google's document [Credentials, access, security, and
#'   identity](https://support.google.com/googleapi/answer/6158857?hl=en&ref_topic=7013279).
#'   A key can be passed as a named component of `params`, but note that the
#'   formal argument `key` will clobber it, if non-`NULL`.
#' @param token Token, ready for inclusion in a request, i.e. prepared with
#'   [httr::config()].
#'
#' @section `request_develop()`:
#'
#' Combines user input (`params`) with information about an API endpoint.
#' `endpoint` should contain these components:
#'   - `path`: See documentation for argument.
#'   - `method`: See documentation for argument.
#'   - `parameters`: Compared with `params` supplied by user. An error is
#'      thrown if user-supplied `params` aren't named in
#'      `endpoint$parameters` or if user fails to supply all required
#'      parameters. In the return value, body parameters are separated from
#'      those destined for path substitution or the query.
#'
#' The return value is typically used as input to `request_build()`.
#'
#' @section `request_build()`:
#'
#' Builds a request, in a purely mechanical sense. This function does nothing
#' specific to any particular Google API or endpoint.
#'   - Use with the output of `request_develop()` or with hand-crafted input.
#'   - `params` are used for variable substitution in `path`. Unused `params`
#'     become the query.
#'   - Adds an API key to the query iff `token = NULL` and removes the API key
#'   otherwise. Client packages should generally pass their own API key in, but
#'   note that [gargle_api_key()] is available for small-scale experimentation.
#'
#' See `googledrive::generate_request()` for an example of usage in a client
#' package. googledrive has an internal list of selected endpoints, derived from
#' the [Drive API Discovery
#' Document](https://www.googleapis.com/discovery/v1/apis/drive/v3/rest),
#' exposed via `googledrive::drive_endpoints()`. An element from such a list is
#' the expected input for `endpoint`. `googledrive::generate_request()` is a
#' wrapper around `request_develop()` and `request_build()` that inserts a
#' googledrive-managed API key and some logic about Team Drives. All user-facing
#' functions use `googledrive::generate_request()` under the hood.
#'
#' @return
#' `request_develop()`: `list()` with components `method`, `path`, `params`,
#' `body`, and `base_url`.
#'
#' `request_build()`: `list()` with components `method`, `path`
#' (post-substitution), `query` (the input `params` not used in URL
#' substitution), `body`, `token`, `url` (the full URL, post-substitution,
#' including the query).
#'
#' @export
#' @family requests and responses
#' @examples
#' \dontrun{
#' ## Example with a prepared endpoint
#' ept <- googledrive::drive_endpoints("drive.files.update")[[1]]
#' req <- request_develop(
#'   ept,
#'   params = list(
#'     fileId = "abc",
#'     addParents = "123",
#'     description = "Exciting File"
#'   )
#' )
#' req
#' 
#' req <- request_build(
#'   method = req$method,
#'   path = req$path,
#'   params = req$params,
#'   body = req$body,
#'   token = "PRETEND_I_AM_A_TOKEN"
#' )
#' req
#' 
#' ## Example with no previous knowledge of the endpoint
#' ## List a file's comments
#' ## https://developers.google.com/drive/v3/reference/comments/list
#' req <- request_build(
#'   method = "GET",
#'   path = "drive/v3/files/{fileId}/comments",
#'   params = list(
#'     fileId = "your-file-id-goes-here",
#'     fields = "*"
#'   ),
#'   token = "PRETEND_I_AM_A_TOKEN"
#' )
#' req
#' }
request_develop <- function(endpoint,
                            params = list(),
                            base_url = "https://www.googleapis.com") {
  check_params(params, endpoint$parameters)
  body_params <- Filter(function(x) x$location == "body", endpoint$parameters)
  params <- partition_params(params, names(body_params))
  list(
    method = endpoint$method,
    path = endpoint$path,
    params = params$unmatched,
    body = params$matched,
    base_url = base_url
  )
}

#' @rdname request_develop
#' @export
request_build <- function(method = "GET",
                          path = "",
                          params = list(),
                          body = list(),
                          token = NULL,
                          key = NULL,
                          base_url = "https://www.googleapis.com") {
  params <- partition_params(params, extract_path_names(path))

  ## send a token or a key, but never both
  params$unmatched$key <- if (is.null(token)) {
    key %||% params$unmatched$key
  } else {
    NULL
  }

  out <- list(
    method = method,
    url = httr::modify_url(
      url = base_url,
      path = glue_data(params$matched, path),
      query = params$unmatched
    ),
    body = body,
    token = token
  )
  out
}

## check params provided by user against spec
##   * error if required params are missing
##   * error for unknown params
check_params <- function(provided, spec) {
  required <- Filter(function(x) isTRUE(x$required), spec)
  missing <- setdiff(names(required), names(provided))
  if (length(missing)) {
    stop_collapse(
      c("Required parameter(s) are missing:", missing)
    )
  }

  unknown <- setdiff(names(provided), names(spec))
  if (length(unknown)) {
    stop_collapse(
      c("These parameters are not recognized for this endpoint:", unknown)
    )
  }

  invisible(provided)
}

## partition a parameter list into two parts, based on names:
##   * unmatched
##   * matched
##
## example input:
# partition_params(
#   list(a = "a", b = "b", c = "c", d = "d"),
#   nms_to_match = c("b", "c")
# )
## example output:
# list(
#   unmatched = list(a = "a", d = "d"),
#   matched = list(b = "b", c = "c")
# )
partition_params <- function(input, nms_to_match) {
  out <- list(
    unmatched = input,
    matched = list()
  )
  if (length(nms_to_match) && length(input)) {
    m <- names(out$unmatched) %in% nms_to_match
    out$matched <- out$unmatched[m]
    out$unmatched <- out$unmatched[!m]
  }
  out
}

##  input: /v4/spreadsheets/{spreadsheetId}/sheets/{sheetId}:copyTo
## output: spreadsheetId, sheetId
extract_path_names <- function(path) {
  m <- gregexpr("\\{[^/]*\\}", path)
  path_param_names <- regmatches(path, m)[[1]]
  gsub("[\\{\\}]", "", path_param_names)
}
