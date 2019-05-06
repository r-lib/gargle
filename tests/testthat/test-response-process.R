context("Process responses")

test_that("Request for non-existent resource (Drive v3, JSON content)", {
  resp <- readRDS(test_path("fixtures", "drive-files-get_404.rds"))
  cnd <- rlang::catch_cnd(response_process(resp))
  expect_s3_class(cnd, "http_error_404")
  expect_s3_class(cnd, "gargle_error_request_failed")
  expect_identical(cnd$code, 404L)
})

test_that("Request for non-existent resource (Sheets v4, HTML content)", {
  resp <- readRDS(test_path("fixtures", "sheets-spreadsheets-get_404.rds"))
  cnd <- rlang::catch_cnd(response_process(resp))
  expect_s3_class(cnd, "http_error_404")
  expect_s3_class(cnd, "gargle_error_request_failed")
  expect_identical(cnd$code, 404L)
  expect_match(cnd$message, "html")
})

test_that("Request with invalid argument (Sheets v4 error style)", {
  resp <- readRDS(test_path("fixtures", "sheets-spreadsheets-get_400.rds"))
  cnd <- rlang::catch_cnd(response_process(resp))
  expect_s3_class(cnd, "http_error_400")
  expect_s3_class(cnd, "gargle_error_request_failed")
  expect_identical(cnd$code, 400L)
  expect_match(cnd$message, "INVALID_ARGUMENT")
})

test_that("Request with invalid value (tokeninfo, JSON content)", {
  resp <- readRDS(test_path("fixtures", "tokeninfo_400_stale.rds"))
  cnd <- rlang::catch_cnd(response_process(resp))
  expect_s3_class(cnd, "http_error_400")
  expect_s3_class(cnd, "gargle_error_request_failed")
  expect_identical(cnd$code, 400L)
  expect_match(cnd$message, "Invalid Value")
})

test_that("Request to bad URL (tokeninfo, HTML content)", {
  resp <- readRDS(test_path("fixtures", "tokeninfo_400_bad-path.rds"))
  cnd <- rlang::catch_cnd(response_process(resp))
  expect_s3_class(cnd, "http_error_404")
  expect_s3_class(cnd, "gargle_error_request_failed")
  expect_identical(cnd$code, 404L)
  expect_match(cnd$message, "html")
})

test_that("RPC codes can be looked up (or not)", {
  expect_match(
    rpc_description("ALREADY_EXISTS"),
    "resource .* already exists"
  )
  expect_null(rpc_description("MATCHES_NOTHING"))
})
