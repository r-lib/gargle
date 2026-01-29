# OAuth2 token objects specific to Google APIs

`Gargle2.0` is based on the
[`Token2.0`](https://httr.r-lib.org/reference/Token-class.html) class
provided in httr. The preferred way to create a `Gargle2.0` token is
through the constructor function
[`gargle2.0_token()`](https://gargle.r-lib.org/reference/gargle2.0_token.md).
Key differences with `Token2.0`:

- The key for a cached `Token2.0` comes from hashing the endpoint,
  client, and scopes. For the `Gargle2.0` subclass, the identifier or
  key is expanded to include the email address associated with the
  token. This makes it easier to work with Google APIs with multiple
  identities.

- `Gargle2.0` tokens are cached, by default, at the user level,
  following the XDG spec for storing user-specific data and cache files.
  In contrast, the default location for `Token2.0` is `./.httr-oauth`,
  i.e. in current working directory. `Gargle2.0` behaviour makes it
  easier to reuse tokens across projects and makes it less likely that
  tokens are accidentally synced to a remote location like GitHub or
  DropBox.

- Each `Gargle2.0` token is cached in its own file. The token cache is a
  directory of such files. In contrast, `Token2.0` tokens are cached as
  components of a list, which is typically serialized to
  `./.httr-oauth`.

## Super classes

[`httr::Token`](https://httr.r-lib.org/reference/Token-class.html) -\>
[`httr::Token2.0`](https://httr.r-lib.org/reference/Token-class.html)
-\> `Gargle2.0`

## Public fields

- `email`:

  Email associated with the token.

- `package`:

  Name of the package requesting a token. Used in messages.

- `client`:

  An OAuth client.

## Methods

### Public methods

- [`Gargle2.0$new()`](#method-Gargle2.0-new)

- [`Gargle2.0$format()`](#method-Gargle2.0-format)

- [`Gargle2.0$print()`](#method-Gargle2.0-print)

- [`Gargle2.0$hash()`](#method-Gargle2.0-hash)

- [`Gargle2.0$cache()`](#method-Gargle2.0-cache)

- [`Gargle2.0$load_from_cache()`](#method-Gargle2.0-load_from_cache)

- [`Gargle2.0$refresh()`](#method-Gargle2.0-refresh)

- [`Gargle2.0$init_credentials()`](#method-Gargle2.0-init_credentials)

- [`Gargle2.0$clone()`](#method-Gargle2.0-clone)

Inherited methods

- [`httr::Token2.0$can_refresh()`](https://gargle.r-lib.org/httr/html/Token2.0.html#method-Token2.0-can_refresh)
- [`httr::Token2.0$revoke()`](https://gargle.r-lib.org/httr/html/Token2.0.html#method-Token2.0-revoke)
- [`httr::Token2.0$sign()`](https://gargle.r-lib.org/httr/html/Token2.0.html#method-Token2.0-sign)
- [`httr::Token2.0$validate()`](https://gargle.r-lib.org/httr/html/Token2.0.html#method-Token2.0-validate)

------------------------------------------------------------------------

### Method `new()`

Create a Gargle2.0 token

#### Usage

    Gargle2.0$new(
      email = gargle_oauth_email(),
      client = gargle_client(),
      package = "gargle",
      credentials = NULL,
      params = list(),
      cache_path = gargle_oauth_cache(),
      app = deprecated()
    )

#### Arguments

- `email`:

  Optional email address. See
  [`gargle2.0_token()`](https://gargle.r-lib.org/reference/gargle2.0_token.md)
  for full details.

- `client`:

  An OAuth consumer application.

- `package`:

  Name of the package requesting a token. Used in messages.

- `credentials`:

  Exists largely for testing purposes.

- `params`:

  A list of parameters for the internal function `init_oauth2.0()`,
  which is a modified version of
  [`httr::init_oauth2.0()`](https://httr.r-lib.org/reference/init_oauth2.0.html).
  gargle actively uses `scope` and `use_oob`, but does not use
  `user_params`, `type`, `as_header` (hard-wired to `TRUE`),
  `use_basic_auth` (accept default of `use_basic_auth = FALSE`),
  `config_init`, or `client_credentials`.

- `cache_path`:

  Specifies the OAuth token cache. Read more in
  [`gargle_oauth_cache()`](https://gargle.r-lib.org/reference/gargle_options.md).

- `app`:

  **\[deprecated\]** Use `client` instead.

#### Returns

A Gargle2.0 token.

------------------------------------------------------------------------

### Method [`format()`](https://rdrr.io/r/base/format.html)

Format a Gargle2.0 token

#### Usage

    Gargle2.0$format(...)

#### Arguments

- `...`:

  Not used.

------------------------------------------------------------------------

### Method [`print()`](https://rdrr.io/r/base/print.html)

Print a Gargle2.0 token

#### Usage

    Gargle2.0$print(...)

#### Arguments

- `...`:

  Not used.

------------------------------------------------------------------------

### Method `hash()`

Generate the email-augmented hash of a Gargle2.0 token

#### Usage

    Gargle2.0$hash()

------------------------------------------------------------------------

### Method `cache()`

Put a Gargle2.0 token into the cache

#### Usage

    Gargle2.0$cache()

------------------------------------------------------------------------

### Method `load_from_cache()`

(Attempt to) get a Gargle2.0 token from the cache

#### Usage

    Gargle2.0$load_from_cache()

------------------------------------------------------------------------

### Method `refresh()`

(Attempt to) refresh a Gargle2.0 token

#### Usage

    Gargle2.0$refresh()

------------------------------------------------------------------------

### Method `init_credentials()`

Initiate a new Gargle2.0 token

#### Usage

    Gargle2.0$init_credentials()

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    Gargle2.0$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
