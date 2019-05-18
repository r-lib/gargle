This is a 4th submission of a new package. I have replied to the reviewer
and cc'd cran-submissions and cran in response to my latest round of feedback on
2019-05-18 but have not yet received further instructions. I summarize the main
points here in this resubmission, in case these explanations suffice.

-------------------------------------------------------------------------------

Comment #1 from 3rd CRAN review (2019-05-16)

> \dontrun{} is supposed to be used for examples which should not be
> called by the user. Please replace \dontrun{} with \donttest{}.

The use of \dontrun{} in gargle seems more in line with information offered by
Uwe Ligges on r-package-devel (2018-06-12):

> Sure, \dontrun{} markup is intended for cases where neither automated 
> chercks nor users can expect that the given code work out of the box 
> and, e.g., changes are needed to make it work, e.g. isertion of otehr 
> useranmes ... while \donttest{} is expected to work out of the box 
> (perhaps code that only work interactively or excluded in order to omit 
> ling running examples from the checks).

I see exclusive use of \dontrun{} in packages with similar goals (e.g. accessing
web services with authentication) such as AzureAuth and sparklyr which both had
CRAN updates this past week. It is also used extensively in httr's examples.

gargle has 70% test coverage and these tests are run via CI on multiple OSes and
versions of R after each commit.

-------------------------------------------------------------------------------

Comment #2 from 3rd CRAN review (2019-05-16)

> You still write information messages to the console that cannot be
> easily suppressed. Instead of print()/cat()/cat_line() rather use
> message()/warning() if you really have to write text to the console.
> (f.i.: token_fetch() )

No output is written to the console that "cannot be easily suppressed".

Currently gargle uses one central function for outputting information to
the user (cat_line()). This is primarily used for print methods and that
is its long term use. I also have some usage that provides more of a
"debugging mode", just in case users need more information about which
credential functions token_fetch() is actually executing. This
centralized function cat_line() is under control of a documented option,
wrapped in a documented function, and it defaults to NOT emitting any output. A
user will never see this debugging output unless they actively set an option,
presumably at my request, while we debug a problem with token acquisition. I
believe I will have a richer set of UI options in the future and, if this
debugging mode proves to be useful, I will refactor it accordingly.
 
-------------------------------------------------------------------------------
 
Comment #3 from 3rd CRAN review (2019-05-16)

> Please rephrase the first sentence of the description.

I added the URL to this sentence in response to this comment from the 2nd CRAN
review (2019-05-13).

> Please add a link to the google apis to the description field of your
> DESCRIPTION file in the form
> <http:...> or <https:...>
> with angle brackets for auto-linking and no space after 'http:' and
> 'https:'

I have now also rephrased to make it as close as possible to the first sentences
seen in paws and vaultr, other API-wrappers that had CRAN releases this week.

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
