## CRAN submission notes

2019-05-09 Initial submission v0.1.0

  * Clean pass from auto-check service

2019-05-10 Feedback from CRAN assistant SH re: examples for unexported functions (see email).

  * Ensured that no `.Rd` file would be created for this internal function <https://github.com/r-lib/gargle/commit/c6f9894bcc157f42c4a0f17bf2cad96980134e83>.

2019-05-09 Resubmit, bump version to v0.1.1

  * Clean pass from auto-check service

2019-05-13 Feedback from CRAN assistant MS re: title, description, using `cat()`, examples (see email).

  * Removed "from R" from title and provided a "link to the google apis" in description via [eb3a4cd](https://github.com/r-lib/gargle/commit/eb3a4cdf87d9f64d4e0f5472fe377f97a9f75538)
  * Added examples via [a23bced](https://github.com/r-lib/gargle/commit/a23bced6e62cb947c49fad061424d50de39e3ff0). 7 of 9 must be in `\dontrun{}` because the code can't be run on CRAN due to lack of encrypted files / env vars and the inability to make HTTP calls with a tolerance for intermittent server side failure.

2019-05-13 Resubmit, bump version to v0.1.2

  * Clean pass from auto-check service

2019-05-16 Feedback from CRAN assistant MS requests `\donttest()` now instead of `\dontrun{}`, reiterates the `cat()` stuff, new request to "rephrase the first sentence of the description" (no further specifics).
