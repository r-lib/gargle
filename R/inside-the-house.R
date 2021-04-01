from_permitted_package <- function(env = parent.frame()) {
  env <- topenv(env, globalenv())
  if (!isNamespace(env)) {
    return(FALSE)
  }

  nm <- getNamespaceName(env)
  gargle_debug("attempt to access internal gargle data from: {.pkg {nm}}")
  nm %in% c("gargle", "googledrive", "bigrquery", "googlesheets4", "gmailr")
}

check_permitted_package <- function(env = parent.frame()) {
  if (!from_permitted_package(env)) {
    # TODO: this could be done differently if/when this gets resolved
    # https://github.com/r-lib/rlang/issues/1130
    # https://github.com/r-lib/rlang/pull/1144
    msg <- c(
      "Attempt to directly access a credential that can only be used within \\
       tidyverse packages.
       This error may mean that you need to:",
      "Create a new project on Google Cloud Platform",
      "Enable relevant APIs for your project",
      "Create an API key and/or an OAuth client ID",
      "Configure your requests to use your API key and OAuth client ID"
    )
    gargle_abort(msg)
  }
  invisible(env)
}
