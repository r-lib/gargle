glue_lines <- function(lines, ..., .env = parent.frame()) {
  # eliminate confusion re: `...` of glue_lines() vs. `...` of map_chr()
  g <- function(line) glue(line, ..., .envir = .env)
  map_chr(lines, g)
}

glue_data_lines <- function(.data, lines, ..., .env = parent.frame()) {
  # work around name collision of `.x` of map_chr() vs. of glue_data()
  # and confusion re: `...` of glue_data_lines() vs. `...` of map_chr()
  gd <- function(line) glue_data(.x = .data, line, ..., .envir = .env)
  map_chr(lines, gd)
}

stop_glue <- function(..., .sep = "", .envir = parent.frame(),
                      call. = FALSE, .domain = NULL) {
  stop(
    glue(..., .sep = .sep, .envir = .envir),
    call. = call., domain = .domain
  )
}

stop_glue_data <- function(..., .sep = "", .envir = parent.frame(),
                           call. = FALSE, .domain = NULL) {
  stop(
    glue_data(..., .sep = .sep, .envir = .envir),
    call. = call., domain = .domain
  )
}

stop_collapse <- function(x) stop(glue_collapse(x, sep = "\n"), call. = FALSE)

warning_glue <- function(..., .sep = "", .envir = parent.frame(),
                         call. = FALSE, .domain = NULL) {
  warning(
    glue(..., .sep = .sep, .envir = .envir),
    call. = call., domain = .domain
  )
}

warning_glue_data <- function(..., .sep = "", .envir = parent.frame(),
                              call. = FALSE, .domain = NULL) {
  warning(
    glue_data(..., .sep = .sep, .envir = .envir),
    call. = call., domain = .domain
  )
}

warning_collapse <- function(x) warning(glue_collapse(x, sep = "\n"))

message_glue <- function(..., .sep = "", .envir = parent.frame(),
                         .domain = NULL, .appendLF = TRUE) {
  message(
    glue(..., .sep = .sep, .envir = .envir),
    domain = .domain, appendLF = .appendLF
  )
}

message_glue_data <- function(..., .sep = "", .envir = parent.frame(),
                              .domain = NULL) {
  message(
    glue_data(..., .sep = .sep, .envir = .envir),
    domain = .domain
  )
}

message_collapse <- function(x) message(glue_collapse(x, sep = "\n"))
