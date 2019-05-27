This is a 5th submission of a new package. I have replied to the reviewer
and cc'd cran-submissions and cran in response to my 4th round of feedback on
2019-05-18 and received answers from Uwe Ligges today 2019-05-27. I summarize
this last bit of conversation here.

-------------------------------------------------------------------------------

cat() vs. message()

>  If you really want to stay with cat() rather then the uniformly 
better message() ...  I can live with it.

Yes, I'd like to stay with cat_line() (which is controlled by an option) for now and I understand the sub-optimality. I believe I will have richer options for
both debugging statements and styled UI statements in the future and the package will take advantage of that in a future release.

-------------------------------------------------------------------------------

\dontrun{} vs \donttest{}

> So please simply tell us if we were wrong and \dontrun{} is really needed.

Yes I believe \dontrun{} is more appropriate than \donttest{} for gargle as this
code requires access to secret token files and/or requires the user to authenticate with Google (in the browser, i.e. it's not obvious from the R
code). This is also typical of what I see in comparable packages/functions that provide OAuth functionality.

-------------------------------------------------------------------------------

> Finally, while your submission was pending, we introduced a new check 
> and found:
>
> Found the following (possibly) invalid file URI:
>   URI: .github/CODE_OF_CONDUCT.md
>      From: README.md

This file *does* exist at that location in the package source on GitHub.
This is how GitHub encourages developers to locate and link this file.
However the entire .github/ directory needs to be Rbuildignored, hence it's not present in the source you receive.

I have replaced this internal link with a full URL to the file on gargle's
website.

-------------------------------------------------------------------------------

## Test environments

* local OS X install, R 3.5.3
* local Windows 10, R 3.6.0
* ubuntu 14.04 (on travis-ci), R devel through 3.2
* win-builder (devel and release)
* Windows Server 2012 R2 x64 (on appveyor), R 3.6.0 Patched

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new submission.
