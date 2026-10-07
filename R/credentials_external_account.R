#' Get a token for an external account
#'
#' @description

#' `r lifecycle::badge('experimental')`

#' Workload identity federation is a keyless authentication mechanism that
#' allows applications running on a non-Google Cloud platform, such as AWS or
#' GitHub Actions, to access Google Cloud resources without using a
#' conventional service account token. This eliminates the dilemma of how to
#' safely manage service account credential files.
#'

#'  Unlike a service account key, the configuration for workload identity
#'  federation is not a long-lived secret that you need to store and protect.
#'  What the configuration looks like depends on the platform.
#'
#'  * On AWS, it's a file of non-sensitive metadata that you download once and
#'    keep on the instance; the sensitive data is obtained "on-the-fly" at run
#'    time.
#'  * On GitHub Actions, the configuration file is written fresh for each job
#'    and contains only a short-lived credential.
#'
#'  The configuration is used to obtain a so-called subject token from the
#'  external identity provider, such as AWS or GitHub. The subject token is then
#'  sent to Google's Security Token Service API, in exchange for a very
#'  short-lived federated access token. Finally, the federated access token is
#'  sent to Google's Service Account Credentials API, in exchange for a
#'  short-lived GCP access token. This access token allows the external
#'  application to impersonate a service account and inherit the permissions of
#'  the service account to access GCP resources.

#'
#'  This feature is still experimental in gargle. The `credential_source` in
#'  the configuration determines how the subject token is obtained and gargle
#'  supports these types:
#'
#'  * AWS (`"environment_id": "aws1"`). This only works when running on an EC2
#'    instance and requires the suggested packages \pkg{aws.signature} and
#'    \pkg{aws.ec2metadata}.
#'  * URL-sourced credentials (`"url"`). The subject token is fetched from a
#'    URL, with optional request `headers`. The
#'    [`google-github-actions/auth`](https://github.com/google-github-actions/auth)
#'    action writes this type of configuration for GitHub Actions and points
#'    the `GOOGLE_APPLICATION_CREDENTIALS` environment variable at it. That
#'    means that, in a workflow that runs this action, [token_fetch()] (and,
#'    therefore, the auth functions of client packages) can discover and use
#'    the credentials via [credentials_app_default()].
#'  * File-sourced credentials (`"file"`). The subject token is read from a
#'    local file.
#'
#'  For URL- and file-sourced credentials, the subject token is either the
#'  entire response or file (`"format": {"type": "text"}`, the default) or a
#'  field in a JSON object (`"format": {"type": "json",
#'  "subject_token_field_name": "..."}`).
#'
#'  gargle does not support executable-sourced credentials. The configuration
#'  must include `service_account_impersonation_url`, i.e. gargle does not yet
#'  support direct workload identity federation, without service account
#'  impersonation. If you would like gargle to support additional variations
#'  of this token flow, please [open an issue on
#'  GitHub](https://github.com/r-lib/gargle/issues) and describe your use case.

#'
#' @inheritParams token_fetch

#' @param path JSON containing the workload identity configuration for the
#'   external account, in one of the forms supported for the `txt` argument of
#'   [jsonlite::fromJSON()] (probably, a file path, although it could be a JSON
#'   string). The instructions for generating this configuration are given at
#'   [Configuring workload identity federation](https://cloud.google.com/iam/docs/configuring-workload-identity-federation).
#'
#'   Note that external account tokens are a natural fit for use as Application
#'   Default Credentials, so consider storing the configuration file in one of
#'   the standard locations consulted for ADC, instead of providing `path`
#'   explicitly. See [credentials_app_default()] for more.
#'

#' @seealso There is substantial setup necessary, both on the GCP side and on
#'   the external platform, to use this authentication method. These links
#'   provide, respectively, a high-level overview, step-by-step instructions,
#'   and Google's specification for the configuration file.

#' * <https://cloud.google.com/blog/products/identity-security/enable-keyless-access-to-gcp-with-workload-identity-federation/>

#' * <https://cloud.google.com/iam/docs/configuring-workload-identity-federation>

#' * <https://google.aip.dev/auth/4117>

#' @return A [WifToken()] or `NULL`.
#' @family credential functions
#' @export
#' @examples
#' \dontrun{
#' credentials_external_account()
#' }
credentials_external_account <- function(
  scopes = "https://www.googleapis.com/auth/cloud-platform",
  path = "",
  ...
) {
  gargle_debug("trying {.fun credentials_external_account}")
  if (is.null(scopes)) {
    return(NULL)
  }

  info <- external_account_info(path)
  if (is.null(info)) {
    return(NULL)
  }
  if (is_aws_source(info[["credential_source"]]) && !detect_aws_ec2()) {
    gargle_debug("AWS credential source, but not running on EC2")
    return(NULL)
  }

  scopes <- normalize_scopes(add_email_scope(scopes))

  token <- oauth_external_token(path = path, scopes = scopes)

  if (
    is.null(token$credentials$access_token) ||
      !nzchar(token$credentials$access_token)
  ) {
    NULL
  } else {
    gargle_debug("service account email: {.email {token_email(token)}}")
    token
  }
}

#' Generate OAuth token for an external account
#'
#' @inheritParams credentials_external_account
#'
#' @keywords internal
#' @export
oauth_external_token <- function(
  path = "",
  scopes = "https://www.googleapis.com/auth/cloud-platform"
) {
  info <- external_account_info(path)
  if (is.null(info)) {
    return()
  }

  params <- c(
    list(scopes = scopes),
    info,
    # the most pragmatic way to get super$sign() to work
    # can't implement my own method without needing unexported httr functions
    # request() or build_request()
    as_header = TRUE
  )
  WifToken$new(params = params)
}

#' Token for use with workload identity federation
#'
#' Not intended for direct use. See [credentials_external_account()] instead.
#'
#' @keywords internal
#' @export
WifToken <- R6::R6Class(
  "WifToken",
  inherit = httr::Token2.0,
  list(
    #' @description Get a token via workload identity federation
    #' @param params A list of parameters for `init_oauth_external_account()`.
    #' @return A WifToken.
    initialize = function(params = list()) {
      gargle_debug("WifToken initialize")
      # TODO: any desired validity checks on contents of params

      # NOTE: the final token exchange with
      # https://cloud.google.com/iam/docs/reference/credentials/rest/v1/projects.serviceAccounts/generateAccessToken
      # takes scopes as an **array**, not a space delimited string
      # so we do NOT collapse scopes in this flow
      params$scope <- params$scopes
      self$params <- params

      self$init_credentials()
    },

    #' @description Enact the actual token exchange for workload identity
    #'   federation.
    init_credentials = function() {
      gargle_debug("WifToken init_credentials")
      creds <- init_oauth_external_account(params = self$params)

      # for some reason, the serviceAccounts.generateAccessToken method of
      # Google's Service Account Credentials API returns in camelCase, not
      # snake_case
      # as in, we get this:
      # "accessToken":"ya29.c.KsY..."
      # "expireTime":"2021-06-01T18:01:06Z"
      # instead of this:
      # "access_token": "ya29.a0A..."
      # "expires_in": 3599
      snake_case <- function(x) {
        gsub("([a-z0-9])([A-Z])", "\\1_\\L\\2", x, perl = TRUE)
      }
      names(creds) <- snake_case(names(creds))
      self$credentials <- creds
      self
    },

    #' @description Refreshes the token, which means re-doing the entire token
    #'   flow in this case.
    refresh = function() {
      gargle_debug("WifToken refresh")
      # There's something kind of wrong about this, because it's not a true
      # refresh. But this method is basically required by the way httr currently
      # works.
      # This means that some uses of $refresh() aren't really appropriate for a
      # WifToken.
      # For example, if I attempt token_userinfo(x) on a WifToken that lacks
      # appropriate scope, it fails with 401.
      # httr tries to "fix" things by refreshing the token. But this is
      # not a problem that refreshing can fix.
      # I've now prevented that particular phenomenon in token_userinfo().
      self$init_credentials()
    },

    #' @description Format a [WifToken()].
    #' @param ... Not used.
    format = function(...) {
      x <- list(
        scopes = commapse(base_scope(self$params$scope)),
        credentials = commapse(names(self$credentials))
      )
      c(
        cli::cli_format_method(
          cli::cli_h1("<WifToken (via {.pkg gargle})>")
        ),
        glue("{fr(names(x))}: {fl(x)}")
      )
    },
    #' @description Print a [WifToken()].
    #' @param ... Not used.
    print = function(...) {
      # a format method is not sufficient for WifToken because the parent class
      # has a print method
      cli::cat_line(self$format())
    },

    #' @description Placeholder implementation of required method. Returns `TRUE`.
    can_refresh = function() {
      # TODO: see above re: my ambivalence about the whole notion of refresh with
      # respect to this flow
      TRUE
    },

    # TODO: are cache and load_from_cache really required?
    # alternatively, what if calling them threw an error?
    #' @description Placeholder implementation of required method. Returns self.
    cache = function() self,
    #' @description Placeholder implementation of required method. Returns self.
    load_from_cache = function() self,

    # TODO: are these really required?
    #' @description Placeholder implementation of required method.
    validate = function() {},
    #' @description Placeholder implementation of required method.
    revoke = function() {}
  )
)

# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/identify_ec2_instances.html
# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-identity-documents.html
detect_aws_ec2 <- function() {
  if (is_installed("aws.ec2metadata")) {
    return(aws.ec2metadata::is_ec2())
  }
  gargle_debug(
    "
    {.pkg aws.ec2metadata} not installed; can't detect whether running on \\
    EC2 instance"
  )
  FALSE
}

init_oauth_external_account <- function(params) {
  impersonation_url <- params[["service_account_impersonation_url"]]
  if (!is_string(impersonation_url) || !nzchar(impersonation_url)) {
    gargle_abort(c(
      "
      {.pkg gargle}'s workload identity federation flow requires \\
      {.field service_account_impersonation_url}.",
      "i" = "
      Direct workload identity federation, i.e. without service account \\
      impersonation, isn't supported yet."
    ))
  }

  subject_token <- external_subject_token(params)

  federated_access_token <- fetch_federated_access_token(
    params = params,
    subject_token = subject_token
  )

  fetch_wif_access_token(
    federated_access_token,
    impersonation_url = impersonation_url,
    scope = params[["scope"]]
  )
}

external_account_info <- function(path) {
  info <- tryCatch(
    jsonlite::fromJSON(path, simplifyVector = FALSE),
    error = function(e) NULL
  )
  if (!identical(info[["type"]], "external_account")) {
    gargle_debug("JSON does not appear to represent an external account")
    return(NULL)
  }
  info
}

is_aws_source <- function(credential_source) {
  identical(credential_source[["environment_id"]], "aws1")
}

# https://google.aip.dev/auth/4117
external_subject_token <- function(params) {
  credential_source <- params[["credential_source"]]

  if (is_aws_source(credential_source)) {
    gargle_debug("credential source: {.val aws1}")
    subject_token <- aws_subject_token(
      credential_source = credential_source,
      audience = params[["audience"]]
    )
    return(serialize_subject_token(subject_token))
  }

  if (!is.null(credential_source[["url"]])) {
    gargle_debug("credential source: {.field url}")
    raw <- url_subject_token(credential_source)
  } else if (!is.null(credential_source[["file"]])) {
    gargle_debug("credential source: {.field file}")
    raw <- file_subject_token(credential_source)
  } else {
    fields <- names(credential_source)
    gargle_abort(c(
      "Unsupported {.field credential_source} for workload identity federation.",
      "i" = "
      {.pkg gargle} supports {.field url}, {.field file}, and AWS \\
      ({.field environment_id} = {.val aws1}) credential sources.",
      "x" = if (length(fields) > 0) {
        "{.field credential_source} has field{?s}: {.field {fields}}."
      } else {
        "{.field credential_source} is missing or empty."
      }
    ))
  }

  parse_subject_token(raw, format = credential_source[["format"]])
}

url_subject_token <- function(credential_source) {
  headers <- unlist(credential_source[["headers"]]) %||% character()
  resp <- httr::GET(
    credential_source[["url"]],
    httr::add_headers(.headers = headers),
    gargle_user_agent()
  )
  if (httr::http_error(resp)) {
    gargle_abort(c(
      "Failed to fetch the subject token from the {.field credential_source} URL.",
      "x" = "{httr::http_status(resp)$message}"
    ))
  }
  httr::content(resp, as = "text", encoding = "UTF-8")
}

file_subject_token <- function(credential_source) {
  path <- credential_source[["file"]]
  if (!is_string(path) || !file_exists(path)) {
    gargle_abort(
      "The {.field credential_source} file does not exist: {.path {path}}."
    )
  }
  paste(readLines(path, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
}

parse_subject_token <- function(x, format = NULL) {
  type <- format[["type"]] %||% "text"
  token <- switch(
    type,
    text = trimws(x),
    json = json_subject_token(x, format[["subject_token_field_name"]]),
    gargle_abort(
      "Unsupported subject token {.field format} type: {.val {type}}."
    )
  )
  if (!is_string(token) || !nzchar(token)) {
    gargle_abort("The subject token is empty.")
  }
  token
}

json_subject_token <- function(x, field) {
  if (!is_string(field) || !nzchar(field)) {
    gargle_abort(
      "
      A {.val json} subject token {.field format} requires \\
      {.field subject_token_field_name}."
    )
  }
  call <- current_env()
  # don't chain the jsonlite error, which can reveal the subject token
  parsed <- tryCatch(
    jsonlite::parse_json(x, simplifyVector = FALSE),
    error = function(e) {
      gargle_abort(
        "The subject token source can't be parsed as JSON.",
        call = call
      )
    }
  )
  token <- if (is.list(parsed)) parsed[[field]]
  if (is.null(token)) {
    gargle_abort(
      "Can't find the field {.field {field}} in the subject token JSON."
    )
  }
  token
}

# For AWS, the subject token isn't really a token, but rather the instructions
# necessary to get a token:
#
# From https://cloud.google.com/iam/docs/access-resources-aws#exchange-token
#
# "The GetCallerIdentity token contains the information that you would normally
# include in a request to the AWS GetCallerIdentity() method, as well as the
# signature that you would normally generate for the request.
#
# Also scroll down here, to see the AWS-specific content
# https://cloud.google.com/iam/docs/reference/sts/rest/v1/TopLevel/token
aws_subject_token <- function(credential_source, audience) {
  if (!is_installed(c("aws.ec2metadata", "aws.signature"))) {
    gargle_abort(
      "
      Packages {.pkg aws.ec2metadata} and {.pkg aws.signature} must be \\
      installed in order to use workload identity federation on AWS."
    )
  }

  region <- aws.ec2metadata::instance_document()$region

  regional_cred_verification_url <- glue(
    credential_source[["regional_cred_verification_url"]],
    region = region
  )
  parsed_url <- httr::parse_url(regional_cred_verification_url)

  headers_orig <- list(
    host = parsed_url$hostname,
    # for some reason, this is not included as a signed header unless I provide
    # it
    `x-amz-date` = format(Sys.time(), "%Y%m%dT%H%M%SZ", tz = "UTC"),
    # in contrast, session token IS automatically included if it exists, which
    # it should
    `x-goog-cloud-target-resource` = audience
  )

  verb <- "POST"
  # https://docs.aws.amazon.com/general/latest/gr/signature-version-4.html
  signed <- aws.signature::signature_v4_auth(
    region = region,
    service = "sts",
    verb = verb,
    action = "/",
    query_args = parsed_url$query,
    canonical_headers = headers_orig,
    request_body = ""
  )

  # unfortunately, the headers actually used to make the canonical request are
  # not returned in the signed object, so we dig them out of the canonical
  # request
  req_parts <- strsplit(signed[["CanonicalRequest"]], split = "\n")[[1]]
  f <- function(needle) {
    needle <- paste0("^", needle, ":")
    x <- grep(needle, req_parts, value = TRUE)
    sub(needle, "", x)
  }
  headers <- list(
    host = f("host"),
    `x-amz-date` = f("x-amz-date"),
    `x-amz-security-token` = f("x-amz-security-token"),
    `x-goog-cloud-target-resource` = f("x-goog-cloud-target-resource")
  )

  list(
    url = regional_cred_verification_url,
    method = verb,
    headers = c(
      Authorization = signed$SignatureHeader,
      headers
    )
  )
}

serialize_subject_token <- function(x) {
  # The GCP STS endpoint expects the headers to be formatted as:
  # [
  #   {key: 'Authorization', value: '...'},
  #   {key: 'x-amz-date', value: '...'},
  #   ...
  # ]
  # even though the headers were formatted differently, i.e. in the usual way,
  # when we generated the V4 signature.
  # we're using a purrr compat file, so must call with actual function
  kv <- function(val, nm) list(key = nm, value = val)
  headers_key_value <- unname(imap(x$headers, kv))
  x$headers <- headers_key_value

  # The GCP STS endpoint expects the prepared request to be serialized as a JSON
  # string, which is then URL-encoded.
  utils::URLencode(
    jsonlite::toJSON(x, auto_unbox = TRUE),
    reserved = TRUE
  )
}

# https://datatracker.ietf.org/doc/html/rfc8693
# https://cloud.google.com/iam/docs/reference/sts/rest/v1/TopLevel/token
# https://cloud.google.com/iam/docs/reference/credentials/rest/v1/projects.serviceAccounts/generateAccessToken#authorization-scopes
fetch_federated_access_token <- function(params, subject_token) {
  req <- list(
    method = "POST",
    url = params$token_url,
    body = list(
      audience = params[["audience"]],
      grantType = "urn:ietf:params:oauth:grant-type:token-exchange",
      requestedTokenType = "urn:ietf:params:oauth:token-type:access_token",
      # this request must have one of these scopes:
      # https://www.googleapis.com/auth/cloud-platform
      # https://www.googleapis.com/auth/iam
      # I am hard-wiring the iam scope, guided by the least privilege principle,
      # as it is the narrower of the 2 scopes
      scope = "https://www.googleapis.com/auth/iam",
      subjectTokenType = params[["subject_token_type"]],
      subjectToken = subject_token
    )
  )
  # rfc 8693 says to encode as "application/x-www-form-urlencoded"
  resp <- request_make(req, encode = "form")
  response_process(resp)
}

# https://cloud.google.com/iam/docs/creating-short-lived-service-account-credentials#sa-credentials-oauth
fetch_wif_access_token <- function(
  federated_access_token,
  impersonation_url,
  scope = "https://www.googleapis.com/auth/cloud-platform"
) {
  req <- list(
    method = "POST",
    url = impersonation_url,
    # https://cloud.google.com/iam/docs/reference/credentials/rest/v1/projects.serviceAccounts/generateAccessToken
    # takes scope as an **array**, not a space delimited string
    body = list(scope = scope),
    token = httr::add_headers(
      Authorization = paste("Bearer", federated_access_token$access_token)
    )
  )
  resp <- request_make(req)
  response_process(resp)
}
