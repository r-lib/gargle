# Generate a gargle token

Constructor function for objects of class
[Gargle2.0](https://gargle.r-lib.org/dev/reference/Gargle-class.md).

## Usage

``` r
gargle2.0_token(
  email = gargle_oauth_email(),
  client = gargle_client(),
  package = "gargle",
  scope = NULL,
  use_oob = gargle_oob_default(),
  credentials = NULL,
  cache = if (is.null(credentials)) gargle_oauth_cache() else FALSE,
  ...,
  app = deprecated()
)
```

## Arguments

- email:

  Optional. If specified, `email` can take several different forms:

  - `"jane@gmail.com"`, i.e. an actual email address. This allows the
    user to target a specific Google identity. If specified, this is
    used for token lookup, i.e. to determine if a suitable token is
    already available in the cache. If no such token is found, `email`
    is used to pre-select the targeted Google identity in the OAuth
    chooser. (Note, however, that the email associated with a token when
    it's cached is always determined from the token itself, never from
    this argument).

  - `"*@example.com"`, i.e. a domain-only glob pattern. This can be
    helpful if you need code that "just works" for both
    `alice@example.com` and `bob@example.com`.

  - `TRUE` means that you are approving email auto-discovery. If exactly
    one matching token is found in the cache, it will be used.

  - `FALSE` or `NA` mean that you want to ignore the token cache and
    force a new OAuth dance in the browser.

  Defaults to the option named `"gargle_oauth_email"`, retrieved by
  [`gargle_oauth_email()`](https://gargle.r-lib.org/dev/reference/gargle_options.md)
  (unless a wrapper package implements different default behavior).

- client:

  A Google OAuth client, preferably constructed via
  [`gargle_oauth_client_from_json()`](https://gargle.r-lib.org/dev/reference/gargle_oauth_client_from_json.md),
  which returns an instance of `gargle_oauth_client`. For backwards
  compatibility, for a limited time, gargle will still accept an "OAuth
  app" created with
  [`httr::oauth_app()`](https://httr.r-lib.org/reference/oauth_app.html).

- package:

  Name of the package requesting a token. Used in messages.

- scope:

  A character vector of scopes to request.

- use_oob:

  Whether to use out-of-band authentication (or, perhaps, a variant
  implemented by gargle and known as "pseudo-OOB") when first acquiring
  the token. Defaults to the value returned by
  [`gargle_oob_default()`](https://gargle.r-lib.org/dev/reference/gargle_options.md).
  Note that (pseudo-)OOB auth only affects the initial OAuth dance. If
  we retrieve (and possibly refresh) a cached token, `use_oob` has no
  effect.

  If the OAuth client is provided implicitly by a wrapper package, its
  type probably defaults to the value returned by
  [`gargle_oauth_client_type()`](https://gargle.r-lib.org/dev/reference/gargle_options.md).
  You can take control of the client type by setting
  `options(gargle_oauth_client_type = "web")` or
  `options(gargle_oauth_client_type = "installed")`.

- credentials:

  Advanced use only: allows you to completely customise token
  generation.

- cache:

  Specifies the OAuth token cache. Defaults to the option named
  `"gargle_oauth_cache"`, retrieved via
  [`gargle_oauth_cache()`](https://gargle.r-lib.org/dev/reference/gargle_options.md).

- ...:

  Absorbs arguments intended for use by other credential functions. Not
  used.

- app:

  **\[deprecated\]** Replaced by the `client` argument.

## Value

An object of class
[Gargle2.0](https://gargle.r-lib.org/dev/reference/Gargle-class.md),
either new or loaded from the cache.

## Examples

``` r
if (FALSE) { # \dontrun{
gargle2.0_token()
} # }
```
