# Generate OAuth token for an external account

Generate OAuth token for an external account

## Usage

``` r
oauth_external_token(
  path = "",
  scopes = "https://www.googleapis.com/auth/cloud-platform"
)
```

## Arguments

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

- scopes:

  A character vector of scopes to request. Pick from those listed at
  <https://developers.google.com/identity/protocols/oauth2/scopes>.

  For certain token flows, the
  `"https://www.googleapis.com/auth/userinfo.email"` scope is
  unconditionally included. This grants permission to retrieve the email
  address associated with a token; gargle uses this to index cached
  OAuth tokens. This grants no permission to view or send email and is
  generally considered a low-value scope.
