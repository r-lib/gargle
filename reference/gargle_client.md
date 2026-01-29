# OAuth client for demonstration purposes

Invisibly returns an instance of
[`gargle_oauth_client`](https://gargle.r-lib.org/reference/gargle_oauth_client_from_json.md)
that can be used to test drive gargle before obtaining your own client
ID and secret. This OAuth client may be deleted or rotated at any time.
There are no guarantees about which APIs are enabled. DO NOT USE THIS IN
A PACKAGE or for anything other than interactive, small-scale
experimentation.

You can get your own OAuth client ID and secret, without these
limitations. See the
[`vignette("get-api-credentials")`](https://gargle.r-lib.org/articles/get-api-credentials.md)
for more details.

## Usage

``` r
gargle_client(type = NULL)
```

## Arguments

- type:

  Specifies the type of OAuth client. The valid values are a subset of
  possible Google client types and reflect the key used to describe the
  client in its JSON representation:

  - `"installed"` is associated with a "Desktop app"

  - `"web"` is associated with a "Web application"

## Value

An OAuth client, produced by
[`gargle_oauth_client()`](https://gargle.r-lib.org/reference/gargle_oauth_client_from_json.md),
invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
gargle_client()
} # }
```
