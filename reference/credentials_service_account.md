# Load a service account token

Load a service account token

## Usage

``` r
credentials_service_account(scopes = NULL, path = "", ..., subject = NULL)
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

  JSON identifying the service account, in one of the forms supported
  for the `txt` argument of
  [`jsonlite::fromJSON()`](https://jeroen.r-universe.dev/jsonlite/reference/fromJSON.html)
  (typically, a file path or JSON string).

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
[`httr::TokenServiceAccount`](https://httr.r-lib.org/reference/Token-class.html)
or `NULL`.

## Details

Note that fetching a token for a service account requires a reasonably
accurate system clock. For more information, see the
[`vignette("how-gargle-gets-tokens")`](https://gargle.r-lib.org/articles/how-gargle-gets-tokens.md).

## See also

Additional reading on delegation of domain-wide authority:

- <https://developers.google.com/identity/protocols/oauth2/service-account#delegatingauthority>

Other credential functions:
[`credentials_app_default()`](https://gargle.r-lib.org/reference/credentials_app_default.md),
[`credentials_byo_oauth2()`](https://gargle.r-lib.org/reference/credentials_byo_oauth2.md),
[`credentials_external_account()`](https://gargle.r-lib.org/reference/credentials_external_account.md),
[`credentials_gce()`](https://gargle.r-lib.org/reference/credentials_gce.md),
[`credentials_user_oauth2()`](https://gargle.r-lib.org/reference/credentials_user_oauth2.md),
[`token_fetch()`](https://gargle.r-lib.org/reference/token_fetch.md)

## Examples

``` r
if (FALSE) { # \dontrun{
token <- credentials_service_account(
  scopes = "https://www.googleapis.com/auth/userinfo.email",
  path = "/path/to/your/service-account.json"
)
} # }
```
