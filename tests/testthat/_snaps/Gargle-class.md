# Gargle2.0 prints nicely

    Code
      print(fauxen)
    Output
      
      -- <Token (via gargle)> --------------------------------------------------------
      oauth_endpoint: google
                 app: APPNAME
               email: 'a@example.org'
              scopes: ...userinfo.email
         credentials: a

# we reject redirect URIs from conventional OOB for pseudo-OOB flow

    Code
      select_pseudo_oob_value("urn:ietf:wg:oauth:2.0:oob")
    Condition
      Error in `select_pseudo_oob_value()`:
      ! OAuth client (a.k.a "app") does not have a redirect URI suitable for the pseudo-OOB flow.

# we reject local web server redirect URIs for pseudo-OOB flow

    Code
      select_pseudo_oob_value("http://localhost")
    Condition
      Error in `select_pseudo_oob_value()`:
      ! OAuth client (a.k.a "app") does not have a redirect URI suitable for the pseudo-OOB flow.

# we insist on finding exactly one redirect URI for pseudo-OOB flow

    Code
      select_pseudo_oob_value(redirect_uris)
    Condition
      Error in `select_pseudo_oob_value()`:
      ! Can't determine which redirect URI to use for the pseudo-OOB flow:
      * https://example.com/google-callback/one.html
      * https://example.com/google-callback/two.html

