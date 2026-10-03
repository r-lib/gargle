# OAuth token situation report

Get a human-oriented overview of the existing gargle OAuth tokens:

- Filepath of the current cache

- Number of tokens found there

- Compact summary of the associated

  - Email = Google identity

  - OAuth client (actually, just its nickname)

  - Scopes

  - Hash (actually, just the first 7 characters)

This is the most direct way to find out where gargle's OAuth cache is
(see
[`gargle_oauth_cache()`](https://gargle.r-lib.org/dev/reference/gargle_options.md)
for more about the cache location). The `filepath` column of the
returned data frame makes it easy to delete specific tokens, e.g.:

    dat <- gargle_oauth_sitrep()
    # delete all cached tokens for one Google identity
    unlink(dat$filepath[dat$email == "jane@example.com"])

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
frame contains more columns than it seems, e.g. the `filepath` column
isn't printed by default.

## Examples

``` r
gargle_oauth_sitrep()
#> ℹ Reporting the default cache location.
#> No gargle OAuth cache found at ~/.cache/gargle.
```
