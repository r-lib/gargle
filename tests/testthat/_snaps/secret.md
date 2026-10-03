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

