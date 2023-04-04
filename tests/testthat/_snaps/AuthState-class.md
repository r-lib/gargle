# inputs are checked when creating AuthState

    Code
      init_AuthState(package = NULL, app = app, api_key = "API_KEY", auth_active = TRUE)
    Condition
      Error in `initialize()`:
      ! is_scalar_character(package) is not TRUE

---

    Code
      init_AuthState(app = "not_an_oauth_app")
    Condition
      Error in `initialize()`:
      ! is.null(app) || is.oauth_app(app) is not TRUE

---

    Code
      init_AuthState(app = app, api_key = 1234)
    Condition
      Error in `initialize()`:
      ! is.null(api_key) || is_string(api_key) is not TRUE

---

    Code
      init_AuthState(app = app, api_key = "API_KEY", auth_active = NULL)
    Condition
      Error in `initialize()`:
      ! is_bool(auth_active) is not TRUE

# AuthState prints nicely

    Code
      print(a)
    Output
      
      -- <AuthState (via gargle)> ----------------------------------------------------
          package: PKG
              app: APPNAME
          api_key: API_KEY
      auth_active: TRUE
      credentials: <some_sort_of_token>

