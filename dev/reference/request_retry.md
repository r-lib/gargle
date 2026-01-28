# Make a Google API request, repeatedly

Intended primarily for internal use in client packages that provide
high-level wrappers for users. It is a drop-in substitute for
[`request_make()`](https://gargle.r-lib.org/dev/reference/request_make.md)
that also has the ability to retry the request. Codes that are
considered retryable: 408, 429, 500, 502, 503.

## Usage

``` r
request_retry(..., max_tries_total = 5, max_total_wait_time_in_seconds = 100)
```

## Arguments

- ...:

  Passed along to
  [`request_make()`](https://gargle.r-lib.org/dev/reference/request_make.md).

- max_tries_total:

  Maximum number of tries.

- max_total_wait_time_in_seconds:

  Total seconds we are willing to dedicate to waiting, summed across all
  tries. This is a technical upper bound and actual cumulative waiting
  will be less.

## Value

Object of class `response` from
[httr::httr](https://httr.r-lib.org/reference/httr-package.html).

## Details

Consider an example where we are willing to make a request up to 5
times.

    try  1  2    3        4                5
         |--|----|--------|----------------|
    wait  1   2      3           4

There will be up to 5 - 1 = 4 waits and we generally want the waiting
period to get longer, in an exponential way. Such schemes are called
exponential backoff. `request_retry()` implements exponential backoff
with "full jitter", where each waiting time is generated from a uniform
distribution, where the interval of support grows exponentially. A
common alternative is "equal jitter", which adds some noise to fixed,
exponentially increasing waiting times.

Either way our waiting times are based on a geometric series, which, by
convention, is usually written in terms of powers of 2:

    b, 2b, 4b, 8b, ...
      = b * 2^0, b * 2^1, b * 2^2, b * 2^3, ...

The terms in this series require knowledge of `b`, the so-called
exponential base, and many retry functions and libraries require the
user to specify this. But most users find it easier to declare the total
amount of waiting time they can tolerate for one request. Therefore
`request_retry()` asks for that instead and solves for `b` internally.
This is inspired by the Opnieuw Python library for retries. Opnieuw's
interface is designed to eliminate uncertainty around:

- Units: Is this thing given in seconds? minutes? milliseconds?

- Ambiguity around how things are counted: Are we starting at 0 or 1?
  Are we counting tries or just the retries?

- Non-intuitive required inputs, e.g., the exponential base.

Let *n* be the total number of tries we're willing to make (the argument
`max_tries_total`) and let *W* be the total amount of seconds we're
willing to dedicate to making and retrying this request (the argument
`max_total_wait_time_in_seconds`). Here's how we determine *b*:

    sum_{i=0}^(n - 1) b * 2^i = W
    b * sum_{i=0}^(n - 1) 2^i = W
           b * ( (2 ^ n) - 1) = W
                            b = W / ( (2 ^ n) - 1)

## Special cases

`request_retry()` departs from exponential backoff in three special
cases:

- It actually implements *truncated* exponential backoff. There is a
  floor and a ceiling on random wait times.

- `Retry-After` header: If the response has a header named `Retry-After`
  (case-insensitive), it is assumed to provide a non-negative integer
  indicating the number of seconds to wait. If present, we wait this
  many seconds and do not generate a random waiting time. (In theory,
  this header can alternatively provide a datetime after which to retry,
  but we have no first-hand experience with this variant for a Google
  API.)

- Sheets API quota exhaustion: In the course of googlesheets4
  development, we've grown very familiar with the
  `429 RESOURCE_EXHAUSTED` error. As of 2023-04-15, the Sheets API v4
  has a limit of 300 requests per minute per project and 60 requests per
  minute per user per project. Limits for reads and writes are tracked
  separately. In our experience, the "60 (read or write) requests per
  minute per user" limit is the one you hit most often. If we detect
  this specific failure, the first wait time is a bit more than one
  minute, then we revert to exponential backoff.

## See also

- <https://aws.amazon.com/blogs/architecture/exponential-backoff-and-jitter/>

- `https://www.channable.com/tech/opnieuw-a-simple-and-intuitive-retrying-library-for-python`

- <https://github.com/channable/opnieuw>

- <https://docs.cloud.google.com/storage/docs/retry-strategy>

- <https://www.rfc-editor.org/rfc/rfc7231#section-7.1.3>

- <https://developers.google.com/sheets/api/limits>

- <https://googleapis.dev/python/google-api-core/latest/retry.html>

## Examples

``` r
if (FALSE) { # \dontrun{
req <- gargle::request_build(
  method = "GET",
  path = "path/to/the/resource",
  token = "PRETEND_I_AM_TOKEN"
)
gargle::request_retry(req)
} # }
```
