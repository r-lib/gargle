# We insist on uniquely named credential functions

    Code
      cred_funs_add(creds_one)
    Condition
      Error in `cred_funs_check()`:
      ! Each credential function must have a unique name

---

    Code
      cred_funs_add(a = creds_one)
    Condition
      Error in `cred_funs_add()`:
      ! This name already appears in the credential function registry:
      x 'a'

---

    Code
      cred_funs_set(list(creds_one, a = function(scopes, ...) { }))
    Condition
      Error in `cred_funs_check()`:
      ! Each credential function must have a unique name

---

    Code
      cred_funs_set(list(a = creds_one, a = function(scopes, ...) { }))
    Condition
      Error in `cred_funs_check()`:
      ! Each credential function must have a unique name

# cred_funs_set() warns for use of `ls`

    Code
      out <- cred_funs_set(ls = list(a = function(scopes, ...) { }))
    Condition
      Warning:
      The `ls` argument of `cred_funs_set()` is deprecated as of gargle 1.3.0.
      i Please use the `funs` argument instead.

