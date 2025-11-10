# OAuth token situation report

Get a human-oriented overview of the existing gargle OAuth tokens:

- Filepath of the current cache

- Number of tokens found there

- Compact summary of the associated

  - Email = Google identity

  - OAuth client (actually, just its nickname)

  - Scopes

  - Hash (actually, just the first 7 characters) Mostly useful for the
    development of gargle and client packages.

## Usage

``` r
gargle_oauth_sitrep(cache = NULL)
```

## Arguments

- cache:

  Specifies the OAuth token cache. Defaults to the option named
  `"gargle_oauth_cache"`, retrieved via
  [`gargle_oauth_cache()`](https://gargle.r-lib.org/dev/reference/gargle_options.md).

## Value

A data frame with one row per cached token, invisibly. Note this data
frame may contain more columns than it seems, e.g. the `filepath` column
isn't printed by default.

## Examples

``` r
gargle_oauth_sitrep()
#> ℹ Reporting the default cache location.
#> No gargle OAuth cache found at ~/.cache/gargle.
```
