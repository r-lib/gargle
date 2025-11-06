# gargle: Tools for wrapping Google APIs in R

## Package Overview

**gargle** provides infrastructure for R packages that wrap Google APIs. It handles authentication, credential management, and HTTP request/response processing.

**Target Users:** R package authors wrapping Google APIs (e.g., googledrive, googlesheets4, bigrquery). May also be used directly by users making low-level API calls.

**Two Main Domains:**
1. **Authentication:** Multi-method credential fetching (OAuth2, service accounts, GCE metadata, workload identity federation, application default credentials)
2. **HTTP:** Request preparation, execution, response processing, error handling, and retry logic

**Key Dependencies:** httr (HTTP), fs (file system), rlang (tidy eval), cli (user interaction), jsonlite (JSON), openssl (crypto)

## Essential Commands

Always use `R --no-save --no-restore-data` when running R from the console.

Always run `air format .` after generating or modifying code. The binary of air is probably not on the PATH but is typically found inside the Air extension used by Positron, e.g. something like `~/.positron/extensions/posit.air-vscode-0.18.0/bundled/bin/air`

## Development Workflow

**Testing**
Place tests in `tests/testthat/test-{name}.R` alongside corresponding source files. Run tests with `devtools::test()` or `devtools::test_file("tests/testthat/test-{name}.R")`. Do NOT use `test_active_file()`. All new code requires accompanying tests.

**Documentation**
After modifying roxygen2 comments, run `devtools::document()` to regenerate documentation. Export all user-facing functions with proper roxygen2 documentation. Add new function topics to the appropriate section in `_pkgdown.yml`. Use sentence case for documentation headings.

**Code Style**
Follow tidyverse style guide conventions. Use `cli::cli_abort()` for error messages with informative formatting. Organize code with "newspaper style"—main logic first, helper functions below.

## Key Technical Details

**Core Classes**

- **`Gargle2.0`** (R6, in `R/Gargle-class.R`): OAuth2 token class extending `httr::Token2.0`. Key differences: email-based cache keys, user-level caching, per-file cache storage. Methods: `initialize()`, `hash()`, `cache()`, `load_from_cache()`, `refresh()`, `init_credentials()`.

- **`AuthState`** (R6, in `R/AuthState-class.R`): Session-scoped auth manager for client packages. Holds package name, OAuth client, API key, auth_active flag, and current credential. Methods: `set_client()`, `set_api_key()`, `set_auth_active()`, `set_cred()`, `get_cred()`, `has_cred()`.

- **`gargle_oauth_client`** (S3 list, in `R/gargle_oauth_client.R`): OAuth application representation. Fields: id, secret, redirect_uris, type ("web" or "installed"), name. Created via `gargle_oauth_client()` or `gargle_oauth_client_from_json()`.

**Credential Function Registry**

All auth flows go through `token_fetch()` which tries registered credential functions in order until one succeeds. Default order (tried first to last):
1. `credentials_byo_oauth2()` - Bring-your-own token
2. `credentials_service_account()` - Service account JSON
3. `credentials_external_account()` - Workload identity federation
4. `credentials_app_default()` - Google Application Default Credentials
5. `credentials_gce()` - GCE metadata server
6. `credentials_user_oauth2()` - Interactive OAuth browser flow

Modify registry with `cred_funs_add()`, `cred_funs_set()`, `cred_funs_set_default()`, or temporarily with `local_cred_funs()`/`with_cred_funs()`. All credential functions must have signature `function(scopes, ...)` and return `httr::Token` or `NULL`.

**Request/Response Pattern**

Standard workflow:
```r
# 1. Develop (validate params against API spec)
req <- request_develop(endpoint = ..., params = ...)

# 2. Build (substitute params, add auth)
req <- request_build(method, path, params, token = token, key = api_key)

# 3. Make HTTP call
resp <- request_make(req, encode = "json", user_agent = ...)

# 4. Process response (parse JSON or throw informative error)
result <- response_process(resp, error_message = gargle_error_message)
```

For automatic retries with exponential backoff, use `request_retry()` instead of `request_make()`. Retries on status codes: 408, 429, 500, 502, 503.

**Token Cache**

- Location: `~/.R/gargle/gargle-oauth/` (XDG-compliant via rappdirs)
- File naming: `{parent_hash}_{email}.json`
- Parent hash: hash of endpoint + client + scopes
- Email-based lookup enables multi-identity support
- Functions: `cache_establish()`, `token_into_cache()`, `token_from_cache()`

**Configuration**

Uses `getOption()` pattern with wrapper functions:
- `gargle_oauth_email()` - Target Google identity
- `gargle_oauth_cache()` - Cache location (NA = auto-detect)
- `gargle_oob_default()` - Out-of-band auth default
- `gargle_oauth_client_type()` - "web" or "installed"

**Global State**

`gargle_env` (in `R/gargle-package.R`) holds:
- `$cred_funs` - Credential function registry
- `$last_response` - Most recent API response (debugging)

**Hosted Environment Detection**

Automatically uses pseudo-OOB flow on RStudio Server, Posit Workbench/Cloud, and Google Colaboratory.

**File Organization**

Key files by domain:
- **Auth classes:** `Gargle-class.R`, `AuthState-class.R`
- **OAuth infrastructure:** `oauth-init.R`, `oauth-cache.R`, `oauth-refresh.R`
- **Credentials:** `credentials_user_oauth2.R`, `credentials_service_account.R`, `credentials_gce.R`, `credentials_external_account.R`, `credentials_app_default.R`, `credentials_byo_oauth2.R`
- **Registry:** `cred_funs.R`, `token_fetch.R`
- **HTTP:** `request_develop.R`, `request_make.R`, `request_retry.R`, `response_process.R`
- **Config:** `gargle-package.R` (defines `gargle_env` and option accessors)
- **Client management:** `gargle_oauth_client.R`
- **Utilities:** `secret.R` (encryption), `utils-ui.R` (CLI), `token-info.R`

**Client Package Pattern**

Wrapper packages typically:
1. Initialize `AuthState` in `.onLoad()` with package-specific client and API key
2. Call `token_fetch()` to get credentials
3. Use `request_build()` + `request_make()` + `response_process()` for API calls
4. Provide user-facing auth functions that wrap `token_fetch()` and update the `AuthState`

See vignettes for detailed guidance on wrapping Google APIs.
