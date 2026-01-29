# Build a Google API request

Intended primarily for internal use in client packages that provide
high-level wrappers for users. The
[`vignette("request-helper-functions")`](https://gargle.r-lib.org/articles/request-helper-functions.md)
describes how one might use these functions inside a wrapper package.

## Usage

``` r
request_develop(
  endpoint,
  params = list(),
  base_url = "https://www.googleapis.com"
)

request_build(
  method = "GET",
  path = "",
  params = list(),
  body = list(),
  token = NULL,
  key = NULL,
  base_url = "https://www.googleapis.com"
)
```

## Arguments

- endpoint:

  List of information about the target endpoint or, in Google's
  vocabulary, the target "method". Presumably prepared from the
  [Discovery
  Document](https://developers.google.com/discovery/v1/getting_started#background-resources)
  for the target API.

- params:

  Named list. Values destined for URL substitution, the query, or, for
  `request_develop()` only, the body. For `request_build()`, body
  parameters must be passed via the `body` argument.

- base_url:

  Character.

- method:

  Character. An HTTP verb, such as `GET` or `POST`.

- path:

  Character. Path to the resource, not including the API's `base_url`.
  Examples: `drive/v3/about` or `drive/v3/files/{fileId}`. The `path`
  can be a template, i.e. it can include variables inside curly
  brackets, such as `{fileId}` in the example. Such variables are
  substituted by `request_build()`, using named parameters found in
  `params`.

- body:

  List. Values to send in the API request body.

- token:

  Token, ready for inclusion in a request, i.e. prepared with
  [`httr::config()`](https://httr.r-lib.org/reference/config.html).

- key:

  API key. Needed for requests that don't contain a token. For more, see
  Google's document Credentials, access, security, and identity
  (`https://support.google.com/googleapi/answer/6158857?hl=en&ref_topic=7013279`).
  A key can be passed as a named component of `params`, but note that
  the formal argument `key` will clobber it, if non-`NULL`.

## Value

`request_develop()`: [`list()`](https://rdrr.io/r/base/list.html) with
components `method`, `path`, `params`, `body`, and `base_url`.

`request_build()`: [`list()`](https://rdrr.io/r/base/list.html) with
components `method`, `path` (post-substitution), `query` (the input
`params` not used in URL substitution), `body`, `token`, `url` (the full
URL, post-substitution, including the query).

## `request_develop()`

Combines user input (`params`) with information about an API endpoint.
`endpoint` should contain these components:

- `path`: See documentation for argument.

- `method`: See documentation for argument.

- `parameters`: Compared with `params` supplied by user. An error is
  thrown if user-supplied `params` aren't named in `endpoint$parameters`
  or if user fails to supply all required parameters. In the return
  value, body parameters are separated from those destined for path
  substitution or the query.

The return value is typically used as input to `request_build()`.

## `request_build()`

Builds a request, in a purely mechanical sense. This function does
nothing specific to any particular Google API or endpoint.

- Use with the output of `request_develop()` or with hand-crafted input.

- `params` are used for variable substitution in `path`. Leftover
  `params` that are not bound by the `path` template automatically
  become HTTP query parameters.

- Adds an API key to the query iff `token = NULL` and removes the API
  key otherwise. Client packages should generally pass their own API key
  in, but note that
  [`gargle_api_key()`](https://gargle.r-lib.org/reference/gargle_api_key.md)
  is available for small-scale experimentation.

See `googledrive::generate_request()` for an example of usage in a
client package. googledrive has an internal list of selected endpoints,
derived from the Drive API Discovery Document
(`https://www.googleapis.com/discovery/v1/apis/drive/v3/rest`), exposed
via `googledrive::drive_endpoints()`. An element from such a list is the
expected input for `endpoint`. `googledrive::generate_request()` is a
wrapper around `request_develop()` and `request_build()` that inserts a
googledrive-managed API key and some logic about Team Drives. All
user-facing functions use `googledrive::generate_request()` under the
hood.

## See also

Other requests and responses:
[`request_make()`](https://gargle.r-lib.org/reference/request_make.md),
[`response_process()`](https://gargle.r-lib.org/reference/response_process.md)

## Examples

``` r
if (FALSE) { # \dontrun{
## Example with a prepared endpoint
ept <- googledrive::drive_endpoints("drive.files.update")[[1]]
req <- request_develop(
  ept,
  params = list(
    fileId = "abc",
    addParents = "123",
    description = "Exciting File"
  )
)
req

req <- request_build(
  method = req$method,
  path = req$path,
  params = req$params,
  body = req$body,
  token = "PRETEND_I_AM_A_TOKEN"
)
req

## Example with no previous knowledge of the endpoint
## List a file's comments
## https://developers.google.com/drive/v3/reference/comments/list
req <- request_build(
  method = "GET",
  path = "drive/v3/files/{fileId}/comments",
  params = list(
    fileId = "your-file-id-goes-here",
    fields = "*"
  ),
  token = "PRETEND_I_AM_A_TOKEN"
)
req

# Example with no previous knowledge of the endpoint and no token
# use an API key for which the Places API is enabled!
API_KEY <- "1234567890"

# get restaurants close to a location in Vancouver, BC
req <- request_build(
  method = "GET",
  path = "maps/api/place/nearbysearch/json",
  params = list(
    location = "49.268682,-123.167117",
    radius = 100,
    type = "restaurant"
  ),
  key = API_KEY,
  base_url = "https://maps.googleapis.com"
)
resp <- request_make(req)
out <- response_process(resp)
vapply(out$results, function(x) x$name, character(1))
} # }
```
