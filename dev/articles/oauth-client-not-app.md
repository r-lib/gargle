# Transition from OAuth app to OAuth client

``` r

library(gargle)
```

In 2023, over the course of versions 1.3.0, 1.4.0, and 1.5.0, gargle
switched from an OAuth “app” to an OAuth **client** in the user flow
facilitated by
[`credentials_user_oauth2()`](https://gargle.r-lib.org/dev/reference/credentials_user_oauth2.md).
gargle introduced client-based functions, arguments, and fields and
deprecated the app-based ones, while keeping them working.

That transition is now wrapping up, in two stages:

1.  Wrapper packages remove their own deprecated `app` interfaces, such
    as the `app` argument of `PKG_auth_configure()` and the
    `PKG_oauth_app()` function, and stop using gargle’s deprecated `app`
    interfaces. The tidyverse and r-lib packages that wrap Google APIs
    are doing this now.
2.  A future version of gargle removes its own deprecated `app`
    arguments, methods, and functions.

This vignette is a checklist for maintainers of wrapper packages. A
package that satisfies every item is ready for both stages.

## Background

In 2022, Google partially deprecated the conventional out-of-band (OOB)
OAuth flow, which is how many people authenticate when they use R in a
browser, e.g., on Posit Workbench or Google Colaboratory. In response,
gargle 1.3.0 introduced a new flow, pseudo-OOB, that needs to know the
type of the OAuth client (“installed” or “web”) and its redirect URIs.
[`httr::oauth_app()`](https://httr.r-lib.org/reference/oauth_app.html),
which gargle had been using to store a client’s ID and secret, has no
place for this information, so gargle introduced a new S3 class,
`"gargle_oauth_client"`. We also took the chance to adopt the term
“OAuth client”, which is what Google’s documentation has always used
(and what httr2 uses, in
[`httr2::oauth_client()`](https://httr2.r-lib.org/reference/oauth_client.html)).
For now, the `"gargle_oauth_client"` class also inherits from httr’s
`"oauth_app"` class, but don’t rely on that.

See
[`vignette("auth-from-web")`](https://gargle.r-lib.org/dev/articles/auth-from-web.md)
for more about conventional OOB, pseudo-OOB, and client types.

## Checklist for wrapper packages

The examples below come from googledrive, whose prefix is `drive`. They
assume the design laid out in
[`vignette("gargle-auth-in-client-package")`](https://gargle.r-lib.org/dev/articles/gargle-auth-in-client-package.md),
in which an internal `AuthState` object named `.auth` manages the
package’s auth state.

### Create OAuth clients with gargle

Create an OAuth client with
[`gargle_oauth_client_from_json()`](https://gargle.r-lib.org/dev/reference/gargle_oauth_client_from_json.md)
(strongly recommended) or
[`gargle_oauth_client()`](https://gargle.r-lib.org/dev/reference/gargle_oauth_client_from_json.md).
Don’t use
[`httr::oauth_app()`](https://httr.r-lib.org/reference/oauth_app.html)
or the deprecated
[`oauth_app_from_json()`](https://gargle.r-lib.org/dev/reference/oauth_app_from_json.md).
Likewise, use
[`gargle_client()`](https://gargle.r-lib.org/dev/reference/gargle_client.md),
not the deprecated
[`gargle_app()`](https://gargle.r-lib.org/dev/reference/oauth_app_from_json.md),
and, in a tidyverse package, use
[`tidyverse_client()`](https://gargle.r-lib.org/dev/reference/internal-assets.md),
not the deprecated
[`tidyverse_app()`](https://gargle.r-lib.org/dev/reference/internal-assets.md).
This applies to your package’s code and to what you show your users in
examples and documentation.

The JSON downloaded from Google Cloud Console records the client’s type
and redirect URIs, which is why it’s the preferred way to create a
client. gargle ships with JSON for a non-functional client of each type.
Here’s the “web” one:

``` r

path <- system.file(
  "extdata", "client_secret_web.googleusercontent.com.json",
  package = "gargle"
)
(client <- gargle_oauth_client_from_json(path))
#> <gargle_oauth_client>
#> name: a_project_59aa1797ab7ac4667a77617c3400999c
#> id: abc.apps.googleusercontent.com
#> secret: <REDACTED>
#> type: web
#> redirect_uris: https://www.tidyverse.org/google-callback/
class(client)
#> [1] "gargle_oauth_client" "oauth_app"
```

The “installed” one is
`client_secret_installed.googleusercontent.com.json`, in the same
folder.

### Use the `client` interfaces of `AuthState`

- Create the auth state with `init_AuthState(client = )`, not
  `init_AuthState(app = )`.
- Set the client with `.auth$set_client()`, not `.auth$set_app()`.
- Get the client from `.auth$client`, not `.auth$app`. The `app` field
  exists only for backwards compatibility and `$set_client()` doesn’t
  update it.

### Pass `client` to gargle’s token functions

Inside `PKG_auth()`, you presumably call
[`token_fetch()`](https://gargle.r-lib.org/dev/reference/token_fetch.md).
Pass the OAuth client as `client`, not `app`. Neither is a formal
argument of
[`token_fetch()`](https://gargle.r-lib.org/dev/reference/token_fetch.md);
it’s passed along to
[`credentials_user_oauth2()`](https://gargle.r-lib.org/dev/reference/credentials_user_oauth2.md).
Here’s a sketch of `googledrive::drive_auth()`:

``` r

drive_auth <- function(...) {
  # code not shown
  cred <- gargle::token_fetch(
    scopes = scopes,
    client = drive_oauth_client() %||% gargle::tidyverse_client(),
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

If you call
[`credentials_user_oauth2()`](https://gargle.r-lib.org/dev/reference/credentials_user_oauth2.md)
or
[`gargle2.0_token()`](https://gargle.r-lib.org/dev/reference/gargle2.0_token.md)
directly, use their `client` argument, not `app`.

### Finish the user-facing functions

`PKG_auth_configure()` should take `client` as its first argument and
should have no `app` argument. `PKG_oauth_client()` reveals the user’s
configured client and `PKG_oauth_app()` should not exist.

If your package deprecated `app` and `PKG_oauth_app()` during the
transition, it’s time to remove them, along with the
`lifecycle::is_present(app)` branch in `PKG_auth_configure()`. Mention
the removal in `NEWS.md`. Here’s how this looks in googledrive:

``` r

drive_auth_configure <- function(client, path, api_key) {
  # code not shown
  .auth$set_client(client)
  # code not shown
}

drive_oauth_client <- function() .auth$client
```

If your package still has `app` as the main argument of
`PKG_auth_configure()`, you can’t remove it right away, because your
users may be relying on it. Introduce `client` and `PKG_oauth_client()`
and deprecate `app` and `PKG_oauth_app()` for at least one release,
following the conventions in
[`vignette("communicate", package = "lifecycle")`](https://lifecycle.r-lib.org/articles/communicate.html).

### Re-document with current gargle

gargle has unexported roxygen helpers that generate standard
documentation for auth functions, e.g.,
`#' @eval gargle:::PREFIX_auth_configure_params()`. In current gargle:

- `PREFIX_auth_configure_description()` crosslinks to
  `PREFIX_oauth_client()`, not `PREFIX_oauth_app()`.
- `PREFIX_auth_configure_params()` documents the `client` argument and
  crosslinks to
  [`gargle_oauth_client_from_json()`](https://gargle.r-lib.org/dev/reference/gargle_oauth_client_from_json.md),
  which requires gargle (\>= 1.3.0).
- `PREFIX_auth_configure_params()` does not document `app`.

These helpers run when you re-document, so the gargle version installed
at that moment is what matters. Re-document with current gargle after
you remove `app` from `PKG_auth_configure()`. An older gargle documents
`app`, which leads to an `R CMD check` warning about a documented
argument that’s not in the function’s usage.

## What’s next in gargle

Once wrapper packages have made these changes, a future version of
gargle will remove its own deprecated `app` interfaces:

- The `app` argument of
  [`init_AuthState()`](https://gargle.r-lib.org/dev/reference/init_AuthState.md),
  `AuthState$new()`,
  [`credentials_user_oauth2()`](https://gargle.r-lib.org/dev/reference/credentials_user_oauth2.md),
  [`gargle2.0_token()`](https://gargle.r-lib.org/dev/reference/gargle2.0_token.md),
  and `Gargle2.0$new()`.
- The `app` field and the `$set_app()` method of `AuthState`.
- [`oauth_app_from_json()`](https://gargle.r-lib.org/dev/reference/oauth_app_from_json.md),
  [`gargle_app()`](https://gargle.r-lib.org/dev/reference/oauth_app_from_json.md),
  and
  [`tidyverse_app()`](https://gargle.r-lib.org/dev/reference/internal-assets.md).

A package that satisfies the checklist above won’t be affected.
