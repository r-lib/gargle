# check_is_service_account() errors for OAuth client

    Code
      PKG_auth(test_path("fixtures", "client_secret_123.googleusercontent.com.json"))
    Condition
      Error in `PKG_auth()`:
      ! `path` does not represent a service account.
      Did you provide the JSON for an OAuth client instead of for a service account?
      Use `PKG_auth_configure()` to configure the OAuth client.

