context("utils")

test_that("%||% works", {
  expect_equal(1, 1 %||% 7)
  expect_equal(1, NULL %||% 1)
  expect_equal(1, c() %||% 1)
  expect_equal(1, 1 %||% stop("oh no"))
})
