# Authorization state

An `AuthState` object manages an authorization state, typically on
behalf of a wrapper package that makes requests to a Google API.

The `vignette("gargle-auth-in-client-package)` describes a design for
wrapper packages that relies on an `AuthState` object. This state can
then be incorporated into the package's requests for tokens and can
control the inclusion of tokens in requests to the target API.

- `api_key` is the simplest way to associate a request with a specific
  Google Cloud Platform
  [project](https://docs.cloud.google.com/resource-manager/docs/cloud-platform-resource-hierarchy).
  A few calls to certain APIs, e.g. reading a public Sheet, can succeed
  with an API key, but this is the exception.

- `client` is an OAuth client ID (and secret) associated with a specific
  Google Cloud Platform
  [project](https://docs.cloud.google.com/resource-manager/docs/cloud-platform-resource-hierarchy).
  This is used in the OAuth flow, in which an authenticated user
  authorizes the client to access or manipulate data on their behalf.

- `auth_active` reflects whether outgoing requests will be authorized by
  an authenticated user or are unauthorized requests for public
  resources. These two states correspond to sending a request with a
  token versus an API key, respectively.

- `cred` is where the current token is cached within a session, once one
  has been fetched. It is generally assumed to be an instance of
  [`httr::TokenServiceAccount`](https://httr.r-lib.org/reference/Token-class.html)
  or
  [`httr::Token2.0`](https://httr.r-lib.org/reference/Token-class.html)
  (or a subclass thereof), probably obtained via
  [`token_fetch()`](https://gargle.r-lib.org/dev/reference/token_fetch.md)
  (or one of its constituent credential fetching functions).

An `AuthState` should be created through the constructor function
[`init_AuthState()`](https://gargle.r-lib.org/dev/reference/init_AuthState.md),
which has more details on the arguments.

## Public fields

- `package`:

  Package name.

- `client`:

  An OAuth client.

- `app`:

  **\[deprecated\]** Use `client` instead.

- `api_key`:

  An API key.

- `auth_active`:

  Logical, indicating whether auth is active.

- `cred`:

  Credentials.

## Methods

### Public methods

- [`AuthState$new()`](#method-AuthState-new)

- [`AuthState$format()`](#method-AuthState-format)

- [`AuthState$set_client()`](#method-AuthState-set_client)

- [`AuthState$set_app()`](#method-AuthState-set_app)

- [`AuthState$set_api_key()`](#method-AuthState-set_api_key)

- [`AuthState$set_auth_active()`](#method-AuthState-set_auth_active)

- [`AuthState$set_cred()`](#method-AuthState-set_cred)

- [`AuthState$clear_cred()`](#method-AuthState-clear_cred)

- [`AuthState$get_cred()`](#method-AuthState-get_cred)

- [`AuthState$has_cred()`](#method-AuthState-has_cred)

- [`AuthState$clone()`](#method-AuthState-clone)

------------------------------------------------------------------------

### Method `new()`

Create a new AuthState

#### Usage

    AuthState$new(
      package = NA_character_,
      client = NULL,
      api_key = NULL,
      auth_active = TRUE,
      cred = NULL,
      app = deprecated()
    )

#### Arguments

- `package`:

  Package name.

- `client`:

  An OAuth client.

- `api_key`:

  An API key.

- `auth_active`:

  Logical, indicating whether auth is active.

- `cred`:

  Credentials.

- `app`:

  **\[deprecated\]** Use `client` instead.

#### Details

For more details on the parameters, see
[`init_AuthState()`](https://gargle.r-lib.org/dev/reference/init_AuthState.md)

------------------------------------------------------------------------

### Method [`format()`](https://rdrr.io/r/base/format.html)

Format an AuthState

#### Usage

    AuthState$format(...)

#### Arguments

- `...`:

  Not used.

------------------------------------------------------------------------

### Method `set_client()`

Set the OAuth client

#### Usage

    AuthState$set_client(client)

#### Arguments

- `client`:

  An OAuth client.

------------------------------------------------------------------------

### Method `set_app()`

**\[deprecated\]** Deprecated method to set the OAuth client

#### Usage

    AuthState$set_app(app)

#### Arguments

- `app`:

  **\[deprecated\]** Use `client` instead.

------------------------------------------------------------------------

### Method `set_api_key()`

Set the API key

#### Usage

    AuthState$set_api_key(value)

#### Arguments

- `value`:

  An API key.

------------------------------------------------------------------------

### Method `set_auth_active()`

Set whether auth is (in)active

#### Usage

    AuthState$set_auth_active(value)

#### Arguments

- `value`:

  Logical, indicating whether to send requests authorized with user
  credentials.

------------------------------------------------------------------------

### Method `set_cred()`

Set credentials

#### Usage

    AuthState$set_cred(cred)

#### Arguments

- `cred`:

  User credentials.

------------------------------------------------------------------------

### Method `clear_cred()`

Clear credentials

#### Usage

    AuthState$clear_cred()

------------------------------------------------------------------------

### Method `get_cred()`

Get credentials

#### Usage

    AuthState$get_cred()

------------------------------------------------------------------------

### Method `has_cred()`

Report if we have credentials

#### Usage

    AuthState$has_cred()

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    AuthState$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
