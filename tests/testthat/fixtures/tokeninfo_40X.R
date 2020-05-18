# intent is to specify an existing, valid, but STALE token in the cache
googledrive::drive_auth("jenny.f.bryan@gmail.com")
token <- googledrive::drive_token()
token <- token$auth_token
req <- gargle::request_build(
  method = "GET",
  path = "oauth2/v3/tokeninfo",
  token = token
)
resp <- gargle::request_make(req)

# if this is not 400, it's not what we want
# perhaps the token isn't actually stale?
stopifnot(httr::status_code(resp) == 400)
saveRDS(
  gargle:::redact_response(resp),
  testthat::test_path("fixtures", "tokeninfo-stale_400.rds"),
  version = 2
)

gargle::response_process(resp)

# specify a bad path
req <- gargle::request_build(
  method = "GET",
  path = "oauth2/v3/tokeninf", # <-- typo here
  token = token
)
resp <- gargle::request_make(req)

stopifnot(httr::status_code(resp) == 404)
saveRDS(
  gargle:::redact_response(resp),
  testthat::test_path("fixtures", "tokeninfo-bad-path_404.rds"),
  version = 2
)

gargle::response_process(resp)
