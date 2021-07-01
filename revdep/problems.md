# bigrquery

<details>

* Version: 1.3.2
* GitHub: https://github.com/r-dbi/bigrquery
* Source code: https://github.com/cran/bigrquery
* Date/Publication: 2020-10-05 14:40:03 UTC
* Number of recursive dependencies: 67

Run `revdep_details(, "bigrquery")` for more info

</details>

## In both

*   checking tests ...
    ```
     ERROR
    Running the tests in ‘tests/testthat.R’ failed.
    Last 13 lines of output:
      > library(bigrquery)
      > 
      > test_check("bigrquery")
      ══ Skipped tests ═══════════════════════════════════════════════════════════════
      • On CRAN (2)
      
      ══ Failed tests ════════════════════════════════════════════════════════════════
      ── Failure (test-bq-dataset.R:34:3): can list tables in a dataset ──────────────
      bq_dataset_tables(ds) not equal to list(bq_table(ds, "mtcars")).
      Length mismatch: comparison on first 1 components
      Component 1: Component 3: 1 string mismatch
      
      [ FAIL 1 | WARN 0 | SKIP 2 | PASS 234 ]
      Error: Test failures
      Execution halted
    ```

*   checking LazyData ... NOTE
    ```
      'LazyData' is specified without a 'data' directory
    ```

# daiR

<details>

* Version: 0.9.0
* GitHub: https://github.com/Hegghammer/daiR
* Source code: https://github.com/cran/daiR
* Date/Publication: 2021-06-11 09:20:02 UTC
* Number of recursive dependencies: 79

Run `revdep_details(, "daiR")` for more info

</details>

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespaces in Imports field not imported from:
      ‘curl’ ‘fs’ ‘googleCloudStorageR’
      All declared Imports should be used.
    ```

# googledrive

<details>

* Version: 1.0.1
* GitHub: https://github.com/tidyverse/googledrive
* Source code: https://github.com/cran/googledrive
* Date/Publication: 2020-05-05 16:10:02 UTC
* Number of recursive dependencies: 67

Run `revdep_details(, "googledrive")` for more info

</details>

## In both

*   checking tests ...
    ```
     ERROR
    Running the tests in ‘tests/testthat.R’ failed.
    Last 13 lines of output:
      Backtrace:
          █
       1. └─googledrive::drive_empty_trash() test-path-utils.R:191:4
       2.   └─googledrive::drive_find(trashed = TRUE)
       3.     └─googledrive::do_paginated_request(...)
       4.       └─gargle::response_process(page)
       5.         └─gargle:::gargle_abort_request_failed(error_message(resp), resp)
       6.           └─gargle:::gargle_abort(...)
       7.             └─cli::cli_abort(...)
      ── Failure (test-path-utils.R:237:3): check_for_overwrite() copes with `parent = NULL` ──
      `check_for_overwrite(parent = NULL, nm_("create-in-me"), overwrite = FALSE)` did not throw an error.
      
      [ FAIL 50 | WARN 0 | SKIP 0 | PASS 346 ]
      Error: Test failures
      Execution halted
    ```

*   checking LazyData ... NOTE
    ```
      'LazyData' is specified without a 'data' directory
    ```

# googlesheets4

<details>

* Version: 0.3.0
* GitHub: https://github.com/tidyverse/googlesheets4
* Source code: https://github.com/cran/googlesheets4
* Date/Publication: 2021-03-04 17:50:02 UTC
* Number of recursive dependencies: 71

Run `revdep_details(, "googlesheets4")` for more info

</details>

## Newly fixed

*   checking tests ...
    ```
     ERROR
    Running the tests in ‘tests/testthat.R’ failed.
    Last 13 lines of output:
      ── Error (test-sheet_copy.R:28:3): external copy works ─────────────────────────
      Error: Server error: (500) INTERNAL
      * Internal server error. Typically a server bug.
      * Internal error encountered.
      Backtrace:
          █
       1. └─googlesheets4::sheet_copy(...) test-sheet_copy.R:28:2
       2.   └─googlesheets4:::sheet_copy_external(...)
       3.     └─gargle::response_process(resp_raw)
       4.       └─gargle:::gargle_abort_request_failed(error_message(resp), resp)
       5.         └─gargle:::gargle_abort(...)
      
      [ FAIL 1 | WARN 0 | SKIP 4 | PASS 516 ]
      Error: Test failures
      Execution halted
    ```

## In both

*   checking LazyData ... NOTE
    ```
      'LazyData' is specified without a 'data' directory
    ```

# ReviewR

<details>

* Version: 2.3.6
* GitHub: https://github.com/thewileylab/ReviewR
* Source code: https://github.com/cran/ReviewR
* Date/Publication: 2021-04-02 11:30:05 UTC
* Number of recursive dependencies: 144

Run `revdep_details(, "ReviewR")` for more info

</details>

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespace in Imports field not imported from: ‘pkgload’
      All declared Imports should be used.
    ```

*   checking data for non-ASCII characters ... NOTE
    ```
      Note: found 12 marked UTF-8 strings
    ```

