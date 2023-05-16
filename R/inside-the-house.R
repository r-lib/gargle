from_permitted_package <- function(env = caller_env()) {
  env <- topenv(env, globalenv())
  if (!isNamespace(env)) {
    return(FALSE)
  }

  nm <- getNamespaceName(env)
  gargle_debug("attempt to access internal gargle data from: {.pkg {nm}}")
  nm %in% c("gargle", "googledrive", "bigrquery", "googlesheets4", "gmailr")
}

check_permitted_package <- function(env = caller_env(), call = caller_env()) {
  if (!from_permitted_package(env)) {
    msg <- c(
      "Attempt to directly access a credential that can only be used within \\
       tidyverse packages.",
      "This error may mean that you need to:",
      "*" = "Create a new project on Google Cloud Platform.",
      "*" = "Enable relevant APIs for your project.",
      "*" = "Create an API key and/or an OAuth client ID.",
      "*" = "Configure your requests to use your API key and OAuth client ID.",
      "i" = "See gargle's \"How to get your own API credentials\" vignette for more details:",
      "i" = "{.url https://gargle.r-lib.org/articles/get-api-credentials.html}"
    )
    gargle_abort(msg, call = call)
  }
  invisible(env)
}
