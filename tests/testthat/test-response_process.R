expect_recorded_error <- function(filename, status_code) {
  rds_file <- test_path("fixtures", fs::path_ext_set(filename, "rds"))
  resp <- readRDS(rds_file)
  expect_error(response_process(resp), class = "gargle_error_request_failed")
  expect_error(response_process(resp), class = glue("http_error_{status_code}"))
  # HTML errors (as opposed to JSON) need this
  scrub_filepath <- function(x) {
    gsub(
      "([\"\'])\\S+gargle-unexpected-html-error-\\S+[.]html([\"\'])",
      "\\1VOLATILE_FILE_PATH\\2",
      x,
      perl = TRUE
    )
  }
  expect_snapshot(response_process(resp), error = TRUE, transform = scrub_filepath)
}

test_that("Resource exhausted (Sheets, ReadGroup)", {
  expect_recorded_error(
    "sheets-spreadsheets-get-quota-exceeded-readgroup_429",
    429
  )
})

test_that("Request for non-existent resource (Drive)", {
  expect_recorded_error(
    "drive-files-get-nonexistent-file-id_404",
    404
  )
})

# https://github.com/r-lib/gargle/issues/254
test_that("Too many requests (Drive, HTML content)", {
  expect_recorded_error(
    "drive-automated-queries_429",
    429
  )
})

# https://github.com/r-lib/gargle/issues/254
test_that("HTML error is offered as a file", {
  rds_file <- test_path("fixtures", "drive-automated-queries_429.rds")
  resp <- readRDS(rds_file)
  err <- tryCatch(
    response_process(resp),
    gargle_error_request_failed = function(e) e
  )
  regex <- "[^'\" \\t\\n\\r]+gargle-unexpected-html-error-\\S+[.]html"
  m <- gregexpr(regex, err$body, perl = TRUE)
  path_to_html_error <- unique(unlist(regmatches(err$body, m)))
  # the strwrap() result is a bit goofy, but seems least of all evils
  # this is mostly about making sure we excavate the HTML
  expect_snapshot(strwrap(readLines(path_to_html_error), width = 60))
  unlink(path_to_html_error)
})

test_that("Request for which we don't have scope (Fitness)", {
  expect_recorded_error(
    "fitness-get-wrong-scope_403",
    403
  )
})

test_that("Use key that's not enabled for the API (Sheets)", {
  expect_recorded_error(
    "sheets-spreadsheets-get-api-key-not-enabled_403",
    403
  )
})

test_that("Request with invalid argument (Sheets, bad range)", {
  expect_recorded_error(
    "sheets-spreadsheets-get-nonexistent-range_400",
    400
  )
})

test_that("Request with bad field mask (Sheets)", {
  expect_recorded_error(
    "sheets-spreadsheets-get-bad-field-mask_400",
    400
  )
})

test_that("Request for nonexistent resource (Sheets)", {
  expect_recorded_error(
    "sheets-spreadsheets-get-nonexistent-sheet-id_404",
    404
  )
})

# https://github.com/tidyverse/googlesheets4/issues/317
test_that("Use service account that's not enabled for the API (Sheets)", {
  expect_recorded_error(
    "sheets-spreadsheets-get-service-disabled_403",
    403
  )
})

test_that("Request with invalid value (tokeninfo, stale token)", {
  expect_recorded_error(
    "tokeninfo-stale_400",
    400
  )
})

test_that("Request to bad URL (tokeninfo, HTML content)", {
  expect_recorded_error(
    "tokeninfo-bad-path_404",
    404
  )
})

# helpers ----
test_that("RPC codes can be looked up (or not)", {
  expect_match(
    rpc_description("ALREADY_EXISTS"),
    "resource .* already exists"
  )
  expect_null(rpc_description("MATCHES_NOTHING"))
})
