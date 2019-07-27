# gargle (development version)

# gargle 0.3.1

* [Non-interactive auth](https://gargle.r-lib.org/articles/non-interactive-auth.html) is a new vignette that serves as a guide for any client packages that use gargle for auth.

* `credentials_gce()` might actually work now (#97, @wlongabaugh).

* `credentials_app_default()` got a small bug fix relating to putting the token in the header (r-dbi/bigrquery#336)

* `token_fetch()` silently catches warnings, in addition to errors, as it falls
  through the registry of credential-fetching methods (#89).

* The yes/no asking if it's OK to cache OAuth tokens prints fully now
  (r-dbi/bigrquery#333).

# gargle 0.3.0

* The unexported functions available for generating standardized docs for
  `PKG_auth` functions in client packages have been updated.
  
* `token_userinfo()`, `token_email()`, and `token_tokeninfo()` are newly
  exported helpers that retrieve information for a token.

* `AuthState$set_app()` and `AuthState$set_api_key()` now allow setting a value
  of `NULL`, i.e. these fields are easier to clear.

* `credentials_byo_oauth2()` gains the ability to ingest a token from an object of class `httr::request`, i.e. to retrieve the `auth_token` component that holds an object of class `httr::Token2.0` that has been processed with `httr::config()`.

# gargle 0.2.0

* All built-in API credentials have been rotated and are stored internally in a way that reinforces appropriate use. There is a new [Privacy policy](https://www.tidyverse.org/google_privacy_policy/) as well as a [policy for authors of packages or other applications](https://www.tidyverse.org/google_privacy_policy/#policies-for-authors-of-packages-or-other-applications). This is related to a process to get the gargle project [verified](https://support.google.com/cloud/answer/7454865?hl=en), which affects the OAuth2 capabilities and the consent screen.

* New vignette on "How to get your own API credentials", to help other package authors or users obtain their own API key or OAuth client ID and secret.

* `credentials_byo_oauth2()` is a new credential function. It is included in the
default registry consulted by `token_fetch()` and is tried just before
`credentials_user_oauth2()`.

# gargle 0.1.3

* Initial CRAN release
