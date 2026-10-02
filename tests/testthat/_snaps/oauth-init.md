# use_oob must be TRUE or FALSE

    Code
      check_oob("a")
    Condition
      Error in `check_oob()`:
      ! `use_oob` must be `TRUE` or `FALSE`, not the string "a".

---

    Code
      check_oob(c(FALSE, FALSE))
    Condition
      Error in `check_oob()`:
      ! `use_oob` must be `TRUE` or `FALSE`, not a logical vector.

# OOB requires an interactive session

    Code
      check_oob(TRUE)
    Condition
      Error in `check_oob()`:
      ! Out-of-band auth only works in an interactive session.

# makes no sense to pass oob_value if not OOB

    Code
      check_oob(FALSE, "custom_value")
    Condition
      Error in `check_oob()`:
      ! The `oob_value` argument can only be used when `use_oob = TRUE`.

# oob_value has to be a string

    Code
      check_oob(TRUE, c("a", "b"))
    Condition
      Error in `check_oob()`:
      ! Out-of-band auth only works in an interactive session.

# check_oauth_redirect() requires matching state, checked first

    Code
      check_oauth_redirect(list(code = "abc", state = "nope"), "xyz")
    Condition
      Error:
      ! OAuth `state` did not match.
      i The authorization response may not be from the request that gargle initiated. Please try again.

---

    Code
      check_oauth_redirect(list(code = "abc"), "xyz")
    Condition
      Error:
      ! OAuth `state` did not match.
      i The authorization response may not be from the request that gargle initiated. Please try again.

---

    Code
      check_oauth_redirect(list(error = "access_denied", state = "nope"), "xyz")
    Condition
      Error:
      ! OAuth `state` did not match.
      i The authorization response may not be from the request that gargle initiated. Please try again.

# check_oauth_redirect() reports an error or missing code

    Code
      check_oauth_redirect(list(error = "access_denied", state = "xyz"), "xyz")
    Condition
      Error:
      ! OAuth authorization failed: "access_denied".

---

    Code
      check_oauth_redirect(list(state = "xyz"), "xyz")
    Condition
      Error:
      ! OAuth authorization response did not include an authorization code.

# loopback flow checks the redirect

    Code
      oauth_authorize("https://example.org", state = "nope")
    Condition
      Error in `oauth_authorize()`:
      ! OAuth `state` did not match.
      i The authorization response may not be from the request that gargle initiated. Please try again.

