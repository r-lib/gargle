#' Generate a field mask
#'
#' Many Google API requests take a field mask, via a `fields` parameter, in the
#' URL and/or in the body. `field_mask()` generates such a field mask from an R
#' list, typically a list that is destined to be part of the body of a request
#' that writes or updates a resource. `field_mask()` is designed to help in the
#' common case where the attributes you wish to modify are exactly the ones
#' represented in the object. It is possible to use a "larger" field mask, that
#' is either less specific or that explicitly includes other attributes, in
#' which case the attributes covered by the mask but absent from the object are
#' reset to default values. This is not exactly the use case `field_mask()` is
#' designed for, but its output could still be useful as a first step in
#' constructing such a mask.
#'
#' @param x A named R list, where the requirement for names applies at all
#'   levels, i.e. recursively.
#'
#' @return A Google API field mask, as a string.
#' @export
#'
#' @seealso The documentation for the [JSON encoding of a Protocol Buffers
#'   FieldMask](https://protobuf.dev/reference/protobuf/google.protobuf/#json-encoding-of-field-masks).
#'
#' @examples
#' x <- list(sheetId = 1234, title = "my_favorite_worksheet")
#' field_mask(x)
#'
#' x <- list(
#'   userEnteredFormat = list(
#'     backgroundColor = list(
#'       red = 159 / 255, green = 183 / 255, blue = 196 / 255
#'     )
#'   )
#' )
#' field_mask(x)
#'
#' x <- list(
#'   sheetId = 1234,
#'   gridProperties = list(rowCount = 5, columnCount = 3)
#' )
#' field_mask(x)
field_mask <- function(x) {
  stopifnot(is_dictionaryish(x))
  explicit_mask <- imap(x, field_mask_impl_)
  as.character(glue_collapse(unname(unlist(explicit_mask)), ","))
}

field_mask_impl_ <- function(x, y = "") {
  if (!is_list(x)) {
    return(y)
  }
  stopifnot(is_dictionaryish(x))

  leafs <- !map_lgl(x, is_list)
  if (sum(leafs) <= 1) {
    leafs <- FALSE
  }
  names(x)[!leafs] <- glue(".{names(x)[!leafs]}")
  if (sum(leafs) > 1) {
    nm <- glue("({glue_collapse(names(x)[leafs], sep = ',')})")
    x <- list2(!!nm := NA, !!!x[!leafs])
  }
  map2(x, glue("{y}{names(x)}"), field_mask_impl_)
}
