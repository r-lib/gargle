# NA

## This package

**gargle** provides infrastructure for R packages that wrap Google APIs.
It handles authentication, credential management, and HTTP
request/response processing.

**Target Users:** R package authors wrapping Google APIs (e.g.,
googledrive, googlesheets4, bigrquery). May also be used directly by
users making low-level API calls.

**Two Main Domains:** 1. **Authentication:** Multi-method credential
fetching (OAuth2, service accounts, GCE metadata, workload identity
federation, application default credentials) 2. **HTTP:** Request
preparation, execution, response processing, error handling, and retry
logic

### Key Technical Details

**Core Classes**

- **`Gargle2.0`** (R6, in `R/Gargle-class.R`): OAuth2 token class
  extending
  [`httr::Token2.0`](https://httr.r-lib.org/reference/Token-class.html).
  Key differences: email-based cache keys, user-level caching, per-file
  cache storage. Methods: `initialize()`, `hash()`, `cache()`,
  `load_from_cache()`, `refresh()`, `init_credentials()`.

- **`AuthState`** (R6, in `R/AuthState-class.R`): Session-scoped auth
  manager for client packages. Holds package name, OAuth client, API
  key, auth_active flag, and current credential. Methods:
  `set_client()`, `set_api_key()`, `set_auth_active()`, `set_cred()`,
  `get_cred()`, `has_cred()`.

- **`gargle_oauth_client`** (S3 list, in `R/gargle_oauth_client.R`):
  OAuth application representation. Fields: id, secret, redirect_uris,
  type (“web” or “installed”), name. Created via
  [`gargle_oauth_client()`](https://gargle.r-lib.org/dev/reference/gargle_oauth_client_from_json.md)
  or
  [`gargle_oauth_client_from_json()`](https://gargle.r-lib.org/dev/reference/gargle_oauth_client_from_json.md).

**Credential Function Registry**

All auth flows go through
[`token_fetch()`](https://gargle.r-lib.org/dev/reference/token_fetch.md)
which tries registered credential functions in order until one succeeds.
Default order (tried first to last): 1.
[`credentials_byo_oauth2()`](https://gargle.r-lib.org/dev/reference/credentials_byo_oauth2.md) -
Bring-your-own token 2.
[`credentials_service_account()`](https://gargle.r-lib.org/dev/reference/credentials_service_account.md) -
Service account JSON 3.
[`credentials_external_account()`](https://gargle.r-lib.org/dev/reference/credentials_external_account.md) -
Workload identity federation 4.
[`credentials_app_default()`](https://gargle.r-lib.org/dev/reference/credentials_app_default.md) -
Google Application Default Credentials 5.
[`credentials_gce()`](https://gargle.r-lib.org/dev/reference/credentials_gce.md) -
GCE metadata server 6.
[`credentials_user_oauth2()`](https://gargle.r-lib.org/dev/reference/credentials_user_oauth2.md) -
Interactive OAuth browser flow

Modify registry with
[`cred_funs_add()`](https://gargle.r-lib.org/dev/reference/cred_funs.md),
[`cred_funs_set()`](https://gargle.r-lib.org/dev/reference/cred_funs.md),
[`cred_funs_set_default()`](https://gargle.r-lib.org/dev/reference/cred_funs.md),
or temporarily with
[`local_cred_funs()`](https://gargle.r-lib.org/dev/reference/cred_funs.md)/[`with_cred_funs()`](https://gargle.r-lib.org/dev/reference/cred_funs.md).
All credential functions must have signature `function(scopes, ...)` and
return
[`httr::Token`](https://httr.r-lib.org/reference/Token-class.html) or
`NULL`.

**Request/Response Pattern**

Standard workflow:

``` r

# 1. Develop (validate params against API spec)
req <- request_develop(endpoint = ..., params = ...)

# 2. Build (substitute params, add auth)
req <- request_build(method, path, params, token = token, key = api_key)

# 3. Make HTTP call
resp <- request_make(req, encode = "json", user_agent = ...)

# 4. Process response (parse JSON or throw informative error)
result <- response_process(resp, error_message = gargle_error_message)
```

For automatic retries with exponential backoff, use
[`request_retry()`](https://gargle.r-lib.org/dev/reference/request_retry.md)
instead of
[`request_make()`](https://gargle.r-lib.org/dev/reference/request_make.md).
Retries on status codes: 408, 429, 500, 502, 503.

**Token Cache**

- Location: `~/.R/gargle/gargle-oauth/` (XDG-compliant via rappdirs)
- File naming: `{parent_hash}_{email}.json`
- Parent hash: hash of endpoint + client + scopes
- Email-based lookup enables multi-identity support
- Functions: `cache_establish()`, `token_into_cache()`,
  `token_from_cache()`

**Configuration**

Uses [`getOption()`](https://rdrr.io/r/base/options.html) pattern with
wrapper functions: -
[`gargle_oauth_email()`](https://gargle.r-lib.org/dev/reference/gargle_options.md) -
Target Google identity -
[`gargle_oauth_cache()`](https://gargle.r-lib.org/dev/reference/gargle_options.md) -
Cache location (NA = auto-detect) -
[`gargle_oob_default()`](https://gargle.r-lib.org/dev/reference/gargle_options.md) -
Out-of-band auth default -
[`gargle_oauth_client_type()`](https://gargle.r-lib.org/dev/reference/gargle_options.md) -
“web” or “installed”

**Global State**

`gargle_env` (in `R/gargle-package.R`) holds: - `$cred_funs` -
Credential function registry - `$last_response` - Most recent API
response (debugging)

**Hosted Environment Detection**

Automatically uses pseudo-OOB flow on RStudio Server, Posit
Workbench/Cloud, and Google Colaboratory.

**File Organization**

Key files by domain: - **Auth classes:** `Gargle-class.R`,
`AuthState-class.R` - **OAuth infrastructure:** `oauth-init.R`,
`oauth-cache.R`, `oauth-refresh.R` - **Credentials:**
`credentials_user_oauth2.R`, `credentials_service_account.R`,
`credentials_gce.R`, `credentials_external_account.R`,
`credentials_app_default.R`, `credentials_byo_oauth2.R` - **Registry:**
`cred_funs.R`, `token_fetch.R` - **HTTP:** `request_develop.R`,
`request_make.R`, `request_retry.R`, `response_process.R` - **Config:**
`gargle-package.R` (defines `gargle_env` and option accessors) -
**Client management:** `gargle_oauth_client.R` - **Utilities:**
`secret.R` (encryption), `utils-ui.R` (CLI), `token-info.R`

**Client Package Pattern**

Wrapper packages typically: 1. Initialize `AuthState` in `.onLoad()`
with package-specific client and API key 2. Call
[`token_fetch()`](https://gargle.r-lib.org/dev/reference/token_fetch.md)
to get credentials 3. Use
[`request_build()`](https://gargle.r-lib.org/dev/reference/request_develop.md) +
[`request_make()`](https://gargle.r-lib.org/dev/reference/request_make.md) +
[`response_process()`](https://gargle.r-lib.org/dev/reference/response_process.md)
for API calls 4. Provide user-facing auth functions that wrap
[`token_fetch()`](https://gargle.r-lib.org/dev/reference/token_fetch.md)
and update the `AuthState`

See vignettes for detailed guidance on wrapping Google APIs.

## Package development

### Key commands

(All these functions have been optimized for agentic use, so they can be
called directly without other arguments.)

``` r

# Executing code
devtools::load_all()
code

# Tests
devtools::test() # all tests
devtools::test(filter = "^{name}") # tests for files starting with {name}
devtools::test_active_file("R/{name}.R") # tests for R/{name}.R
devtools::test_active_file("R/{name}.R", desc = 'blah') # single test with exact description "blah" (no regexp)

# Test coverage
devtools::test_coverage() # all files
devtools::test_coverage_active_file("R/{name}.R") # coverage for R/{name}.R from tests in tests/testthat/test-{name}.R

# Documentation
devtools::document() # redocument package
pkgdown::check_pkgdown() # check website

# Run complete R CMD check
devtools::check()
```

### Running R

There are three possible ways to run code, listed in rough order of
desirability:

- If you’re running inside Posit Assistant or otherwise have an
  `executeCode()` tool available, use it to run code in a session that
  the user can also interact with.

- Otherwise, if an R REPL (e.g. `mcp__r__repl` or `btw::run_r`) is
  available, use that. Note that `mcp__r__repl` uses a sandbox that
  blocks network requests and reads/writes outside of the current
  directory.

- Otherwise, use `Rscript -e "code"`. On Windows, `Rscript -e` can
  segfault on multiline or complex code; in that case, write it to a
  temporary `.R` file and run `Rscript path/to/file.R`.

### Code style

- Follow the tidyverse style guide
- Always run `air format .` after generating code. (air is bundled with
  Positron so look there if you can’t otherwise find it.)
- Use the base pipe operator (`|>`), not the magrittr pipe (`%>%`).
- Use `\() ...` for single-line anonymous functions. For all other
  cases, use `function() {...}`.

### Test style

- Tests for `R/{name}.R` go in `tests/testthat/test-{name}.R`.
- All new code should have an accompanying test.
- If there are existing tests, place new tests next to similar existing
  tests.
- Strive to keep your tests minimal with few comments.
- Never put code in a `test-{name}.R` file outside of a `test_that()`
  block. Instead, use `tests/testthat/helper.R` or
  `tests/testthat/helper-{name}.R`.
- Avoid `expect_true()` and `expect_false()` in favor of a specific
  expectation with a better failure message. A few expectations in newer
  releases that you might not know about are `expect_all_true()`,
  `expect_all_equal()`, and `expect_r6_class()`.
- When testing errors and warnings:
  - Only use `expect_error()` or `expect_warning()` if the error or
    warning has a known class.
  - Generally, prefer `expect_snapshot(error = TRUE)` for errors and
    `expect_snapshot()` for warnings because these allow the user to
    review the full text of the output.
- Avoid the `.package` argument to `local_mocked_bindings()`; this
  modifies the namespace of another package, which is not good practice.
  Instead create a mockable version of the function in the current
  package. See `?local_mocked_bindings` for more details.

### Documentation

- Every user-facing function should be exported and have roxygen2
  documentation.
- Internal functions should not have roxygen documentation.
- Wrap roxygen2 comments to 80 characters.
- Whenever you add a new (non-internal) documentation topic, also add
  the topic to `_pkgdown.yml`.
- Always re-document the package after changing a roxygen2 comment.
- Use
  [`pkgdown::check_pkgdown()`](https://pkgdown.r-lib.org/reference/check_pkgdown.html)
  to check that all topics are included in the reference index.

### `NEWS.md`

- Every user-facing change should be given a bullet in `NEWS.md`.
- Changes that shouldn’t get a bullet:
  - Small documentation changes.
  - Internal refactorings.
  - Fixes to bugs introduced in the current dev version.
- Each bullet should briefly describe the change to the end user and
  mention the related issue in parentheses.
- A bullet can consist of multiple sentences but should not contain any
  newlines (i.e. DO NOT line wrap).
- If the change is related to a function, put the name of the function
  early in the bullet.
- If the change is related to an issue, include the issue number in
  parentheses.
- Only include a GitHub username if the PR was created by someone who
  isn’t an author.
- Order bullets alphabetically by function name. Put all bullets that
  don’t mention function names at the beginning.

## Specialized skills

- Do you need to deprecate a function or argument? Read
  `usethis::learn_tidy_skill("deprecate")`.
- Are you adding input checking to an existing function or writing a new
  exported function? Read `usethis::learn_tidy_skill("arg-checking")`.
- Are you creating a new package? Read
  `usethis::learn_tidy_skill("package-setup")`.

## Git

- If the user asks you to commit, use markdown in the commit message,
  and don’t line wrap.
- If the commit fixes an issue, include `Fixes #num.` on its own line.
- Only push when the user explicitly requests it.

## Writing

- Use sentence case for headings.
- Use US English.

### Proofreading

If the user asks you to proofread a file, act as an expert proofreader
and editor with a deep understanding of clear, engaging, and
well-structured writing.

Work paragraph by paragraph, always starting by making a TODO list that
includes individual items for each top-level section.

Fix spelling, grammar, and other minor problems without asking the user.
Label any unclear, confusing, or ambiguous sentences with a FIXME
comment.

Only report what you have changed.
