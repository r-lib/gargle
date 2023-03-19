test_that("PREFIX_auth_description()", {
  expect_snapshot(writeLines(PREFIX_auth_description()))
})

test_that("PREFIX_auth_details()", {
  expect_snapshot(writeLines(PREFIX_auth_details()))
})

test_that("PREFIX_auth_params()", {
  expect_snapshot(writeLines(PREFIX_auth_params()))
})

test_that("PREFIX_deauth_description_with_api_key()", {
  expect_snapshot(writeLines(PREFIX_deauth_description_with_api_key()))
})

test_that("PREFIX_deauth_description_no_api_key()", {
  expect_snapshot(writeLines(PREFIX_deauth_description_no_api_key()))
})

test_that("PREFIX_token_description()", {
  expect_snapshot(writeLines(PREFIX_token_description()))
})

test_that("PREFIX_token_return()", {
  expect_snapshot(writeLines(PREFIX_token_return()))
})

test_that("PREFIX_has_token_description()", {
  expect_snapshot(writeLines(PREFIX_has_token_description()))
})

test_that("PREFIX_has_token_return()", {
  expect_snapshot(writeLines(PREFIX_has_token_return()))
})

test_that("PREFIX_auth_configure_description()", {
  expect_snapshot(writeLines(PREFIX_auth_configure_description()))
})

test_that("PREFIX_auth_configure_params()", {
  expect_snapshot(writeLines(PREFIX_auth_configure_params()))
})

test_that("PREFIX_auth_configure_return()", {
  expect_snapshot(writeLines(PREFIX_auth_configure_return()))
})

test_that("PREFIX_user_description()", {
  expect_snapshot(writeLines(PREFIX_user_description()))
})

test_that("PREFIX_user_seealso()", {
  expect_snapshot(writeLines(PREFIX_user_seealso()))
})

test_that("PREFIX_user_return()", {
  expect_snapshot(writeLines(PREFIX_user_return()))
})
