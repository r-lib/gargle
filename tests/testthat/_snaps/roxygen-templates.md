# PREFIX_auth_description()

    Code
      writeLines(PREFIX_auth_description())
    Output
      @description
      Authorize PACKAGE to view and manage YOUR STUFF. This function is a
      wrapper around [gargle::token_fetch()].
      
      By default, you are directed to a web browser, asked to sign in to your
      Google account, and to grant PACKAGE permission to operate on your
      behalf with A GOOGLE PRODUCT. By default, with your permission, these user
      credentials are cached in a folder below your home directory, from where
      they can be automatically refreshed, as necessary. Storage at the user
      level means the same token can be used across multiple projects and
      tokens are less likely to be synced to the cloud by accident.

# PREFIX_auth_details()

    Code
      writeLines(PREFIX_auth_details())
    Output
      @details
      Most users, most of the time, do not need to call `PREFIX_auth()`
      explicitly -- it is triggered by the first action that requires
      authorization. Even when called, the default arguments often suffice.
      
      However, when necessary, `PREFIX_auth()` allows the user to explicitly:
        * Declare which Google identity to use, via an `email` specification.
        * Use a service account token or workload identity federation via
          `path`.
        * Bring your own `token`.
        * Customize `scopes`.
        * Use a non-default `cache` folder or turn caching off.
        * Explicitly request out-of-bound auth via `use_oob`.
      
      If you are interacting with R within a browser (applies to RStudio
      Server, Posit Workbench, Posit Cloud, and Google Colaboratory), you need
      oob auth or the pseudo-oob variant. If this does not happen
      automatically, you can request it explicitly with `use_oob = TRUE` or,
      more persistently, by setting an option via
      `options(gargle_oob_default = TRUE)`.
      
      The choice between conventional oob or pseudo-oob auth is determined
      by the type of OAuth client. If the client is of the "installed" type,
      `use_oob = TRUE` results in conventional oob auth. If the client is of
      the "web" type, `use_oob = TRUE` results in pseudo-oob auth. Packages
      that provide a built-in OAuth client can usually detect which type of
      client to use. But if you need to set this explicitly, use the
      `"gargle_oauth_client_type"` option:
      ```r
      options(gargle_oauth_client_type = "web")       # pseudo-oob
      # or, alternatively
      options(gargle_oauth_client_type = "installed") # conventional oob
      ```
      
      For details on the many ways to find a token, see
      [gargle::token_fetch()]. For deeper control over auth, use
      [PREFIX_auth_configure()] to bring your own OAuth client or API key.
      Read more about gargle options, see [gargle::gargle_options].

# PREFIX_auth_params()

    Code
      writeLines(PREFIX_auth_params())
    Output
      @inheritParams gargle::credentials_service_account
      @inheritParams gargle::credentials_external_account
      @inheritParams gargle::credentials_app_default
      @inheritParams gargle::credentials_gce
      @inheritParams gargle::credentials_byo_oauth2
      @inheritParams gargle::credentials_user_oauth2
      @inheritParams gargle::gargle2.0_token

# PREFIX_deauth_description_with_api_key()

    Code
      writeLines(PREFIX_deauth_description_with_api_key())
    Output
      @description
      Put PACKAGE into a de-authorized state. Instead of sending a token,
      PACKAGE will send an API key. This can be used to access public
      resources for which no Google sign-in is required. This is handy for using
      PACKAGE in a non-interactive setting to make requests that do not
      require a token. It will prevent the attempt to obtain a token
      interactively in the browser. The user can configure their own API key
      via [PREFIX_auth_configure()] and retrieve that key via
      [PREFIX_api_key()].
      In the absence of a user-configured key, a built-in default key is used.

# PREFIX_deauth_description_no_api_key()

    Code
      writeLines(PREFIX_deauth_description_no_api_key())
    Output
      @description
      Clears any currently stored token. The next time PACKAGE needs a token,
      the token acquisition process starts over, with a fresh call to
      [PREFIX_auth()] and, therefore, internally, a call to
      [gargle::token_fetch()]. Unlike some other packages that use gargle,
      PACKAGE is not usable in a de-authorized state. Therefore, calling
      `PREFIX_deauth()` only clears the token, i.e. it does NOT imply that
      subsequent requests are made with an API key in lieu of a token.

# PREFIX_token_description()

    Code
      writeLines(PREFIX_token_description())
    Output
      @description
      For internal use or for those programming around the GOOGLE API.
      Returns a token pre-processed with [httr::config()]. Most users
      do not need to handle tokens "by hand" or, even if they need some
      control, [PREFIX_auth()] is what they need. If there is no current
      token, [PREFIX_auth()] is called to either load from cache or
      initiate OAuth2.0 flow.
      If auth has been deactivated via [PREFIX_deauth()], `PREFIX_token()`
      returns `NULL`.

# PREFIX_token_return()

    Code
      writeLines(PREFIX_token_return())
    Output
      @return A `request` object (an S3 class provided by [httr][httr::httr]).

# PREFIX_has_token_description()

    Code
      writeLines(PREFIX_has_token_description())
    Output
      @description
      Reports whether PACKAGE has stored a token, ready for use in downstream
      requests.

# PREFIX_has_token_return()

    Code
      writeLines(PREFIX_has_token_return())
    Output
      @return Logical.

# PREFIX_auth_configure_description()

    Code
      writeLines(PREFIX_auth_configure_description())
    Output
      @description
      These functions give more control over and visibility into the auth
      configuration than [PREFIX_auth()] does. `PREFIX_auth_configure()`
      lets the user specify their own:
        * OAuth client, which is used when obtaining a user token.
        * API key. If PACKAGE is de-authorized via [PREFIX_deauth()], all
          requests are sent with an API key in lieu of a token.
      
      See the `vignette("get-api-credentials", package = "gargle")`
      for more.
      If the user does not configure these settings, internal defaults
      are used.
      
      `PREFIX_oauth_client()` and `PREFIX_api_key()` retrieve the
      currently configured OAuth client and API key, respectively.

# PREFIX_auth_configure_params()

    Code
      writeLines(PREFIX_auth_configure_params())
    Output
      @param client A Google OAuth client, presumably constructed via
      [gargle::gargle_oauth_client_from_json()]. Note, however, that it is
      preferred to specify the client with JSON, using the `path` argument.
      @inheritParams gargle::gargle_oauth_client_from_json
      @param api_key API key.
      @param app `r lifecycle::badge('deprecated')` Replaced by the `client`
      argument.

# PREFIX_auth_configure_return()

    Code
      writeLines(PREFIX_auth_configure_return())
    Output
      @return
        * `PREFIX_auth_configure()`: An object of R6 class
          [gargle::AuthState], invisibly.
        * `PREFIX_oauth_client()`: the current user-configured OAuth client.
        * `PREFIX_api_key()`: the current user-configured API key.

# PREFIX_user_description()

    Code
      writeLines(PREFIX_user_description())
    Output
      @description
      Reveals the email address of the user associated with the current token.
      If no token has been loaded yet, this function does not initiate auth.

# PREFIX_user_seealso()

    Code
      writeLines(PREFIX_user_seealso())
    Output
      @seealso [gargle::token_userinfo()], [gargle::token_email()],
      [gargle::token_tokeninfo()]

# PREFIX_user_return()

    Code
      writeLines(PREFIX_user_return())
    Output
      @return An email address or, if no token has been loaded, `NULL`.

