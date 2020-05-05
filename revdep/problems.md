# bigrquery

<details>

* Version: 1.2.0
* Source code: https://github.com/cran/bigrquery
* URL: https://github.com/rstats-db/bigrquery
* BugReports: https://github.com/rstats-db/bigrquery/issues
* Date/Publication: 2019-07-02 05:20:57 UTC
* Number of recursive dependencies: 63

Run `revdep_details(,"bigrquery")` for more info

</details>

## In both

*   checking tests ...
    ```
     ERROR
    Running the tests in ‘tests/testthat.R’ failed.
    Last 13 lines of output:
      [90m 8. [39mbigrquery:::bq_check_response(status, type, content)
      [90m 9. [39mbigrquery:::signal_reason(json$error$errors[[1L]]$reason, json$error$message)
      
      ══ testthat results  ═══════════════════════════════════════════════════════════
      [ OK: 237 | SKIPPED: 0 | WARNINGS: 1 | FAILED: 7 ]
      1. Error: bq_perform_upload creates job that succeeds (@test-bq-perform.R#7) 
      2. Error: can round trip to non-default location (@test-bq-table.R#44) 
      3. Error: can round trip atomic vectors (@test-bq-table.R#89) 
      4. Error: can round trip data frame with list-cols (@test-bq-table.R#129) 
      5. Error: can init new dataset (@test-bq-test.R#5) 
      6. Error: can roundtrip a data frame (@test-dbi-connection.R#69) 
      7. Error: can append to an existing dataset (@test-dbi-connection.R#81) 
      
      Error: testthat unit tests failed
      Execution halted
    ```

# googledrive

<details>

* Version: 1.0.1
* Source code: https://github.com/cran/googledrive
* URL: https://googledrive.tidyverse.org, https://github.com/tidyverse/googledrive
* BugReports: https://github.com/tidyverse/googledrive/issues
* Date/Publication: 2020-05-05 16:10:02 UTC
* Number of recursive dependencies: 67

Run `revdep_details(,"googledrive")` for more info

</details>

## In both

*   checking tests ...
    ```
     ERROR
    Running the tests in ‘tests/testthat.R’ failed.
    Last 13 lines of output:
        *     location: fileId
      [1mBacktrace:[22m
      [90m 1. [39mgoogledrive::drive_rm(me_("folder-in-root"))
      [90m 2. [39mpurrr::map_lgl(file$id, delete_one)
      [90m 3. [39mgoogledrive:::.f(.x[[i]], ...)
      [90m 4. [39mgargle::response_process(response)
      [90m 5. [39mgargle:::stop_request_failed(error_message(resp), resp)
      
      ══ testthat results  ═══════════════════════════════════════════════════════════
      [ OK: 453 | SKIPPED: 0 | WARNINGS: 0 | FAILED: 2 ]
      1. Error: drive_create() create specific things in root folder 
      2. Error: drive_mkdir() creates a folder in root folder 
      
      Error: testthat unit tests failed
      Execution halted
    ```

