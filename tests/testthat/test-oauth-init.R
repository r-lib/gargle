test_that("use_oob must be TRUE or FALSE", {
  expect_snapshot(error = TRUE, check_oob("a"))
  expect_snapshot(error = TRUE, check_oob(c(FALSE, FALSE)))
})

test_that("OOB requires an interactive session", {
  local_interactive(FALSE)
  expect_snapshot(error = TRUE, check_oob(TRUE))
})

test_that("makes no sense to pass oob_value if not OOB", {
  skip_if_not_installed("httpuv")
  local_interactive(TRUE)
  expect_snapshot(error = TRUE, check_oob(FALSE, "custom_value"))
})

test_that("oob_value has to be a string", {
  expect_snapshot(error = TRUE, check_oob(TRUE, c("a", "b")))
})

test_that("check_oauth_redirect() requires matching state, checked first", {
  expect_snapshot(
    error = TRUE,
    check_oauth_redirect(list(code = "abc", state = "nope"), "xyz")
  )
  expect_snapshot(
    error = TRUE,
    check_oauth_redirect(list(code = "abc"), "xyz")
  )
  expect_snapshot(
    error = TRUE,
    check_oauth_redirect(list(error = "access_denied", state = "nope"), "xyz")
  )
})

test_that("check_oauth_redirect() reports an error or missing code", {
  expect_snapshot(
    error = TRUE,
    check_oauth_redirect(list(error = "access_denied", state = "xyz"), "xyz")
  )
  expect_snapshot(
    error = TRUE,
    check_oauth_redirect(list(state = "xyz"), "xyz")
  )
})

test_that("pkce_challenge() matches the RFC 7636 test vector", {
  expect_equal(
    pkce_challenge("dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk"),
    "E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM"
  )
})

test_that("pkce_verifier() has an RFC 7636-compliant form", {
  expect_match(pkce_verifier(), "^[A-Za-z0-9_-]{43}$")
})

test_that("pkce_verifier() generates a different value each time", {
  v <- c(pkce_verifier(), pkce_verifier())
  expect_length(unique(v), 2)
})

test_that("loopback flow uses PKCE", {
  skip_if_not_installed("httpuv")
  authorize_url <- NULL
  token_params <- NULL
  local_mocked_bindings(
    oauth_listener = function(url) {
      authorize_url <<- url
      list(code = "abc", state = httr::parse_url(url)$query$state)
    },
    oauth_access_token = function(endpoint, client, code, user_params, ...) {
      token_params <<- user_params
      "TOKEN"
    }
  )

  init_oauth2.0(
    client = gargle_oauth_client("ID", "SECRET"),
    scope = "email",
    use_oob = FALSE
  )

  query <- httr::parse_url(authorize_url)$query
  expect_equal(query$code_challenge_method, "S256")
  expect_equal(query$code_challenge, pkce_challenge(token_params$code_verifier))
})

test_that("pseudo-OOB flow uses PKCE", {
  local_interactive(TRUE)
  authorize_url <- NULL
  token_params <- NULL
  local_mocked_bindings(
    oauth_exchanger_with_state = function(request_url, state) {
      authorize_url <<- request_url
      list(code = "abc")
    },
    oauth_access_token = function(endpoint, client, code, user_params, ...) {
      token_params <<- user_params
      "TOKEN"
    }
  )

  init_oauth2.0(
    client = gargle_oauth_client(
      "ID",
      "SECRET",
      type = "web",
      redirect_uris = "https://example.org/google-callback/"
    ),
    scope = "email",
    use_oob = TRUE,
    oob_value = "https://example.org/google-callback/"
  )

  query <- httr::parse_url(authorize_url)$query
  expect_equal(query$code_challenge_method, "S256")
  expect_equal(query$code_challenge, pkce_challenge(token_params$code_verifier))
})

test_that("loopback flow checks the redirect", {
  local_mocked_bindings(
    oauth_listener = function(url) list(code = "abc", state = "xyz")
  )
  expect_equal(oauth_authorize("https://example.org", state = "xyz"), "abc")
  expect_snapshot(
    error = TRUE,
    oauth_authorize("https://example.org", state = "nope")
  )
})
