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
