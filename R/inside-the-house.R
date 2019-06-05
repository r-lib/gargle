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
      "Resource is only available inside specific tidyverse packages.",
      "Do you need to create your own OAuth app or API key?",
      sep = "\n"
    )
    abort(msg)
  }
  invisible(env)
}
