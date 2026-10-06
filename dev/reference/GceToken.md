# Token for use on Google Compute Engine instances

This class uses the metadata service available on GCE VMs to fetch
access tokens. Not intended for direct use. See
[`credentials_gce()`](https://gargle.r-lib.org/dev/reference/credentials_gce.md)
instead.

## Super classes

[`httr::Token`](https://httr.r-lib.org/reference/Token-class.html) -\>
[`httr::Token2.0`](https://httr.r-lib.org/reference/Token-class.html)
-\> `GceToken`

## Methods

### Public methods

- [`GceToken$new()`](#method-GceToken-initialize)

- [`GceToken$init_credentials()`](#method-GceToken-init_credentials)

- [`GceToken$refresh()`](#method-GceToken-refresh)

- [`GceToken$can_refresh()`](#method-GceToken-can_refresh)

- [`GceToken$format()`](#method-GceToken-format)

- [`GceToken$print()`](#method-GceToken-print)

- [`GceToken$cache()`](#method-GceToken-cache)

- [`GceToken$load_from_cache()`](#method-GceToken-load_from_cache)

- [`GceToken$revoke()`](#method-GceToken-revoke)

- [`GceToken$validate()`](#method-GceToken-validate)

- [`GceToken$clone()`](#method-GceToken-clone)

Inherited methods

- [`httr::Token$hash()`](https://httr.r-lib.org/reference/Token-class.html#method-hash)
- [`httr::Token2.0$sign()`](https://httr.r-lib.org/reference/Token-class.html#method-sign)

------------------------------------------------------------------------

### `GceToken$new()`

Get an access for a GCE service account.

#### Usage

    GceToken$new(params)

#### Arguments

- `params`:

  A list of parameters for `fetch_gce_access_token()`.

#### Returns

A GceToken.

------------------------------------------------------------------------

### `GceToken$init_credentials()`

Request an access token.

#### Usage

    GceToken$init_credentials()

------------------------------------------------------------------------

### `GceToken$refresh()`

Refreshes the token. In this case, that just means "ask again for an
access token".

#### Usage

    GceToken$refresh()

------------------------------------------------------------------------

### `GceToken$can_refresh()`

Placeholder implementation of required method. Returns `TRUE`.

#### Usage

    GceToken$can_refresh()

------------------------------------------------------------------------

### `GceToken$format()`

Format a `GceToken()`.

#### Usage

    GceToken$format(...)

#### Arguments

- `...`:

  Not used.

------------------------------------------------------------------------

### `GceToken$print()`

Print a `GceToken()`.

#### Usage

    GceToken$print(...)

#### Arguments

- `...`:

  Not used.

------------------------------------------------------------------------

### `GceToken$cache()`

Placeholder implementation of required method.

#### Usage

    GceToken$cache()

------------------------------------------------------------------------

### `GceToken$load_from_cache()`

Placeholder implementation of required method.

#### Usage

    GceToken$load_from_cache()

------------------------------------------------------------------------

### `GceToken$revoke()`

Placeholder implementation of required method.

#### Usage

    GceToken$revoke()

------------------------------------------------------------------------

### `GceToken$validate()`

Placeholder implementation of required method

#### Usage

    GceToken$validate()

------------------------------------------------------------------------

### `GceToken$clone()`

The objects of this class are cloneable with this method.

#### Usage

    GceToken$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
