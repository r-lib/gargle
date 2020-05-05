Notes from revdepchecks 2020-05-05 for v0.5.0

Two challenges:

  * Unfortunate things with the state of certain packages in crancache
  * Have to think carefully about whether the env vars that allow "our"
    packages (googledrive, bigrquery, googlesheets4) to decrypt their
    tokens should really be available to revdepcheck's jobs.
  * Packages that change external state -- such as creating and deleting files
    on Drive -- have special considerations around parallel checks. Consider
    the potential for crosstalk.
    
## crancache matters

At first, several packages failed (including googledrive, bigrquery, googlesheets4). Packages that I could test locally "by hand" just fine.

It's very easy to delude yourself that all is well, because here's how that looked:

```
> revdepcheck::revdep_check(num_workers = 4)
── INIT ───────────────────────────────────────────────────── Computing revdeps ──
── INSTALL ───────────────────────────────────────────────────────── 2 versions ──
Installing CRAN version of gargle
also installing the dependencies 'sys', 'askpass', 'curl', 'mime', 'openssl', 'R6', 'fs', 'glue', 'httr', 'jsonlite', 'rlang', 'withr'
Installing DEV version of gargle
Installing 12 packages: fs, glue, httr, jsonlite, rlang, withr, askpass, sys, curl, mime, openssl, R6
── CHECK ─────────────────────────────────────────────────────────── 7 packages ──
✓ gmailr 1.0.0                           ── E: 0     | W: 0     | N: 0            
✓ boxr 0.3.5                             ── E: 0     | W: 0     | N: 0            
✓ bigrquery 1.2.0                        ── E: 1     | W: 0     | N: 0            
I googleCloudStorageR 0.5.1              ── E: 1     | W: 0     | N: 0            
✓ googleAuthR 1.2.1                      ── E: 0     | W: 0     | N: 0            
✓ googledrive 1.0.0                      ── E: 1     | W: 0     | N: 0            
✓ googlesheets4 0.1.1                    ── E: 1     | W: 0     | N: 0            
OK: 7                                                                           
BROKEN: 0
Total time: 3 min
── REPORT ────────────────────────────────────────────────────────────────────────
Writing summary to 'revdep/README.md'
Writing problems to 'revdep/problems.md'
Writing failures to 'revdep/failures.md'
```

Notice the 4 instances of `E: 1` but also `OK: 7`.

This happens because the error happens with both CRAN and dev (old and new), so it looks like no change for the worse.

In `problems.md`, you might even see happy talk like:

```
Wow, no problems at all. :)
```

But you should really follow up on these. Do this to get more details dumped into `problems.md`:

```
revdepcheck::revdep_report(all = TRUE)
```

Here's an example of how these packages were failing:

```
* installing *source* package 'googleCloudStorageR' ...
** package 'googleCloudStorageR' successfully unpacked and MD5 sums checked
** using staged installation
** R
** inst
** byte-compile and prepare package for lazy loading
Error in dyn.load(file, DLLpath = DLLpath, ...) :
  unable to load shared object '/Users/jenny/rrr/gargle/revdep/library.noindex/gargle/old/openssl/libs/openssl.so':
  dlopen(/Users/jenny/rrr/gargle/revdep/library.noindex/gargle/old/openssl/libs/openssl.so, 6): Library not loaded: /usr/local/opt/openssl/lib/libssl.1.0.0.dylib
  Referenced from: /Users/jenny/rrr/gargle/revdep/library.noindex/gargle/old/openssl/libs/openssl.so
  Reason: image not found
Calls: <Anonymous> ... asNamespace -> loadNamespace -> library.dynam -> dyn.load
Execution halted
ERROR: lazy loading failed for package 'googleCloudStorageR'
* removing '/Users/jenny/rrr/gargle/revdep/checks.noindex/googleCloudStorageR/old/googleCloudStorageR.Rcheck/googleCloudStorageR'
```

This was due to a bad state of openssl w.r.t. crancache. The cached version was linked against `libssl.1.0.0.dylib`, but the current installation on my system was `libssl.1.1.dylib`.

Solve this by clearing that cache and forcing openssl to be downloaded and built from scratch.

```
crancache::crancache_clean()
```

But this created a new problem. Luckily this was recognized fairly quickly by my Slack helpers as an error associated with a recent Rcpp release (v1.0.4) which was broken on macOS. My old cache actually had a *better* version of Rcpp (in the sense of being functional on macOS)! Although a new, fixed version of Rcpp was already on CRAN (v1.0.4.6), macOS binaries weren't yet available for my R version and revdepcheck was choosing to use the broken 1.0,4 binary instead of building Rcpp from 1.0.4.6 source. There is probably a way to control this, e.g. through an env var, but no one could immediately summon that wisdom. Instead we ...

Pre-populated the cache with a good version of Rcpp:

```
crancache::install_packages("Rcpp")
```

At this point, good versions of openssl and Rcpp were in crancache and I got accurate revdep results. The problems seen were legitimate.

The second situation is also easy to miss because any affected packages won't be installed and, then, obviously won't be checked. But that's another situation where we sort of assume the fault lies with the revdep package ("we can't install it!"), but the problem was elsewhere (Rcpp) and was causing us to not get any real data.

Bottom line: Always look at those live results and do `revdepcheck::revdep_report(all = TRUE)` if you have any reason to believe the results are too good to be true.

## Passwords for decryption

googledrive, bigrquery, googlesheets4, and gargle all use a common approach for storing one or more encrypted tokens in the package itself. The key to decrypt is stored in an env var. Now, of course, CRAN won't have that key, so to best emulate what CRAN will see, we should make sure those env vars are not available during revdep checks. Accomplish that by commenting out the relevant entries in `.Renviron` (be sure to reload!).

Now, I actually care more than about getting just gargle onto CRAN. I really want gargle to work with all of those client packages in real life, for real users. So once I got all the crancache issues fixed, I ran revdep checks yet again, with all the env vars available. This was largely successful except for googledrive.

## Parallel checks

There was intermittent test failure for googledrive functions that create files, i.e. in tests with a lot of quick file creation and deletion. I hypothesized that the 2 different check runs (against CRAN gargle and dev gargle) were actually interfering with each other.

So I made sure to queue up just googledrive then rerun revdep checks **with just 1 worker**. Usually we use 4 workers. But in this case, I don't want any checks running in parallel. And this worked.

```
revdep_add(packages = "googledrive")
revdep_check(num_workers = 1)
```
