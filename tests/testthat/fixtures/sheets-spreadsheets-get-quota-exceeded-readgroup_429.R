# ---- make too many read requests in a time interval
googlesheets4::gs4_deauth()
deaths_id <- as.character(googlesheets4::gs4_example("deaths"))

f <- function(ssid = deaths_id, i = 0) {
  req <- googlesheets4::request_generate(
    "sheets.spreadsheets.get",
    params = list(spreadsheetId = ssid, fields = "spreadsheetId")
  )
  raw_resp <- googlesheets4::request_make(req)
  code <- httr::status_code(raw_resp)
  cat(i, "code:", code, "\n")
  if (code >= 200 && code < 300) {
    invisible(TRUE)
  } else {
    invisible(raw_resp)
  }
}

n <- 300
i <- 0
resp <- TRUE
while(isTRUE(resp) && i < n) {
  i <- i + 1
  resp <- f(i = i)
}

resp

stopifnot(httr::status_code(resp) == 429)
saveRDS(
  gargle:::redact_response(resp),
  testthat::test_path("fixtures", "sheets-spreadsheets-get-quota-exceeded-readgroup_429.rds"),
  version = 2
)

gargle::response_process(resp)
