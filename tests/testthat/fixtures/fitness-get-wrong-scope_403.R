# ---- GET to an API for which token does not have scope
# used as an example for response_process()

devtools::load_all()

# get an OAuth2 token with 'userinfo.email' scope
token <- token_fetch(scopes = "https://www.googleapis.com/auth/userinfo.email")

# make a request to the Fitness API, for which we don't have scope
req <- gargle::request_build(
  method = "GET",
  path = "fitness/v1/users/{userId}/dataSources",
  token = token,
  params = list(userId = 12345)
)
resp <- gargle::request_make(req)

stopifnot(httr::status_code(resp) == 403)
saveRDS(
  gargle:::redact_response(resp),
  testthat::test_path("fixtures", "fitness-get-wrong-scope_403.rds"),
  version = 2
)

gargle::response_process(resp)
