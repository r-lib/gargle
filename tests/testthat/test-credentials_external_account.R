test_that("unparseable JSON subject token errors without revealing it", {
  expect_snapshot(
    error = TRUE,
    parse_subject_token(
      '{"id_token": "SECRET-TOKEN"',
      format = list(type = "json", subject_token_field_name = "id_token")
    )
  )
})

test_that("service account impersonation is required", {
  expect_snapshot(
    error = TRUE,
    init_oauth_external_account(list(credential_source = list(file = "x")))
  )
})
