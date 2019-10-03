test_that("Can list service accounts", {
  service_accounts <- c("account1@project.gserviceaccount.com", "default")
  request_mock <- function(path, ...) {
    stopifnot(path == "instance/service-accounts")
    httr:::response(
      url = path,
      status_code = 200,
      header = list(`metadata-flavor` = "Google"),
      content = charToRaw(paste0(c(service_accounts, ""), collapse = "/\n"))
    )
  }

  testthat::with_mock(
    `gargle::gce_metadata_request` = request_mock,
    expect_equal(service_accounts, list_service_accounts())
  )
})

test_that("GCE metadata env vars are respected", {
  tryCatch({
    expect_equal("http://metadata.google.internal/", gce_metadata_url())
    Sys.setenv(GCE_METADATA_URL = "fake.url")
    expect_equal("http://fake.url/", gce_metadata_url())

    options(gargle.gce.use_ip = TRUE)
    expect_equal("http://169.254.169.254/", gce_metadata_url())
    Sys.setenv(GCE_METADATA_IP = "1.2.3.4")
    expect_equal("http://1.2.3.4/", gce_metadata_url())
  }, finally = {
    # We could save and restore these values, but there's no reason they should
    # be set in tests.
    Sys.unsetenv("GCE_METADATA_IP")
    Sys.unsetenv("GCE_METADATA_URL")
    options(gargle.gce.use_ip = NULL)
  })
})

test_that("GCE metadata detection fails not on GCE", {
  tryCatch({
    Sys.setenv(GCE_METADATA_URL = "some.fake.address")
    expect_false(detect_gce())
  }, finally = {
    Sys.unsetenv("GCE_METADATA_URL")
  })
})
