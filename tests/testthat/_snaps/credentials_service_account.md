# check_is_service_account() errors for OAuth client

    Code
      PKG_auth(fs::path_package("gargle", "extdata",
        "client_secret_installed.googleusercontent.com.json"))
    Condition
      Error in `PKG_auth()`:
      ! `path` does not represent a service account.
      i If `path` is meant to be a filepath, perhaps the file does not exist?
      i Did you provide the JSON for an OAuth client instead of for a service account?
      i To configure the OAuth client, use `PKG_auth_configure()` instead.

# check_is_service_account() errors for invalid input

    Code
      PKG_auth("wut")
    Condition
      Error in `PKG_auth()`:
      ! `path` does not represent a service account.
      i If `path` is meant to be a filepath, perhaps the file does not exist?
      i Did you provide the JSON for an OAuth client instead of for a service account?
      i To configure the OAuth client, use `PKG_auth_configure()` instead.

