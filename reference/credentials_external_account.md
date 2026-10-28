# Get a token for an external account

**\[experimental\]** Workload identity federation lets applications
running outside Google Cloud, such as on AWS or GitHub Actions, access
Google Cloud resources by using a federated identity instead of a
service account key. This eliminates the dilemma of how to safely manage
service account credential files.

Unlike a service account key, the configuration for workload identity
federation is not a long-lived secret that you need to store and
protect. What the configuration looks like depends on the platform.

- On AWS, it's a file of non-sensitive metadata that you download once
  and keep on the instance; the sensitive data is obtained "on-the-fly"
  at run time.

- On GitHub Actions, the configuration file is written fresh for each
  job and contains only a short-lived credential.

The configuration is used to obtain a so-called subject token from the
external identity provider, such as AWS or GitHub. The subject token is
then sent to Google's Security Token Service API, in exchange for a very
short-lived federated access token. Finally, the federated access token
is sent to Google's Service Account Credentials API, in exchange for a
short-lived GCP access token. This access token allows the external
application to impersonate a service account and inherit the permissions
of the service account to access GCP resources.

This feature is still experimental in gargle. The `credential_source` in
the configuration determines how the subject token is obtained and
gargle supports these types:

- AWS (`"environment_id": "aws1"`). This only works when running on an
  EC2 instance and requires the suggested packages aws.signature and
  aws.ec2metadata.

- URL-sourced credentials (`"url"`). The subject token is fetched from a
  URL, with optional request `headers`. The
  [`google-github-actions/auth`](https://github.com/google-github-actions/auth)
  action writes this type of configuration for GitHub Actions and points
  the `GOOGLE_APPLICATION_CREDENTIALS` environment variable at it. That
  means that, in a workflow that runs this action,
  [`token_fetch()`](https://gargle.r-lib.org/reference/token_fetch.md)
  (and, therefore, the auth functions of client packages) can discover
  and use the credentials via
  [`credentials_app_default()`](https://gargle.r-lib.org/reference/credentials_app_default.md).

- File-sourced credentials (`"file"`). The subject token is read from a
  local file.

For URL- and file-sourced credentials, the subject token is either the
entire response or file (`"format": {"type": "text"}`, the default) or a
field in a JSON object
(`"format": {"type": "json", "subject_token_field_name": "..."}`).

gargle does not support executable-sourced credentials. The
configuration must include `service_account_impersonation_url`, i.e.
gargle does not yet support direct workload identity federation, without
service account impersonation. If you would like gargle to support
additional variations of this token flow, please [open an issue on
GitHub](https://github.com/r-lib/gargle/issues) and describe your use
case.

## Usage

``` r
credentials_external_account(
  scopes = "https://www.googleapis.com/auth/cloud-platform",
  path = "",
  ...
)
```

## Arguments

- scopes:

  A character vector of scopes to request. Pick from those listed at
  <https://developers.google.com/identity/protocols/oauth2/scopes>.

  For certain token flows, the
  `"https://www.googleapis.com/auth/userinfo.email"` scope is
  unconditionally included. This grants permission to retrieve the email
  address associated with a token; gargle uses this to index cached
  OAuth tokens. This grants no permission to view or send email and is
  generally considered a low-value scope.

- path:

  JSON containing the workload identity configuration for the external
  account, in one of the forms supported for the `txt` argument of
  [`jsonlite::fromJSON()`](https://jeroen.r-universe.dev/jsonlite/reference/fromJSON.html)
  (probably, a file path, although it could be a JSON string). The
  instructions for generating this configuration are given at
  [Configuring workload identity
  federation](https://cloud.google.com/iam/docs/configuring-workload-identity-federation).

  Note that external account tokens are a natural fit for use as
  Application Default Credentials, so consider storing the configuration
  file in one of the standard locations consulted for ADC, instead of
  providing `path` explicitly. See
  [`credentials_app_default()`](https://gargle.r-lib.org/reference/credentials_app_default.md)
  for more.

- ...:

  Additional arguments passed to all credential functions.

## Value

A [`WifToken()`](https://gargle.r-lib.org/reference/WifToken.md) or
`NULL`.

## See also

Most of the setup for this authentication method happens on the GCP
side; the external platform typically needs little or no configuration.
These links provide, respectively, a high-level overview, step-by-step
instructions, and Google's specification for the configuration file.

- <https://cloud.google.com/blog/products/identity-security/enable-keyless-access-to-gcp-with-workload-identity-federation/>

- <https://cloud.google.com/iam/docs/configuring-workload-identity-federation>

- <https://google.aip.dev/auth/4117>

Other credential functions:
[`credentials_app_default()`](https://gargle.r-lib.org/reference/credentials_app_default.md),
[`credentials_byo_oauth2()`](https://gargle.r-lib.org/reference/credentials_byo_oauth2.md),
[`credentials_gce()`](https://gargle.r-lib.org/reference/credentials_gce.md),
[`credentials_service_account()`](https://gargle.r-lib.org/reference/credentials_service_account.md),
[`credentials_user_oauth2()`](https://gargle.r-lib.org/reference/credentials_user_oauth2.md),
[`token_fetch()`](https://gargle.r-lib.org/reference/token_fetch.md)

## Examples

``` r
if (FALSE) { # \dontrun{
credentials_external_account()
} # }
```
