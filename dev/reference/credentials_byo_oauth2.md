# Load a user-provided token

This function is designed to pass its `token` input through, after doing
a few checks and some light processing:

- If `token` has class `request`, i.e. it is a token that has been
  prepared with
  [`httr::config()`](https://httr.r-lib.org/reference/config.html), the
  `auth_token` component is extracted. For example, such input could be
  returned by `googledrive::drive_token()` or `bigrquery::bq_token()`.

- If `token` is an instance of `Gargle2.0` (so: a gargle-obtained user
  token), checks that it appears to be a Google OAuth token, based on
  its embedded `oauth_endpoint`. Refreshes the token, if it's
  refreshable.

- Returns the `token`.

There is no point in providing `scopes`. They are ignored because the
`scopes` associated with the token have already been baked in to the
token itself and gargle does not support incremental authorization. The
main point of `credentials_byo_oauth2()` is to allow
[`token_fetch()`](https://gargle.r-lib.org/dev/reference/token_fetch.md)
(and packages that wrap it) to accommodate a "bring your own token"
workflow.

This also makes it possible to obtain a token with one package and then
register it for use with another package. For example, the default scope
requested by googledrive is also sufficient for operations available in
googlesheets4. You could use a shared token like so:

    library(googledrive)
    library(googlesheets4)
    drive_auth(email = "jane_doe@example.com")
    gs4_auth(token = drive_token())
    # work with both packages freely now, with the same identity

## Usage

``` r
credentials_byo_oauth2(scopes = NULL, token, ...)
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

- token:

  A token with class
  [Token2.0](https://httr.r-lib.org/reference/Token-class.html) or an
  object of httr's class `request`, i.e. a token that has been prepared
  with [`httr::config()`](https://httr.r-lib.org/reference/config.html)
  and has a
  [Token2.0](https://httr.r-lib.org/reference/Token-class.html) in the
  `auth_token` component.

- ...:

  Additional arguments passed to all credential functions.

## Value

An [Token2.0](https://httr.r-lib.org/reference/Token-class.html).

## See also

Other credential functions:
[`credentials_app_default()`](https://gargle.r-lib.org/dev/reference/credentials_app_default.md),
[`credentials_external_account()`](https://gargle.r-lib.org/dev/reference/credentials_external_account.md),
[`credentials_gce()`](https://gargle.r-lib.org/dev/reference/credentials_gce.md),
[`credentials_service_account()`](https://gargle.r-lib.org/dev/reference/credentials_service_account.md),
[`credentials_user_oauth2()`](https://gargle.r-lib.org/dev/reference/credentials_user_oauth2.md),
[`token_fetch()`](https://gargle.r-lib.org/dev/reference/token_fetch.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# assume `my_token` is a Token2.0 object returned by a function such as
# credentials_user_oauth2()
credentials_byo_oauth2(token = my_token)
} # }
```
