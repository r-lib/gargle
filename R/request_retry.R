#' Make a Google API request, repeatedly
#'
#' Intended primarily for internal use in client packages that provide
#' high-level wrappers for users. It is a drop-in substitute for
#' [request_make()] that also has the ability to retry the request.
#'
#' Consider an example where we are willing to make a request up to 5 times.
#'
#' ```
#' try  1  2    3        4                5
#'      |--|----|--------|----------------|
#' wait  1   2      3           4
#' ```
#'
#' There will be up to 5 - 1 = 4 waits and we generally want the waiting period
#' to get longer, in an exponential way. Such schemes are called exponential
#' backoff. `request_retry()` implements exponential backoff with "full jitter",
#' where each waiting time is generated from a uniform distribution, where the
#' interval of support grows exponentially. A common alternative is "equal
#' jitter", which adds some noise to fixed, exponentially increasing waiting
#' times.
#'
#' Either way our waiting times are based on a geometric series, which, by
#' convention, is usually written in terms of powers of 2:
#'
#' ```
#' b , 2b, 4b, 8b, ...
#'   = b * 2^0, b * 2^1, b * 2^2, b * 2^3, ...
#' ```
#'
#' The terms in this series require knowledge of `b`, the so-called exponential
#' base, and many retry functions and libraries require the user to specify
#' this. But most users find it easier to declare the total amount of waiting
#' time they can tolerate for one request. Therefore `request_retry()` asks for
#' that instead and solves for `b` internally. This is inspired by the Opnieuw
#' Python library for retries. Opnieuw's interface is designed to eliminate
#' uncertainty around:
#' * Units: Is this thing given in seconds? minutes? milliseconds?
#' * Ambiguity around how things are counted: Are we starting at 0 or 1?
#'   Are we counting tries or just the retries?
#' * Non-intuitive required inputs, e.g., the exponential base.
#'
#' Let *n* be the total number of tries we're willing to make (the argument
#' `max_tries_total`) and let *W* be the total amount of seconds we're willing
#' to dedicate to making and retrying this request (the argument
#' `max_total_wait_time_in_seconds`). Here's how we determine *b*:
#'
#' ```
#' sum_{i=0}^(n - 1) b * 2^i = W
#' b * sum_{i=0}^(n - 1) 2^i = W
#'        b * ( (2 ^ n) - 1) = W
#'                         b = W / ( (2 ^ n) - 1)
#' ```
#'
#' @section Special cases:
#' `request_retry()` departs from exponential backoff in three special cases:
#' * It actually implements *truncated* exponential backoff. There is a floor
#'   and a ceiling on random wait times.
#' * `Retry-After` header: If the response has a header named `Retry-After`
#'   (case-insensitive), it is assumed to provide a non-negative integer
#'   indicating the number of seconds to wait. If present, we wait this many
#'   seconds and do not generate a random waiting time. (In theory, this header
#'   can alternatively provide a datetime after which to retry, but we have no
#'   first-hand experience with this variant for a Google API.)
#' * Sheets API quota exhaustion: In the course of googlesheets4 development,
#'   we've grown very familiar with the `429 RESOURCE_EXHAUSTED` error. The
#'   Sheets API v4 has "a limit of 500 requests per 100 seconds per project and
#'   100 requests per 100 seconds per user. Limits for reads and writes are
#'   tracked separately." In our experience, the "100 (read or write) requests
#'   per 100 seconds per user" limit is the one you hit most often. If we detect
#'   this specific failure, the first wait time is a bit more than 100 seconds,
#'   then we revert to exponential backoff.
#'
#' @param ... Passed along to [request_make()].
#' @param max_tries_total Maximum number of tries.
#' @param max_total_wait_time_in_seconds Total seconds we are willing to
#'   dedicate to waiting, summed across all tries. This is a technical upper
#'   bound and actual cumulative waiting will be less.
#'
#' @seealso
#' * <https://aws.amazon.com/blogs/architecture/exponential-backoff-and-jitter/>
#' * <https://tech.channable.com/posts/2020-02-05-opnieuw.html>
#' * <https://github.com/channable/opnieuw>
#' * <https://cloud.google.com/storage/docs/exponential-backoff>
#' * <https://cloud.google.com/storage/docs/gsutil/addlhelp/RetryHandlingStrategy>
#' * <https://tools.ietf.org/html/rfc7231#section-7.1.3>
#' * <https://developers.google.com/sheets/api/limits>
#' * <https://googleapis.dev/python/google-api-core/latest/retry.html>
#'
#' @inherit request_make return
#' @export
#'
#' @examples
#' \dontrun{
#' req <- gargle::request_build(
#'   method = "GET",
#'   path = "path/to/the/resource",
#'   token = "PRETEND_I_AM_TOKEN"
#' )
#' gargle::request_retry(req)
#' }
request_retry <- function(...,
                          max_tries_total = 5,
                          max_total_wait_time_in_seconds = 100) {
  resp <- request_make(...)
  tries_made <- 1
  b <- calculate_base_wait(
    n_waits         = max_tries_total - 1,
    total_wait_time = max_total_wait_time_in_seconds
  )

  while (we_should_retry(tries_made, max_tries_total, resp)) {
    wait_time <- backoff(tries_made, resp, base = b)
    # TODO: show progress in some way
    Sys.sleep(wait_time)
    resp <- request_make(...)
    tries_made <- tries_made + 1
  }

  invisible(resp)
}

we_should_retry <- function(tries_made, max_tries_total, resp) {
  if (tries_made >= max_tries_total) {
    FALSE
  } else if (httr::status_code(resp) == "429") {
    TRUE
  } else {
    FALSE
  }
}

backoff <- function(tries_made,
                    resp,
                    base = 1,
                    min_wait = 1,
                    max_wait = 45) {
  wait_time <- stats::runif(1, 0, base * (2^(tries_made - 1)))
  wait_rationale <- "exponential backoff, full jitter"

  if (wait_time < min_wait) {
    wait_time <- min_wait + stats::runif(1)
    wait_rationale <- glue(
      "{wait_rationale}, clipped to floor of {min_wait} seconds"
    )
  }

  if (wait_time > max_wait) {
    wait_time <- max_wait + stats::runif(1)
    wait_rationale <- glue(
      "{wait_rationale}, clipped to ceiling of {max_wait} seconds"
    )
  }

  if (sheets_per_user_quota_exhaustion(resp) && tries_made == 1) {
    wait_time <- 100 + stats::runif(1)
    wait_rationale <- "fixed 100 second wait for per user quota exhaustion"
  }

  retry_after <- retry_after_header(resp)
  if (!is.null(retry_after)) {
    wait_time <- retry_after
    wait_rationale <- "'Retry-After' header"
  }

  status_code <- httr::status_code(resp)

  # ALERT we're going to emit information regardless of the value of
  # gargle_quiet(). But we'll be very brief it it's FALSE.
  if (gargle_quiet()) {
    msg <- glue("
        Request failed [{status_code}]. Retry {tries_made} happens in \\
        {round(wait_time, 1)} seconds ...
                  ")
  } else {
    msg <- c(
      glue("Request failed [{status_code}]."), "",
      gargle_error_message(resp), "",
      glue("
          Retry {tries_made} happens in {round(wait_time, 1)} seconds ...
          (strategy: {wait_rationale})
             ")
    )
    msg <- glue_collapse(msg, sep = "\n")
  }
  ui_line(msg, quiet = FALSE)

  wait_time
}

retry_after_header <- function(resp) {
  # TODO: consider honoring Retry-After with status codes besides 429
  if (!(httr::status_code(resp) == "429")) {
    return(NULL)
  }

  h <- httr::headers(resp)
  # workaround https://github.com/r-lib/httr/issues/611
  loc <- grep("retry-after", names(h), ignore.case = TRUE)
  if (length(loc) > 0) {
    as.numeric(h[[loc]])
  } else {
    NULL
  }
}

sheets_per_user_quota_exhaustion <- function(resp) {
  any(grepl("per user per 100 seconds", gargle_error_message(resp)))
}

calculate_base_wait <- function(n_waits, total_wait_time) {
  stopifnot(is.numeric(n_waits), length(n_waits) == 1L, n_waits > 0)
  stopifnot(is.numeric(total_wait_time), length(total_wait_time) == 1L, total_wait_time > 0)
  total_wait_time / (2 ^ (n_waits) - 1)
}
