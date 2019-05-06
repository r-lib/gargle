# intent is to specify an existing, valid, but STALE token in the cache
token <- token_fetch(
  scope = "https://www.googleapis.com/auth/drive",
  email = "jenny.f.bryan@gmail.com"
)
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
  redact_response(resp),
  test_path("fixtures", "tokeninfo_400_stale.rds")
)

resp <- readRDS(test_path("fixtures", "tokeninfo_400_stale.rds"))
response_process(resp)

req <- gargle::request_build(
  method = "GET",
  path = "oauth2/v3/tokeninf", # <-- typo here
  token = token
)
resp <- gargle::request_make(req)

stopifnot(httr::status_code(resp) == 404)
saveRDS(
  redact_response(resp),
  test_path("fixtures", "tokeninfo_400_bad-path.rds")
)

resp <- readRDS(test_path("fixtures", "tokeninfo_400_bad-path.rds"))
response_process(resp)
