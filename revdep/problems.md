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
        6.         └─googledrive::drive_get(path = x)
        7.           └─googledrive:::dribble_from_path(path, team_drive, corpus)
        8.             └─googledrive:::get_nodes(path, team_drive, corpus)
        9.               └─googledrive::drive_find(...)
       10.                 └─googledrive::do_paginated_request(...)
       11.                   └─gargle::response_process(page)
       12.                     └─gargle:::gargle_abort_request_failed(error_message(resp), resp)
       13.                       └─gargle:::gargle_abort(...)
       14.                         └─cli::cli_abort(...)
      ── Failure (test-path-utils.R:237:3): check_for_overwrite() copes with `parent = NULL` ──
      `check_for_overwrite(parent = NULL, nm_("create-in-me"), overwrite = FALSE)` did not throw an error.
      
      [ FAIL 49 | WARN 0 | SKIP 0 | PASS 348 ]
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

## In both

*   checking tests ...
    ```
     ERROR
    Running the tests in ‘tests/testthat.R’ failed.
    Last 13 lines of output:
      Error: A spreadsheet named 'TEST-sheet_relocate-jenny' already exists.
      Backtrace:
          █
       1. └─googlesheets4:::local_ss(me_(), sheets = sheet_names) test-sheet_relocate.R:10:2
       2.   └─googlesheets4:::stop_glue("A spreadsheet named {sq(name)} already exists.") helper.R:50:4
      ── Error (test-sheet_resize.R:9:3): sheet_resize() works ───────────────────────
      Error: A spreadsheet named 'TEST-sheet_resize-jenny' already exists.
      Backtrace:
          █
       1. └─googlesheets4:::local_ss(me_()) test-sheet_resize.R:9:2
       2.   └─googlesheets4:::stop_glue("A spreadsheet named {sq(name)} already exists.") helper.R:50:4
      
      [ FAIL 3 | WARN 0 | SKIP 4 | PASS 512 ]
      Error: Test failures
      Execution halted
    ```

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

