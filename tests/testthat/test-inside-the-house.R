test_that("gargle is 'inside the house'", {
  expect_true(from_permitted_package())
})

test_that("from_permitted_package() can return FALSE", {
  expect_false(local(gargle:::from_permitted_package(), envir = globalenv()))
})
