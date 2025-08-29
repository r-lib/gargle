# gargle's new secret management functions -------------------------------------

#' Encrypt/decrypt JSON or an R object
#'
#' @description

#' These functions help to encrypt and decrypt confidential information that you
#' might need when deploying gargle-using projects or in CI/CD. They basically
#' rely on inlined copies of the [secret functions in the httr2
#' package](https://httr2.r-lib.org/reference/secrets.html). The awkwardness of
#' inlining code from httr2 can be removed if/when gargle starts to depend on
#' httr2.

#' * The `secret_encrypt_json()` + `secret_decrypt_json()` pair is unique to
#' gargle, given how frequently Google auth relies on JSON files, e.g., service
#' account tokens and OAuth clients.
#' * The `secret_write_rds()` + `secret_read_rds()` pair is just a copy of
#' functions from httr2. They are handy if you need to secure a user token.
#' * `secret_make_key()` and `secret_has_key()` are also copies of functions
#' from httr2. Use `secret_make_key` to generate a key. Use `secret_has_key()`
#' to condition on key availability in, e.g., examples, tests, or apps.
#'
#' @param path The path to write to (`secret_encrypt_json()`,
#'   `secret_write_rds()`) or to read from (`secret_decrypt_json()`,
#'   `secret_read_rds()`).
#' @param key Encryption key, as implemented by httr2's [secret
#'   functions](https://httr2.r-lib.org/reference/secrets.html). This should
#'   almost always be the name of an environment variable whose value was
#'   generated with `secret_make_key()` (which is an inlined copy of
#'   `httr2::secret_make_key()`).

#'
#' @return
#' * `secret_encrypt_json()`: The encrypted JSON string, invisibly. In typical
#' use, this function is mainly called for its side effect, which is to write an
#' encrypted file.
#' * `secret_decrypt_json()`: The decrypted JSON string, invisibly.
#' * `secret_write_rds()`: `x`, invisibly
#' * `secret_read_rds()`: the decrypted object.
#' * `secret_make_key()`: a random string to use as an encryption key.
#' * `secret_has_key()` returns `TRUE` if the key is available and `FALSE`
#'   otherwise.
#'
#' @name gargle_secret
#' @examplesIf secret_has_key("GARGLE_KEY")
#' # gargle ships with JSON for a fake service account
#' # here we put the encrypted JSON into a new file
#' tmp <- tempfile()
#' secret_encrypt_json(
#'   fs::path_package("gargle", "extdata", "fake_service_account.json"),
#'   tmp,
#'   key = "GARGLE_KEY"
#' )
#'
#' # complete the round trip by providing the decrypted JSON to a credential
#' # function
#' credentials_service_account(
#'  scopes = "https://www.googleapis.com/auth/userinfo.email",
#'  path = secret_decrypt_json(
#'    fs::path_package("gargle", "secret", "gargle-testing.json"),
#'    key = "GARGLE_KEY"
#'  )
#' )
#'
#' file.remove(tmp)
#'
#' # make an artificial Gargle2.0 token
#' fauxen <- gargle2.0_token(
#'   email = "jane@example.org",
#'   client = gargle_oauth_client(
#'     id = "CLIENT_ID", secret = "SECRET", name = "CLIENT"
#'   ),
#'   credentials = list(token = "fauxen"),
#'   cache = FALSE
#' )
#' fauxen
#'
#' # store the fake token in an encrypted file
#' tmp2 <- tempfile()
#' secret_write_rds(fauxen, path = tmp2, key = "GARGLE_KEY")
#'
#' # complete the round trip by providing the decrypted token to the "BYO token"
#' # credential function
#' rt_fauxen <- credentials_byo_oauth2(
#'   token  = secret_read_rds(tmp2, key = "GARGLE_KEY")
#' )
#' rt_fauxen
#'
#' file.remove(tmp2)
NULL

#' @param json A JSON file (or string).
#' @rdname gargle_secret
#' @export
secret_encrypt_json <- function(json, path = NULL, key) {
  if (!jsonlite::validate(json)) {
    json <- readChar(json, file.info(json)$size - 1)
  }
  enc <- secret_encrypt(json, key = key)

  if (!is.null(path)) {
    check_string(path)
    writeBin(enc, path)
  }

  invisible(enc)
}

#' @rdname gargle_secret
#' @export
secret_decrypt_json <- function(path, key) {
  raw <- readBin(path, "raw", file.size(path))
  enc <- rawToChar(raw)
  invisible(secret_decrypt(enc, key = key))
}

# httr2's secret management functions ------------------------------------------
# inlined as of:
# https://github.com/r-lib/httr2/commit/86127996b98c03f4ada8949969db83bb0c4a7921

# # Basic workflow
#
# 1.  Use `secret_make_key()` to generate a password. Make this available
#     as an env var (e.g. `{MYPACKAGE}_KEY`) by adding a line to your
#     `.Renviron`.
#
# 2.  Encrypt strings with `secret_encrypt()` and other data with
#     `secret_write_rds()`, setting `key = "{MYPACKAGE}_KEY"`.
#
# 3.  In your tests, decrypt the data with `secret_decrypt()` or
#     `secret_read_rds()` to match how you encrypt it.
#
# 4.  If you push this code to your CI server, it will already "work" because
#     all functions automatically skip tests when your `{MYPACKAGE}_KEY}`
#     env var isn't set. To make the tests actually run, you'll need to set
#     the env var using whatever tool your CI system provides for setting
#     env vars. Make sure to carefully inspect the test output to check that
#     the skips have actually gone away.
#'

#' @rdname gargle_secret
#' @export
secret_make_key <- function() {
  I(base64_url_rand(16))
}

secret_encrypt <- function(x, key) {
  check_string(x)
  key <- as_key(key)

  value <- openssl::aes_ctr_encrypt(charToRaw(x), key)
  base64_url_encode(c(attr(value, "iv"), value))
}

secret_decrypt <- function(encrypted, key) {
  check_string(encrypted, arg = "encrypted")
  key <- as_key(key)

  bytes <- base64_url_decode(encrypted)
  iv <- bytes[1:16]
  value <- bytes[-(1:16)]

  rawToChar(openssl::aes_ctr_decrypt(value, key, iv = iv))
}

#' @param x An R object.
#' @rdname gargle_secret
#' @export
secret_write_rds <- function(x, path, key) {
  writeBin(secret_serialize(x, key), path)
  invisible(x)
}

#' @rdname gargle_secret
#' @export
secret_read_rds <- function(path, key) {
  x <- readBin(path, "raw", file.size(path))
  secret_unserialize(x, key)
}

secret_serialize <- function(x, key) {
  key <- as_key(key)

  x <- serialize(x, NULL, version = 2)
  x_cmp <- memCompress(x, "bzip2")
  x_enc <- openssl::aes_ctr_encrypt(x_cmp, key)
  c(attr(x_enc, "iv"), x_enc)
}

secret_unserialize <- function(encrypted, key) {
  key <- as_key(key)

  iv <- encrypted[1:16]

  x_enc <- encrypted[-(1:16)]
  x_cmp <- openssl::aes_ctr_decrypt(x_enc, key, iv = iv)
  x <- memDecompress(x_cmp, "bzip2")
  unserialize(x)
}

#' @rdname gargle_secret
#' @export
secret_has_key <- function(key) {
  check_string(key)
  key <- Sys.getenv(key)
  !identical(key, "")
}

secret_get_key <- function(envvar, call = caller_env()) {
  key <- Sys.getenv(envvar)

  if (identical(key, "")) {
    if (is_testing()) {
      msg <- glue("Env var {envvar} not defined.")
      testthat::skip(msg)
    } else {
      msg <- gargle_map_cli(
        envvar,
        "Env var {.envvar <<x>>} not defined."
      )
      cli::cli_abort(msg, call = call)
    }
  }

  base64_url_decode(key)
}

## Helpers -----------------------------------------------------------------

as_key <- function(x) {
  if (inherits(x, "AsIs") && is_string(x)) {
    base64_url_decode(x)
  } else if (is.raw(x)) {
    x
  } else if (is_string(x)) {
    secret_get_key(x)
  } else {
    cli::cli_abort(c(
      "{.arg key} must be one of the following:",
      "*" = "a string giving the name of an env var",
      "*" = "a raw vector containing the key",
      "*" = "a string wrapped in {.fun I} that contains the base64url encoded \\
             key"
    ))
  }
}

# https://datatracker.ietf.org/doc/html/rfc7636#appendix-A
base64_url_encode <- function(x) {
  x <- openssl::base64_encode(x)
  x <- gsub("=+$", "", x)
  x <- gsub("+", "-", x, fixed = TRUE)
  x <- gsub("/", "_", x, fixed = TRUE)
  x
}

base64_url_decode <- function(x) {
  mod4 <- nchar(x) %% 4
  if (mod4 > 0) {
    x <- paste0(x, strrep("=", 4 - mod4))
  }

  x <- gsub("_", "/", x, fixed = TRUE)
  x <- gsub("-", "+", x, fixed = TRUE)
  # x <- gsub("=+$", "", x)
  openssl::base64_decode(x)
}

base64_url_rand <- function(bytes = 32) {
  base64_url_encode(openssl::rand_bytes(bytes))
}

# gargle's legacy, internal secret management functions ------------------------
warn_for_legacy_secret <- function(
  what,
  env = caller_env(),
  user_env = caller_env(2)
) {
  lifecycle::deprecate_soft(
    when = "1.5.0",
    what = what,
    details = c(
      "Use the new secret functions instead:",
      "<https://gargle.r-lib.org/articles/managing-tokens-securely.html>"
    ),
    env = env,
    user_env = user_env,
    id = "httr2_secret_mgmt"
  )
}

## Setup support for the NAME=PASSWORD envvar ----------------------------------

# secret_pw_name("gargle") --> "GARGLE_PASSWORD"
secret_pw_name <- function(package) {
  warn_for_legacy_secret("secret_pw_name()")
  paste0(toupper(gsub("[.]", "_", package)), "_PASSWORD")
}

# secret_pw_gen() --> "9AkKLa50wf1zHNCnHiQWeFLDoch9MYJHmPNnIVYZgSUt0Emwgi"
secret_pw_gen <- function() {
  warn_for_legacy_secret("secret_pw_gen()")
  x <- sample(c(letters, LETTERS, 0:9), 50, replace = TRUE)
  paste0(x, collapse = "")
}

# secret_pw_exists("gargle") --> TRUE or FALSE
secret_pw_exists <- function(package) {
  pw_name <- secret_pw_name(package)
  pw <- Sys.getenv(pw_name, "")
  !identical(pw, "")
}

# secret_pw_get("gargle") --> error or key-ified PASSWORD =
#                             hash of charToRaw(PASSWORD)
secret_pw_get <- function(package) {
  pw_name <- secret_pw_name(package)
  pw <- Sys.getenv(pw_name, "")
  if (identical(pw, "")) {
    gargle_abort_secret(
      message = "Env var {.envvar {pw_name}} is not defined.",
      package = package
    )
  }

  sodium::sha256(charToRaw(pw))
}

## Store and retrieve encrypted data -------------------------------------------

secret_can_decrypt <- function(package) {
  warn_for_legacy_secret("secret_can_decrypt()")
  requireNamespace("sodium", quietly = TRUE) && secret_pw_exists(package)
}

# input should either be a filepath or a raw vector
secret_write <- function(package, name, input) {
  warn_for_legacy_secret("secret_write()")
  if (is.character(input)) {
    input <- readBin(input, "raw", file.size(input))
  } else if (!is.raw(input)) {
    stop_input_type(input, what = c("character", "raw"))
  }

  destdir <- fs::path("inst", "secret")
  fs::dir_create(destdir)
  destpath <- fs::path(destdir, name)

  enc <- sodium::data_encrypt(
    msg = input,
    key = secret_pw_get(package),
    nonce = secret_nonce()
  )
  attr(enc, "nonce") <- NULL
  writeBin(enc, destpath)

  invisible(destpath)
}

# Generated with sodium::bin2hex(sodium::random(24)). AFAICT nonces are
# primarily used to prevent replay attacks, which shouldn't be a concern here
secret_nonce <- function() {
  sodium::hex2bin("cb36bab652dec6ae9b1827c684a7b6d21d2ea31cd9f766ac")
}

secret_path <- function(package, name) {
  fs::path_package(package, "secret", name)
}

# Returns a raw vector
secret_read <- function(package, name) {
  warn_for_legacy_secret("secret_read()")
  if (!secret_can_decrypt(package)) {
    gargle_abort_secret(
      message = "Decryption not available.",
      package = package
    )
  }

  path <- secret_path(package, name)
  raw <- readBin(path, "raw", file.size(path))

  sodium::data_decrypt(
    bin = raw,
    key = secret_pw_get(package),
    nonce = secret_nonce()
  )
}

gargle_abort_secret <- function(message, package, call = caller_env()) {
  gargle_abort(
    class = "gargle_error_secret",
    call = call,
    message = message,
    package = package
  )
}
