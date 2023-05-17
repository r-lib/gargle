# I got a response object from a user
# see discussion here:
# https://github.com/r-lib/gargle/issues/254
resp <- readRDS("~/Downloads/gargle-last-response.rds")
# this response object was captured before I started to omit the handle from
# the stored response, so I do it retroactively
resp$handle <- NULL

gargle::response_process(resp)
stopifnot(httr::status_code(resp) == 429)

saveRDS(
  resp,
  testthat::test_path("fixtures", "drive-automated-queries_429.rds"),
  version = 2
)
