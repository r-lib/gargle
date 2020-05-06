# gargle 0.5.0

* [Troubleshooting gargle auth](https://gargle.r-lib.org/articles/troubleshooting.html)
  is a new vignette.

* All user-facing messaging routes through `rlang::inform()`, which (as of
  rlang 0.4.2) prints to standard output in interactive sessions and to
  standard error in non-interactive sessions (#133). Messaging remains under
  the control of the `"gargle_quiet"` option, which defaults to `TRUE`.
  
* The `Gargle2.0` class gains its own `$refresh()` method, which removes a
  token from gargle's cache when it cannot be refreshed (#79).
  
* `credentials_service_account()` and `credentials_app_default()` gain an
  optional `subject` argument, which can be used to pass a subject claim along
  to `httr::oauth_service_token()` (#131, @samterfa).

* `request_make()` defaults to `encode = "json"`, which differs from the httr
  default, but aligns better with Google APIs (#124).

* `field_mask()` is a utility function for constructing a
  Protocol-Buffers-style, JSON-encoded field mask from a named R list.

* All R6 classes use the new documentation capabilities that appeared in
  roxygen2 7.0.0.

* OAuth2 flow can only be initiated when `rlang::is_interactive()` is `TRUE`. If
  a new token is needed in a non-interactive session, gargle now throws an
  error (#113).

* The application default credentials path is fixed on non-Windows platforms
  (#115, @acroz).
  
* `request_develop()` can accept a parameter that appears in both the path and
  the body (#123).

* `response_process()` explicitly declares the UTF-8 encoding of the content in
  Google API responses [tidyverse/googlesheets4#26](https://github.com/tidyverse/googlesheets4/issues/26).
  
* `response_process()` is able to expose details for a wider set of errors.

# gargle 0.4.0

* Eliminated uninformative failure when OAuth tokens cached on R <= 3.5 are re-loaded on R >= 3.6. The change to the default serialization version (2 vs. 3) creates an apparent mismatch between a token's hash and its key. Instead of inexplicably failing, now we attempt to repair the cache and carry on (#109, [tidyverse/googledrive#274](https://github.com/tidyverse/googledrive/issues/274).

* In a non-interactive context, gargle will use a cached OAuth token, if it discovers (at least) one, even if the user has not given explicit instructions. We emit a recommendation that the user make their intent unambiguous and link to the vignette on non-interactive auth (#92).

* gargle consults the option `"httr_oob_default"`, if the option `"gargle_oob_default"` is unset. This is part of an effort to automatically detect the need for out-of-bound auth in more situations (#102).

* `credentials_service_account()` checks explicitly that `type` is `"service_account"`. This makes it easier to detect a common mistake, where the JSON for an OAuth client is provided instead of the JSON representing a service account (#93).

* `credentials_gce()` gains `cloud-platform` as a default scope, assuming that the typical user wants to "View and manage your data across Google Cloud Platform services" (#110, @MarkEdmondson1234).

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
