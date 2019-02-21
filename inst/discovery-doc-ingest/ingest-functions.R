library(tidyverse)

#' Get versioned IDs from API Discovery Service
#'
#' @return A character vector.
#' @keywords internal
#' @examples
#' get_discovery_ids()
#' grep("drive", get_discovery_ids(), value = TRUE)
#' grep("sheets", get_discovery_ids(), value = TRUE)
#' grep("gmail", get_discovery_ids(), value = TRUE)
#' grep("bigquery", get_discovery_ids(), value = TRUE)
get_discovery_ids <- function() {
  apis <- httr::content(
    httr::GET("https://www.googleapis.com/discovery/v1/apis")
  )
  map_chr(apis[["items"]], "id")
}

#' Download a Discovery Document
#'
#' @param id Versioned ID string for target API. Use [get_discovery_ids()] to
#'   see them all and find the one you want.
#' @param path Target filepath. Default filename is formed from the API's
#'   versioned ID and the Discovery Document's revision date. Default parent
#'   directory is the current package's `data-raw/` directory, if such exists,
#'   or current working directory, otherwise.
#'
#' @return Filepath
#' @keywords internal
#' @examples
#' download_discovery_document("drive:v3")
#' download_discovery_document("sheets:v4")
#' download_discovery_document("gmail:v1")
#' download_discovery_document("bigquery:v2")
#' download_discovery_document("docs:v1")
#' download_discovery_document("youtube:v3")
download_discovery_document <- function(id, path = NULL) {
  av <- set_names(as.list(strsplit(id, split =":")[[1]]), c("api", "version"))
  ## https://developers.google.com/discovery/v1/reference/apis/getRest
  getRest_url <-
    "https://www.googleapis.com/discovery/v1/apis/{api}/{version}/rest"
  url <- glue::glue_data(av, getRest_url)
  dd <- httr::GET(url)
  httr::stop_for_status(dd, glue::glue("find Discovery Document for ID '{id}'"))

  if (is.null(path)) {
    dd_content <- httr::content(dd)
    api_date <- dd_content[c("revision", "id")]
    api_date <- c(
      id = sub(":", "-", api_date$id),
      revision = as.character(as.Date(api_date$revision, format = "%Y%m%d"))
    )
    json_filename <- fs::path(paste(api_date, collapse = "_"), ext = "json")
    data_raw <- rprojroot::find_package_root_file("data-raw")
    path <- if (fs::dir_exists(data_raw)) {
      fs::path(data_raw, json_filename)
    } else {
      json_filename
    }
  }

  writeLines(httr::content(dd, as = "text"), path)
  path
}

#' Read a Discovery Document
#'
#' @param path Path to a JSON Discovery Document
#'
#' @return A list
#' @examples
#' drive <- "data-raw/drive-v3_2019-02-07.json"
#' dd <- read_discovery_document(drive)
read_discovery_document <- function(path) {
  jsonlite::fromJSON(path)
}

#' Get raw methods
#'
#' https://developers.google.com/discovery/v1/using#discovery-doc-methods
#'
#' @param dd List representing a Discovery Document
#'
#' @return a list with one element per method
#' @examples
#' drive <- "data-raw/drive-v3_2019-02-07.json"
#' dd <- read_discovery_document(drive)
#' e <- get_raw_methods(dd)
get_raw_methods <- function(dd) {
  dd %>%
    pluck("resources") %>%
    map("methods") %>%
    flatten() %>%
    set_names(map_chr(., "id"))
}

groom_methods <- function(methods, dd) {
  methods <- map(methods, modify_in, "path", ~ fs::path(dd$servicePath, .x))

  condense_scopes <- function(scopes) {
    scopes %>%
      str_remove("https://www.googleapis.com/auth/") %>%
      str_c(collapse = ", ")
  }
  methods <- map(methods, modify_in, "scopes", condense_scopes)

  ## I am currently ignoring the fact that `request` sometimes has both
  ## a `$ref` and a `parameterName` part in the original JSON
  elevate_ref <- function(m, .where) {
    modify_if(m, ~has_name(.x, .where), ~modify_in(.x, .where, ~.x$`$ref`))
  }
  methods <- elevate_ref(methods, "request")
  methods <- elevate_ref(methods, "response")

  # all of the properties in the RestMethod schema, in order of usefulness
  property_names <- c(
    "id", "httpMethod", "path", "parameters", "scopes", "description",
    "request", "response",
    "mediaUpload", "supportsMediaDownload", "supportsMediaUpload",
    "useMediaDownloadService",
    "etagRequired", "parameterOrder", "supportsSubscription"
  )

  reorder_properties <- function(m) {
    m[intersect(property_names, names(m))]
  }
  map(methods, reorder_properties)
}

add_schema_params <- function(method, dd) {
  req <- pluck(method, "request")
  if (is.null(req)) {
    return(method)
  }

  id <- method$id
  schema_params <- dd[[c("schemas", req, "properties")]]
  schema_params <- modify(schema_params, ~ `[[<-`(.x, "location", "body"))

  message(glue::glue("{id} gains {req} schema params\n"))
  method$parameters <- c(method$parameters, schema_params)
  method
}

add_global_params <- function(method, dd) {
  method[["parameters"]] <- c(method[["parameters"]], dd[["parameters"]])
  method
}

