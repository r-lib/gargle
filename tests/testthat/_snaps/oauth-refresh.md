# 'deleted_client' causes extra special feedback

    Code
      gargle_refresh_failure(err, httr::oauth_app(appname = NULL, key = "KEY",
        secret = "SECRET"))
    Condition
      Warning:
      Unable to refresh token, because the associated OAuth client has been deleted.

---

    Code
      gargle_refresh_failure(err, httr::oauth_app(appname = "APPNAME", key = "KEY",
        secret = "SECRET"))
    Condition
      Warning:
      Unable to refresh token, because the associated OAuth client has been deleted.
      * Client name: 'APPNAME'

---

    Code
      gargle_refresh_failure(err, httr::oauth_app(appname = "APPNAME", key = "KEY",
        secret = "SECRET"), package = "PACKAGE")
    Condition
      Warning:
      Unable to refresh token, because the associated OAuth client has been deleted.
      * Client name: 'APPNAME'
      i If you did not configure this OAuth client, it may be built into the PACKAGE package.
        If so, consider re-installing PACKAGE to get an updated client.

---

    Code
      gargle_refresh_failure(err, httr::oauth_app(appname = "fake-calliope", key = "KEY",
        secret = "SECRET"))
    Condition
      Warning:
      Unable to refresh token, because the associated OAuth client has been deleted.
      i You appear to be relying on the default client used by the gargle package.
        Consider re-installing gargle, in case the default client has been updated.

---

    Code
      gargle_refresh_failure(err, httr::oauth_app(appname = "fake-calliope", key = "KEY",
        secret = "SECRET"), package = "PACKAGE")
    Condition
      Warning:
      Unable to refresh token, because the associated OAuth client has been deleted.
      i You appear to be relying on the default client used by the PACKAGE package.
        Consider re-installing PACKAGE and gargle, in case the default client has been updated.

