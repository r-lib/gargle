# Transition from OAuth app to OAuth client

``` r
library(gargle)
```

Over the course of several releases (v1.3.0, v1.4.0, and v1.5.0), gargle
has shifted to using an OAuth **client** in the user flow facilitated by
[`gargle::credentials_user_oauth2()`](https://gargle.r-lib.org/dev/reference/credentials_user_oauth2.md),
instead the previous OAuth “app”. This is a more than just a vocabulary
change (but it is also a vocabulary change). This vignette explains what
actually changed and how wrapper packages should adjust.

## Why change was needed

In 2022, Google partially deprecated the out-of-band (OOB) OAuth flow.
The OOB flow is used by R users who are working with Google APIs and who
use R in the browser, such as via RStudio Server, Posit Workbench, Posit
Cloud, or Google Colaboratory.

Conventional OOB auth **still works** under certain conditions, for
example, if the OAuth client is associated with a GCP project that is in
testing mode or that is internal to a Google Workspace. But conventional
OOB is no longer supported for projects that serve external users that
are in production mode. In particular, this means that conventional OOB
is no longer supported for the GCP project that has historically made
auth “just work” for casual users of packages such as googledrive,
googlesheets4, and bigrquery. The default OAuth client used by these
package no longer works with conventional OOB.

In response, as of v1.3.0, gargle implements a new variant of OOB,
called **pseudo-OOB**, to continue to provide a user-friendly auth flow
for googledrive/googlesheets4/bigrquery on RStudio Server/Posit
Workbench/Posit Cloud/Google Colaboratory. The pseudo-OOB flow is also
available for other developers to use. This flow is triggered when
`use_oob = TRUE` (an existing convention in gargle and gargle-using
packages) **and** the configured OAuth client is of the *web* type (when
creating an OAuth client, this is called the “Web application” type).

[TABLE]

In the past, gargle basically assumed that every OAuth client was of the
*installed* type (when creating an OAuth client, this is called the
“Desktop app” type). Therefore, the introduction of pseudo-OOB meant
that gargle had to learn about different OAuth client types (web
vs. installed). And that didn’t play well with
[`httr::oauth_app()`](https://httr.r-lib.org/reference/oauth_app.html),
which gargle had been using to store the client ID and secret.

That’s why there is a new S3 class, `"gargle_oauth_client"`, with a
constructor of the same name. Since more information is now necessary to
instantiate a client (e.g. its type and, potentially, redirect URIs),
the recommended way to create a client is to provide JSON downloaded
from the GCP console to
[`gargle_oauth_client_from_json()`](https://gargle.r-lib.org/dev/reference/gargle_oauth_client_from_json.md).

Since we had to introduce a new S3 class and supporting functions, we
also took this chance to make the vocabulary pivot from “OAuth app” to
“OAuth client”. Google’s documentation has always talked about the
“OAuth client”, so this is more natural. This vocabulary is also more
future-facing, anticipating the day when gargle might shift from httr to
httr2, which uses `httr2:oauth_client()`. As a bridging measure, the
`"gargle_oauth_client"` class currently inherits from httr’s
`"oauth_app"`, but this probably won’t be true in the long-term.

### How to instantiate an OAuth client in R

If you do auth via gargle, here are some recommended changes:

1.  Stop using
    [`httr::oauth_app()`](https://httr.r-lib.org/reference/oauth_app.html)
    or
    [`gargle::oauth_app_from_json()`](https://gargle.r-lib.org/dev/reference/oauth_app_from_json.md)
    to instantiate an OAuth client.
2.  Start using
    [`gargle_oauth_client_from_json()`](https://gargle.r-lib.org/dev/reference/gargle_oauth_client_from_json.md)
    (strongly recommended) or
    [`gargle_oauth_client()`](https://gargle.r-lib.org/dev/reference/gargle_oauth_client_from_json.md)
    instead.

This advice applies to anything you do inside your package and also to
what you encourage and document for your users.

gargle ships with JSON files for two non-functional OAuth clients, just
to make this all more concrete:

``` r
(path_to_installed_client <- system.file(
  "extdata", "client_secret_installed.googleusercontent.com.json",
  package = "gargle"
))
#> [1] "/home/runner/work/_temp/Library/gargle/extdata/client_secret_installed.googleusercontent.com.json"
jsonlite::prettify(scan(path_to_installed_client, what = character()))
#> {
#>     "installed": {
#>         "client_id": "abc.apps.googleusercontent.com",
#>         "project_id": "a_project",
#>         "auth_uri": "https://accounts.google.com/o/oauth2/auth",
#>         "token_uri": "https://accounts.google.com/o/oauth2/token",
#>         "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
#>         "client_secret": "ssshh-i-am-a-secret",
#>         "redirect_uris": [
#>             "http://localhost"
#>         ]
#>     }
#> }
#> 
(client <- gargle_oauth_client_from_json(path_to_installed_client))
#> <gargle_oauth_client>
#> name: a_project_d1c5a8066d2cbe48e8d94514dd286163
#> id: abc.apps.googleusercontent.com
#> secret: <REDACTED>
#> type: installed
#> redirect_uris: http://localhost
class(client)
#> [1] "gargle_oauth_client" "oauth_app"

(path_to_web_client <- system.file(
  "extdata", "client_secret_web.googleusercontent.com.json",
  package = "gargle"
))
#> [1] "/home/runner/work/_temp/Library/gargle/extdata/client_secret_web.googleusercontent.com.json"
jsonlite::prettify(scan(path_to_web_client, what = character()))
#> {
#>     "web": {
#>         "client_id": "abc.apps.googleusercontent.com",
#>         "project_id": "a_project",
#>         "auth_uri": "https://accounts.google.com/o/oauth2/auth",
#>         "token_uri": "https://accounts.google.com/o/oauth2/token",
#>         "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
#>         "client_secret": "ssshh-i-am-a-secret",
#>         "redirect_uris": [
#>             "https://www.tidyverse.org/google-callback/"
#>         ]
#>     }
#> }
#> 
(client <- gargle_oauth_client_from_json(path_to_web_client))
#> <gargle_oauth_client>
#> name: a_project_d1c5a8066d2cbe48e8d94514dd286163
#> id: abc.apps.googleusercontent.com
#> secret: <REDACTED>
#> type: web
#> redirect_uris: https://www.tidyverse.org/google-callback/
class(client)
#> [1] "gargle_oauth_client" "oauth_app"
```

Notice the difference in the JSON for the installed vs. web client. Note
the class of the `client` object, the new `type` field, and the
`redirect_uris`.

## `AuthState` class

There are two gargle classes that are impacted by the
OAuth-app-to-client switch: `AuthState` and `Gargle2.0`. We cover
`AuthState` here and `Gargle2.0` in the next section.

If a wrapper package follows the design laid out in
[`vignette("gargle-auth-in-client-package")`](https://gargle.r-lib.org/dev/articles/gargle-auth-in-client-package.md),
it will use an instance of `AuthState` to manage the package’s auth
state. Let’s assume that internal object is named `.auth`, which it
usually is. Here are the changes you need to know about in `AuthState`:

- The `app` field is deprecated, in favor of a new field `client`. If
  you request `.auth$app`, there will be a deprecation message and the
  `client` field is returned.
- The `$set_app()` method is deprecated, in favor of a new
  `$set_client()` method. If you call `.auth$set_app()`, there will be a
  deprecation message and the input is used, instead, to set the
  `client` field.
- The `app` argument of the
  [`init_AuthState()`](https://gargle.r-lib.org/dev/reference/init_AuthState.md)
  constructor is deprecated in favor of the new `client` argument. If
  you call `init_AuthState(app = x)`, there will be a deprecation
  message and the input `x` is used as the `client` argument instead.

Here are the changes you probably need to make in your package:

- The first argument of the user-facing function,
  `PKG_auth_configure()`, should become `client` (which is new). Move
  the existing `app` argument to the last position and deprecate it.
- Deprecate `PKG_oauth_app()` (the function to reveal the user’s
  configured OAuth client).
- Introduce `PKG_oauth_client()` to replace `PKG_oauth_app()`.

Here’s how `googledrive::drive_auth_configure()` and
`googledrive::drive_oauth_client()` looked before and after the
transition:

``` r
# BEFORE
drive_auth_configure <- function(app, path, api_key) {
  # not showing this code
  .auth$set_app(app)
  # more code we're not showing
}

drive_oauth_app <- function() .auth$app

# AFTER
drive_auth_configure <- function(client, path, api_key, app = deprecated()) {
  if (lifecycle::is_present(app)) {
    lifecycle::deprecate_warn(
      "2.1.0",
      "drive_auth_configure(app)",
      "drive_auth_configure(client)"
    )
    drive_auth_configure(client = app, path = path, api_key = api_key)
  } 
  
  # not showing this code
  .auth$set_client(client)
  # more code we're not showing
}

drive_oauth_client <- function() .auth$client

drive_oauth_app <- function() {
  lifecycle::deprecate_warn(
    "2.1.0", "drive_oauth_app()", "drive_oauth_client()"
  )
  drive_oauth_client()
}
```

The approach above follows various conventions explained in
[`vignette("communicate", package = "lifecycle")`](https://lifecycle.r-lib.org/articles/communicate.html).
If you also choose to use the lifecycle package to assist in this
process, `usethis::use_lifecycle()` function does some helpful one-time
setup in your package:

``` r
usethis::use_lifecycle()
```

The roxygen documentation helpers in gargle assume
`PKG_auth_configure()` is adapted as shown above:

- `PREFIX_auth_configure_description()` crosslinks to
  `PREFIX_oauth_client()` now, not `PREFIX_oauth_app()`.
- `PREFIX_auth_configure_params()` documents the `client` argument
- `PREFIX_auth_configure_params()` uses a lifecycle badge and text to
  communicate that `app` is deprecated.
- `PREFIX_auth_configure_params()` crosslinks to
  [`gargle::gargle_oauth_client_from_json()`](https://gargle.r-lib.org/dev/reference/gargle_oauth_client_from_json.md)
  which requires gargle (\>= 1.3.0)

## `Gargle2.0` class

`Gargle2.0` is the second gargle class that is impacted by the
OAuth-app-to-client switch.

Here are the changes you probably need to make in your package:

- Inside `PKG_auth()`, you presumably call
  [`gargle::token_fetch()`](https://gargle.r-lib.org/dev/reference/token_fetch.md).
  If you are passing `app = <SOMETHING>`, change that to
  `client = <SOMETHING>`. Neither `app` nor `client` are formal
  arguments of
  [`gargle::token_fetch()`](https://gargle.r-lib.org/dev/reference/token_fetch.md),
  instead, these are intended for eventual use by
  [`gargle::credentials_user_oauth2()`](https://gargle.r-lib.org/dev/reference/credentials_user_oauth2.md).
  Here’s a sketch of how this looks in `googledrive::drive_auth()`:

  ``` r
  drive_auth <- function(...) {
    # code not shown
    cred <- gargle::token_fetch(
      scopes = scopes,
      # app = drive_oauth_client() %||% <BUILT_IN_DEFAULT_CLIENT>,   # BEFORE
      client = drive_oauth_client() %||% <BUILT_IN_DEFAULT_CLIENT>,  # AFTER
      email = email,
      path = path,
      package = "googledrive",
      cache = cache,
      use_oob = use_oob,
      token = token
    )
    # code not shown
  }
  ```

- If you ever call
  [`gargle::credentials_user_oauth2()`](https://gargle.r-lib.org/dev/reference/credentials_user_oauth2.md)
  directly, use the new `client` argument instead of the deprecated
  `app` argument.
