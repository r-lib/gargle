req <- gargle::request_develop(
  endpoint = googledrive::drive_endpoints("drive.files.get")[[1]],
  params = list(
    fileId = "NOPE_NOT_A_GOOD_ID"
  )
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
  test_path("fixtures", "drive-files-get_404.rds")
)

resp <- readRDS(test_path("fixtures", "drive-files-get_404.rds"))
response_process(resp)
