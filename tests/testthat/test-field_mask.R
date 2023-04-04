test_that("field_mask works", {
  x <- list(a = "A")
  expect_equal(field_mask(x), "a")

  x <- list(a = "A", b = "B")
  expect_equal(field_mask(x), "a,b")

  x <- list(a = list(b = "B", c = "C"))
  expect_equal(field_mask(x), "a(b,c)")

  x <- list(a = "A", b = list(c = "C"))
  expect_equal(field_mask(x), "a,b.c")

  x <- list(a = "A", b = list(c = "C", d = list(e = "E")))
  expect_equal(field_mask(x), "a,b.c,b.d.e")

  x <- list(a = "A", b = list(c = "C", d = "D", e = list(f = "F")))
  expect_equal(field_mask(x), "a,b(c,d),b.e.f")
})
