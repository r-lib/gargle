# Credential function registry

Functions to query or manipulate the registry of credential functions
consulted by
[`token_fetch()`](https://gargle.r-lib.org/dev/reference/token_fetch.md).

## Usage

``` r
cred_funs_list()

cred_funs_add(...)

cred_funs_set(funs, ls = deprecated())

cred_funs_clear()

cred_funs_list_default()

cred_funs_set_default()

local_cred_funs(
  funs = cred_funs_list_default(),
  action = c("replace", "modify"),
  .local_envir = caller_env()
)

with_cred_funs(
  funs = cred_funs_list_default(),
  code,
  action = c("replace", "modify")
)
```

## Arguments

- ...:

  \<[`dynamic-dots`](https://rlang.r-lib.org/reference/dyn-dots.html)\>
  One or more credential functions, in `name = value` form. Each
  credential function is subject to a superficial check that it at least
  "smells like" a credential function: its first argument must be named
  `scopes`, and its signature must include `...`. To remove a credential
  function, you can use a specification like `name = NULL`.

- funs:

  A named list of credential functions.

- ls:

  **\[deprecated\]** This argument has been renamed to `funs`.

- action:

  Whether to use `funs` to replace or modify the registry with funs:

  - `"replace"` does `cred_funs_set(funs)`

  - `"modify"` does `cred_funs_add(!!!funs)`

- .local_envir:

  The environment to use for scoping. Defaults to current execution
  environment.

- code:

  Code to run with temporary credential function registry.

## Value

A list of credential functions or `NULL`.

## Functions

- `cred_funs_list()`: Get the list of registered credential functions.

- `cred_funs_add()`: Register one or more new credential fetching
  functions. Function(s) are added to the *front* of the list. So:

  - "First registered, last tried."

  - "Last registered, first tried."

  Can also be used to *remove* a function from the registry.

- `cred_funs_set()`: Register a list of credential fetching functions.

- `cred_funs_clear()`: Clear the credential function registry.

- `cred_funs_list_default()`: Return the default list of credential
  functions.

- `cred_funs_set_default()`: Reset the registry to the gargle default.

- `local_cred_funs()`: Modify the credential function registry in the
  current scope. It is an example of the `local_*()` functions in withr.

- `with_cred_funs()`: Evaluate `code` with a temporarily modified
  credential function registry. It is an example of the `with_*()`
  functions in withr.

## See also

[`token_fetch()`](https://gargle.r-lib.org/dev/reference/token_fetch.md),
which is where the registry is actually used.

## Examples

``` r
names(cred_funs_list())
#> [1] "credentials_byo_oauth2"       "credentials_service_account" 
#> [3] "credentials_external_account" "credentials_app_default"     
#> [5] "credentials_gce"              "credentials_user_oauth2"     

creds_one <- function(scopes, ...) {}

cred_funs_add(one = creds_one)
cred_funs_add(two = creds_one, three = creds_one)
names(cred_funs_list())
#> [1] "three"                        "two"                         
#> [3] "one"                          "credentials_byo_oauth2"      
#> [5] "credentials_service_account"  "credentials_external_account"
#> [7] "credentials_app_default"      "credentials_gce"             
#> [9] "credentials_user_oauth2"     

cred_funs_add(two = NULL)
names(cred_funs_list())
#> [1] "three"                        "one"                         
#> [3] "credentials_byo_oauth2"       "credentials_service_account" 
#> [5] "credentials_external_account" "credentials_app_default"     
#> [7] "credentials_gce"              "credentials_user_oauth2"     

# restore the default list
cred_funs_set_default()

# remove one specific credential fetcher
cred_funs_add(credentials_gce = NULL)
names(cred_funs_list())
#> [1] "credentials_byo_oauth2"       "credentials_service_account" 
#> [3] "credentials_external_account" "credentials_app_default"     
#> [5] "credentials_user_oauth2"     

# force the use of one specific credential fetcher
cred_funs_set(list(credentials_user_oauth2 = credentials_user_oauth2))
names(cred_funs_list())
#> [1] "credentials_user_oauth2"

# restore the default list
cred_funs_set_default()

# run some code with a temporary change to the registry
# creds_one ONLY
with_cred_funs(
  list(one = creds_one),
  names(cred_funs_list())
)
#> [1] "one"
# add creds_one to the list
with_cred_funs(
  list(one = creds_one),
  names(cred_funs_list()),
  action = "modify"
)
#> [1] "one"                          "credentials_byo_oauth2"      
#> [3] "credentials_service_account"  "credentials_external_account"
#> [5] "credentials_app_default"      "credentials_gce"             
#> [7] "credentials_user_oauth2"     
# remove credentials_gce
with_cred_funs(
  list(credentials_gce = NULL),
  names(cred_funs_list()),
  action = "modify"
)
#> [1] "credentials_byo_oauth2"       "credentials_service_account" 
#> [3] "credentials_external_account" "credentials_app_default"     
#> [5] "credentials_user_oauth2"     
```
