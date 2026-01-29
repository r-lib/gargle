# Get a token for an external account

**\[experimental\]** Workload identity federation is a new (as of April
2021) keyless authentication mechanism that allows applications running
on a non-Google Cloud platform, such as AWS, to access Google Cloud
resources without using a conventional service account token. This
eliminates the dilemma of how to safely manage service account
credential files.

Unlike service accounts, the configuration file for workload identity
federation contains no secrets. Instead, it holds non-sensitive
metadata. The external application obtains the needed sensitive data
"on-the-fly" from the running instance. The combined data is then used
to obtain a so-called subject token from the external identity provider,
such as AWS. This is then sent to Google's Security Token Service API,
in exchange for a very short-lived federated access token. Finally, the
federated access token is sent to Google's Service Account Credentials
API, in exchange for a short-lived GCP access token. This access token
allows the external application to impersonate a service account and
inherit the permissions of the service account to access GCP resources.

This feature is still experimental in gargle and **currently only
supports AWS**. It also requires installation of the suggested packages
aws.signature and aws.ec2metadata. Workload identity federation **can**
be used with other platforms, such as Microsoft Azure or any identity
provider that supports OpenID Connect. If you would like gargle to
support this token flow for additional platforms, please [open an issue
on GitHub](https://github.com/r-lib/gargle/issues) and describe your use
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

There is substantial setup necessary, both on the GCP and AWS side, to
use this authentication method. These two links provide, respectively, a
high-level overview and step-by-step instructions.

- <https://cloud.google.com/blog/products/identity-security/enable-keyless-access-to-gcp-with-workload-identity-federation/>

- <https://cloud.google.com/iam/docs/configuring-workload-identity-federation>

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
