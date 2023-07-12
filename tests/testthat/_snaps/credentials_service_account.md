# check_is_service_account() errors for OAuth client

    Code
      PKG_auth(fs::path_package("gargle", "extdata",
        "client_secret_installed.googleusercontent.com.json"))
    Condition
      Error in `PKG_auth()`:
      ! `path` does not represent a service account.
      Did you provide the JSON for an OAuth client instead of for a service account?
      Use `PKG_auth_configure()` to configure the OAuth client.

# check_is_service_account() errors for invalid input

    Code
      PKG_auth("wut")
    Condition
      Error in `PKG_auth()`:
      ! `path` does not represent a service account.
      Did you provide the JSON for an OAuth client instead of for a service account?
      Use `PKG_auth_configure()` to configure the OAuth client.

