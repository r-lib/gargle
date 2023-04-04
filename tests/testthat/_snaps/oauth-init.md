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

