#' Get a token from the Google metadata server
#'
#' @description
#'
#' If your code is running on Google Cloud, we can often obtain a token for an
#' attached service account directly from a metadata server. This is more secure
#' than working with an explicit a service account key, as
#' [credentials_service_account()] does, and is the preferred method of auth for
#' workloads running on Google Cloud.

#'
#' The most straightforward scenario is when you are working in a VM on Google
#' Compute Engine and it's OK to use the default service account. This should
#' "just work" automatically.

#'
#' `credentials_gce()` supports other use cases (such as GKE Workload Identity),
#' but may require some explicit setup, such as:

#' * Create a service account, grant it appropriate scopes(s) and IAM roles,
#' attach it to the target resource. This prep work happens outside of R, e.g.,
#' in the Google Cloud Console. On the R side, provide the email address of this
#' appropriately configured service account via `service_account`.

#' * Specify details for constructing the root URL of the metadata service:
#'   - The logical option `"gargle.gce.use_ip"`. If undefined, this defaults to
#'     `FALSE`.
#'   - The environment variable `GCE_METADATA_URL` is consulted when
#'     `"gargle.gce.use_ip"` is `FALSE`. If undefined, the default is
#'     `metadata.google.internal`.
#'   - The environment variable `GCE_METADATA_IP` is consulted when
#'     `"gargle.gce.use_ip"` is `TRUE`. If undefined, the default is
#'     `169.254.169.254`.

#'
#' * Change (presumably increase) the timeout for requests to the metadata
#' server via the `"gargle.gce.timeout"` global option. This timeout is given in
#' seconds and is set to a value (strategy, really) that often works well in
#' practice. However, in some cases it may be necessary to increase the timeout
#' with code such as:
#' ``` r
#' options(gargle.gce.timeout = 3)
#' ```

#' For details on specific use cases, such as Google Kubernetes Engine (GKE),
#' see `vignette("non-interactive-auth")`.
#'
#' @inheritParams token_fetch
#' @param service_account Name of the GCE service account to use.
#'
#' @seealso A related auth flow that can be used on certain non-Google cloud
#' providers is workload identity federation, which is implemented in
#' [credentials_external_account()].
#'
#' <https://docs.cloud.google.com/compute/docs/access/service-accounts>
#'
#' <https://docs.cloud.google.com/iam/docs/best-practices-service-accounts>
#'
#' How to attach a service account to a resource:
#' <https://cloud.google.com/iam/docs/impersonating-service-accounts#attaching-to-resources>
#'
#' <https://docs.cloud.google.com/kubernetes-engine/docs/concepts/workload-identity>
#'
#' <https://docs.cloud.google.com/kubernetes-engine/docs/how-to/workload-identity>
#'
#' <https://docs.cloud.google.com/compute/docs/metadata/overview>
#'
#' @return A [GceToken()] or `NULL`.
#' @family credential functions
#' @export
#' @examples
#' \dontrun{
#' credentials_gce()
#' }
credentials_gce <- function(
  scopes = "https://www.googleapis.com/auth/cloud-platform",
  service_account = "default",
  ...
) {
  gargle_debug("Trying {.fun credentials_gce} ...")
  if (!is_gce()) {
    gargle_debug(c("x" = "We don't seem to be on GCE."))
    return(NULL)
  }

  scopes <- scopes %||% "https://www.googleapis.com/auth/cloud-platform"
  requested_scopes <- normalize_scopes(scopes)
  dat <- gce_instance_service_accounts()
  service_account_details <- as.list(dat[dat$name == service_account, ])

  account_scopes <- service_account_details$scopes
  account_scopes <- normalize_scopes(strsplit(account_scopes, split = ",")[[1]])
  missing <- setdiff(requested_scopes, account_scopes)
  if (length(missing) > 0) {
    gargle_debug(c(
      "!" = "{cli::qty(length(missing))}{?This/These} requested \\
             scope{?s} {?is/are} not among the scopes for the \\
             {.val {service_account}} service account:",
      bulletize(missing, bullet = "x"),
      "i" = "If there are problems downstream, this might be the root cause."
    ))
  }

  token <- gce_access_token(scopes, service_account = service_account)

  if (
    is.null(token$credentials$access_token) ||
      !nzchar(token$credentials$access_token)
  ) {
    NULL
  } else {
    gargle_debug(
      "GCE service account email: {.email {service_account_details$email}}"
    )
    gargle_debug(
      "GCE service account name: {.val {token$params$service_account}}"
    )
    gargle_debug(
      "GCE access token scopes: {.val {commapse(base_scope(token$params$scope))}}"
    )
    token
  }
}

#' Fetch access token for a service account on GCE
#'
#' @inheritParams credentials_gce
#'
#' @keywords internal
#' @export
gce_access_token <- function(
  scopes = "https://www.googleapis.com/auth/cloud-platform",
  service_account = "default"
) {
  params <- list(
    scope = scopes,
    service_account = service_account,
    as_header = TRUE
  )
  GceToken$new(
    params = params
  )
}

#' Token for use on Google Compute Engine instances
#'
#' This class uses the metadata service available on GCE VMs to fetch access
#' tokens. Not intended for direct use. See [credentials_gce()] instead.
#'
#' @param ... Not used.
#'
#' @keywords internal
#' @export
GceToken <- R6::R6Class(
  "GceToken",
  inherit = httr::Token2.0,
  list(
    #' @description Get an access for a GCE service account.
    #' @param params A list of parameters for `fetch_gce_access_token()`.
    #' @return A GceToken.
    initialize = function(params) {
      gargle_debug("GceToken initialize")
      self$params <- params
      self$init_credentials()
    },
    #' @description Request an access token.
    init_credentials = function() {
      gargle_debug("GceToken init_credentials")
      token <- fetch_gce_access_token(
        self$params$scope,
        service_account = self$params$service_account
      )

      # find out the scopes actually obtained
      # https://www.googleapis.com/oauth2/v3/tokeninfo
      req <- request_build(
        method = "GET",
        path = "oauth2/v3/tokeninfo",
        params = list(access_token = token$access_token),
        base_url = "https://www.googleapis.com"
      )
      resp <- request_make(req)
      info <- response_process(resp)
      actual_scopes <- normalize_scopes(strsplit(info$scope, split = "\\s+")[[
        1
      ]])

      missing <- setdiff(self$params$scope, actual_scopes)
      if (length(missing) > 0) {
        gargle_debug(c(
          "!" = "{cli::qty(length(missing))}{?This/These} requested \\
             scope{?s} {?is/are} not among the scopes for the \\
             access token returned by the metadata server:",
          bulletize(missing, bullet = "x"),
          "i" = "If there are problems downstream, this might be the root cause."
        ))
      }

      if (!setequal(self$params$scope, actual_scopes)) {
        gargle_debug(c(
          "!" = "Updating token scopes to reflect its actual scopes:",
          bulletize(actual_scopes)
        ))
        self$params$scope <- actual_scopes
      }

      self$credentials <- token
      self
    },
    #' @description Refreshes the token. In this case, that just means "ask again
    #'   for an access token".
    refresh = function() {
      gargle_debug("GceToken refresh")
      # There's something kind of wrong about this, because it's not a true
      # refresh. But this method is basically required by the way httr currently
      # works.
      # This means that some uses of $refresh() aren't really appropriate for a
      # GceToken.
      # For example, if I attempt token_userinfo(x) on a GceToken that lacks
      # appropriate scope, it fails with 401.
      # httr tries to "fix" things by refreshing the token. But this is
      # not a problem that refreshing can fix.
      # I've now prevented an explicit refresh in token_userinfo(), but an
      # implicit one still eventually happens in httr:::request_perform().
      self$init_credentials()
    },
    #' @description Placeholder implementation of required method. Returns `TRUE`.
    can_refresh = function() {
      TRUE
    },

    #' @description Format a [GceToken()].
    #' @param ... Not used.
    format = function(...) {
      x <- list(
        scopes = commapse(base_scope(self$params$scope)),
        credentials = commapse(names(self$credentials))
      )
      c(
        cli::cli_format_method(
          cli::cli_h1("<GceToken (via {.pkg gargle})>")
        ),
        glue("{fr(names(x))}: {fl(x)}")
      )
    },
    #' @description Print a [GceToken()].
    #' @param ... Not used.
    print = function(...) {
      # a format method is not sufficient for GceToken because the parent class
      # has a print method
      cli::cat_line(self$format())
    },

    # Never cache
    #' @description Placeholder implementation of required method.
    cache = function() self,
    #' @description Placeholder implementation of required method.
    load_from_cache = function() self,

    # These methods don't really make sense for GCE access tokens
    #' @description Placeholder implementation of required method.
    revoke = function() {
      gargle_abort("{.fun $revoke} is not implemented for {.cls GceToken}")
    },
    #' @description Placeholder implementation of required method
    validate = function() {
      gargle_abort("{.fun $validate} is not implemented for {.cls GceToken}")
    }
  )
)

gce_metadata_hostname <- function() {
  use_ip <- getOption("gargle.gce.use_ip", FALSE)
  if (isTRUE(use_ip)) {
    Sys.getenv("GCE_METADATA_IP", "169.254.169.254")
  } else {
    Sys.getenv("GCE_METADATA_URL", "metadata.google.internal")
  }
}

gce_metadata_request <- function(
  path = "",
  query = NULL,
  stop_on_error = TRUE
) {
  # TODO(craigcitro): Add options to ignore proxies.
  if (grepl("^/", path)) {
    path <- substring(path, 2)
  }
  url_parts <- structure(
    list(
      scheme = "http",
      hostname = gce_metadata_hostname(),
      path = path,
      query = query
    ),
    class = "url"
  )
  url <- httr::build_url(url_parts)
  response <- try(
    {
      httr::with_config(httr::timeout(gce_timeout()), {
        httr::GET(url, httr::add_headers("Metadata-Flavor" = "Google"))
      })
    },
    silent = TRUE
  )

  if (stop_on_error) {
    if (inherits(response, "try-error")) {
      gargle_abort(
        "
        Error fetching GCE metadata: {attr(response, 'condition')$message}"
      )
    } else if (httr::http_error(response)) {
      gargle_abort(
        "
        Error fetching GCE metadata: {httr::http_status(response)$message}"
      )
    }
    if (response$headers$`metadata-flavor` != "Google") {
      gargle_abort(
        "
        Error fetching GCE metadata: missing/invalid metadata-flavor header"
      )
    }
  }
  response
}

# https://cloud.google.com/compute/docs/instances/detect-compute-engine
is_gce <- function() {
  response <- gce_metadata_request(stop_on_error = FALSE)
  !(inherits(response, "try-error") || httr::http_error(response))
}

#' List all service accounts available on this GCE instance
#'
#' @returns A data frame, where each row is a service account. Due to aliasing,
#'   there is no guarantee that each row represents a distinct service account.
#'
#' @seealso The return value is built from a recursive query of the so-called
#'   "directory" of the instance's service accounts as documented in
#'   <https://cloud.google.com/compute/docs/metadata/default-metadata-values#vm_instance_metadata>.
#'
#' @export
#' @examplesIf gargle:::is_gce()
#' credentials_gce()
gce_instance_service_accounts <- function() {
  response <- gce_metadata_request(
    "computeMetadata/v1/instance/service-accounts",
    query = list(recursive = "true")
  )
  raw <- transpose(response_as_json(response))
  data.frame(
    name = names(raw$email),
    email = unlist(raw$email),
    aliases = map_chr(raw$aliases, function(x) glue_collapse(x, sep = ",")),
    scopes = map_chr(raw$scopes, function(x) glue_collapse(x, sep = ",")),
    stringsAsFactors = FALSE,
    row.names = NULL
  )
}

# TODO: why isn't scopes used here at all?
# the python auth library definitely passes scopes:
# https://github.com/googleapis/google-auth-library-python/blob/a83af399fe98764ee851997bf3078ec45a9b51c9/google/auth/compute_engine/_metadata.py#L237
# perhaps there are use cases where it would be helpful it we did same:
# https://github.com/r-lib/gargle/issues/216
fetch_gce_access_token <- function(scopes, service_account) {
  path <- glue(
    "computeMetadata/v1/instance/service-accounts/{service_account}/token"
  )
  scope_string <- glue_collapse(scopes, sep = ",")
  response <- gce_metadata_request(path, query = list(scopes = scope_string))
  httr::content(response, as = "parsed", type = "application/json")
}

# wrapper to access the "gargle.gce.timeout" option
# https://github.com/r-lib/gargle/issues/186
# https://github.com/r-lib/gargle/pull/195
# if called with no argument:
#   if option is set, return that value
#   if unset: return a short default, suitable for initial ping of
#     the metadata server (and not too burdensome for non-GCE users) and set the
#     option to a longer default, suitable for a subsequent request for all
#     service accounts or a specific token
# if called with an argument:
#   set the option to that value (and return the old value)
gce_timeout <- function(v) {
  opt <- getOption("gargle.gce.timeout")
  if (missing(v)) {
    if (is.null(opt)) {
      ret <- 0.8 # short default timeout
      options(gargle.gce.timeout = 2) # long default timeout
    } else {
      ret <- opt
    }
  } else {
    ret <- options(gargle.gce.timeout = v)[["gargle.gce.timeout"]]
  }
  ret
}
