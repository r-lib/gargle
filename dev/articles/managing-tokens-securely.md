# Managing tokens securely

It can be tricky to deal with auth in a non-interactive setting on a
remote machine. Specifically, we’re thinking about running tests on a
continuous integration (CI) service, such as GitHub Actions, or
deploying a data product, such as a Shiny app.

This article documents a token management approach for packages and apps
that use gargle, which includes packages like googledrive,
googlesheets4, bigrquery, and gmailr. We want it to be relatively easy
to have a secret, such as a service account token, that we can:

- Use locally.
- Use with CI services, such as GitHub Actions.
- Use with [R-hub](https://docs.r-hub.io).
- Use in deployed settings, such as [Posit
  Connect](https://posit.co/products/enterprise/connect/).

all while keeping the secret secure.

The approach uses symmetric encryption, where the shared key is stored
in an environment variable. Why? This works well with existing
conventions for local R usage. Most CI or hosting services offer support
for secure environment variables. And R-hub accepts environment
variables via the `env_vars` argument of
[`rhub::check()`](https://r-hub.github.io/rhub/reference/check.html).

This mostly uses functions inlined from the httr2
(<https://httr2.r-lib.org/>) package, which gargle does not (yet) depend
on.

``` r
library(gargle)
```

## Overview of the approach

1.  Generate an encryption key (basically a password) and give it a
    self-documenting name, e.g. `GARGLE_KEY`. Store as an environment
    variable.
2.  Identify a secret file of interest, such as the JSON representing a
    service account token. This is presumably stored *outside* your
    package.
3.  Use the key to apply a method for symmetric encryption to the target
    file. Store the resulting encrypted file in a designated location
    *within* your package.
4.  Store or pass the key as an environment variable everywhere you’ll
    need to decrypt the secret.
    - Check that the platform has support for keeping the key concealed.
    - Make sure you don’t do anything in your own code that would dump
      it to a log file, such as printing all environment variables.

## Annotated code-through

### Choose a name for the encryption key

Pick a name for the encryption key. I recommend that it be clearly
associated with whatever package or data product you plan to use it
with. For example, gargle’s testing credentials are encrypted with a key
named `GARGLE_KEY`.

You don’t need to store this name as a variable. We’re only doing so
because it makes this exposition easier.

``` r
key_name <- "SOMETHING_KEY"
```

### Generate the encryption key

In real life, you should keep the output of
[`secret_make_key()`](https://gargle.r-lib.org/dev/reference/gargle_secret.md)
to yourself! We reveal it here as part of the exposition.

``` r
key <- secret_make_key()
key
#> [1] "pzqcCarOzj1HtPDc636Lfw"
```

[`gargle::secret_make_key()`](https://gargle.r-lib.org/dev/reference/gargle_secret.md)
is a copy of
[`httr2::secret_make_key()`](https://httr2.r-lib.org/reference/secrets.html).

### Define environment variable in local `.Renviron`

Combine the key name and value to form a line like this in your
user-level `.Renviron` file:

    SOMETHING_KEY=pzqcCarOzj1HtPDc636Lfw

`usethis::edit_r_environ()` can help create or open this file. I
**strongly recommend** using the user-level `.Renviron`, as opposed to
project-level, because this makes it less likely you will share
sensitive information by mistake. If for some reason you choose to store
the key in a file inside a Git repo, you must make sure that file is
listed in `.gitignore`. This still would not prevent leaking your secret
if, for example, that project is in a directory that syncs to DropBox or
Google Drive (i.e. any service that has no real notion of an “ignore”
file).

Remember you’ll need to restart R (or call
`readRenviron("~/.Renviron")`) for the newly defined environment
variable to take effect.

In an interactive session, you can call
[`Sys.getenv()`](https://rdrr.io/r/base/Sys.getenv.html) to do a quick
check that the key is setup correctly locally:

``` r
Sys.getenv("SOMETHING_KEY")
#> [1] "pzqcCarOzj1HtPDc636Lfw"
```

This [`Sys.getenv()`](https://rdrr.io/r/base/Sys.getenv.html) call is
**exactly** the sort of thing you should be very careful about doing in
a deployed setting, where the result could up in a (semi-)public log
file.

### Encrypt credentials

The Google auth ecosystem involves different types of secrets, which
require slightly different handling when you’re placing an encrypted
version inside your project.

#### Encrypt a JSON file

[`secret_encrypt_json()`](https://gargle.r-lib.org/dev/reference/gargle_secret.md)
is a gargle-specific function, built on top of httr2’s secret management
machinery. This is because JSON files and strings are especially
relevant to auth in the Google ecosystem. You will be interested in
[`secret_encrypt_json()`](https://gargle.r-lib.org/dev/reference/gargle_secret.md)
if you want to encrypt a service account key (or, even, an OAuth
client).

[`secret_encrypt_json()`](https://gargle.r-lib.org/dev/reference/gargle_secret.md)
takes 3 arguments:

- `json`: probably the path to a JSON file, but a JSON string is also
  acceptable.
- `path`: The path to write the encrypted JSON to. Technically this is
  optional, but this function mostly exists to write to file.
- `key`: The name of the environment variable that holds the encryption
  key.

This example shows how googledrive’s testing credentials are placed
inside the package source. `googledrive-testing.json` is a JSON file
downloaded for a service account managed via the [Google API / Cloud
Platform console](https://console.cloud.google.com/project):

``` r
secret_encrypt_json(
  json = "~/some/place/where/I/keep/secret/stuff/googledrive-testing.json",
  path = "inst/secret/googledrive-testing.json",
  key = "GOOGLEDRIVE_KEY"
)
```

This writes an encrypted version of `googledrive-testing.json` to
`inst/secret/googledrive-testing.json` relative to the current working
directory, which is presumably the top-level directory of googledrive’s
source. This encrypted file *should* be committed and pushed.

Later we show how to use `secret_decypt_json()` to decrypt this token.

#### Encrypt an R object

[`gargle::secret_write_rds()`](https://gargle.r-lib.org/dev/reference/gargle_secret.md)
is a copy of
[`httr2::secret_write_rds()`](https://httr2.r-lib.org/reference/secrets.html),
exported by gargle for convenience. If you must encrypt an R object,
such as a `Gargle2.0` user token, this is the function you need. But
note that it should be quite rare to encrypt a user token. If at all
possible, use a service account instead.

[`secret_write_rds()`](https://gargle.r-lib.org/dev/reference/gargle_secret.md)
takes 3 arguments:

- `x`: The R object to encrypt. In the gargle context, this is usually a
  token. After a successful OAuth dance, wrapper packages often provide
  access to the token with a function like `googledrive::drive_token()`,
  `googlesheets4::gs4_token()`, `bigrquery::bq_token()`, or
  `gmailr::gm_token()`.
- `path`: The path to write the encrypted object to. Technically this is
  optional, but this function mostly exists to write to file.
- `key`: The name of the environment variable that holds the encryption
  key.

This example shows how an encrypted googlesheets4 user token could be
placed inside the `.secrets/` directory of a project, e.g. a Shiny app
intended for deployment.

``` r
library(googlesheets4)

dir.create(".secrets")

# get a token and DO NOT CACHE IT
gs4_auth("someone@example.com", cache = FALSE)

# encrypt the token and write to file
gargle::secret_write_rds(
  gs4_token(),
  ".secrets/gs4-token.rds",
  key = "SOMETHING_KEY"
)
```

This writes an encrypted version of the token to
`.secrets/gs4-token.rds`. This encrypted file *should* be committed and
pushed/deployed.

Later we show how to use
[`gargle::secret_read_rds()`](https://gargle.r-lib.org/dev/reference/gargle_secret.md)
to decrypt this token.

### Provide environment variable to other services

Here’s how you make the encryption key available when your code is
running elsewhere.

#### GitHub Actions:

Define the environment variable as an encrypted secret in your repo:

<https://docs.github.com/en/actions/security-guides/encrypted-secrets>

Use the secrets context to expose a secret as an environment variable in
your workflows. That will look like like so, in some appropriate place
in your workflow file:

    env:
      SOMETHING_KEY: ${{ secrets.SOMETHING_KEY }}

The secret, and therefore the associated environment variable, is not
available when workflows are triggered via an external pull request.

#### R-hub

Send the environment variable in your calls to
[`rhub::check()`](https://r-hub.github.io/rhub/reference/check.html) and
[friends](https://r-hub.github.io/rhub/reference/index.html#section-check-shortcuts):

    rhub::check(env_vars = Sys.getenv("SOMETHING_KEY", names = TRUE))

#### Posit Connect

Define the environment variable in the *{X} Vars* pane of the dashboard
for your content:

<https://docs.posit.co/connect/user/content-settings/#content-vars>

### Using encrypted credentials

It should come as no surprise that
[`secret_encrypt_json()`](https://gargle.r-lib.org/dev/reference/gargle_secret.md)
and
[`secret_write_rds()`](https://gargle.r-lib.org/dev/reference/gargle_secret.md)
each have a companion function for decryption:
[`secret_decrypt_json()`](https://gargle.r-lib.org/dev/reference/gargle_secret.md)
and
[`secret_read_rds()`](https://gargle.r-lib.org/dev/reference/gargle_secret.md),
respectively.

#### Decrypt a JSON file

Recall that in the example above we encrypted the JSON specifying a
service account token, for use in CI by googledrive. Here’s how you
would use
[`secret_decrypt_json()`](https://gargle.r-lib.org/dev/reference/gargle_secret.md)
to decrypt that token and direct googledrive to use it:

``` r
library(googledrive)

drive_auth(
  path = gargle::secret_decrypt_json(
    system.file("secret", "googledrive-testing.json", package = "googledrive"),
    "GOOGLEDRIVE_KEY"
  )
)
```

#### Decrypt a user token

Recall that in the example above we encrypted a googlesheets4 user
token, for use inside something like a deployed Shiny app. Here’s how
you would use
[`secret_read_rds()`](https://gargle.r-lib.org/dev/reference/gargle_secret.md)
to decrypt that token and direct googlesheets4 to use it:

``` r
library(googlesheets4)

gs4_auth(token = gargle::secret_read_rds(
  ".secrets/gs4-token.rds",
  key = "SOMETHING_KEY"
))
```

### Anticipating decryption failure

The snippets above are great when they work, i.e. when `"SOMETHING_KEY"`
is available for decryption. But what about when the key isn’t
available?

You do want to rig things for graceful, informative failure in this
case.

- If you’re using encrypted testing credentials, CRAN is not going to be
  able to decrypt them. So you want affected tests to be *skipped* in
  that case, not to error. Likewise, an external pull request won’t be
  able to use the testing credentials, so you also want test skipping
  there.
- If you’re using encrypted credentials in a Shiny app, you might want
  to make some provision for when the encryption key is unavailable. The
  person most likely to benefit from this is you, i.e. when you’re
  trying to figure out why your app isn’t working. It’s nice to have a
  clear signal that the encryption key is unavailable instead of some
  mysterious deployment failure.

#### Condition on key availability

`secret_has_key("SOMETHING_KEY")` reports whether the `"SOMETHING_KEY"`
environment variable is defined. In a deployed data product, you might
want to call
[`secret_has_key()`](https://gargle.r-lib.org/dev/reference/gargle_secret.md)
before any attempt to decrypt a secret. If the encryption key is not
available, report that finding and arrange to do something graceful
instead of erroring, especially in some cryptic, difficult-to-debug way.

#### Automatic skips

The `secret_*` functions have a built-in feature such that, if they are
called during testing, when the encryption key is unavailable, that test
is skipped. That behaviour is implemented in the internal helper
`secret_get_key()`, which looks something like this:

``` r
secret_get_key <- function(envvar) {
  key <- Sys.getenv(envvar)
  
  if (identical(key, "")) {
    if (is_testing()) {
      msg <- glue("Env var {envvar} not defined.")
      testthat::skip(msg)
    } else {
      # error
    }
  }
  # return the key
}
```

If `envvar` (presumably, `SOMETHING_KEY` or the like) is undefined,
during tests, that test is just skipped. Note that “during tests” is
defined as when `is_testing()` returns `TRUE`. The `is_testing()` helper
is defined like so:

``` r
is_testing <- function() {
  identical(Sys.getenv("TESTTHAT"), "true")
}
```

Therefore automatic skipping will happen during automated testing,
including on CRAN, and for external contributors. The automatic skips
won’t kick in when you’re just, e.g., running a single test “by hand”.
The `"TESTTHAT"` environment variable is set by functions like
`devtools::test()` or
[`testthat::test_file()`](https://testthat.r-lib.org/reference/test_file.html).

I will also point out that this is not how test skipping is achieved in
packages like googledrive, googlesheets4, bigrquery, and gmailr. Those
packages are all designed to load a token into an internal auth state,
then use that token in downstream requests. This means that individual
requests or tests won’t ever call
[`secret_decrypt_json()`](https://gargle.r-lib.org/dev/reference/gargle_secret.md)
or
[`secret_read_rds()`](https://gargle.r-lib.org/dev/reference/gargle_secret.md),
so the automatic skips aren’t relevant. These packages make different
arrangements for skipping auth-requiring tests when the testing
credentials are unavailable. The source code for those packages is the
best place to learn more. Start by consulting the package’s
`tests/testthat/helper.R` file.

#### CI configuration

I recommend that you actively check your package under the “no
decryption, no token” scenario, so that you discover problems before
CRAN or your contributors do. In fact, this should probably be the
default situation for your `R CMD check` workflow.

In auth-requiring package, we usually have two `R CMD check` workflows:

- `R-CMD-check.yaml` is the main workflow, which tests the package
  against a relatively large matrix of operating systems and R versions.
  This workflow does not have access to the encryption key.
- `with-auth.yaml` is another `R CMD check` workflow that only checks
  with the released version of R, on `ubuntu-latest`. This workflow does
  have access to the encryption key. Here’s the bit of the `.yaml` file
  where that happens:

``` yaml
      - uses: r-lib/actions/check-r-package@v2
        env:
          SOMETHING_KEY: ${{ secrets.SOMETHING_KEY }}
```

Look at the GitHub Actions workflow configurations for googledrive,
googlesheets4, bigrquery, and gmailr, to see some concrete examples.

## Resources

- The [Wrapping APIs
  vignette](https://httr2.r-lib.org/articles/wrapping-apis.html#secret-management)
  for the httr2 package, specifically the “Secret management” section.

- The [How does cryptography work?
  vignette](https://docs.ropensci.org/sodium/articles/crypto101.html#symmetric-encryption)
  for the sodium package, specifically the “Symmetric encryption”
  section.
