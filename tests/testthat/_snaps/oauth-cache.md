# cache_load() repairs tokens stored with names != their hash

    Code
      tokens <- cache_load(cache_folder)
    Message <cliMessage>
      > Cache contains tokens with names that do not match their hash:
        'abc123_c@example.org' (name)
        6b9469630f4421cb48150bb3dfe8bdb0_a@example.org (hash)
        'def456_d@example.org' (name)
        6b9469630f4421cb48150bb3dfe8bdb0_b@example.org (hash)
        Will attempt to repair by renaming

# token_match() scolds but returns short hash match when non-interactive

    Code
      m <- token_match("abc_", one_existing)
    Message <cliMessage>
      > Using an auto-discovered, cached token
        To suppress this message, modify your code or options to clearly consent to the use of a cached token
        See gargle's "Non-interactive auth" vignette for more details:
        <https://gargle.r-lib.org/articles/non-interactive-auth.html>
      > The gargle package is using a cached token for a@example.com

---

    Code
      m <- token_match("abc_*", one_existing)
    Message <cliMessage>
      > Using an auto-discovered, cached token
        To suppress this message, modify your code or options to clearly consent to the use of a cached token
        See gargle's "Non-interactive auth" vignette for more details:
        <https://gargle.r-lib.org/articles/non-interactive-auth.html>
      > The gargle package is using a cached token for a@example.com

---

    Code
      m <- token_match("abc_", two_existing)
    Message <cliMessage>
      > Suitable tokens found in the cache, associated with these emails:
        - a@example.com
        - b@example.com
        Defaulting to the first email
      > Using an auto-discovered, cached token
        To suppress this message, modify your code or options to clearly consent to the use of a cached token
        See gargle's "Non-interactive auth" vignette for more details:
        <https://gargle.r-lib.org/articles/non-interactive-auth.html>
      > The gargle package is using a cached token for a@example.com

---

    Code
      m <- token_match("abc_*", two_existing)
    Message <cliMessage>
      > Suitable tokens found in the cache, associated with these emails:
        - a@example.com
        - b@example.com
        Defaulting to the first email
      > Using an auto-discovered, cached token
        To suppress this message, modify your code or options to clearly consent to the use of a cached token
        See gargle's "Non-interactive auth" vignette for more details:
        <https://gargle.r-lib.org/articles/non-interactive-auth.html>
      > The gargle package is using a cached token for a@example.com

# gargle_oauth_sitrep() works with a cache

    Code
      writeLines(out)
    Output
      > 2 tokens found in this gargle OAuth cache:
        {path to gargle oauth cache}
        
      email         app         scopes hash...   
      _____________ ___________ ______ __________
      a@example.org gargle-clio        {hash...}
      b@example.org gargle-clio        {hash...}

