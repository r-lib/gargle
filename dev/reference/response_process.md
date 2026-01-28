# Process a Google API response

`response_process()` is intended primarily for internal use in client
packages that provide high-level wrappers for users. Typically applied
as the final step in this sequence of calls:

- Request prepared with
  [`request_build()`](https://gargle.r-lib.org/dev/reference/request_develop.md).

- Request made with
  [`request_make()`](https://gargle.r-lib.org/dev/reference/request_make.md).

- Response processed with `response_process()`.

All that's needed for a successful request is to parse the JSON
extracted via
[`httr::content()`](https://httr.r-lib.org/reference/content.html).
Therefore, the main point of `response_process()` is to handle less
happy outcomes:

- Status codes in the 400s (client error) and 500s (server error). The
  structure of the error payload varies across Google APIs and we try to
  create a useful message for all variants we know about.

- Non-JSON content type, such as HTML.

- Status code in the 100s (information) or 300s (redirection). These are
  unexpected.

If `response_process()` results in an error, a redacted version of the
`resp` input is returned in the condition (auth tokens are removed).

## Usage

``` r
response_process(
  resp,
  error_message = gargle_error_message,
  error_class = NULL,
  remember = TRUE,
  call = caller_env()
)

response_as_json(resp, call = caller_env())

gargle_error_message(resp, call = caller_env())
```

## Arguments

- resp:

  Object of class `response` from
  [httr::httr](https://httr.r-lib.org/reference/httr-package.html).

- error_message:

  Function that produces an informative error message from the primary
  input, `resp`. It must return a character vector.

- error_class:

  Optional character vector of error classes to add to the condition
  object. These classes are prepended to gargle's default classes
  (`"gargle_error_request_failed"` and `"http_error_{status_code}"`).

- remember:

  Whether to remember the most recently processed response.

- call:

  The execution environment of a currently running function, e.g.
  `call = caller_env()`. The corresponding function call is retrieved
  and mentioned in error messages as the source of the error.

  You only need to supply `call` when throwing a condition from a helper
  function which wouldn't be relevant to mention in the message.

  Can also be `NULL` or a [defused function
  call](https://rlang.r-lib.org/reference/topic-defuse.html) to
  respectively not display any call or hard-code a code to display.

  For more information about error calls, see [Including function calls
  in error
  messages](https://rlang.r-lib.org/reference/topic-error-call.html).

## Value

The content of the request, as a list. An HTTP status code of 204 (No
content) is a special case returning `TRUE`.

## Details

When `remember = TRUE` (the default), gargle stores the most recently
seen response internally, for *post hoc* examination. The stored
response is literally just the most recent `resp` input, but with auth
tokens redacted. It can be accessed via
[`gargle_last_response()`](https://gargle.r-lib.org/dev/reference/gargle_last_response.md).
A companion function
[`gargle_last_content()`](https://gargle.r-lib.org/dev/reference/gargle_last_response.md)
returns the just the parsed content, which is probably the most useful
form for *post mortem* analysis.

The `response_as_json()` helper is exported only as an aid to
maintainers who wish to use their own `error_message` function, instead
of gargle's built-in `gargle_error_message()`. When implementing a
custom `error_message` function, call `response_as_json()` immediately
on the input in order to inherit gargle's handling of non-JSON input.

## See also

Other requests and responses:
[`request_develop()`](https://gargle.r-lib.org/dev/reference/request_develop.md),
[`request_make()`](https://gargle.r-lib.org/dev/reference/request_make.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# get an OAuth2 token with 'userinfo.email' scope
token <- token_fetch(scopes = "https://www.googleapis.com/auth/userinfo.email")

# see the email associated with this token
req <- gargle::request_build(
  method = "GET",
  path = "v1/userinfo",
  token = token,
  base_url = "https://openidconnect.googleapis.com"
)
resp <- gargle::request_make(req)
response_process(resp)

# make a bad request (this token has incorrect scope)
req <- gargle::request_build(
  method = "GET",
  path = "fitness/v1/users/{userId}/dataSources",
  token = token,
  params = list(userId = 12345)
)
resp <- gargle::request_make(req)
response_process(resp)
} # }
```
