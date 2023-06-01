# testing just the secret_* bits that are unique to gargle ----
test_that("secret_encrypt_json()/secret_decrypt_json() round-trip", {
  key <- openssl::rand_bytes(32)
  pth <- withr::local_tempfile()
  in_pth <- fs::path_package("gargle", "extdata", "fake_service_account.json")

  # path in
  secret_encrypt_json(in_pth, pth, key = key)
  res <- secret_decrypt_json(pth, key = key)
  expect_equal(
    jsonlite::fromJSON(in_pth, simplifyVector = FALSE),
    jsonlite::fromJSON(res, simplifyVector = FALSE)
  )

  # string in
  in_str <- readChar(in_pth, nchars = fs::file_size(in_pth))
  secret_encrypt_json(in_str, pth, key = key)
  res <- secret_decrypt_json(pth, key = key)
  expect_equal(
    jsonlite::fromJSON(in_str, simplifyVector = FALSE),
    jsonlite::fromJSON(res, simplifyVector = FALSE)
  )
})

test_that("secret_get_key() error", {
  withr::local_envvar(TESTTHAT = NA)
  expect_snapshot(
    error = TRUE,
    secret_get_key("HA_HA_HA_NO")
  )
})

test_that("as_key() error", {
  expect_snapshot(
    error = TRUE,
    as_key(pi)
  )
})

# gargle's older deprecated secret_ functions ----
test_that("older secret functions are deprecated", {
  withr::local_options(lifecycle_verbosity = "warning")
  withr::local_envvar(FAKEPKG_PASSWORD = "fake_password")

  expect_snapshot(secret_pw_name("pkg"))
  expect_snapshot(absorb_it <- secret_pw_gen())

  expect_snapshot(secret_pw_exists("fakePKG"))
  expect_snapshot(absorb_it <- secret_pw_get("fakePKG"))
  expect_snapshot(secret_can_decrypt("fakePKG"))

  # leaving secret_write, secret_read untested
})
