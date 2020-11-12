## Functions that modify the gargle environment for Shiny purposes

install_shiny_authstate_interceptor <- function(shiny, onStop) {
  push_authstate_interceptor(
    auth_active_func = function(value, fallback) {
      if (missing(value)) {
        !is.null(shiny_token())
      } else {
        fallback(value)
      }
    },
    cred_func = function(value, fallback) {
      if (missing(value)) {
        shiny_token()
      } else {
        fallback(value)
      }
    }
  )

  shiny::onStop(function() {
    pop_authstate_interceptor()
  }, session = NULL)
}

suppress_token_fetch <- function(shiny, onStop) {
  cred_funs <- cred_funs_list()
  cred_funs_clear()
  cred_funs_add(shiny = function(scopes, ...) {
    args <- list(...)
    pkg <- if (!is.null(args$package)) {
      paste("The", args$package, "package")
    } else {
      "A package"
    }
    message(
      pkg, " tried to access Google credentials without consulting Shiny. ",
      "This operation will fail! Try upgrading that package to the latest ",
      "version."
    )
    NULL
  })
  shiny::onStop(function() {
    cred_funs_set(cred_funs)
  })
}

shiny_token <- function(session = shiny::getDefaultReactiveDomain()) {
  if (!is.null(session)) {
    session$userData$gargle_token
  } else {
    NULL
  }
}

with_shiny_token <- function(token, expr) {
  force(token)

  on <- function() {
    push_authstate_interceptor(
      auth_active_func = function(value, fallback) {
        if (missing(value)) {
          !is.null(token)
        } else {
          fallback(value)
        }
      },
      cred_func = function(value, fallback) {
        if (missing(value)) {
          token
        } else {
          fallback(value)
        }
      }
    )
  }
  off <- pop_authstate_interceptor

  domain <- promises::new_promise_domain(
    wrapOnFulfilled = function(onFulfilled) {
      function(...) {
        on()
        on.exit(off(), add = TRUE)

        onFulfilled(...)
      }
    },
    wrapOnRejected = function(onRejected) {
      function(...) {
        on()
        on.exit(off, add = TRUE)

        onRejected(...)
      }
    },
    wrapSync = function(expr) {
      on()
      on.exit(off, add = TRUE)

      expr
    }
  )

  promises::with_promise_domain(domain, expr)
}

