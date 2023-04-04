# request_make() errors for invalid HTTP methods

    Code
      request_make(list(method = httr::GET))
    Condition
      Error in `request_make()`:
      ! `x$method` must be a single string, not a function.

---

    Code
      request_make(list(method = "PETCH"))
    Condition
      Error in `request_make()`:
      ! Not a recognized HTTP method: `PETCH`.

