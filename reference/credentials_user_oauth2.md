# Get an OAuth token for a user

Consults the token cache for a suitable OAuth token and, if
unsuccessful, gets a token via the browser flow. A cached token is
suitable if it's compatible with the user's request in this sense:

- OAuth client must be same.

- Scopes must be same.

- Email, if provided, must be same. If specified email is a glob pattern
  like `"*@example.com"`, email matching is done at the domain level.

gargle is very conservative about using OAuth tokens discovered in the
user's cache and will generally seek interactive confirmation.
Therefore, in a non-interactive setting, it's important to explicitly
specify the `"email"` of the target account or to explicitly authorize
automatic discovery. See
[`gargle2.0_token()`](https://gargle.r-lib.org/reference/gargle2.0_token.md),
which this function wraps, for more. Non-interactive use also suggests
it might be time to use a [service account
token](https://gargle.r-lib.org/reference/credentials_service_account.md)
or [workload identity
federation](https://gargle.r-lib.org/reference/credentials_external_account.md).

## Usage

``` r
credentials_user_oauth2(
  scopes = NULL,
  client = gargle_client(),
  package = "gargle",
  ...,
  app = deprecated()
)
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

- client:

  A Google OAuth client, preferably constructed via
  [`gargle_oauth_client_from_json()`](https://gargle.r-lib.org/reference/gargle_oauth_client_from_json.md),
  which returns an instance of `gargle_oauth_client`. For backwards
  compatibility, for a limited time, gargle will still accept an "OAuth
  app" created with
  [`httr::oauth_app()`](https://httr.r-lib.org/reference/oauth_app.html).

- package:

  Name of the package requesting a token. Used in messages.

- ...:

  Arguments passed on to
  [`gargle2.0_token`](https://gargle.r-lib.org/reference/gargle2.0_token.md)

  `email`

  :   Optional. If specified, `email` can take several different forms:

      - `"jane@gmail.com"`, i.e. an actual email address. This allows
        the user to target a specific Google identity. If specified,
        this is used for token lookup, i.e. to determine if a suitable
        token is already available in the cache. If no such token is
        found, `email` is used to pre-select the targeted Google
        identity in the OAuth chooser. (Note, however, that the email
        associated with a token when it's cached is always determined
        from the token itself, never from this argument).

      - `"*@example.com"`, i.e. a domain-only glob pattern. This can be
        helpful if you need code that "just works" for both
        `alice@example.com` and `bob@example.com`.

      - `TRUE` means that you are approving email auto-discovery. If
        exactly one matching token is found in the cache, it will be
        used.

      - `FALSE` or `NA` mean that you want to ignore the token cache and
        force a new OAuth dance in the browser.

      Defaults to the option named `"gargle_oauth_email"`, retrieved by
      [`gargle_oauth_email()`](https://gargle.r-lib.org/reference/gargle_options.md)
      (unless a wrapper package implements different default behavior).

  `use_oob`

  :   Whether to use out-of-band authentication (or, perhaps, a variant
      implemented by gargle and known as "pseudo-OOB") when first
      acquiring the token. Defaults to the value returned by
      [`gargle_oob_default()`](https://gargle.r-lib.org/reference/gargle_options.md).
      Note that (pseudo-)OOB auth only affects the initial OAuth dance.
      If we retrieve (and possibly refresh) a cached token, `use_oob`
      has no effect.

      If the OAuth client is provided implicitly by a wrapper package,
      its type probably defaults to the value returned by
      [`gargle_oauth_client_type()`](https://gargle.r-lib.org/reference/gargle_options.md).
      You can take control of the client type by setting
      `options(gargle_oauth_client_type = "web")` or
      `options(gargle_oauth_client_type = "installed")`.

  `cache`

  :   Specifies the OAuth token cache. Defaults to the option named
      `"gargle_oauth_cache"`, retrieved via
      [`gargle_oauth_cache()`](https://gargle.r-lib.org/reference/gargle_options.md).

  `credentials`

  :   Advanced use only: allows you to completely customise token
      generation.

- app:

  **\[deprecated\]** Replaced by the `client` argument.

## Value

A [Gargle2.0](https://gargle.r-lib.org/reference/Gargle-class.md) token.

## See also

Other credential functions:
[`credentials_app_default()`](https://gargle.r-lib.org/reference/credentials_app_default.md),
[`credentials_byo_oauth2()`](https://gargle.r-lib.org/reference/credentials_byo_oauth2.md),
[`credentials_external_account()`](https://gargle.r-lib.org/reference/credentials_external_account.md),
[`credentials_gce()`](https://gargle.r-lib.org/reference/credentials_gce.md),
[`credentials_service_account()`](https://gargle.r-lib.org/reference/credentials_service_account.md),
[`token_fetch()`](https://gargle.r-lib.org/reference/token_fetch.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Drive scope, built-in gargle demo client
scopes <- "https://www.googleapis.com/auth/drive"
credentials_user_oauth2(scopes, client = gargle_client())

# bring your own client
client <- gargle_oauth_client_from_json(
  path = "/path/to/the/JSON/you/downloaded/from/gcp/console.json",
  name = "my-nifty-oauth-client"
)
credentials_user_oauth2(scopes, client)
} # }
```
