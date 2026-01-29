# Create an OAuth app from JSON

**\[deprecated\]**

`oauth_app_from_json()` is being replaced with
[`gargle_oauth_client_from_json()`](https://gargle.r-lib.org/reference/gargle_oauth_client_from_json.md),
in light of the new `gargle_oauth_client` class. Now
`oauth_app_from_json()` potentially warns about this deprecation and
immediately passes its inputs through to
[`gargle_oauth_client_from_json()`](https://gargle.r-lib.org/reference/gargle_oauth_client_from_json.md).

`gargle_app()` is being replaced with
[`gargle_client()`](https://gargle.r-lib.org/reference/gargle_client.md).

## Usage

``` r
oauth_app_from_json(path, appname = NULL)

gargle_app()
```

## Arguments

- path:

  JSON downloaded from [Google Cloud
  Console](https://console.cloud.google.com), containing a client id and
  secret, in one of the forms supported for the `txt` argument of
  [`jsonlite::fromJSON()`](https://jeroen.r-universe.dev/jsonlite/reference/fromJSON.html)
  (typically, a file path or JSON string).

- appname:

  name of the application. This is not used for OAuth, but is used to
  make it easier to identify different applications.
