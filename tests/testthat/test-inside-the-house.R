test_that("gargle is 'inside the house'", {
  expect_true(from_permitted_package())
  expect_error_free(check_permitted_package())
})

test_that("it is possible to be 'outside the house'", {
  expect_false(local(gargle:::from_permitted_package(), envir = globalenv()))
  expect_error(
    local(gargle:::check_permitted_package(), envir = globalenv()),
    "restricted to specific tidyverse packages"
  )
})

test_that("tidyverse API key", {
  key <- tidyverse_api_key()
  expect_true(is_string(key))
  expect_error(
    local(gargle:::tidyverse_api_key(), envir = globalenv()),
    "restricted"
  )
})

test_that("gargle API key", {
  key <- gargle_api_key()
  expect_true(is_string(key))
  expect_error(
    local(gargle:::gargle_api_key(), envir = globalenv()),
    "restricted"
  )
})

# test_that("tidyverse oauth app", {
#   oa <- tidyverse_app()
#   expect_s3_class(oa, "oauth_app")
#   expect_identical(oa$appname, "tidyverse")
# })
#
# test_that("gargle oauth app", {
#   oa <- gargle_app()
#   expect_s3_class(oa, "oauth_app")
#   expect_identical(oa$appname, "gargle-demo")
# })
