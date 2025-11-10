# Fetch a token for the given scopes

This is a rather magical function that calls a series of concrete
credential-fetching functions, each wrapped in a
[`tryCatch()`](https://rdrr.io/r/base/conditions.html). `token_fetch()`
keeps trying until it succeeds or there are no more functions to try.
See the
[`vignette("how-gargle-gets-tokens")`](https://gargle.r-lib.org/dev/articles/how-gargle-gets-tokens.md)
for a full description of `token_fetch()`.

## Usage

``` r
token_fetch(scopes = NULL, ...)
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

## Value

An [`httr::Token`](https://httr.r-lib.org/reference/Token-class.html)
(often an instance of something that inherits from
[`httr::Token`](https://httr.r-lib.org/reference/Token-class.html)) or
`NULL`.

## See also

[`cred_funs_list()`](https://gargle.r-lib.org/dev/reference/cred_funs.md)
reveals the current registry of credential-fetching functions, in order.

Other credential functions:
[`credentials_app_default()`](https://gargle.r-lib.org/dev/reference/credentials_app_default.md),
[`credentials_byo_oauth2()`](https://gargle.r-lib.org/dev/reference/credentials_byo_oauth2.md),
[`credentials_external_account()`](https://gargle.r-lib.org/dev/reference/credentials_external_account.md),
[`credentials_gce()`](https://gargle.r-lib.org/dev/reference/credentials_gce.md),
[`credentials_service_account()`](https://gargle.r-lib.org/dev/reference/credentials_service_account.md),
[`credentials_user_oauth2()`](https://gargle.r-lib.org/dev/reference/credentials_user_oauth2.md)

## Examples

``` r
if (FALSE) { # \dontrun{
token_fetch(scopes = "https://www.googleapis.com/auth/userinfo.email")
} # }
```
