# Load Application Default Credentials

Loads credentials from a file identified via a search strategy known as
Application Default Credentials (ADC). The hope is to make auth "just
work" for someone working on Google-provided infrastructure or who has
used Google tooling to get started, such as the [`gcloud` command line
tool](https://docs.cloud.google.com/sdk/gcloud).

A sequence of paths is consulted, which we describe here, with some
abuse of notation. ALL_CAPS represents the value of an environment
variable and `%||%` is used in the spirit of a [null coalescing
operator](https://en.wikipedia.org/wiki/Null_coalescing_operator).

    GOOGLE_APPLICATION_CREDENTIALS
    CLOUDSDK_CONFIG/application_default_credentials.json
    # on Windows:
    (APPDATA %||% SystemDrive %||% C:)\gcloud\application_default_credentials.json
    # on not-Windows:
    ~/.config/gcloud/application_default_credentials.json

If the above search successfully identifies a JSON file, it is parsed
and ingested as a service account, an external account ("workload
identity federation"), or a user account. Literally, if the JSON
describes a service account, we call
[`credentials_service_account()`](https://gargle.r-lib.org/dev/reference/credentials_service_account.md)
and if it describes an external account, we call
[`credentials_external_account()`](https://gargle.r-lib.org/dev/reference/credentials_external_account.md).

## Usage

``` r
credentials_app_default(scopes = NULL, ..., subject = NULL)
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

- ...:

  Additional arguments passed to all credential functions.

- subject:

  An optional subject claim. Specify this if you wish to use the service
  account represented by `path` to impersonate the `subject`, who is a
  normal user. Before this can work, an administrator must grant the
  service account domain-wide authority. Identify the user to
  impersonate via their email, e.g. `subject = "user@example.com"`. Note
  that gargle automatically adds the non-sensitive
  `"https://www.googleapis.com/auth/userinfo.email"` scope, so this
  scope must be enabled for the service account, along with any other
  `scopes` being requested.

## Value

An
[`httr::TokenServiceAccount`](https://httr.r-lib.org/reference/Token-class.html),
a [`WifToken`](https://gargle.r-lib.org/dev/reference/WifToken.md), an
[`httr::Token2.0`](https://httr.r-lib.org/reference/Token-class.html) or
`NULL`.

## See also

- <https://docs.cloud.google.com/docs/authentication>

- <https://docs.cloud.google.com/sdk/docs>

Other credential functions:
[`credentials_byo_oauth2()`](https://gargle.r-lib.org/dev/reference/credentials_byo_oauth2.md),
[`credentials_external_account()`](https://gargle.r-lib.org/dev/reference/credentials_external_account.md),
[`credentials_gce()`](https://gargle.r-lib.org/dev/reference/credentials_gce.md),
[`credentials_service_account()`](https://gargle.r-lib.org/dev/reference/credentials_service_account.md),
[`credentials_user_oauth2()`](https://gargle.r-lib.org/dev/reference/credentials_user_oauth2.md),
[`token_fetch()`](https://gargle.r-lib.org/dev/reference/token_fetch.md)

## Examples

``` r
if (FALSE) { # \dontrun{
credentials_app_default()
} # }
```
