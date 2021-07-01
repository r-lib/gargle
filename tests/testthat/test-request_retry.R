test_that("request_retry() logic works as advertised", {
  # TODO: I'm testing too much re: retry logic via messages.
  # Classed errors should simplify things, in due course.

  faux_response <- function(status_code = 200, h = NULL) {
    structure(
      list(status_code = status_code,
           headers = if (!is.null(h)) httr::insensitive(h)),
      class = "response"
    )
  }
  # allows us to replay a fixed set of responses
  faux_request_make <- function(responses = list(faux_response())) {
    i <- 0
    force(responses)
    function(...) {
      i <<- i + 1
      responses[[i]]
    }
  }

  # turn this: Retry 1 happens in 1.7 seconds
  #            Retry 1 happens in 1 seconds
  # into this: Retry 1 happens in {WAIT_TIME} seconds
  fix_wait_time <- function(x) {
    sub(
      "(?<=in )[[:digit:]]+([.][[:digit:]]+)?(?= seconds)",
      "{WAIT_TIME}",
      x, perl = TRUE
    )
  }
  # turn this: (strategy: exponential backoff, full jitter, clipped to floor of 1 seconds)
  #            (strategy: exponential backoff, full jitter, clipped to ceiling of 45 seconds)
  # into this: (strategy: exponential backoff, full jitter)
  fix_strategy <- function(x) {
    sub(
      ", clipped to (floor|ceiling) of [[:digit:]]+([.][[:digit:]]+)? seconds",
      "",
      x, perl = TRUE
    )
  }
  local_gargle_verbosity("debug")

  # 2021-03-18
  # The switch to mockr::with_mock() has caused trouble interactively
  # executing this test. The closures used to mock request_make() seem to
  # use a common counter (i) and responses. I plan to open a mockr issue.
  # Workaround in the meantime: load_all() before each interactive call to
  # with_mock().

  # succeed on first try
  out <- with_mock(
    request_make = faux_request_make(), {
      request_retry()
    }
  )
  expect_equal(httr::status_code(out), 200)

  # fail, then succeed (exponential backoff)
  r <- list(faux_response(429), faux_response())
  with_mock(
    request_make = faux_request_make(r),
    gargle_error_message = function(...) "oops", {
      msg_fail_once <- capture.output(
        out <- request_retry(max_total_wait_time_in_seconds = 5),
        type = "message"
      )
    }
  )
  expect_snapshot(
    writeLines(fix_strategy(fix_wait_time(msg_fail_once)))
  )
  expect_equal(httr::status_code(out), 200)

  # fail, then succeed (Retry-After header)
  r <- list(
    faux_response(429, h = list(`Retry-After` = 1.4)),
    faux_response()
  )
  with_mock(
    request_make = faux_request_make(r),
    gargle_error_message = function(...) "oops", {
      msg_retry_after <- capture.output(
        out <- request_retry(),
        type = "message"
      )
    }
  )
  expect_snapshot(
    writeLines(fix_strategy(fix_wait_time(msg_retry_after)))
  )
  expect_equal(httr::status_code(out), 200)

  # make sure max_tries_total is adjustable)
  r <- list(
    faux_response(429),
    faux_response(429),
    faux_response(429),
    faux_response()
  )
  with_mock(
    request_make = faux_request_make(r[1:3]),
    gargle_error_message = function(...) "oops", {
      msg_max_tries <- capture.output(
        out <- request_retry(max_tries_total = 3, max_total_wait_time_in_seconds = 6),
        type = "message"
      )
    }
  )
  expect_snapshot(
    writeLines(fix_strategy(fix_wait_time(msg_max_tries)))
  )
  expect_equal(httr::status_code(out), 429)
})

test_that("backoff() obeys obvious bounds from min_wait and max_wait", {
  faux_error <- function() {
    structure(list(status_code = 429), class = "response")
  }

  # raw wait_times in U[0,1], therefore all become min_wait + U[0,1]
  with_mock(
    gargle_error_message = function(...) "oops", {
      wait_times <- vapply(
        rep.int(1, 100),
        backoff,
        FUN.VALUE = numeric(1),
        resp = faux_error(), min_wait = 3
      )
    }
  ) %>% suppressMessages()
  expect_true(all(wait_times > 3))
  expect_true(all(wait_times < 4))

  # raw wait_times in U[0,6], those that are < 1 become min_wait + U[0,1] and
  # those > 3 become max_wait + U[0,1]
  with_mock(
    gargle_error_message = function(...) "oops", {
      wait_times <- vapply(
        rep.int(1, 100),
        backoff,
        FUN.VALUE = numeric(1),
        resp = faux_error(), base = 6, max_wait = 3
      )
    }
  ) %>% suppressMessages()
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
    gargle_error_message = function(...) "oops", {
      backoff(1, faux_429(list(`Retry-After` = "1.2")))
    }
  ) %>% suppressMessages()
  expect_equal(out, 1.2)

  out <- with_mock(
    gargle_error_message = function(...) "oops", {
      backoff(1, faux_429(list(`retry-after` = 2.4)))
    }
  ) %>% suppressMessages()
  expect_equal(out, 2.4)

  # should work even when tries_made > 1
  out <- with_mock(
    gargle_error_message = function(...) "oops", {
      backoff(3, faux_429(list(`reTry-aFteR` = 3.6)))
    }
  ) %>% suppressMessages()
  expect_equal(out, 3.6)
})
