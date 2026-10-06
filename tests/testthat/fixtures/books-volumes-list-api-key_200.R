# ---- request with an API key, sent in the X-goog-api-key header
req <- gargle::request_build(
  path = "books/v1/volumes",
  params = list(q = "R Packages", maxResults = 1),
  key = gargle::gargle_api_key()
)
resp <- gargle::request_retry(req)

stopifnot(httr::status_code(resp) == 200)

# keep httr's real structure, but not the real key
resp$request$headers[["X-goog-api-key"]] <- "SECRET"

saveRDS(
  resp,
  testthat::test_path("fixtures", "books-volumes-list-api-key_200.rds"),
  version = 2
)
