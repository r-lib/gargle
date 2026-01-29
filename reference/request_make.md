# Make a Google API request

Intended primarily for internal use in client packages that provide
high-level wrappers for users. `request_make()` does relatively little:

- Calls an HTTP method.

- Adds a user agent.

- Enforces `"json"` as the default for `encode`. This differs from
  httr's default behaviour, but aligns better with Google APIs.

Typically the input is created with
[`request_build()`](https://gargle.r-lib.org/reference/request_develop.md)
and the output is processed with
[`response_process()`](https://gargle.r-lib.org/reference/response_process.md).

## Usage

``` r
request_make(x, ..., encode = "json", user_agent = gargle_user_agent())
```

## Arguments

- x:

  List. Holds the components for an HTTP request, presumably created
  with
  [`request_develop()`](https://gargle.r-lib.org/reference/request_develop.md)
  or
  [`request_build()`](https://gargle.r-lib.org/reference/request_develop.md).
  Must contain a `method` and `url`. If present, `body` and `token` are
  used.

- ...:

  Optional arguments passed through to the HTTP method. Currently
  neither gargle nor httr checks that all are used, so be aware that
  unused arguments may be silently ignored.

- encode:

  If the body is a named list, how should it be encoded? Can be one of
  form (application/x-www-form-urlencoded), multipart,
  (multipart/form-data), or json (application/json).

  For "multipart", list elements can be strings or objects created by
  [`upload_file()`](https://httr.r-lib.org/reference/upload_file.html).
  For "form", elements are coerced to strings and escaped, use
  [`I()`](https://rdrr.io/r/base/AsIs.html) to prevent double-escaping.
  For "json", parameters are automatically "unboxed" (i.e. length 1
  vectors are converted to scalars). To preserve a length 1 vector as a
  vector, wrap in [`I()`](https://rdrr.io/r/base/AsIs.html). For "raw",
  either a character or raw vector. You'll need to make sure to set the
  [`content_type()`](https://httr.r-lib.org/reference/content_type.html)
  yourself.

- user_agent:

  A user agent string, prepared by
  [`httr::user_agent()`](https://httr.r-lib.org/reference/user_agent.html).
  When in doubt, a client package should have an internal function that
  extends `gargle_user_agent()` by prepending its return value with the
  client package's name and version.

## Value

Object of class `response` from
[httr::httr](https://httr.r-lib.org/reference/httr-package.html).

## See also

Other requests and responses:
[`request_develop()`](https://gargle.r-lib.org/reference/request_develop.md),
[`response_process()`](https://gargle.r-lib.org/reference/response_process.md)

## Examples

``` r
if (FALSE) { # \dontrun{
req <- gargle::request_build(
  method = "GET",
  path = "path/to/the/resource",
  token = "PRETEND_I_AM_TOKEN"
)
gargle::request_make(req)
} # }
```
