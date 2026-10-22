# Deploy a document that uses an encrypted user token

This is a complete example of a Quarto document, deployed to Posit
Connect, that uses googlesheets4 to read a Google Sheet as a specific
user. It applies the approach for an encrypted user token described in
[`vignette("articles/managing-tokens-securely")`](https://gargle.r-lib.org/dev/articles/managing-tokens-securely.md).

`token-setup.R` runs once, interactively, and is not deployed:

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

The deployed document lists the encrypted token in `resource_files`. The
`GARGLE_DEPLOY_DEMO_KEY` environment variable must also be defined on
Connect, with the same value as locally. Since the token is passed
directly via `token =`, there is no cache lookup and it doesn’t matter
whether the token was obtained with a “web” or “installed” OAuth client.

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
