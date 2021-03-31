# Gargle2.0 prints nicely

    Code
      print(fauxen)
    Output
      
      -- <Token (via gargle)> --------------------------------------------------------
      oauth_endpoint: google
                 app: APPNAME
               email: a@example.org
              scopes: ...userinfo.email
         credentials: a

# 'deleted_client' causes extra special feedback

    Code
      gargle_refresh_failure(err, httr::oauth_app(appname = NULL, key = "KEY",
        secret = "SECRET"))
    Warning <warning>
      Unable to refresh token, because the associated OAuth app has been deleted

---

    Code
      gargle_refresh_failure(err, httr::oauth_app(appname = "APPNAME", key = "KEY",
        secret = "SECRET"))
    Warning <warning>
      Unable to refresh token, because the associated OAuth app has been deleted
      * App name: APPNAME

---

    Code
      gargle_refresh_failure(err, httr::oauth_app(appname = "APPNAME", key = "KEY",
        secret = "SECRET"), package = "PACKAGE")
    Warning <warning>
      Unable to refresh token, because the associated OAuth app has been deleted
      * App name: APPNAME
      * If you did not configure this OAuth app, it may be built into the PACKAGE package
      * If so, consider re-installing PACKAGE to get an updated app

---

    Code
      gargle_refresh_failure(err, httr::oauth_app(appname = "fake-calliope", key = "KEY",
        secret = "SECRET"))
    Warning <warning>
      Unable to refresh token, because the associated OAuth app has been deleted
      * You appear to be relying on the default app used by the gargle package
      * Consider re-installing gargle, in case the default app has been updated

---

    Code
      gargle_refresh_failure(err, httr::oauth_app(appname = "fake-calliope", key = "KEY",
        secret = "SECRET"), package = "PACKAGE")
    Warning <warning>
      Unable to refresh token, because the associated OAuth app has been deleted
      * You appear to be relying on the default app used by the PACKAGE package
      * Consider re-installing PACKAGE and gargle, in case the default app has been updated

