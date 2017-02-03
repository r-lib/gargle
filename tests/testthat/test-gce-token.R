context("gce-token-mocked")

test_that('Can list service accounts', {
  service_accounts = c('account1@project.gserviceaccount.com', 'default')
  request_mock <- function(path, ...) {
    stopifnot(path == 'instance/service-accounts')
    httr:::response(
      url = path,
      status_code = 200,
      header = list(`metadata-flavor` = 'Google'),
      content = charToRaw(paste0(c(service_accounts, ''), collapse = '/\n'))
    )
  }

  testthat::with_mock(
    `gauth::gce_metadata_request` = request_mock,
    expect_equal(service_accounts, gauth::list_service_accounts())
  )
})
