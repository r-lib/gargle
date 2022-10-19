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
