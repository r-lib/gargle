# ---- non-existent range
googlesheets4::gs4_deauth()
deaths_id <- as.character(googlesheets4::gs4_example("deaths"))
req <- googlesheets4::request_generate(
  endpoint = "sheets.spreadsheets.get",
  params = list(
    spreadsheetId = deaths_id,
    ranges = "NOPE!A5:F15"
  )
)
resp <- googlesheets4::request_make(req)

stopifnot(httr::status_code(resp) == 400)
saveRDS(
  gargle:::redact_response(resp),
  testthat::test_path("fixtures", "sheets-spreadsheets-get-nonexistent-range_400.rds"),
  version = 2
)

gargle::response_process(resp)
