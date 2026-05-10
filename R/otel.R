otel_tracer_name <- "org.r-lib.gargle"

otel_cache_tracer <- NULL
otel_local_active_span <- NULL
otel_span_add_events <- NULL

local({
  otel_is_tracing <- FALSE
  otel_tracer <- NULL

  otel_cache_tracer <<- function() {
    requireNamespace("otel", quietly = TRUE) || return()
    otel_tracer <<- otel::get_tracer(otel_tracer_name)
    otel_is_tracing <<- tracer_enabled(otel_tracer)
  }

  otel_local_active_span <<- function(
    name,
    attributes = list(),
    links = NULL,
    options = NULL,
    return_ctx = FALSE,
    scope = parent.frame()
  ) {
    otel_is_tracing || return()
    otel::start_local_active_span(
      name,
      attributes = otel::as_attributes(attributes),
      links = links,
      options = options,
      tracer = otel_tracer,
      activation_scope = scope
    )
  }

  otel_span_add_events <<- function(text) {
    otel_is_tracing || return()
    spn <- otel::get_active_span()
    lapply(cli::ansi_strip(text), spn$add_event)
  }
})

tracer_enabled <- function(tracer) {
  .subset2(tracer, "is_enabled")()
}

with_otel_record <- function(expr) {
  on.exit(otel_cache_tracer())
  otelsdk::with_otel_record({
    otel_cache_tracer()
    expr
  })
}
