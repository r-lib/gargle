# Encrypt/decrypt JSON or an R object

These functions help to encrypt and decrypt confidential information
that you might need when deploying gargle-using projects or in CI/CD.
They basically rely on inlined copies of the [secret functions in the
httr2 package](https://httr2.r-lib.org/reference/secrets.html). The
awkwardness of inlining code from httr2 can be removed if/when gargle
starts to depend on httr2.

- The `secret_encrypt_json()` + `secret_decrypt_json()` pair is unique
  to gargle, given how frequently Google auth relies on JSON files,
  e.g., service account tokens and OAuth clients.

- The `secret_write_rds()` + `secret_read_rds()` pair is just a copy of
  functions from httr2. They are handy if you need to secure a user
  token.

- `secret_make_key()` and `secret_has_key()` are also copies of
  functions from httr2. Use `secret_make_key` to generate a key. Use
  `secret_has_key()` to condition on key availability in, e.g.,
  examples, tests, or apps.

## Usage

``` r
secret_encrypt_json(json, path = NULL, key)

secret_decrypt_json(path, key)

secret_make_key()

secret_write_rds(x, path, key)

secret_read_rds(path, key)

secret_has_key(key)
```

## Arguments

- json:

  A JSON file (or string).

- path:

  The path to write to (`secret_encrypt_json()`, `secret_write_rds()`)
  or to read from (`secret_decrypt_json()`, `secret_read_rds()`).

- key:

  Encryption key, as implemented by httr2's [secret
  functions](https://httr2.r-lib.org/reference/secrets.html). This
  should almost always be the name of an environment variable whose
  value was generated with `secret_make_key()` (which is an inlined copy
  of
  [`httr2::secret_make_key()`](https://httr2.r-lib.org/reference/secrets.html)).

- x:

  An R object.

## Value

- `secret_encrypt_json()`: The encrypted JSON string, invisibly. In
  typical use, this function is mainly called for its side effect, which
  is to write an encrypted file.

- `secret_decrypt_json()`: The decrypted JSON string, invisibly.

- `secret_write_rds()`: `x`, invisibly

- `secret_read_rds()`: the decrypted object.

- `secret_make_key()`: a random string to use as an encryption key.

- `secret_has_key()` returns `TRUE` if the key is available and `FALSE`
  otherwise.

## Examples

``` r
# gargle ships with JSON for a fake service account
# here we put the encrypted JSON into a new file
tmp <- tempfile()
secret_encrypt_json(
  fs::path_package("gargle", "extdata", "fake_service_account.json"),
  tmp,
  key = "GARGLE_KEY"
)

# complete the round trip by providing the decrypted JSON to a credential
# function
credentials_service_account(
 scopes = "https://www.googleapis.com/auth/userinfo.email",
 path = secret_decrypt_json(
   fs::path_package("gargle", "secret", "gargle-testing.json"),
   key = "GARGLE_KEY"
 )
)
#> <Token>
#> <oauth_endpoint>
#>  authorize: https://accounts.google.com/o/oauth2/v2/auth
#>  access:    https://oauth2.googleapis.com/token
#>  validate:  https://oauth2.googleapis.com/tokeninfo
#>  revoke:    https://oauth2.googleapis.com/revoke
#> NULL
#> <credentials> access_token, expires_in, token_type
#> ---

file.remove(tmp)
#> [1] TRUE

# make an artificial Gargle2.0 token
fauxen <- gargle2.0_token(
  email = "jane@example.org",
  client = gargle_oauth_client(
    id = "CLIENT_ID", secret = "SECRET", name = "CLIENT"
  ),
  credentials = list(token = "fauxen"),
  cache = FALSE
)
fauxen
#> 
#> ── <Token (via gargle)> ───────────────────────────────────────────────
#> oauth_endpoint: google
#>         client: CLIENT
#>          email: jane@example.org
#>         scopes: ...userinfo.email
#>    credentials: token

# store the fake token in an encrypted file
tmp2 <- tempfile()
secret_write_rds(fauxen, path = tmp2, key = "GARGLE_KEY")

# complete the round trip by providing the decrypted token to the "BYO token"
# credential function
rt_fauxen <- credentials_byo_oauth2(
  token  = secret_read_rds(tmp2, key = "GARGLE_KEY")
)
rt_fauxen
#> 
#> ── <Token (via gargle)> ───────────────────────────────────────────────
#> oauth_endpoint: google
#>         client: CLIENT
#>          email: jane@example.org
#>         scopes: ...userinfo.email
#>    credentials: token

file.remove(tmp2)
#> [1] TRUE
```
