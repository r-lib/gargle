#' GceToken is a token for use only on Google Compute Engine instances.
#'
#' This class uses the metadata service available on GCE VMs to fetch access tokens.
#' @export
GceToken <- R6::R6Class("GceToken", inherit = httr::Token2.0, list(
  print = function(...) {
    cat("<GceToken>")
  },
  init_credentials = function() {
    self$credentials <- list(access_token = NULL)
  },
  cache = function(...) {},
  load_from_cache = function(...) {},
  can_refresh = function() {
    TRUE
  },
  refresh = function() {
    self$credentials$access_token <- fetch_access_token(self$params$scope)
  },
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
  }
  response
}

detect_gce <- function() {
  response <- gce_metadata_request("", stop_on_error = FALSE)
  !(inherits(response, "try-error") %||% httr::http_error(response))
}

#' List all service accounts available on this GCE instance.
#'
#' @return A list of service account names.
list_service_accounts <- function() {
  accounts <- gce_metadata_request("instance/service-accounts")
  ct <- httr::content(accounts, as = "text", encoding = "utf8")
  strsplit(ct, split = "/\n", fixed = TRUE)[[1]]
}

get_instance_scopes <- function(service_account) {
  path <- paste0("instance/service-accounts/", service_account, "scopes")
  scopes <- gce_metadata_request(path)
  ct <- httr::content(scopes, as = "text")
  strsplit(ct, split = "\n", fixed = TRUE)[[1]]
}

fetch_access_token <- function(scopes, service_account, ...) {
  path <- paste0("instance/service-accounts/", service_account, "/token")
  response <- gce_metadata_request(path)
  httr::content(response, as = "parsed", "application/json")
}

#' Create a token for use on Google Compute Engine for the given scopes, if possible.
#'
#' @param scopes List of scopes required for the returned token.
#' @param service_account Name of the GCE service account to use (defaults to `default`)
#' @param ... Additional arguments passed to all credentials functions.
#' @return A [GceToken()] or `NULL`.
#' @export
credentials_gce <- function(scopes, service_account = "default", ...) {
  "!DEBUG trying credentials_gce"
  if (!detect_gce()) {
    return(NULL)
  }
  instance_scopes <- get_instance_scopes(service_account = service_account)
  # We add a special case for the cloud-platform -> bigquery scope implication.
  if ("https://www.googleapis.com/auth/cloud-platform" %in% instance_scopes) {
    instance_scopes <- c("https://www.googleapis.com/auth/bigquery", instance_scopes)
  }
  if (!all(scopes %in% instance_scopes)) {
    return(NULL)
  }
  credentials <- fetch_access_token(scopes, service_account = service_account)
  params <- list(
    as_header = TRUE,
    scope = scopes,
    service_account = service_account
  )
  token <- GceToken$new(credentials = credentials, params = params)
  token$refresh()
  if (is.null(token$credentials$access_token) ||
    !nzchar(token$credentials$access_token)) {
    NULL
  } else {
    token
  }
}
