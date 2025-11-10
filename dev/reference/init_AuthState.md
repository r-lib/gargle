# Create an AuthState

Constructor function for objects of class
[AuthState](https://gargle.r-lib.org/dev/reference/AuthState-class.md).

## Usage

``` r
init_AuthState(
  package = NA_character_,
  client = NULL,
  api_key = NULL,
  auth_active = TRUE,
  cred = NULL,
  app = deprecated()
)
```

## Arguments

- package:

  Package name, an optional string. It is recommended to record the name
  of the package whose auth state is being managed. Ultimately, this may
  be used in some downstream messaging.

- client:

  A Google OAuth client, preferably constructed via
  [`gargle_oauth_client_from_json()`](https://gargle.r-lib.org/dev/reference/gargle_oauth_client_from_json.md),
  which returns an instance of `gargle_oauth_client`. For backwards
  compatibility, for a limited time, gargle will still accept an "OAuth
  app" created with
  [`httr::oauth_app()`](https://httr.r-lib.org/reference/oauth_app.html).

- api_key:

  Optional. API key (a string). Some APIs accept unauthorized,
  "token-free" requests for public resources, but only if the request
  includes an API key.

- auth_active:

  Logical. `TRUE` means requests should include a token (and probably
  not an API key). `FALSE` means requests should include an API key (and
  probably not a token).

- cred:

  Credentials. Typically populated indirectly via
  [`token_fetch()`](https://gargle.r-lib.org/dev/reference/token_fetch.md).

- app:

  **\[deprecated\]** Replaced by the `client` argument.

## Value

An object of class
[AuthState](https://gargle.r-lib.org/dev/reference/AuthState-class.md).

## Examples

``` r
my_client <- gargle_oauth_client(
  id = "some_long_client_id",
  secret = "ssshhhhh_its_a_secret",
  name = "my-nifty-oauth-client"
)

init_AuthState(
  package = "my_package",
  client = my_client,
  api_key = "api_key_api_key_api_key",
)
#> 
#> ── <AuthState (via gargle)> ───────────────────────────────────────────
#>     package: my_package
#>      client: my-nifty-oauth-client
#>     api_key: api_key...
#> auth_active: TRUE
#> credentials: <NULL>
```
