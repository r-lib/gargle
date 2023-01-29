test_that("GCE metadata server hostname is correct w.r.t. option and env var", {
  withr::local_options(list(gargle.gce.use_ip = NULL))
  withr::local_envvar(c(GCE_METADATA_URL = NA))
  expect_equal(gce_metadata_hostname(), "metadata.google.internal")

  withr::local_options(list(gargle.gce.use_ip = FALSE))
  expect_equal(gce_metadata_hostname(), "metadata.google.internal")

  withr::local_envvar(GCE_METADATA_URL = "some.fake.hostname")
  expect_equal(gce_metadata_hostname(), "some.fake.hostname")
})

test_that("GCE metadata server IP address is correct w.r.t. option and env var", {
  withr::local_options(list(gargle.gce.use_ip = TRUE))
  withr::local_envvar(c(GCE_METADATA_IP = NA))
  expect_equal(gce_metadata_hostname(), "169.254.169.254")

  withr::local_envvar(c(GCE_METADATA_IP = "1.2.3.4"))
  expect_equal(gce_metadata_hostname(), "1.2.3.4")
})

test_that("GCE metadata detection fails not on GCE", {
  withr::local_envvar(GCE_METADATA_URL = "some.fake.hostname")
  expect_false(is_gce())
})

test_that("Can list service accounts", {
  skip_if_not(is_gce(), "Not on GCE")
  service_accounts <- gce_instance_service_accounts()
  expect_s3_class(service_accounts, class = "data.frame")
})
