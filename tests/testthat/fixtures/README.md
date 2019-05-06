
<!-- README.md is generated from README.Rmd. Please edit that file -->

``` r
library(gargle)
# testthat::test_path() does not work here ... too deep?
test_path <- function(...) {
  rprojroot::find_testthat_root_file(...)
}
```

# Response test fixtures

Demos of how we fail for various bad requests.

-----

Get a `fileId` that does not exist on Drive.

``` r
resp <- readRDS(test_path("fixtures", "drive-files-get_404.rds"))
response_process(resp)
#> Client error: (404) Not Found
#>   *       domain: global
#>   *       reason: notFound
#>   *      message: File not found: NOPE_NOT_A_GOOD_ID.
#>   * locationType: parameter
#>   *     location: fileId
```

-----

Get a spreadsheet `fileId` that does not exist in
Sheets.

``` r
resp <- readRDS(test_path("fixtures", "sheets-spreadsheets-get_404.rds"))
response_process(resp)
#> Client error: (404) Not Found
#>   * Non-JSON content type: text/html
```

-----

Request cell data for a range on a worksheet that does not exist, within
a spreadsheet that does exist and is world
readable.

``` r
resp <- readRDS(test_path("fixtures", "sheets-spreadsheets-get_400.rds"))
response_process(resp)
#> Client error: (400) INVALID_ARGUMENT
#>   * Client specified an invalid argument. Check error message and error details for more information.
#>   * Unable to parse range: NOPE!A5:F15
```

-----

Ask for info about a refreshable, but stale OAuth token

``` r
resp <- readRDS(test_path("fixtures", "tokeninfo_400_stale.rds"))
response_process(resp)
#> Client error: (400) Bad Request
#>   * Invalid Value
```

-----

Ask for info about an OAuth token, with a typo in the endpoint path.

``` r
resp <- readRDS(test_path("fixtures", "tokeninfo_400_bad-path.rds"))
response_process(resp)
#> Client error: (404) Not Found
#>   * Non-JSON content type: text/html
```
