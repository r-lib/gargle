test_that("use_oob must be TRUE or FALSE", {
  expect_snapshot(error = TRUE, check_oob("a"))
  expect_snapshot(error = TRUE, check_oob(c(FALSE, FALSE)))
})

test_that("OOB requires an interactive session", {
  local_interactive(FALSE)
  expect_snapshot(error = TRUE, check_oob(TRUE))
})

test_that("makes no sense to pass oob_value if not OOB", {
  skip_if_not_installed("httpuv")
  local_interactive(TRUE)
  expect_snapshot(error = TRUE, check_oob(FALSE, "custom_value"))
})

test_that("oob_value has to be a string", {
  expect_snapshot(error = TRUE, check_oob(TRUE, c("a", "b")))
})

test_that("check_oauth_redirect() requires matching state, checked first", {
  expect_snapshot(
    error = TRUE,
    check_oauth_redirect(list(code = "abc", state = "nope"), "xyz")
  )
  expect_snapshot(
    error = TRUE,
    check_oauth_redirect(list(code = "abc"), "xyz")
  )
  expect_snapshot(
    error = TRUE,
    check_oauth_redirect(list(error = "access_denied", state = "nope"), "xyz")
  )
})

test_that("check_oauth_redirect() reports an error or missing code", {
  expect_snapshot(
    error = TRUE,
    check_oauth_redirect(list(error = "access_denied", state = "xyz"), "xyz")
  )
  expect_snapshot(
    error = TRUE,
    check_oauth_redirect(list(state = "xyz"), "xyz")
  )
})

test_that("loopback flow checks the redirect", {
  local_mocked_bindings(
    oauth_listener = function(url) list(code = "abc", state = "xyz")
  )
  expect_equal(oauth_authorize("https://example.org", state = "xyz"), "abc")
  expect_snapshot(
    error = TRUE,
    oauth_authorize("https://example.org", state = "nope")
  )
})
