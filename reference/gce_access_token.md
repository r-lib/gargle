# Fetch access token for a service account on GCE

Fetch access token for a service account on GCE

## Usage

``` r
gce_access_token(
  scopes = "https://www.googleapis.com/auth/cloud-platform",
  service_account = "default"
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

- service_account:

  Name of the GCE service account to use.
