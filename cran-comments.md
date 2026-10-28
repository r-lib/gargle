## revdepcheck results

We checked 18 reverse dependencies, comparing R CMD check results across CRAN and dev versions of this package.

 * We saw 3 new problems
 * We failed to check 0 packages

Issues with CRAN packages are summarised below.

All of these are expected.

### New problems
(This reports the first line of each new failure)

* googledrive
  checking tests ... ERROR
  I maintain this package and the new gargle causes some test failure, but no
  failure for users.
  I will submit a new version as soon as gargle is on CRAN.

* googlesheets4
  checking tests ... ERROR
  I maintain this package and the new gargle causes some test failure, but no
  failure for users.
  I will submit a new version as soon as gargle is on CRAN.

* trackdown
  checking tests ... ERROR
  This package is using unexported, legacy functions from gargle that were
  marked as deprecated in June 2023. I opened an issue about their upcoming
  removal several weeks ago: <https://github.com/ClaudioZandonella/trackdown/issues/75>.
