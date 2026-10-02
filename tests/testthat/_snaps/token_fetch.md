# Caught conditions are logged, even with curly braces

    Code
      out <- token_fetch()
    Message
      trying `token_fetch()`
      Warning caught by `token_fetch()`:
      careful {now}
    Condition
      Warning in `f()`:
      careful {now}
    Message
      Error caught by `token_fetch()`:
      no {creds} i a hint

