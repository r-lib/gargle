# token_match() scolds but returns short hash match when non-interactive

    Code
      m <- token_match("abc_", one_existing)
    Message <message>
      Using an auto-discovered, cached token.
      To suppress this message, modify your code or options to clearly consent to the use of a cached token.
      See gargle's "Non-interactive auth" vignette for more details:
      https://gargle.r-lib.org/articles/non-interactive-auth.html
      The gargle package is using a cached token for a@example.com.

---

    Code
      m <- token_match("abc_*", one_existing)
    Message <message>
      Using an auto-discovered, cached token.
      To suppress this message, modify your code or options to clearly consent to the use of a cached token.
      See gargle's "Non-interactive auth" vignette for more details:
      https://gargle.r-lib.org/articles/non-interactive-auth.html
      The gargle package is using a cached token for a@example.com.

---

    Code
      m <- token_match("abc_", two_existing)
    Message <message>
      Suitable tokens found in the cache, associated with these emails:
        * a@example.com
        * b@example.com
      The first will be used.
      Using an auto-discovered, cached token.
      To suppress this message, modify your code or options to clearly consent to the use of a cached token.
      See gargle's "Non-interactive auth" vignette for more details:
      https://gargle.r-lib.org/articles/non-interactive-auth.html
      The gargle package is using a cached token for a@example.com.

---

    Code
      m <- token_match("abc_*", two_existing)
    Message <message>
      Suitable tokens found in the cache, associated with these emails:
        * a@example.com
        * b@example.com
      The first will be used.
      Using an auto-discovered, cached token.
      To suppress this message, modify your code or options to clearly consent to the use of a cached token.
      See gargle's "Non-interactive auth" vignette for more details:
      https://gargle.r-lib.org/articles/non-interactive-auth.html
      The gargle package is using a cached token for a@example.com.

# gargle_oauth_sitrep() works

    Code
      writeLines(out)
    Output
      gargle OAuth cache path:
      {path to gargle oauth cache}
      
      2 tokens found
      
      email         app         scopes hash...   
      _____________ ___________ ______ __________
      a@example.org gargle-clio        1286a24...
      b@example.org gargle-clio        1286a24...

