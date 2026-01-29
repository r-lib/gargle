# Check for a service account

This pre-checks information provided to a high-level, user-facing auth
function, such as `googledrive::drive_auth()`, before passing the user's
input along to
[`token_fetch()`](https://gargle.r-lib.org/reference/token_fetch.md),
which is designed to silently swallow errors. Some users are confused
about the difference between an OAuth client and a service account and
they provide the (path to the) JSON for one, when the other is what's
actually expected.

## Usage

``` r
check_is_service_account(path, hint, call = caller_env())
```

## Arguments

- path:

  JSON identifying the service account, in one of the forms supported
  for the `txt` argument of
  [`jsonlite::fromJSON()`](https://jeroen.r-universe.dev/jsonlite/reference/fromJSON.html)
  (typically, a file path or JSON string).

- hint:

  The relevant function to call for configuring an OAuth client.

- call:

  The execution environment of a currently running function, e.g.
  `call = caller_env()`. The corresponding function call is retrieved
  and mentioned in error messages as the source of the error.

  You only need to supply `call` when throwing a condition from a helper
  function which wouldn't be relevant to mention in the message.

  Can also be `NULL` or a [defused function
  call](https://rlang.r-lib.org/reference/topic-defuse.html) to
  respectively not display any call or hard-code a code to display.

  For more information about error calls, see [Including function calls
  in error
  messages](https://rlang.r-lib.org/reference/topic-error-call.html).

## Value

Nothing. Exists purely to throw an error.
