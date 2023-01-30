## R CMD check results

0 errors | 0 warnings | 0 notes

## revdepcheck results

We checked 14 reverse dependencies, comparing R CMD check results across CRAN and dev versions of this package.

 * We saw 2 new problems (but they are not actual problems; see below).
 * We failed to check 0 packages.

Issues with CRAN packages are summarised below.

### New problems
* googledrive
  checking dependencies in R code ... NOTE
  ```
  Unexported objects imported by ':::' calls:
    ‘gargle:::secret_can_decrypt’ ‘gargle:::secret_read’
    See the note in ?`:::` about the use of this operator.
  ```

* googlesheets4
  (same NOTE as for googledrive)
  
I maintain both googledrive and googlesheets4.

Both packages have internal utility functions that make `:::` calls into gargle to determine if we are able to decrypt a token and, if so, to decrypt it. These utilities are during testing and when building the pkgdown website and are never called by exported functions. And, to reiterate, I maintain all of these packages myself.
