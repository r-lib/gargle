# inputs are checked when creating AuthState

    Code
      init_AuthState(package = NULL, client = client, api_key = "API_KEY",
        auth_active = TRUE)
    Condition
      Error in `initialize()`:
      ! is_scalar_character(package) is not TRUE

---

    Code
      init_AuthState(client = "not_an_oauth_client")
    Condition
      Error in `initialize()`:
      ! is.null(client) || is.oauth_app(client) is not TRUE

---

    Code
      init_AuthState(client = client, api_key = 1234)
    Condition
      Error in `initialize()`:
      ! is.null(api_key) || is_string(api_key) is not TRUE

---

    Code
      init_AuthState(client = client, api_key = "API_KEY", auth_active = NULL)
    Condition
      Error in `initialize()`:
      ! is_bool(auth_active) is not TRUE

# AuthState prints nicely

    Code
      print(a)
    Output
      
      -- <AuthState (via gargle)> ----------------------------------------------------
          package: PKG
           client: AAA
          api_key: API_KEY
      auth_active: TRUE
      credentials: <some_sort_of_token>

# init_Authstate(app) argument is deprecated, but still works

    Code
      a <- init_AuthState(package = "PACKAGE", app = client, api_key = "API_KEY",
        auth_active = TRUE)
    Condition
      Warning:
      The `app` argument of `init_AuthState()` is deprecated as of gargle 1.5.0.
      i Please use the `client` argument instead.

# AuthState$new(app) is deprecated, but still works

    Code
      a <- AuthState$new(package = "PACKAGE", app = client, api_key = "API_KEY",
        auth_active = TRUE)
    Condition
      Warning:
      The `app` argument of `AuthState$initialize()` is deprecated as of gargle 1.5.0.
      i Please use the `client` argument instead.
      i The deprecated feature was likely used in the R6 package.
        Please report the issue at <https://github.com/r-lib/R6/issues>.

# $set_app is deprecated, but still works

    Code
      a$set_app(client2)
    Condition
      Warning:
      `AuthState$set_app()` was deprecated in gargle 1.5.0.
      i Please use `AuthState$set_client()` instead.
      i This probably needs to be addressed in the rlang package.
      i Please report the issue at <https://github.com/r-lib/rlang/issues>.

# app active field warns but returns the client

    Code
      client <- a$app
    Condition
      Warning:
      AuthState$app was deprecated in gargle 1.5.0.
      i Please use AuthState$client instead.

# app active field won't accept input

    Code
      a$app <- client
    Condition
      Error:
      ! app is read-only (and deprecated)

