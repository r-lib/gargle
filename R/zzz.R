.onLoad <- function(lib, pkg) {
  cred_funs_set_default()
  debugme::debugme()

  backports::import(pkg, c("dir.exists", "file.size", "startsWith", "endsWith"))

  invisible()
}
