#' API key for tidyverse packages
#'
#' Returns an API key for use in tidyverse packages, e.g., googledrive,
#' googlesheets, bigrquery. Please don't use this API key in non-tidyverse
#' projects. For a default API key to use while getting to know gargle and
#' instructions on how to get your own key, see [gargle_api_key()].
#'
#' @return A Google API key
#' @keywords internal
#' @export
#' @examples
#' tidyverse_api_key()
tidyverse_api_key <- function() {
  paste0(
    "AIzaSyCJ-",
    # jqLHc77cw
    "oYJlNhbPDJ",
    # T3b9oAuU6
    "ySWsbR_B7Q",
    # 4x0HCJJZa
    "qzNz5EthTg"
  )
}
