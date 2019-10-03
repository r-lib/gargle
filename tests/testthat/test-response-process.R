find_known_message <- function(file) {
  glue("{fs::path_ext_remove(file)}_MESSAGE.txt")
}

test_that("Request for non-existent resource (Drive v3, JSON content)", {
  file <- test_path("fixtures", "drive-files-get_404.rds")
  resp <- readRDS(file)
  err <- expect_error(response_process(resp), class = "gargle_error_request_failed")
  expect_known_output(print(err$message), find_known_message(file))
})

test_that("Request for non-existent resource (Sheets v4, HTML content)", {
  file <- test_path("fixtures", "sheets-spreadsheets-get_404.rds")
  resp <- readRDS(file)
  err <- expect_error(response_process(resp), class = "gargle_error_request_failed")
  expect_known_output(print(err$message), find_known_message(file))
})

test_that("Request with invalid argument (Sheets v4 error style)", {
  file <- test_path("fixtures", "sheets-spreadsheets-get_400.rds")
  resp <- readRDS(file)
  err <- expect_error(response_process(resp), class = "gargle_error_request_failed")
  expect_known_output(print(err$message), find_known_message(file))
})

test_that("Request with invalid value (tokeninfo, JSON content)", {
  file <- test_path("fixtures", "tokeninfo_400_stale.rds")
  resp <- readRDS(file)
  err <- expect_error(response_process(resp), class = "gargle_error_request_failed")
  expect_known_output(print(err$message), find_known_message(file))
})

test_that("Request to bad URL (tokeninfo, HTML content)", {
  file <- test_path("fixtures", "tokeninfo_400_bad-path.rds")
  resp <- readRDS(file)
  err <- expect_error(response_process(resp), class = "gargle_error_request_failed")
  expect_known_output(print(err$message), find_known_message(file))
})

test_that("RPC codes can be looked up (or not)", {
  expect_match(
    rpc_description("ALREADY_EXISTS"),
    "resource .* already exists"
  )
  expect_null(rpc_description("MATCHES_NOTHING"))
})
