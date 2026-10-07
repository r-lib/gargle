# Build a Google API request

Intended primarily for internal use in client packages that provide
high-level wrappers for users. The
[`vignette("request-helper-functions")`](https://gargle.r-lib.org/dev/articles/request-helper-functions.md)
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
  the formal argument `key` will clobber it, if non-`NULL`. Either way,
  the `key` is sent in the `X-goog-api-key` request header in order to
  keep it out of the URL.

## Value

`request_develop()`: [`list()`](https://rdrr.io/r/base/list.html) with
components `method`, `path`, `params`, `body`, and `base_url`.

`request_build()`: [`list()`](https://rdrr.io/r/base/list.html) with
components `method`, `url` (the full URL, post-substitution, including
the query), `body`, `token`, and `headers` (a named character vector
holding the `X-goog-api-key` header, or `NULL`).

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

- Adds an API key, in the `X-goog-api-key` header, if and only if
  `token = NULL` and removes the API key otherwise. Client packages
  should generally pass their own API key in, but note that
  [`gargle_api_key()`](https://gargle.r-lib.org/dev/reference/gargle_api_key.md)
  is available for small-scale experimentation.

- Client packages should send the request with
  [`request_make()`](https://gargle.r-lib.org/dev/reference/request_make.md)
  or
  [`request_retry()`](https://gargle.r-lib.org/dev/reference/request_retry.md),
  which apply the `headers`. Code that makes its own HTTP call with only
  the `url` won't send the API key.

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
[`request_make()`](https://gargle.r-lib.org/dev/reference/request_make.md),
[`response_process()`](https://gargle.r-lib.org/dev/reference/response_process.md)

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
} # }

# Example with no previous knowledge of the endpoint and no token
# find books by Hadley Wickham with the Books API,
# using gargle's demo API key (for which the Books API is enabled)
req <- request_build(
  method = "GET",
  path = "books/v1/volumes",
  params = list(
    q = "inauthor:Hadley Wickham",
    maxResults = 10
  ),
  key = gargle_api_key()
)
resp <- request_make(req)
out <- response_process(resp)
books <- lapply(out$items, \(x) x$volumeInfo)
data.frame(
  title = vapply(books, \(x) x$title, character(1)),
  authors = vapply(books, \(x) toString(x$authors), character(1)),
  date = vapply(books, \(x) toString(x$publishedDate), character(1))
)
#>                         title
#> 1                  R Packages
#> 2          R for Data Science
#> 3                     ggplot2
#> 4                  Advanced R
#> 5  Advanced R, Second Edition
#> 6                  R Packages
#> 7             Mastering Shiny
#> 8          R for Data Science
#> 9             Mastering Shiny
#> 10       Advanced R Solutions
#>                                                     authors       date
#> 1                            Hadley Wickham, Jennifer Bryan 2023-06-14
#> 2                         Hadley Wickham, Garrett Grolemund 2016-12-12
#> 3                                            Hadley Wickham 2016-06-08
#> 4                                            Hadley Wickham    2020-12
#> 5                                            Hadley Wickham 2019-05-24
#> 6                                            Hadley Wickham 2015-04-13
#> 7                                            Hadley Wickham 2021-04-29
#> 8  Hadley Wickham, Mine Çetinkaya-Rundel, Garrett Grolemund 2023-06-08
#> 9                                            Hadley Wickham 2021-04-13
#> 10            Malte Grosser, Henning Bumann, Hadley Wickham 2021-08-23
```
