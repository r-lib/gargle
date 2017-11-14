"%||%" <- function(a, b) {
  if (length(a) > 0) a else b
}

#' @importFrom magrittr %>%
NULL

is_string <- function(x) is.character(x) && length(x) == 1
