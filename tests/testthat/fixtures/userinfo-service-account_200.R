# ---- request with a token, sent in the Authorization header
token <- gargle::credentials_service_account(
  scopes = "https://www.googleapis.com/auth/userinfo.email",
  path = gargle::secret_decrypt_json(
    fs::path_package("gargle", "secret", "gargle-testing.json"),
    key = "GARGLE_KEY"
  )
)
req <- gargle::request_build(
  method = "GET",
  path = "v1/userinfo",
  token = token,
  base_url = "https://openidconnect.googleapis.com"
)
resp <- gargle::request_make(req)

stopifnot(httr::status_code(resp) == 200)

# keep httr's real structure, but not the real access token or the token
# object, which holds the service account's private key
resp$request$headers[["Authorization"]] <- "SECRET"
resp$request$auth_token <- "SECRET"

tmp <- tempfile()
saveRDS(resp, tmp, compress = FALSE)
bytes <- readBin(tmp, "raw", file.size(tmp))
stopifnot(
  length(grepRaw(token$credentials$access_token, bytes, fixed = TRUE)) == 0,
  length(grepRaw("PRIVATE KEY", bytes, fixed = TRUE)) == 0
)
unlink(tmp)

saveRDS(
  resp,
  testthat::test_path("fixtures", "userinfo-service-account_200.rds"),
  version = 2
)
