test_that("gargle is 'inside the house'", {
  expect_true(from_permitted_package())
  expect_no_error(check_permitted_package())
})

test_that("it is possible to be 'outside the house'", {
  expect_false(local(gargle:::from_permitted_package(), envir = globalenv()))
  expect_snapshot(
    local(gargle:::check_permitted_package(), envir = globalenv()),
    error = TRUE
  )
})

test_that("gargle API key", {
  key <- gargle_api_key()
  expect_true(is_string(key))
})

test_that("tidyverse API key", {
  key <- tidyverse_api_key()
  expect_true(is_string(key))
  expect_snapshot(
    local(tidyverse_api_key(), envir = globalenv()),
    error = TRUE
  )
})

test_that("gargle oauth app (deprecated)", {
  expect_snapshot(
    oa <- gargle_app()
  )
  expect_s3_class(oa, "oauth_app")
  expect_match(oa$appname, "^gargle")
})

test_that("gargle oauth installed client", {
  oc <- gargle_client()
  expect_s3_class(oc, "gargle_oauth_client")
  expect_s3_class(oc, "oauth_app")
  expect_match(oc$name, "^gargle")
  expect_equal(oc$type, "installed")

  expect_equal(gargle_client("installed"), oc)
})

test_that("gargle oauth web client", {
  oc <- gargle_client("web")
  expect_s3_class(oc, "gargle_oauth_client")
  expect_s3_class(oc, "oauth_app")
  expect_match(oc$name, "^gargle")
  expect_equal(oc$type, "web")
  expect_equal(oc$redirect_uris, "https://www.tidyverse.org/google-callback/")
})

test_that("tidyverse oauth app (deprecated)", {
  expect_snapshot(
    oa <- tidyverse_app()
  )
  expect_s3_class(oa, "oauth_app")
  expect_match(oa$appname, "^tidyverse")
})

test_that("tidyverse oauth installed client", {
  oc <- tidyverse_client()
  expect_s3_class(oc, "gargle_oauth_client")
  expect_s3_class(oc, "oauth_app")
  expect_match(oc$name, "^tidyverse")
  expect_equal(oc$type, "installed")

  expect_equal(tidyverse_client("installed"), oc)
})

test_that("tidyverse oauth web client", {
  oc <- tidyverse_client("web")
  expect_s3_class(oc, "gargle_oauth_client")
  expect_s3_class(oc, "oauth_app")
  expect_match(oc$name, "^tidyverse")
  expect_equal(oc$type, "web")
  expect_equal(oc$redirect_uris, "https://www.tidyverse.org/google-callback/")
})
