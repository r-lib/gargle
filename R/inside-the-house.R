from_permitted_package <- function(env = parent.frame()) {
  env <- topenv(env, globalenv())
  if (!isNamespace(env)) {
    return(FALSE)
  }

  nm <- getNamespaceName(env)
  cat_line("attempt from: ", nm)
  nm %in% c("gargle", "googledrive", "googlesheets4", "gmailr", "bigrquery")
}

check_permitted_package <- function(env = parent.frame()) {
  if (!from_permitted_package(env)) {
    msg <- paste(
      "Attempt to use a resource that is restricted to specific tidyverse packages.",
      "This error may mean that you need to:",
      "  * Create a new project on Google Cloud Platform",
      "  * Enable relevant APIs for your project",
      "  * Create an API key and/or an OAuth client ID",
      "  * Configure your requests to use your API key and OAuth client ID",
      sep = "\n"
    )
    abort(msg)
  }
  invisible(env)
}
