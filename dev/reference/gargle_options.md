# Options consulted by gargle

Wrapper functions around options consulted by gargle, which provide:

- A place to hang documentation.

- The mechanism for setting a default.

If the built-in defaults don't suit you, set one or more of these
options. Typically, this is done in the `.Rprofile` startup file, with
code along these lines:

    options(
      gargle_oauth_email = "jane@example.com",
      gargle_oauth_cache = "/path/to/folder/that/does/not/sync/to/cloud"
    )

## Usage

``` r
gargle_oauth_email()

gargle_oob_default()

gargle_oauth_cache()

gargle_oauth_client_type()

gargle_verbosity()

local_gargle_verbosity(level, env = caller_env())

with_gargle_verbosity(level, code)
```

## Arguments

- level:

  Verbosity level: "debug" \> "info" \> "silent"

- env:

  The environment to use for scoping

- code:

  Code to execute with specified verbosity level

## `gargle_oauth_email`

`gargle_oauth_email()` returns the option named "gargle_oauth_email",
which is undefined by default. If set, this option should be one of:

- An actual email address corresponding to your preferred Google
  identity. Example:`janedoe@gmail.com`.

- A glob pattern that indicates your preferred Google domain.
  Example:`*@example.com`.

- `TRUE` to allow email and OAuth token auto-discovery, if exactly one
  suitable token is found in the cache.

- `FALSE` or `NA` to force the OAuth dance in the browser.

## `gargle_oob_default`

`gargle_oob_default()` returns `TRUE` unconditionally on RStudio Server,
Posit Workbench, Posit Cloud, or Google Colaboratory, since it is not
possible to launch a local web server in these contexts. In this case,
for the final step of the OAuth dance, the user is redirected to a
specific URL where they must copy a code and paste it back into the R
session.

In all other contexts, `gargle_oob_default()` consults the option named
`"gargle_oob_default"`, then the option named `"httr_oob_default"`, and
eventually defaults to `FALSE`.

"oob" stands for out-of-band. Read more about out-of-band authentication
in the vignette
[`vignette("auth-from-web")`](https://gargle.r-lib.org/dev/articles/auth-from-web.md).

## `gargle_oauth_cache`

`gargle_oauth_cache()` returns the option named "gargle_oauth_cache",
defaulting to `NA`. If defined, the option must be set to a logical
value or a string. `TRUE` means to cache using the default user-level
cache file, `~/.R/gargle/gargle-oauth`, `FALSE` means don't cache, and
`NA` means to guess using some sensible heuristics.

## `gargle_oauth_client_type`

`gargle_oauth_client_type()` returns the option named
"gargle_oauth_client_type", if defined. If defined, the option must be
either "installed" or "web". If the option is not defined, the function
returns:

- "web" on RStudio Server, Posit Workbench, Posit Cloud, or Google
  Colaboratory

- "installed" otherwise

Primarily intended to help infer the most suitable OAuth client type
when a user is relying on a built-in client, such as the tidyverse
client used by packages like bigrquery, googledrive, and googlesheets4.

## `gargle_verbosity`

`gargle_verbosity()` returns the option named "gargle_verbosity", which
determines gargle's verbosity. There are three possible values, inspired
by the logging levels of log4j:

- "debug": Fine-grained information helpful when debugging, e.g.
  figuring out how
  [`token_fetch()`](https://gargle.r-lib.org/dev/reference/token_fetch.md)
  is working through the registry of credential functions. Previously,
  this was activated by setting an option named "gargle_quiet" to
  `FALSE`.

- "info" (default): High-level information that a typical user needs to
  see. Since typical gargle usage is always indirect, i.e. gargle is
  called by another package, gargle itself is very quiet. There are very
  few messages emitted when `gargle_verbosity = "info"`.

- "silent": No messages at all. However, warnings or errors are still
  thrown normally.

## Examples

``` r
gargle_oauth_email()
#> NULL
gargle_oob_default()
#> [1] FALSE
gargle_oauth_cache()
#> [1] NA
gargle_oauth_client_type()
#> [1] "installed"
gargle_verbosity()
#> [1] "info"
```
