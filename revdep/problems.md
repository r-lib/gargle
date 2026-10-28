# googledrive (2.1.2)

* GitHub: <https://github.com/tidyverse/googledrive>
* Email: <mailto:jenny@posit.co>
* GitHub mirror: <https://github.com/cran/googledrive>

Run `revdepcheck::cloud_details(, "googledrive")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
       Expected `names(req)` to have the same values as `c("method", "url", "body", "token")`.
       Actual: "method", "url", "body", "token", "headers"
       Expected: "method", "url", "body", "token"
       Needs: "headers"
       ── Failure ('test-request_generate.R:59:3'): request_generate() adds gargle's tidyverse API key if no token ──
       Expected `req$url` to match regexp "<REDACTED>".
       Actual text:
       x | https://www.googleapis.com/drive/v3/files/abc?supportsAllDrives=TRUE
       ── Failure ('test-request_generate.R:69:3'): request_generate(): explicit API key > key in params > built-in ──
       Expected `req$url` to match regexp "key=xyz".
       Actual text:
       x | https://www.googleapis.com/drive/v3/files/abc?supportsAllDrives=TRUE
       ── Failure ('test-request_generate.R:77:3'): request_generate(): explicit API key > key in params > built-in ──
       Expected `req$url` to match regexp "key=xyz".
       Actual text:
       x | https://www.googleapis.com/drive/v3/files/abc?supportsAllDrives=TRUE
       ── Failure ('test-request_generate.R:84:3'): request_generate(): explicit API key > key in params > built-in ──
       Expected `req$url` to match regexp "xyz".
       Actual text:
       x | https://www.googleapis.com/drive/v3/files/abc?supportsAllDrives=TRUE
       
       [ FAIL 5 | WARN 0 | SKIP 126 | PASS 273 ]
       Error:
       ! Test failures.
       Execution halted
     ```

# googlesheets4 (1.1.2)

* GitHub: <https://github.com/tidyverse/googlesheets4>
* Email: <mailto:jenny@posit.co>
* GitHub mirror: <https://github.com/cran/googlesheets4>

Run `revdepcheck::cloud_details(, "googlesheets4")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
         'test-range_read_cells.R:2:3', 'test-range_read_cells.R:14:3',
         'test-range_read_cells.R:46:3', 'test-range_read_cells.R:76:3',
         'test-range_speedread.R:2:3', 'test-range_write.R:6:3',
         'test-range_write.R:48:3', 'test-schemas.R:18:1', 'test-schemas.R:76:1',
         'test-sheet_add.R:5:1', 'test-sheet_add.R:13:3', 'test-sheet_append.R:6:3',
         'test-sheet_copy.R:6:3', 'test-sheet_copy.R:19:3',
         'test-sheet_delete.R:13:3', 'test-sheet_relocate.R:6:3',
         'test-sheet_rename.R:6:3', 'test-sheet_resize.R:6:3',
         'test-sheet_write.R:6:3', 'test-sheet_write.R:57:3',
         'test-sheets_id-class.R:7:1', 'test-sheets_id-class.R:11:1',
         'test-sheets_id-class.R:40:1', 'test-sheets_id-class.R:45:1',
         'test-sheets_id-class.R:74:3', 'test-sheets_id-class.R:81:3',
         'test-sheets_id-class.R:89:3', 'test-sheets_id-class.R:97:3',
         'test-utils-ui.R:18:1'
       
       ══ Failed tests ════════════════════════════════════════════════════════════════
       ── Failure ('test-request_generate.R:8:3'): can generate a basic request ───────
       Expected `req$url` to match regexp "^https://sheets.googleapis.com/v4/spreadsheets/abc123\\?key=.+".
       Actual text:
       x | https://sheets.googleapis.com/v4/spreadsheets/abc123
       
       [ FAIL 1 | WARN 0 | SKIP 52 | PASS 412 ]
       Error:
       ! Test failures.
       Execution halted
     ```

# trackdown (1.1.1)

* GitHub: <https://github.com/claudiozandonella/trackdown>
* Email: <mailto:claudiozandonella@gmail.com>
* GitHub mirror: <https://github.com/cran/trackdown>

Run `revdepcheck::cloud_details(, "trackdown")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
       Error in `source_dir()`:
       ! Failed to evaluate './setup-trackdown.R'.
       Caused by error in `get_auth_credentials()`:
       ! object 'secret_can_decrypt' not found
       Backtrace:
            ▆
         1. ├─testthat::test_check("trackdown")
         2. │ └─testthat::test_dir(...)
         3. │   └─testthat:::test_files(...)
         4. │     └─testthat:::test_files_serial(...)
         5. │       └─testthat:::test_files_setup_state(...)
         6. │         └─testthat::source_test_setup(".", env)
         7. │           └─testthat::source_dir(path, "^setup.*\\.[rR]$", env = env, wrap = FALSE)
         8. │             └─base::lapply(...)
         9. │               └─testthat (local) FUN(X[[i]], ...)
        10. │                 └─testthat::source_file(...)
        11. │                   ├─base::withCallingHandlers(...)
        12. │                   └─base::eval(exprs, env)
        13. │                     └─base::eval(exprs, env)
        14. │                       └─trackdown:::get_auth_credentials() at ./setup-trackdown.R:3:1
        15. └─base::.handleSimpleError(...) at ./helper.R:30:3
        16.   └─testthat (local) h(simpleError(msg, call))
        17.     └─cli::cli_abort(...)
        18.       └─rlang::abort(...)
       Execution halted
     ```
