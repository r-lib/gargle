# Get info from a token

These functions send the `token` to Google endpoints that return info
about a token or a user.

## Usage

``` r
token_userinfo(token)

token_email(token)

token_tokeninfo(token)
```

## Arguments

- token:

  A token with class
  [Token2.0](https://httr.r-lib.org/reference/Token-class.html) or an
  object of httr's class `request`, i.e. a token that has been prepared
  with [`httr::config()`](https://httr.r-lib.org/reference/config.html)
  and has a
  [Token2.0](https://httr.r-lib.org/reference/Token-class.html) in the
  `auth_token` component.

## Value

A list containing:

- `token_userinfo()`: user info

- `token_email()`: user's email (obtained from a call to
  `token_userinfo()`)

- `token_tokeninfo()`: token info

## Details

It's hard to say exactly what info will be returned by the "userinfo"
endpoint targetted by `token_userinfo()`. It depends on the token's
scopes. Where possible, OAuth2 tokens obtained via the gargle package
include the `https://www.googleapis.com/auth/userinfo.email` scope,
which guarantees we can learn the email associated with the token. If
the token has the `https://www.googleapis.com/auth/userinfo.profile`
scope, there will be even more information available. But for a token
with unknown or arbitrary scopes, we can't make any promises about what
information will be returned.

## Examples

``` r
if (FALSE) { # \dontrun{
# with service account token
t <- token_fetch(
  scopes = "https://www.googleapis.com/auth/drive",
  path   = "path/to/service/account/token/blah-blah-blah.json"
)
# or with an OAuth token
t <- token_fetch(
  scopes = "https://www.googleapis.com/auth/drive",
  email  = "janedoe@example.com"
)
token_userinfo(t)
token_email(t)
tokens_tokeninfo(t)
} # }
```
