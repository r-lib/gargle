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
    c(
      "email", "...drive", "...gmail.readonly", "...gmail.modify",
      "...gmail.compose", "...mail.google.com"
    )
  )
})

test_that("obfuscate() works", {
  x <- c("123", "12345", "123456789")
  expect_identical(
    obfuscate(x, first = 1, last = 1),
    c("1...3", "1...5", "1...9")
  )
  expect_identical(
    obfuscate(x, first = 2, last = 1),
    c("123", "12...5", "12...9")
  )
  expect_identical(
    obfuscate(x, first = 4, last = 1),
    c("123", "12345", "1234...9")
  )
  expect_identical(
    obfuscate(x, first = 3, last = 3),
    c("123", "12345", "123...789")
  )
})
