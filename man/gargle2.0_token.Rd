% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Gargle-class.R
\name{gargle2.0_token}
\alias{gargle2.0_token}
\title{Generate a gargle token}
\usage{
gargle2.0_token(
  email = gargle_oauth_email(),
  client = gargle_client(),
  package = "gargle",
  scope = NULL,
  use_oob = gargle_oob_default(),
  credentials = NULL,
  cache = if (is.null(credentials)) gargle_oauth_cache() else FALSE,
  ...,
  app = deprecated()
)
}
\arguments{
\item{email}{Optional. If specified, \code{email} can take several different
forms:
\itemize{
\item \code{"jane@gmail.com"}, i.e. an actual email address. This allows the user to
target a specific Google identity. If specified, this is used for token
lookup, i.e. to determine if a suitable token is already available in the
cache. If no such token is found, \code{email} is used to pre-select the targeted
Google identity in the OAuth chooser. (Note, however, that the email
associated with a token when it's cached is always determined from the token
itself, never from this argument).
\item \code{"*@example.com"}, i.e. a domain-only glob pattern. This can be helpful if
you need code that "just works" for both \code{alice@example.com} and
\code{bob@example.com}.
\item \code{TRUE} means that you are approving email auto-discovery. If exactly one
matching token is found in the cache, it will be used.
\item \code{FALSE} or \code{NA} mean that you want to ignore the token cache and force a
new OAuth dance in the browser.
}

Defaults to the option named \code{"gargle_oauth_email"}, retrieved by
\code{\link[=gargle_oauth_email]{gargle_oauth_email()}} (unless a wrapper package implements different
default behavior).}

\item{client}{A Google OAuth client, preferably constructed via
\code{\link[=gargle_oauth_client_from_json]{gargle_oauth_client_from_json()}}, which returns an instance of
\code{gargle_oauth_client}. For backwards compatibility, for a limited time,
gargle will still accept an "OAuth app" created with \code{\link[httr:oauth_app]{httr::oauth_app()}}.}

\item{package}{Name of the package requesting a token. Used in messages.}

\item{scope}{A character vector of scopes to request.}

\item{use_oob}{Whether to use out-of-band authentication (or, perhaps, a
variant implemented by gargle and known as "pseudo-OOB") when first
acquiring the token. Defaults to the value returned by
\code{\link[=gargle_oob_default]{gargle_oob_default()}}. Note that (pseudo-)OOB auth only affects
the initial OAuth dance. If we retrieve (and possibly refresh) a
cached token, \code{use_oob} has no effect.

If the OAuth client is provided implicitly by a wrapper package, its type
probably defaults to the value returned by
\code{\link[=gargle_oauth_client_type]{gargle_oauth_client_type()}}. You can take control of the client
type by setting \code{options(gargle_oauth_client_type = "web")} or
\code{options(gargle_oauth_client_type = "installed")}.}

\item{credentials}{Advanced use only: allows you to completely customise
token generation.}

\item{cache}{Specifies the OAuth token cache. Defaults to the option named
\code{"gargle_oauth_cache"}, retrieved via \code{\link[=gargle_oauth_cache]{gargle_oauth_cache()}}.}

\item{...}{Absorbs arguments intended for use by other credential functions.
Not used.}

\item{app}{\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#deprecated}{\figure{lifecycle-deprecated.svg}{options: alt='[Deprecated]'}}}{\strong{[Deprecated]}} Replaced by the \code{client}
argument.}
}
\value{
An object of class \link{Gargle2.0}, either new or loaded from the cache.
}
\description{
Constructor function for objects of class \link{Gargle2.0}.
}
\examples{
\dontrun{
gargle2.0_token()
}
}
