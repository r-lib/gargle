# ---- file ID that does not exist
googledrive::drive_deauth()
req <- googledrive::request_generate(
  endpoint = "drive.files.get",
  params = list(
    fileId = "NOPE_NOT_A_GOOD_ID"
  )
)
resp <- googledrive::request_make(req)

stopifnot(httr::status_code(resp) == 404)
saveRDS(
  gargle:::redact_response(resp),
  testthat::test_path("fixtures", "drive-files-get-nonexistent-file-id_404.rds"),
  version = 2
)

gargle::response_process(resp)
