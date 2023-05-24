# Attempt to initiate OAuth2 flow fails if non-interactive

    Code
      gargle2.0_token(cache = FALSE)
    Condition
      Error in `self$init_credentials()`:
      ! OAuth2 flow requires an interactive session.

# `email = NA`, `email = FALSE` means we don't consult the cache

    Code
      gargle2.0_token(email = NA, cache = cache_folder)
    Condition
      Error in `self$init_credentials()`:
      ! OAuth2 flow requires an interactive session.

---

    Code
      gargle2.0_token(email = FALSE, cache = cache_folder)
    Condition
      Error in `self$init_credentials()`:
      ! OAuth2 flow requires an interactive session.

# Gargle2.0 prints nicely

    Code
      print(fauxen)
    Output
      
      -- <Token (via gargle)> --------------------------------------------------------
      oauth_endpoint: google
              client: CLIENT
               email: 'a@example.org'
              scopes: ...userinfo.email
         credentials: a

# we reject redirect URIs from conventional OOB for pseudo-OOB flow

    Code
      select_pseudo_oob_value("urn:ietf:wg:oauth:2.0:oob")
    Condition
      Error in `select_pseudo_oob_value()`:
      ! OAuth client does not have a redirect URI suitable for the pseudo-OOB flow.

# we reject local web server redirect URIs for pseudo-OOB flow

    Code
      select_pseudo_oob_value("http://localhost")
    Condition
      Error in `select_pseudo_oob_value()`:
      ! OAuth client does not have a redirect URI suitable for the pseudo-OOB flow.

# we insist on finding exactly one redirect URI for pseudo-OOB flow

    Code
      select_pseudo_oob_value(redirect_uris)
    Condition
      Error in `select_pseudo_oob_value()`:
      ! Can't determine which redirect URI to use for the pseudo-OOB flow:
      * https://example.com/google-callback/one.html
      * https://example.com/google-callback/two.html

# gargle2.0_token(app) is deprecated but still works

    Code
      t <- gargle2.0_token(email = NA, credentials = list(a = 1), app = client)
    Condition
      Warning:
      The `app` argument of `gargle2.0_token()` is deprecated as of gargle 1.5.0.
      i Please use the `client` argument instead.

