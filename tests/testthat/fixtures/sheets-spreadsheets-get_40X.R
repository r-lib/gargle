req <- gargle::request_develop(
  endpoint = googlesheets4::sheets_endpoints("sheets.spreadsheets.get")[[1]],
  params = list(
    spreadsheetId = "NOPE_NOT_A_GOOD_ID",
    fields = "spreadsheetId"
  ),
  base_url = "https://sheets.googleapis.com/"
)
req <- gargle::request_build(
  path = req$path,
  method = req$method,
  params = req$params,
  key = gargle_api_key()
)
resp <- request_make(req)

stopifnot(httr::status_code(resp) == 404)
saveRDS(
  redact_response(resp),
  test_path("fixtures", "sheets-spreadsheets-get_404.rds")
)

resp <- readRDS(test_path("fixtures", "sheets-spreadsheets-get_404.rds"))
response_process(resp)

req <- gargle::request_develop(
  endpoint = googlesheets4::sheets_endpoints("sheets.spreadsheets.get")[[1]],
  params = list(
    # sheets_example("deaths")
    spreadsheetId = "1ESTf_tH08qzWwFYRC1NVWJjswtLdZn9EGw5e3Z5wMzA",
    ranges = "NOPE!A5:F15",
    fields = "spreadsheetId"
  ),
  base_url = "https://sheets.googleapis.com/"
)
req <- gargle::request_build(
  path = req$path,
  method = req$method,
  params = req$params,
  key = gargle_api_key(),
  base_url = req$base_url
)
resp <- request_make(req)

stopifnot(httr::status_code(resp) == 400)
saveRDS(
  redact_response(resp),
  test_path("fixtures", "sheets-spreadsheets-get_400.rds")
)

resp <- readRDS(test_path("fixtures", "sheets-spreadsheets-get_400.rds"))
response_process(resp)
