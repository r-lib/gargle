# Token for use with workload identity federation

Not intended for direct use. See
[`credentials_external_account()`](https://gargle.r-lib.org/dev/reference/credentials_external_account.md)
instead.

## Super classes

[`httr::Token`](https://httr.r-lib.org/reference/Token-class.html) -\>
[`httr::Token2.0`](https://httr.r-lib.org/reference/Token-class.html)
-\> `WifToken`

## Methods

### Public methods

- [`WifToken$new()`](#method-WifToken-initialize)

- [`WifToken$init_credentials()`](#method-WifToken-init_credentials)

- [`WifToken$refresh()`](#method-WifToken-refresh)

- [`WifToken$format()`](#method-WifToken-format)

- [`WifToken$print()`](#method-WifToken-print)

- [`WifToken$can_refresh()`](#method-WifToken-can_refresh)

- [`WifToken$cache()`](#method-WifToken-cache)

- [`WifToken$load_from_cache()`](#method-WifToken-load_from_cache)

- [`WifToken$validate()`](#method-WifToken-validate)

- [`WifToken$revoke()`](#method-WifToken-revoke)

- [`WifToken$clone()`](#method-WifToken-clone)

Inherited methods

- [`httr::Token$hash()`](https://gargle.r-lib.org/httr/html/Token.html#method-Token-hash)
- [`httr::Token2.0$sign()`](https://gargle.r-lib.org/httr/html/Token2.0.html#method-Token2.0-sign)

------------------------------------------------------------------------

### `WifToken$new()`

Get a token via workload identity federation

#### Usage

    WifToken$new(params = list())

#### Arguments

- `params`:

  A list of parameters for `init_oauth_external_account()`.

#### Returns

A WifToken.

------------------------------------------------------------------------

### `WifToken$init_credentials()`

Enact the actual token exchange for workload identity federation.

#### Usage

    WifToken$init_credentials()

------------------------------------------------------------------------

### `WifToken$refresh()`

Refreshes the token, which means re-doing the entire token flow in this
case.

#### Usage

    WifToken$refresh()

------------------------------------------------------------------------

### `WifToken$format()`

Format a `WifToken()`.

#### Usage

    WifToken$format(...)

#### Arguments

- `...`:

  Not used.

------------------------------------------------------------------------

### `WifToken$print()`

Print a `WifToken()`.

#### Usage

    WifToken$print(...)

#### Arguments

- `...`:

  Not used.

------------------------------------------------------------------------

### `WifToken$can_refresh()`

Placeholder implementation of required method. Returns `TRUE`.

#### Usage

    WifToken$can_refresh()

------------------------------------------------------------------------

### `WifToken$cache()`

Placeholder implementation of required method. Returns self.

#### Usage

    WifToken$cache()

------------------------------------------------------------------------

### `WifToken$load_from_cache()`

Placeholder implementation of required method. Returns self.

#### Usage

    WifToken$load_from_cache()

------------------------------------------------------------------------

### `WifToken$validate()`

Placeholder implementation of required method.

#### Usage

    WifToken$validate()

------------------------------------------------------------------------

### `WifToken$revoke()`

Placeholder implementation of required method.

#### Usage

    WifToken$revoke()

------------------------------------------------------------------------

### `WifToken$clone()`

The objects of this class are cloneable with this method.

#### Usage

    WifToken$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
