# Deploy a document that uses an encrypted user token

This article works through one specific non-interactive auth scenario: a
Quarto document, deployed to [Posit
Connect](https://posit.co/products/enterprise/connect/), that uses
googlesheets4 to read a Google Sheet as a specific user.

The strategy is to obtain an OAuth user token once, interactively,
encrypt it, and store it in the project. The deployed document decrypts
the token and passes it directly to googlesheets4. This is the “Provide
an OAuth token directly” approach from
[`vignette("non-interactive-auth")`](https://gargle.r-lib.org/dev/articles/non-interactive-auth.md),
combined with the encryption helpers described in
`vignette("managing-tokens-securely")`. Although the example uses
googlesheets4, the same approach works with any package that implements
gargle auth in the standard way, such as googledrive or bigrquery.

## Prerequisite: an encryption key

You need an encryption key stored in an environment variable, both
locally and on Connect. The example uses an environment variable named
`GARGLE_DEPLOY_DEMO_KEY`, but the name is up to you, as long as you use
it consistently. You can generate a suitable key with
[`gargle::secret_make_key()`](https://gargle.r-lib.org/dev/reference/gargle_secret.md).
Locally, you might define the environment variable in your user-level
`.Renviron` file, which you can open with `usethis::edit_r_environ()`.
Restart R so the new environment variable is available.

## One-time setup

The script below, `token-setup.R`, obtains a token for the intended
user, encrypts it, and writes it to `.secrets/gs4-read-only-token.rds`.
You run it once (or occasionally, if you need to replace the token),
interactively, in the project. `token-setup.R` does not run in the
deployed setting and does not need to be deployed at all.

``` r

# This is setup that you run interactively once (or occasionally), to obtain a
# token.
# This code should not run in the deployed setting.
# This code does not need to be deployed at all.

library(googlesheets4)

# create a folder for the auth-related files
dir.create(".secrets")

# we're expecting `NULL` here, which implies googlesheets4 will fall back to
# one of the built-in tidyverse oauth clients
gs4_oauth_client()

# explicit auth with:
# * intended email (= user)
# * intended, minimal scopes
# * `cache = FALSE`: Because we will soon write the encrypted token to disk
#   ourselves (see below).
# No need to set `use_oob` or `gargle_oauth_client_type`. The deployed doc uses
# this stored token directly, so it never gets a new token or searches a cache,
# which is when those settings matter.
gs4_auth(
  "jane@example.com",
  scopes = "spreadsheets.readonly",
  cache = FALSE
)

# confirm you are logged in with the intended identity
gs4_user()

# get the token, encrypt it, and write to file
token <- gs4_token()
if (inherits(token, "request")) {
  token <- token$auth_token
}

# The env var must already exist!
# Specify the name of any env var here, but be consistent everywhere.
# Env var must exist, with same value, locally and on the server.
gargle::secret_write_rds(
  token,
  ".secrets/gs4-read-only-token.rds",
  "GARGLE_DEPLOY_DEMO_KEY"
)

# behold the encrypted token file
list.files(".secrets/")

# check that the `.rds` file can't be read by normal means
# this should be an error
readRDS(".secrets/gs4-read-only-token.rds")

# THE TOKEN SETUP IS DONE!
```

## The deployed document

Here is the complete source of the deployed document,
`read-google-sheet-byo-encrypted-user-token.qmd`. It decrypts the stored
token and provides it to `gs4_auth()` via the `token` argument. If the
decryption key isn’t available, the document still renders, but no code
is evaluated.

```` markdown
---
title: "Read a Google Sheet with googlesheets4"
output:
  html_document:
    theme:
      version: 5
resource_files:
- .secrets/gs4-read-only-token.rds
---

Scenario: BYO encrypted user token

```{r setup}
#| include: false
can_decrypt <- gargle::secret_has_key("GARGLE_DEPLOY_DEMO_KEY")

knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = can_decrypt
)
```

```{r}
#| eval: !expr '!can_decrypt'
#| echo: false
#| output: asis
cat("*Decryption key is unavailable, so no code will be evaluated.*")
```

The following chunk reads the stored token from file, using the environment variable `"GARGLE_DEPLOY_DEMO_KEY"` to decrypt it, and tells googlesheets4 to use it.

```{r}
library(googlesheets4)

try(
  gs4_auth(
    token = gargle::secret_read_rds(
      ".secrets/gs4-read-only-token.rds",
      "GARGLE_DEPLOY_DEMO_KEY"
    )
  )
)
```

We wrap that in `try()` to guard against the scenario where the token *can* be decrypted, but then it can't be refreshed.
If auth has been successful, the `gs4_user()` call below reveals details about the account associated with the cached token.
If auth has not been successful, `gs4_user()` will throw an error.
Other functions that can be helpful for confirming the validity of a re-loaded token are `gargle::token_tokeninfo()` and `gargle::token_userinfo()`.

This Quarto document reads Google Sheets on behalf of this user:

```{r}
#| error: true
(whoami <- gs4_user())
```

## Read a Sheet

```{r}
#| error: true
dat <- read_sheet(
  "https://docs.google.com/spreadsheets/d/YOUR_SPREADSHEET_ID/edit"
)
dat
```
````

## Deployment checklist

- Include the encrypted token file in the deployment. Here that’s done
  by listing `.secrets/gs4-read-only-token.rds` under `resource_files`
  in the document’s YAML header.
- Define the decryption environment variable on Connect, in the
  content’s *Vars* settings, with the same name and the same value as
  the one you used locally to encrypt the token.

## Why this approach works

Two things commonly go wrong when a deployed product relies on a token
that was cached during development, and this approach sidesteps both.

There’s no cache matching. When a token is passed via `token =`, it’s
handled by
[`credentials_byo_oauth2()`](https://gargle.r-lib.org/dev/reference/credentials_byo_oauth2.md)
and used as is. There’s no search of an OAuth cache, so nothing needs to
match with respect to email, scopes, or OAuth client, and you don’t need
to set options such as `gargle_oauth_email` or `gargle_oauth_cache` in
the deployed document.

The OAuth client type doesn’t matter. The built-in tidyverse OAuth
client is a “web” client on, e.g., Posit Workbench and an “installed”
client on, e.g., Connect, which can cause a cached token to go
undiscovered (see the section on OAuth client type in
[`vignette("non-interactive-auth")`](https://gargle.r-lib.org/dev/articles/non-interactive-auth.md)).
That distinction only affects which client is used to look up a token in
the cache or to obtain a new one. A token provided directly carries its
own OAuth client with it, and refreshing the token only involves that
client’s ID and secret, plus the refresh token. So the token can be
refreshed on Connect, regardless of where it was obtained.

## Limitations

This approach keeps working for as long as the token’s refresh token
remains valid. Google may invalidate a refresh token for various
reasons, for example, if the user revokes access, if the token goes
unused for six months, or after seven days if it was obtained with an
OAuth client whose consent screen is in testing mode. If that happens,
the deployed document can decrypt the token but can’t refresh it, which
is why the auth call is wrapped in
[`try()`](https://rdrr.io/r/base/try.html). The fix is to re-run the
one-time setup and redeploy.
