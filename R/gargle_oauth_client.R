#' Create an OAuth client for Google
#'
#' @description
#' `r lifecycle::badge("experimental")`

#' A `gargle_oauth_client` consists of:

#' * A type. gargle only supports the "Desktop app" and "Web application" client
#' types. Different types are associated with different OAuth flows.

#' * A client ID and secret.
#' * Optionally, one or more redirect URIs.

#' * A name. This is really a human-facing label. Or, rather, it can be used
#' that way, but the default is just a hash. We recommend using the same name
#' here as the name used to label the client ID in the [Google Cloud Platform
#' Console](https://console.cloud.google.com).
#'
#' A `gargle_oauth_client` is an adaptation of httr's [oauth_app()] (currently)
#' and httr2's `oauth_client()` (which gargle will migrate to in the future),
#' specialized for Google APIs. This function and class is marked "experimental"
#' since the details of this transition are necessarily uncertain.

#' @param path JSON downloaded from [Google Cloud
#'   Console](https://console.cloud.google.com), containing a client id and
#'   secret, in one of the forms supported for the `txt` argument of
#'   [jsonlite::fromJSON()] (typically, a file path or JSON string).

#' @param name A label for this specific client, presumably the same name used
#'   to label it in Google Cloud Console. Unfortunately there is no way to
#'   make that true programmatically, i.e. the JSON representation does not
#'   contain this information.

#' @param id Client ID
#' @param secret Client secret

#' @param redirect_uris Where your application listens for the response from
#'   Google's authorization server. If you didn't configure this specifically
#'   when creating the client (which is only possible for clients of the "web"
#'   type), you can leave this unspecified.

#' @param type Specifies the type of OAuth client. The valid values are a subset
#'   of possible Google client types and reflect the key used to describe the
#'   client in its JSON representation:

#'   * `"installed"` is associated with a "Desktop app"
#'   * `"web"` is associated with a "Web application"

#' @return An OAuth client: An S3 list with class `gargle_oauth_client`. For
#'   backwards compatibility reasons, this currently also inherits from the httr
#'   S3 class `oauth_app`, but that is a temporary measure. An instance of
#'   `gargle_oauth_client` stores more information than httr's `oauth_app`, such
#'   as the OAuth client's type ("web" or "installed").

#'
#'   There are some redundant fields in this object during the httr-to-httr2
#'   transition period. The legacy fields `appname` and `key` repeat the
#'   information in the future-facing fields `name` and (client) `id`. Prefer
#'   `name` and `id` to `appname` and `key` in downstream code. Prefer the
#'   constructors `gargle_oauth_client_from_json()` and `gargle_oauth_client()`
#'   to [httr::oauth_app()] and [oauth_app_from_json()].

#' @export
#'
#' @examples
#' \dontrun{
#' gargle_oauth_client_from_json(
#'   path = "/path/to/the/JSON/you/downloaded/from/gcp/console.json",
#'   name = "my-nifty-oauth-client"
#' )
#' }
#'
#' gargle_oauth_client(
#'   id = "some_long_id",
#'   secret = "ssshhhhh_its_a_secret",
#'   name = "my-nifty-oauth-client"
#' )
gargle_oauth_client_from_json <- function(path, name = NULL) {
  check_string(path)
  if (!is.null(name)) {
    check_string(name)
  }

  json <- jsonlite::fromJSON(path, simplifyVector = FALSE)
  if (length(json) != 1) {
    gargle_abort(c(
      "JSON has an unexpected form",
      "i" = "Are you sure this is the JSON downloaded for an OAuth client?",
      "i" = "It is easy to confuse the JSON for an OAuth client and a service account."
    ))
  }

  info <- json[[1]]

  gargle_oauth_client(
    id = info$client_id,
    secret = info$client_secret,
    redirect_uris = info$redirect_uris,
    type = names(json),
    name = name %||% glue("{info$project_id}_{hash(info$project_id)}")
  )
}


#' @export
#' @rdname gargle_oauth_client_from_json
gargle_oauth_client <- function(id,
                                secret,
                                redirect_uris = NULL,
                                type = c("installed", "web"),
                                name = hash(id)) {
  check_string(id)
  check_string(secret)
  check_string(name)
  type <- arg_match(type)

  if (!is.null(redirect_uris)) {
    # httr appears to assume that an OAuth app can have exactly 1 redirect_uri
    # (gargle has never used the `redirect_uri` field of httr::oauth_app)
    # httr2 seems to think it can usually construct the redirect_uri?
    # I think I have to accept multiple URIs, because that can be true in the
    # downloaded JSON
    # we'll just have to decide which one to use downstream, based on context
    redirect_uris <- unlist(redirect_uris)
    check_character(redirect_uris)
  }

  if (type == "web" && length(redirect_uris) == 0) {
    gargle_abort('
      A "web" type OAuth client must have one or more {.field redirect_uris}.')
  }

  structure(
    list(
      name = name,
      id = id,
      secret = secret,
      type = type,
      redirect_uris = redirect_uris,
      # needed for backwards compatibility; I need this class to quack like a
      # specialization of httr's oauth_app class, for now
      appname = name,
      key = id
    ),
    class = c("gargle_oauth_client", "oauth_app")
    # in the future, maybe:
    # class = c("gargle_oauth_client", "httr2_oauth_client")
  )
}
# adapted from httr2 ----
#' @export
print.gargle_oauth_client <- function(x, ...) {
  # this print method needs work, but not a high priority atm
  cli::cli_text(cli::style_bold("<gargle_oauth_client>"))
  redacted <- list_redact(compact(x), "secret")
  # quick fix for multiple URIs case
  if (length(redacted$redirect_uris) > 0) {
    redacted$redirect_uris <- commapse(redacted$redirect_uris)
  }
  # hide redundant fields that exist only for backwards compatibility with
  # httr's oauth_app
  redacted$appname <- redacted$key <- NULL
  cli::cli_dl(redacted)
  invisible(x)
}

list_redact <- function(x, names, case_sensitive = TRUE) {
  if (case_sensitive) {
    i <- match(names, names(x))
  } else {
    i <- match(tolower(names), tolower(names(x)))
  }
  x[i] <- cli::col_grey("<REDACTED>")
  x
}

#' OAuth client for demonstration purposes
#'
#' @description

#' Invisibly returns an instance of
#' [`gargle_oauth_client`][gargle_oauth_client()] that can be used to test drive
#' gargle before obtaining your own client ID and secret. This OAuth client may
#' be deleted or rotated at any time. There are no guarantees about which APIs
#' are enabled. DO NOT USE THIS IN A PACKAGE or for anything other than
#' interactive, small-scale experimentation.
#'
#' You can get your own OAuth client ID and secret, without these limitations.
#' See the `vignette("get-api-credentials")` for more details.
#'
#' @inheritParams gargle_oauth_client_from_json
#'
#' @return An OAuth client, produced by [gargle_oauth_client()], invisibly.
#' @export
#' @keywords internal
#' @examples
#' \dontrun{
#' gargle_client()
#' }
gargle_client <- function(type = NULL) {
  if (is.null(type) || is.na(type)) {
    type <- gargle_oauth_client_type()
  }
  check_string(type)
  type <- arg_match(type, values = c("installed", "web"))

  switch(
    type,
    web       = goc_web(),
    installed = goc_installed()
  )
}

#' @export
#' @keywords internal
#' @rdname internal-assets
tidyverse_client <- function(type = NULL) {
  check_permitted_package(caller_env())

  if (is.null(type) || is.na(type)) {
    type <- gargle_oauth_client_type()
  }
  check_string(type)
  type <- arg_match(type, values = c("installed", "web"))

  switch(
    type,
    web       = toc_web(),
    installed = toc_installed()
  )
}

# deprecated functions ----

#' Create an OAuth app from JSON
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'

#' `oauth_app_from_json()` is being replaced with
#' [`gargle_oauth_client_from_json()`], in light of the new
#' `gargle_oauth_client` class. Now `oauth_app_from_json()` potentially warns
#' about this deprecation and immediately passes its inputs through to
#' [`gargle_oauth_client_from_json()`].
#'
#' `gargle_app()` is being replaced with [gargle_client()].
#'
#' @inheritParams gargle_oauth_client
#' @inheritParams httr::oauth_app
#' @keywords internal
#' @export
oauth_app_from_json <- function(path,
                                appname = NULL) {
  lifecycle::deprecate_soft(
    "1.3.0", "oauth_app_from_json()", "gargle_oauth_client_from_json()"
  )
  gargle_oauth_client_from_json(path = path, name = appname)
}

#' @export
#' @keywords internal
#' @rdname internal-assets
tidyverse_app <- function() {
  lifecycle::deprecate_soft(
    "1.3.0", "tidyverse_app()", "tidyverse_client()"
  )
  tidyverse_client()
}

#' @export
#' @keywords internal
#' @rdname oauth_app_from_json
gargle_app <- function() {
  lifecycle::deprecate_soft(
    "1.3.0", "gargle_app()", "gargle_client()"
  )
  gargle_client()
}
