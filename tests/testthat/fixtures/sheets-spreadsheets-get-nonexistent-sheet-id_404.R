# ---- sheet ID that does not exist
googlesheets4::gs4_deauth()
req <- googlesheets4::request_generate(
  endpoint = "sheets.spreadsheets.get",
  params = list(
    spreadsheetId = "DOES_NOT_EXIST",
    fields = "spreadsheetId"
  )
)
resp <- googlesheets4::request_make(req)

stopifnot(httr::status_code(resp) == 404)

saveRDS(
  gargle:::redact_response(resp),
  testthat::test_path(
    "fixtures", "sheets-spreadsheets-get-nonexistent-sheet-id_404.rds"
  ),
  version = 2
)

gargle::response_process(resp)
