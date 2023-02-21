.onLoad <- function(lib, pkg) { # nocov start
  # we need a way to tell httr that a Google Colab session is interactive
  utils::assignInNamespace("is_interactive", rlang::is_interactive, ns = "httr")

  cred_funs_set_default()
  invisible()
} # nocov end
