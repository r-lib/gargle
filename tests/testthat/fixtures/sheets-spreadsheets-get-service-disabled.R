# response provided by the user from
# https://github.com/tidyverse/googlesheets4/issues/317

# in theory, I should be able to reprex by creating a service account and NOT
# enabling the Sheets API, then trying to access even an example sheet via
# gs4_example()

# this script doesn't create the response, but records how I processed their
# original raw response to remove the user's project id

resp_before <- readRDS(testthat::test_path("fixtures", "response.rds"))

content_before <- httr::content(resp_before, type = "raw")
content_before <- rawToChar(content_before)
Encoding(content_before) <- "UTF-8"
content_before <- jsonlite::fromJSON(content_before, simplifyVector = FALSE)

id <- content_before$error$details[[1]]$metadata$containerInfo
redacted_content <- rapply(
  content_before,
  function(x) gsub(id, "1234567890", x),
  classes = "character",
  how = "replace"
)

content_after <- jsonlite::toJSON(redacted_content, auto_unbox = TRUE)
content_after <- charToRaw(content_after)

resp_after <- resp_before
resp_after$content <- content_after

# make sure this looks reasonable
response_process(resp_after)

saveRDS(
  gargle:::redact_response(resp_after),
  testthat::test_path("fixtures", "sheets-spreadsheets-get-service-disabled_403.rds"),
  version = 2
)
