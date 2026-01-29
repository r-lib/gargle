# Create an OAuth client for Google

A `gargle_oauth_client` consists of:

- A type. gargle only supports the "Desktop app" and "Web application"
  client types. Different types are associated with different OAuth
  flows.

- A client ID and secret.

- Optionally, one or more redirect URIs.

- A name. This is really a human-facing label. Or, rather, it can be
  used that way, but the default is just a hash. We recommend using the
  same name here as the name used to label the client ID in the [Google
  Cloud Platform Console](https://console.cloud.google.com).

A `gargle_oauth_client` is an adaptation of httr's
[`httr::oauth_app()`](https://httr.r-lib.org/reference/oauth_app.html)
(currently) and httr2's `oauth_client()` (which gargle will migrate to
in the future).

## Usage

``` r
gargle_oauth_client_from_json(path, name = NULL)

gargle_oauth_client(
  id,
  secret,
  redirect_uris = NULL,
  type = c("installed", "web"),
  name = hash(id)
)
```

## Arguments

- path:

  JSON downloaded from [Google Cloud
  Console](https://console.cloud.google.com), containing a client id and
  secret, in one of the forms supported for the `txt` argument of
  [`jsonlite::fromJSON()`](https://jeroen.r-universe.dev/jsonlite/reference/fromJSON.html)
  (typically, a file path or JSON string).

- name:

  A label for this specific client, presumably the same name used to
  label it in Google Cloud Console. Unfortunately there is no way to
  make that true programmatically, i.e. the JSON representation does not
  contain this information.

- id:

  Client ID

- secret:

  Client secret

- redirect_uris:

  Where your application listens for the response from Google's
  authorization server. If you didn't configure this specifically when
  creating the client (which is only possible for clients of the "web"
  type), you can leave this unspecified.

- type:

  Specifies the type of OAuth client. The valid values are a subset of
  possible Google client types and reflect the key used to describe the
  client in its JSON representation:

  - `"installed"` is associated with a "Desktop app"

  - `"web"` is associated with a "Web application"

## Value

An OAuth client: An S3 list with class `gargle_oauth_client`. For
backwards compatibility reasons, this currently also inherits from the
httr S3 class `oauth_app`, but that is a temporary measure. An instance
of `gargle_oauth_client` stores more information than httr's
`oauth_app`, such as the OAuth client's type ("web" or "installed").

There are some redundant fields in this object during the httr-to-httr2
transition period. The legacy fields `appname` and `key` repeat the
information in the future-facing fields `name` and (client) `id`. Prefer
`name` and `id` to `appname` and `key` in downstream code. Prefer the
constructors `gargle_oauth_client_from_json()` and
`gargle_oauth_client()` to
[`httr::oauth_app()`](https://httr.r-lib.org/reference/oauth_app.html)
and
[`oauth_app_from_json()`](https://gargle.r-lib.org/reference/oauth_app_from_json.md).

## Examples

``` r
if (FALSE) { # \dontrun{
gargle_oauth_client_from_json(
  path = "/path/to/the/JSON/you/downloaded/from/gcp/console.json",
  name = "my-nifty-oauth-client"
)
} # }

gargle_oauth_client(
  id = "some_long_id",
  secret = "ssshhhhh_its_a_secret",
  name = "my-nifty-oauth-client"
)
#> <gargle_oauth_client>
#> name: my-nifty-oauth-client
#> id: some_long_id
#> secret: <REDACTED>
#> type: installed
```
