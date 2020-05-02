#' Get a token for Google Compute Engine
#'
#' Uses the metadata service available on GCE VMs to fetch an access token.
#'
#' @inheritParams token_fetch
#' @param service_account Name of the GCE service account to use.
#'
#' @seealso <https://cloud.google.com/compute/docs/storing-retrieving-metadata>
#'
#' @return A [GceToken()] or `NULL`.
#' @family credential functions
#' @export
#' @examples
#' \dontrun{
#' credentials_gce()
#' }
credentials_gce <- function(scopes = "https://www.googleapis.com/auth/cloud-platform",
                            service_account = "default", ...) {
  ui_line("trying credentials_gce()")
  if (!detect_gce()) {
    ui_line("Error in credentials_gce(): failed to retrieve GCE metadata")
    return(NULL)
  }
  if (is.null(scopes)) {
    ui_line("Error in credentials_gce(): `scopes` is `NULL`")
    return(NULL)
  }
  instance_scopes <- get_instance_scopes(service_account = service_account)
  # We add a special case for the cloud-platform -> bigquery scope implication.
  if ("https://www.googleapis.com/auth/cloud-platform" %in% instance_scopes) {
    instance_scopes <- c(
      "https://www.googleapis.com/auth/bigquery",
      instance_scopes
    )
  }
  if (!all(scopes %in% instance_scopes)) {
    ui_line("Error in credentials_gce(): `scopes` are unacceptable")
    ui_line(c("Acceptable scopes: ", instance_scopes))
    ui_line(c("Actual scopes: ", scopes))
    return(NULL)
  }

  gce_token <- fetch_access_token(scopes, service_account = service_account)

  params <- list(
    as_header = TRUE,
    scope = scopes,
    service_account = service_account
  )
  token <- GceToken$new(
    credentials = gce_token$access_token,
    params = params,
    # The underlying Token2 class appears to *require* an endpoint and an app,
    # though it doesn't use them for anything in this case.
    endpoint = httr::oauth_endpoints("google"),
    app = httr::oauth_app("google", key = "KEY", secret = "SECRET")
  )
  token$refresh()
  if (is.null(token$credentials$access_token) ||
      !nzchar(token$credentials$access_token)) {
    ui_line("Error in credentials_gce(): failed to get access_token")
    NULL
  } else {
    token
  }
}

#' Token for use on Google Compute Engine instances
#'
#' This class uses the metadata service available on GCE VMs to fetch access
#' tokens. Not intended for direct use. See [credentials_gce()] instead.
#'
#' @param ... Not used.
#'
#' @export
GceToken <- R6::R6Class("GceToken", inherit = httr::Token2.0, list(
  #' @description Print token
  print = function(...) {
    cat("<GceToken>")
  },
  #' @description Placeholder implementation of required method
  init_credentials = function() {
    self$credentials <- list(access_token = NULL)
  },
  #' @description Placeholder implementation of required method
  cache = function(...) {},
  #' @description Placeholder implementation of required method
  load_from_cache = function(...) {},
  #' @description Placeholder implementation of required method
  can_refresh = function() {
    TRUE
  },
  #' @description Refresh a GCE token
  refresh = function() {
    # The access_token can only include the token itself, not the expiration and
    # type. Otherwise, the httr code will create extra header lines that bust
    # the POST request:
    gce_token <- fetch_access_token(
      self$params$scope,
      service_account = self$params$service_account
    )
    self$credentials <- list(access_token = NULL)
    self$credentials$access_token <- gce_token$access_token
  },
  #' @description Placeholder implementation of required method
  revoke = function() {}
))

gce_metadata_url <- function() {
  use_ip <- getOption("gargle.gce.use_ip", FALSE)
  root_url <- Sys.getenv("GCE_METADATA_URL", "metadata.google.internal")
  if (use_ip) {
    root_url <- Sys.getenv("GCE_METADATA_IP", "169.254.169.254")
  }
  paste0("http://", root_url, "/")
}

gce_metadata_request <- function(path, stop_on_error = TRUE) {
  root_url <- gce_metadata_url()
  # TODO(craigcitro): Add options to ignore proxies.
  if (grepl("^/", path)) {
    path <- substring(path, 2)
  }
  url <- paste0(root_url, "computeMetadata/v1/", path)
  ui_line("Requesting GCE metadata from: ", url)
  timeout <- getOption("gargle.gce.timeout", default = 0.8)
  response <- try({
    httr::with_config(httr::timeout(timeout), {
      httr::GET(url, httr::add_headers("Metadata-Flavor" = "Google"))
    })
  }, silent = TRUE)

  if (stop_on_error) {
    if (inherits(response, "try-error")) {
      stop(paste0("Error fetching GCE metadata: ", attr(response, "condition")$message))
    } else if (httr::http_error(response)) {
      stop(paste0("Error fetching GCE metadata: ", httr::http_status(response)$message))
    }
    if (response$headers$`metadata-flavor` != "Google") {
      stop(paste0("Error fetching GCE metadata: missing/invalid metadata-flavor header"))
    }
  } else {
    if (inherits(response, "try-error")) {
      ui_line("Error fetching GCE metadata: ", attr(response, "condition")$message)
    } else if (httr::http_error(response)) {
      ui_line("Error fetching GCE metadata: ", httr::http_status(response)$message)
    }
    if (response$headers$`metadata-flavor` != "Google") {
      ui_line("Error fetching GCE metadata: missing/invalid metadata-flavor header")
    }
  }
  response
}

detect_gce <- function() {
  response <- gce_metadata_request("", stop_on_error = FALSE)
  !(inherits(response, "try-error") %||% httr::http_error(response))
}

# List all service accounts available on this GCE instance.
#
# @return A list of service account names.
list_service_accounts <- function() {
  accounts <- gce_metadata_request("instance/service-accounts")
  ct <- httr::content(accounts, as = "text", encoding = "utf8")
  strsplit(ct, split = "/\n", fixed = TRUE)[[1]]
}

get_instance_scopes <- function(service_account) {
  path <- glue("instance/service-accounts/{service_account}/scopes")
  scopes <- gce_metadata_request(path)
  ct <- httr::content(scopes, as = "text", encoding = "utf8")
  strsplit(ct, split = "\n", fixed = TRUE)[[1]]
}

fetch_access_token <- function(scopes, service_account) {
  path <- glue("instance/service-accounts/{service_account}/token")
  response <- gce_metadata_request(path)
  httr::content(response, as = "parsed", type = "application/json")
}
