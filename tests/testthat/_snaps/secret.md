# secret_get_key() error

    Code
      secret_get_key("HA_HA_HA_NO")
    Condition
      Error:
      ! Env var `HA_HA_HA_NO` not defined.

# as_key() error

    Code
      as_key(pi)
    Condition
      Error in `as_key()`:
      ! `key` must be one of the following:
      * a string giving the name of an env var
      * a raw vector containing the key
      * a string wrapped in `I()` that contains the base64url encoded key

# older secret functions are deprecated

    Code
      secret_pw_name("pkg")
    Condition
      Warning:
      `secret_pw_name()` was deprecated in gargle 1.5.0.
      i Use the new secret functions instead:
      i <https://gargle.r-lib.org/articles/managing-tokens-securely.html>
    Output
      [1] "PKG_PASSWORD"

---

    Code
      absorb_it <- secret_pw_gen()
    Condition
      Warning:
      `secret_pw_gen()` was deprecated in gargle 1.5.0.
      i Use the new secret functions instead:
      i <https://gargle.r-lib.org/articles/managing-tokens-securely.html>

---

    Code
      secret_pw_exists("fakePKG")
    Condition
      Warning:
      `secret_pw_name()` was deprecated in gargle 1.5.0.
      i Use the new secret functions instead:
      i <https://gargle.r-lib.org/articles/managing-tokens-securely.html>
    Output
      [1] TRUE

---

    Code
      absorb_it <- secret_pw_get("fakePKG")
    Condition
      Warning:
      `secret_pw_name()` was deprecated in gargle 1.5.0.
      i Use the new secret functions instead:
      i <https://gargle.r-lib.org/articles/managing-tokens-securely.html>

---

    Code
      secret_can_decrypt("fakePKG")
    Condition
      Warning:
      `secret_can_decrypt()` was deprecated in gargle 1.5.0.
      i Use the new secret functions instead:
      i <https://gargle.r-lib.org/articles/managing-tokens-securely.html>
      Warning:
      `secret_pw_name()` was deprecated in gargle 1.5.0.
      i Use the new secret functions instead:
      i <https://gargle.r-lib.org/articles/managing-tokens-securely.html>
    Output
      [1] TRUE

