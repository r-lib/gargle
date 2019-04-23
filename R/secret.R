# Originally from r-dbi/bigrquery/secret.R
#
# Motivation:
# Make it as easy as possible to have a secret (service account token, in our
# case) that can be accessed locally, on travis, and on r-hub, but not anywhere
# else.
#
# Approach:
#
# * Use secret_pw_gen() to generate a random PASSWORD.
# * Use secret_pw_name() to generate its NAME. Typically based on package name.
# * Define envvar with name NAME and value PASSWORD.
#   - Locally, could use usethis::edit_r_environ() to get .Renviron open to add
#     this line:
#     NAME=PASSWORD
#     Collaborators need to share this info via an appropriate private channel.
#     Don't forget to restart R!
#   - On Travis-CI, define this env var via browser UI:
#     https://docs.travis-ci.com/user/environment-variables/#defining-variables-in-repository-settings
#   - On r-hub, send this env var in your calls:
#     rhub::check(env_vars = Sys.getenv(secret_pw_name("gargle"), names = TRUE))
# * Use this PASSWORD and symmetric encryption to encrypt sensitive files stored
#   in the repo.
#   - secret_write() helps you store an encrypted file below `inst/secret` in
#     the source of 'package':
#     secret_write(
#       package = "gargle",
#       name = "gargle-testing.json",
#       data = "~/.R/gargle/gargle-testing.json"
#     )
#   - We anticipate doing this with the JSON files that hold service account
#     tokens.
# * Rig tests (or examples or whatever) to fail gracefully if decryption is not
#   going to succeed, i.e. if the PASSWORD is not found or the Suggested sodium
#   package is not installed.
#   - Here's an example from bigrquery/tests/testthat/setup-auth.R
#     if (secret_can_decrypt("bigrquery")) {
#       json <- secret_read("bigrquery", "service-token.json")
#       bq_auth(path = rawToChar(json))
#     }
#   - Then this skipper is defined and used:
#     skip_if_no_auth <- function() {
#       testthat::skip_if_not(has_access_cred(), "Authentication not available")
#     }
#   - Here's an example with gargle alone:
#     token <- credentials_service_account(
#       scopes = "https://www.googleapis.com/auth/userinfo.email",
#       path = rawToChar(secret_read("gargle", "gargle-testing.json"))
#     )
#     get_userinfo(token)

# Setup support for the NAME=PASSWORD envvar ----------------------------------

## secret_pw_name("gargle") --> "GARGLE_PASSWORD"
secret_pw_name <- function(package) {
  paste0(toupper(package), "_PASSWORD")
}

secret_pw_gen <- function() {
  x <- sample(c(letters, LETTERS, 0:9), 50, replace = TRUE)
  paste0(x, collapse = "")
}

secret_pw_try <- function(package) {
  envvar <- secret_pw_name(package)
  Sys.getenv(envvar, "")
}

secret_pw_exists <- function(package) {
  !identical(secret_pw_try(package), "")
}

secret_pw_get <- function(package) {
  env <- secret_pw_name(package)
  pass <- Sys.getenv(env, "")
  if (identical(pass, "")) {
    stop_glue("Envvar {sq(env)} not defined")
  }

  sodium::sha256(charToRaw(pass))
}

# Store and retrieve encrypted data -------------------------------------------

secret_can_decrypt <- function(package) {
  requireNamespace("sodium", quietly = TRUE) && secret_pw_exists(package)
}

secret_write <- function(package, name, data) {
  #if (inherits(data, "connection")) {
    data <- readBin(data, "raw", file.size(data))
  #} else if (is.character(data)) {
  #  data <- charToRaw(data)
  #}

  secret <- fs::path("inst", "secret")
  if (!fs::dir_exists(secret)) {
    fs::dir_create(secret)
  }
  dst <- fs::path(secret, name)

  enc <- sodium::data_encrypt(
    data,
    key = secret_pw_get(package),
    nonce = secret_nonce()
  )
  attr(enc, "nonce") <- NULL
  writeBin(enc, dst)

  invisible(dst)
}

# Generated with sodium::bin2hex(sodium::random(24)). AFAICT nonces are
# primarily used to prevent replay attacks, which shouldn't be a concern here
secret_nonce <- function() {
  sodium::hex2bin("cb36bab652dec6ae9b1827c684a7b6d21d2ea31cd9f766ac")
}

secret_path <- function(package, name) {
  stopifnot(is_string(name))
  fs::path_package(package, "secret", name)
}

# Returns a raw vector
secret_read <- function(package, name) {
  if (!secret_can_decrypt(package)) {
    stop_glue("Decryption not available")
  }

  path <- secret_path(package, name)
  raw <- readBin(path, "raw", file.size(path))

  sodium::data_decrypt(raw, key = secret_pw_get(package), nonce = secret_nonce())
}
