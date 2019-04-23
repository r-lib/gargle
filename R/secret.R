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
#
# Links:
# https://cran.r-project.org/web/packages/sodium/vignettes/crypto101.html
# https://cran.r-project.org/web/packages/sodium/vignettes/intro.html

# Setup support for the NAME=PASSWORD envvar ----------------------------------

# secret_pw_name("gargle") --> "GARGLE_PASSWORD"
secret_pw_name <- function(package) {
  paste0(toupper(package), "_PASSWORD")
}

# secret_pw_gen() --> "9AkKLa50wf1zHNCnHiQWeFLDoch9MYJHmPNnIVYZgSUt0Emwgi"
secret_pw_gen <- function() {
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
    stop_glue("Envvar {sq(pw_name)} is not defined")
  }

  sodium::sha256(charToRaw(pw))
}

# Store and retrieve encrypted data -------------------------------------------

secret_can_decrypt <- function(package) {
  requireNamespace("sodium", quietly = TRUE) && secret_pw_exists(package)
}

# input should either be a filepath or a raw vector
secret_write <- function(package, name, input) {
  if (is.character(input)) {
    data <- readBin(input, "raw", file.size(input))
  } else if (!is.raw(input)) {
    bad_class <- glue::glue_collapse(class(input), sep = "/")
    stop_glue(
      "{bt(input)} must be a filepath or a raw vector, not {bad_class}"
    )
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
  if (!secret_can_decrypt(package)) {
    stop_glue("Decryption not available")
  }

  path <- secret_path(package, name)
  raw <- readBin(path, "raw", file.size(path))

  sodium::data_decrypt(
    bin = raw,
    key = secret_pw_get(package),
    nonce = secret_nonce()
  )
}
