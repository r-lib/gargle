context("utils")

test_that("%||% works", {
  expect_equal(1, 1 %||% 7)
  expect_equal(1, NULL %||% 1)
  expect_equal(1, c() %||% 1)
  expect_equal(1, 1 %||% stop("oh no"))
})

test_that("add_email_scope() works", {
  expect_identical(add_email_scope(), "email")
  expect_identical(add_email_scope("email"), "email")
  expect_identical(
    add_email_scope("whatever"),
    c("whatever", "email")
  )
  expect_equivalent(
    add_email_scope(c("whatever" = "whatever")),
    c("whatever", "email")
  )
})

test_that("rhash() produces same hash across platforms and R versions", {
 expect_identical(rhash(iris), "ff575c261c949d073b2895b05d1097c3")
})

test_that("base_scope() extracts the last scope part", {
  scopes <- c(
    "email",
    "https://www.googleapis.com/auth/drive",
    "https://www.googleapis.com/auth/gmail.readonly",
    "https://www.googleapis.com/auth/gmail.modify",
    "https://www.googleapis.com/auth/gmail.compose",
    "https://mail.google.com/"
  )
  out <- base_scope(scopes)
  expect_identical(
    out,
    c("email", "...drive", "...gmail.readonly", "...gmail.modify",
      "...gmail.compose", "...mail.google.com")
  )
})
