# Package index

## Fetching credentials

Load an existing token or obtain a new one

- [`token_fetch()`](https://gargle.r-lib.org/reference/token_fetch.md) :
  Fetch a token for the given scopes
- [`credentials_app_default()`](https://gargle.r-lib.org/reference/credentials_app_default.md)
  : Load Application Default Credentials
- [`credentials_byo_oauth2()`](https://gargle.r-lib.org/reference/credentials_byo_oauth2.md)
  : Load a user-provided token
- [`credentials_external_account()`](https://gargle.r-lib.org/reference/credentials_external_account.md)
  **\[experimental\]** : Get a token for an external account
- [`credentials_gce()`](https://gargle.r-lib.org/reference/credentials_gce.md)
  : Get a token from the Google metadata server
- [`credentials_service_account()`](https://gargle.r-lib.org/reference/credentials_service_account.md)
  : Load a service account token
- [`credentials_user_oauth2()`](https://gargle.r-lib.org/reference/credentials_user_oauth2.md)
  : Get an OAuth token for a user
- [`gargle_oauth_sitrep()`](https://gargle.r-lib.org/reference/gargle_oauth_sitrep.md)
  : OAuth token situation report
- [`cred_funs_list()`](https://gargle.r-lib.org/reference/cred_funs.md)
  [`cred_funs_add()`](https://gargle.r-lib.org/reference/cred_funs.md)
  [`cred_funs_set()`](https://gargle.r-lib.org/reference/cred_funs.md)
  [`cred_funs_clear()`](https://gargle.r-lib.org/reference/cred_funs.md)
  [`cred_funs_list_default()`](https://gargle.r-lib.org/reference/cred_funs.md)
  [`cred_funs_set_default()`](https://gargle.r-lib.org/reference/cred_funs.md)
  [`local_cred_funs()`](https://gargle.r-lib.org/reference/cred_funs.md)
  [`with_cred_funs()`](https://gargle.r-lib.org/reference/cred_funs.md)
  : Credential function registry
- [`gargle_oauth_client_from_json()`](https://gargle.r-lib.org/reference/gargle_oauth_client_from_json.md)
  [`gargle_oauth_client()`](https://gargle.r-lib.org/reference/gargle_oauth_client_from_json.md)
  : Create an OAuth client for Google
- [`gargle_oauth_email()`](https://gargle.r-lib.org/reference/gargle_options.md)
  [`gargle_oob_default()`](https://gargle.r-lib.org/reference/gargle_options.md)
  [`gargle_oauth_cache()`](https://gargle.r-lib.org/reference/gargle_options.md)
  [`gargle_oauth_client_type()`](https://gargle.r-lib.org/reference/gargle_options.md)
  [`gargle_verbosity()`](https://gargle.r-lib.org/reference/gargle_options.md)
  [`local_gargle_verbosity()`](https://gargle.r-lib.org/reference/gargle_options.md)
  [`with_gargle_verbosity()`](https://gargle.r-lib.org/reference/gargle_options.md)
  : Options consulted by gargle
- [`token_userinfo()`](https://gargle.r-lib.org/reference/token-info.md)
  [`token_email()`](https://gargle.r-lib.org/reference/token-info.md)
  [`token_tokeninfo()`](https://gargle.r-lib.org/reference/token-info.md)
  : Get info from a token
- [`gce_instance_service_accounts()`](https://gargle.r-lib.org/reference/gce_instance_service_accounts.md)
  : List all service accounts available on this GCE instance
- [`secret_encrypt_json()`](https://gargle.r-lib.org/reference/gargle_secret.md)
  [`secret_decrypt_json()`](https://gargle.r-lib.org/reference/gargle_secret.md)
  [`secret_make_key()`](https://gargle.r-lib.org/reference/gargle_secret.md)
  [`secret_write_rds()`](https://gargle.r-lib.org/reference/gargle_secret.md)
  [`secret_read_rds()`](https://gargle.r-lib.org/reference/gargle_secret.md)
  [`secret_has_key()`](https://gargle.r-lib.org/reference/gargle_secret.md)
  : Encrypt/decrypt JSON or an R object

## Requests and responses

Helpers for forming HTTP requests and processing the response

- [`request_develop()`](https://gargle.r-lib.org/reference/request_develop.md)
  [`request_build()`](https://gargle.r-lib.org/reference/request_develop.md)
  : Build a Google API request
- [`request_make()`](https://gargle.r-lib.org/reference/request_make.md)
  : Make a Google API request
- [`request_retry()`](https://gargle.r-lib.org/reference/request_retry.md)
  : Make a Google API request, repeatedly
- [`response_process()`](https://gargle.r-lib.org/reference/response_process.md)
  [`response_as_json()`](https://gargle.r-lib.org/reference/response_process.md)
  [`gargle_error_message()`](https://gargle.r-lib.org/reference/response_process.md)
  : Process a Google API response
- [`field_mask()`](https://gargle.r-lib.org/reference/field_mask.md) :
  Generate a field mask

## Classes

Classes to represent a token or auth state and their constructors

- [`Gargle-class`](https://gargle.r-lib.org/reference/Gargle-class.md)
  [`Gargle2.0`](https://gargle.r-lib.org/reference/Gargle-class.md) :
  OAuth2 token objects specific to Google APIs
- [`gargle2.0_token()`](https://gargle.r-lib.org/reference/gargle2.0_token.md)
  : Generate a gargle token
- [`AuthState-class`](https://gargle.r-lib.org/reference/AuthState-class.md)
  [`AuthState`](https://gargle.r-lib.org/reference/AuthState-class.md) :
  Authorization state
- [`init_AuthState()`](https://gargle.r-lib.org/reference/init_AuthState.md)
  : Create an AuthState

## Options

- [`gargle_oauth_email()`](https://gargle.r-lib.org/reference/gargle_options.md)
  [`gargle_oob_default()`](https://gargle.r-lib.org/reference/gargle_options.md)
  [`gargle_oauth_cache()`](https://gargle.r-lib.org/reference/gargle_options.md)
  [`gargle_oauth_client_type()`](https://gargle.r-lib.org/reference/gargle_options.md)
  [`gargle_verbosity()`](https://gargle.r-lib.org/reference/gargle_options.md)
  [`local_gargle_verbosity()`](https://gargle.r-lib.org/reference/gargle_options.md)
  [`with_gargle_verbosity()`](https://gargle.r-lib.org/reference/gargle_options.md)
  : Options consulted by gargle

## Demo assets

Assets to aid experimentation during development (not for production
use!)

- [`gargle_api_key()`](https://gargle.r-lib.org/reference/gargle_api_key.md)
  : API key for demonstration purposes
