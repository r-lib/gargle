# ---- API key that does not have Sheets enabled
req <- gargle::request_develop(
  endpoint = googlesheets4::gs4_endpoints("sheets.spreadsheets.get")[[1]],
  params = list(
    spreadsheetId = "DOES_NOT_MATTER",
    fields = "spreadsheetId"
  ),
  base_url = "https://sheets.googleapis.com/"
)
req <- gargle::request_build(
  path     = req$path,
  method   = req$method,
  params   = req$params,
  key      = gargle::gargle_api_key(),
  base_url = req$base_url
)
resp <- gargle::request_make(req)

stopifnot(httr::status_code(resp) == 403)

saveRDS(
  gargle:::redact_response(resp),
  testthat::test_path(
    "fixtures", "sheets-spreadsheets-get-api-key-not-enabled_403.rds"
  ),
  version = 2
)

gargle::response_process(resp)
