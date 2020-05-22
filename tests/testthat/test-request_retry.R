test_that("request_retry() logic works as advertised", {
  faux_response <- function(status_code = 200, h = NULL) {
    structure(
      list(status_code = status_code,
           headers = if (!is.null(h)) httr::insensitive(h)),
      class = "response"
    )
  }
  faux_request_make <- function(responses = list(faux_response())) {
    i <- 0
    force(responses)
    function(...) {
      i <<- i + 1
      responses[[i]]
    }
  }
  withr::local_options(list(gargle_quiet = FALSE))

  # succeed on first try
  out <- with_mock(
    `gargle::request_make` = faux_request_make(),
    request_retry()
  )
  expect_equal(httr::status_code(out), 200)

  # fail, then succeed (exponential backoff)
  r <- list(faux_response(429), faux_response())
  expect_message(
    out <- with_mock(
      `gargle::request_make` = faux_request_make(r),
      `gargle::gargle_error_message` = function(...) "oops",
      request_retry(max_total_wait_time_in_seconds = 5)
    ),
    "Retry 1.*jitter"
  )
  expect_equal(httr::status_code(out), 200)

  # fail, then succeed (Retry-After header)
  r <- list(
    faux_response(429, h = list(`Retry-After` = 1.4)),
    faux_response()
  )
  expect_message(
    out <- with_mock(
      `gargle::request_make` = faux_request_make(r),
      `gargle::gargle_error_message` = function(...) "oops",
      request_retry()
    ),
    "Retry 1.*header"
  )
  expect_equal(httr::status_code(out), 200)

  # make sure max_tries_total is adjustable)
  r <- list(
    faux_response(429),
    faux_response(429),
    faux_response(429),
    faux_response()
  )
  expect_message(
    out <- with_mock(
      `gargle::request_make` = faux_request_make(r[1:3]),
      `gargle::gargle_error_message` = function(...) "oops",
      request_retry(max_tries_total = 3, max_total_wait_time_in_seconds = 6)
    ),
    "Retry 2"
  )
  expect_equal(httr::status_code(out), 429)
})

test_that("backoff() obeys obvious bounds from min_wait and max_wait", {
  faux_error <- function() {
    structure(list(status_code = 429), class = "response")
  }

  # raw wait_times in U[0,1], therefore all become min_wait + U[0,1]
  with_mock(
    `gargle::gargle_error_message` = function(...) "oops",
    wait_times <- vapply(
      rep.int(1, 100),
      backoff,
      FUN.VALUE = numeric(1),
      resp = faux_error(), min_wait = 3
    )
  )
  expect_true(all(wait_times > 3))
  expect_true(all(wait_times < 4))

  # raw wait_times in U[0,6], those that are < 1 become min_wait + U[0,1] and
  # those > 3 become max_wait + U[0,1]
  with_mock(
    `gargle::gargle_error_message` = function(...) "oops",
    wait_times <- vapply(
      rep.int(1, 100),
      backoff,
      FUN.VALUE = numeric(1),
      resp = faux_error(), base = 6, max_wait = 3
    )
  )
  expect_true(all(wait_times > 1))
  expect_true(all(wait_times < 3 + 1))
})

test_that("backoff() honors Retry-After header", {
  faux_429 <- function(h) {
    structure(
      list(status_code = 429,
           headers = httr::insensitive(h)),
      class = "response"
    )
  }

  # play with capitalization and character vs numeric
  out <- with_mock(
    `gargle::gargle_error_message` = function(...) "oops",
    backoff(1, faux_429(list(`Retry-After` = "1.2")))
  )
  expect_equal(out, 1.2)

  out <- with_mock(
    `gargle::gargle_error_message` = function(...) "oops",
    backoff(1, faux_429(list(`retry-after` = 2.4)))
  )
  expect_equal(out, 2.4)

  # should work even when tries_made > 1
  out <- with_mock(
    `gargle::gargle_error_message` = function(...) "oops",
    backoff(3, faux_429(list(`reTry-aFteR` = 3.6)))
  )
  expect_equal(out, 3.6)
})
