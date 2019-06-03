## CRAN submission notes

2019-05-09 Initial submission v0.1.0

  * Clean pass from auto-check service

2019-05-10 Feedback from CRAN assistant SH re: examples for unexported functions (see email).

  * Ensured that no `.Rd` file would be created for this internal function <https://github.com/r-lib/gargle/commit/c6f9894bcc157f42c4a0f17bf2cad96980134e83>.

2019-05-09 Resubmission 2, bump version to v0.1.1

  * Clean pass from auto-check service

2019-05-13 Feedback from CRAN assistant MS re: title, description, using `cat()`, examples (see email).

  * Removed "from R" from title and provided a "link to the google apis" in description via [eb3a4cd](https://github.com/r-lib/gargle/commit/eb3a4cdf87d9f64d4e0f5472fe377f97a9f75538)
  * Added examples via [a23bced](https://github.com/r-lib/gargle/commit/a23bced6e62cb947c49fad061424d50de39e3ff0). 7 of 9 must be in `\dontrun{}` because the code can't be run on CRAN due to lack of encrypted files / env vars and the inability to make HTTP calls with a tolerance for intermittent server side failure.

2019-05-13 Resubmission 3, bump version to v0.1.2

  * Clean pass from auto-check service

2019-05-16 Feedback from CRAN assistant MS requests `\donttest()` now instead of `\dontrun{}`, reiterates the `cat()` stuff, new request to "rephrase the first sentence of the description" (no further specifics).

  * Email sent to reviewer + cran-submissions + cran requesting clarification on
  several points and addressing `cat()`.
  * 2nd email sent pointing out the vignettes and articles, in case it is
  somehow not clear where the bulk of the documentation lies.
  
2019-05-18 Resubmission 4, after no luck with email. Responded to comments on 3rd submission in cran-comments.

  * Clean pass from auto-check service
  
2019-05-27 Email reply from UL. Reiterates general preference for `message()` over `cat()` but also says this is not a blocker. Reiterates purpose of `\dontrun{}` and `\donttest()` and says I can state which is appropriate for gargle's examples. Reports a problem link from a new check introduced by CRAN since I last submitted.
  
2019-05-27 Resubmission 5, bump version to v0.1.3. Replace CoC link in README.md with a full URL. Summarize UL's email in cran-comments.

  * Clean pass from auto-check service
  
2019-05-31 Check in again via email, since all "contemporaries" in the incoming queue have been processed and many newer submissions as well. UL says he's "on it".

2019-06-03 v0.1.3 is accepted!
