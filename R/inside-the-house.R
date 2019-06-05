from_permitted_package <- function(env = parent.frame()) {
  env <- topenv(env, globalenv())
  if (!isNamespace(env)) {
    return(FALSE)
  }

  nm <- getNamespaceName(env)
  cat_line("attempt from: ", nm)
  nm %in% c("gargle", "googledrive", "googlesheets4", "gmailr", "bigrquery")
}
