# Request helper functions

This vignette explains the purpose and usage of:

- `request_develop(endpoint, params, base_url)`
- `request_build(method, path, params, body, token, key, base_url)`
- `request_make(x, ..., user_agent)`

The target audience is someone writing an R package to wrap a Google
API.

``` r
library(gargle)
```

## Why use gargle’s request helpers?

Why would the developer of a Google-API-wrapping package care about the
request helpers in gargle?

You can write less code and safer code, in return for a modest
investment in studying your target API. That is done by ingesting the
API’s so-called Discovery Document.

Hundreds of Google APIs – the ones addressed by the [API Discovery
Service](https://developers.google.com/discovery/) – share a great deal
of behaviour. By ingesting the metadata provided by this service, you
can use gargle’s request helpers to exploit this shared data and logic,
while also decreasing the chance that you and your users will submit
ill-formed requests.

The request helpers in gargle check the combined inputs from user and
developer against suitably prepared API metadata:

- If required parameters are missing, an error is thrown.
- If unrecognized parameters are submitted, an error is thrown.
- Parameters are automatically placed in their correct location: URL
  substitution, query, or body.
- *Is there something else you care about? It is possible to do more,
  but it would help to have concrete requests.*

Google provides [API libraries for several
languages](https://developers.google.com/api-client-library/), including
Java, Go, Python, JavaScript, Ruby and more (but not R). All of these
libraries are machine-generated from the metadata provided by the API
Discovery Service. It is the [official
recommendation](https://developers.google.com/discovery/v1/using#build)
to use the Discovery Document when building client libraries. The gargle
package aims to implement key parts of this strategy, in a way that is
also idiomatic for R and its developers.

## High-level design pattern

gargle facilitates this design for API-wrapping packages:

- A machine-assisted low-level interface driven by the Discovery
  Document:
  - Your package exports thin wrapper functions around gargle’s helpers
    to form and make HTTP requests, that inject package-specific logic
    and data, such as an API key and user agent. This is for power users
    and yourself.
- High-level, task-oriented, user-facing functions that constitute the
  main interface of your package.
  - These functions convert user input into the form required by the API
    and pass it along to your low-level interface functions.

Later, specific examples are given, using the googledrive package.

## gargle’s HTTP request helpers

gargle provides support for creating and sending HTTP requests via these
functions:

`request_develop(endpoint, params, base_url)`: a.k.a. The Smart One.

- Processes the info in `params` relative to detailed knowledge about
  the `endpoint`, derived from an API Discovery Document.
- Checks for required and unrecognized parameters.
- Peels off `params` destined for the body into their own part.
- Returns request data in a form that anticipates the
  [`httr::VERB()`](https://httr.r-lib.org/reference/VERB.html) call that
  is on the horizon.

`request_build(method, path, params, body, token, key, base_url)`:
a.k.a. The Dumb One.

- Typically consumes the output of
  [`request_develop()`](https://gargle.r-lib.org/reference/request_develop.md),
  although that is not required. It can be called directly to enjoy a
  few luxuries even when making one-off API calls in the absence of an
  ingested Discovery Document.
- Integrates `params` into a URL via substitution and the query string.
- Sends either an API key or an OAuth token, but it provides no default
  values or logic for either.

`request_make(x, ..., user_agent)`: actually makes the HTTP request.

- Typically consumes the output of
  [`request_build()`](https://gargle.r-lib.org/reference/request_develop.md),
  although that is not required. However, if you have enough info to
  form a
  [`request_make()`](https://gargle.r-lib.org/reference/request_make.md)
  request, you would probably just make the
  [`httr::VERB()`](https://httr.r-lib.org/reference/VERB.html) call
  yourself.
- Consults `x$method` to determine which
  [`httr::VERB()`](https://httr.r-lib.org/reference/VERB.html) to call,
  then calls it with the rest of `x`, `...`, and `user_agent` passed as
  arguments.

They are usually called in the above order, though they don’t have to be
used that way. It is also fine to ignore this part of gargle and use it
only for help with auth. They are separate parts of the package.

## Discovery Documents

Google’s [API Discovery
Service](https://developers.google.com/discovery/) “provides a
lightweight, JSON-based API that exposes machine-readable metadata about
Google APIs”. We recommend ingesting this metadata into an R list,
stored as internal data in an API-wrapping client package. Then, HTTP
requests inside high-level functions can be made concisely and safely,
by referring to this metadata. The combined use of this data structure
and gargle’s request helpers can eliminate a lot of boilerplate data and
logic that are shared across Google APIs and across endpoints within an
API.

The gargle package ships with some functions and scripts to facilitate
the ingest of a Discovery Document. You can find these files in the
gargle installation like so:

``` r
ddi_dir <- system.file("discovery-doc-ingest", package = "gargle")
list.files(ddi_dir)
#>  [1] "api-wide-parameter-names.txt"   
#>  [2] "api-wide-parameters-humane.txt" 
#>  [3] "api-wide-parameters.csv"        
#>  [4] "discover-discovery.R"           
#>  [5] "drive-example.R"                
#>  [6] "ingest-functions.R"             
#>  [7] "method-properties-humane.txt"   
#>  [8] "method-properties.csv"          
#>  [9] "method-property-names.txt"      
#> [10] "parameter-properties-humane.txt"
#> [11] "parameter-properties.csv"       
#> [12] "parameter-property-names.txt"
```

Main files of interest to the developer of a client package:

- `ingest-functions.R` is a collection of functions for downloading and
  ingesting a Discovery Document.
- `drive-example.R` uses those functions to ingest metadata on the Drive
  v3 API and store it as an internal data object for use in
  [googledrive](https://googledrive.tidyverse.org).

The remaining files present an analysis of the Discovery Document for
the Discovery API itself (very meta!) and write files that are useful
for reference. Several are included at the end of this vignette.

Why aren’t the ingest functions exported by gargle? First, we regard
this as functionality that is needed at development time, not install or
run time. This is something you’ll do every few months, probably
associated with preparing a release of a wrapper package. Second, the
packages that are useful for wrangling JSON and lists are not existing
dependencies of gargle, so putting these function in gargle would
require some unappealing compromises.

## Method (or endpoint) data

Our Discovery Document ingest process leaves you with an R list. Let’s
assume it’s available in your package’s namespace as an internal object
named `.endpoints`. Each item represents one method of the API (Google’s
vocabulary) or an endpoint (gargle’s vocabulary).

Each endpoint has an `id`. These `id`s are also used as names for the
list. Examples of some `id`s from the Drive and Sheets APIs:

    drive.about.get
    drive.files.create
    drive.teamdrives.list
    sheets.spreadsheets.create
    sheets.spreadsheets.values.clear
    sheets.spreadsheets.sheets.copyTo

Retrieve the metadata for one endpoint by name, e.g.:

``` r
.endpoints[["drive.files.create"]]
```

That info can be passed along to
`request_develop(endpoint, params, base_url)`, which conducts sanity
checks and combines this external knowledge with the data coming from
the user and developer via `params`.

## Design suggestion: forming requests

Here’s the model used in googledrive. There is a low-level request
helper, `googledrive::request_generate()`, that is used to form every
request in the package. It is exported as part of a low-level API for
expert use, but most users will never know it exists.

``` r
# googledrive::
request_generate <- function(endpoint = character(),
                             params = list(),
                             key = NULL,
                             token = drive_token()) {
  ept <- .endpoints[[endpoint]]
  if (is.null(ept)) {
    stop_glue("\nEndpoint not recognized:\n  * {endpoint}")
  }

  ## modifications specific to googledrive package
  params$key <- key %||% params$key %||% drive_api_key()
  if (!is.null(ept$parameters$supportsTeamDrives)) {
    params$supportsTeamDrives <- TRUE
  }

  req <- gargle::request_develop(endpoint = ept, params = params)
  gargle::request_build(
    path = req$path,
    method = req$method,
    params = req$params,
    body = req$body,
    token = token
  )
}
```

The `endpoint` argument specifies an endpoint by its name, a.k.a. its
`id`.

`params` is where the processed user input goes.

`key` and `token` refer to an API key and OAuth2 token, respectively.
Both can be populated by default, but it is possible to pass them
explicitly. If your package ships with a default API key, you should
append it above as the final fallback value for `params$key`.

Do not “borrow” an API key from gargle or another package; always send a
key associated with your package or provided by your user. Per the
Google User Data Policy
<https://developers.google.com/terms/api-services-user-data-policy>,
your application must accurately represent itself when authenticating to
Google API services.

After `googledrive::request_generate()` takes care of everything
specific to the Drive API and the user’s input and task, we call
[`gargle::request_develop()`](https://gargle.r-lib.org/reference/request_develop.md).
We finish preparing the request with
[`gargle::request_build()`](https://gargle.r-lib.org/reference/request_develop.md),
which enforces the rule that we always send exactly **one** of `key` and
`token`.

## Design suggestion: making requests

The output of
[`gargle::request_build()`](https://gargle.r-lib.org/reference/request_develop.md)
specifies an HTTP request.

[`gargle::request_make()`](https://gargle.r-lib.org/reference/request_make.md)
can be used to actually execute it.

``` r
# gargle::
request_make <- function(x, ..., user_agent = gargle_user_agent()) {
  stopifnot(is.character(x$method))
  method <- switch(
    x$method,
    GET    = httr::GET,
    POST   = httr::POST,
    PATCH  = httr::PATCH,
    PUT    = httr::PUT,
    DELETE = httr::DELETE,
    abort(glue("Not a recognized HTTP method: {bt(x$method)}"))
  )
  method(
    url = x$url,
    body = x$body,
    x$token,
    user_agent,
    ...
  )
}
```

[`request_make()`](https://gargle.r-lib.org/reference/request_make.md)
consults `x$method` to identify the
[`httr::VERB()`](https://httr.r-lib.org/reference/VERB.html) and then
calls it with the remainder of `x`, `...` and the `user_agent`.

In googledrive we have a thin wrapper around this that injects the
googledrive user agent:

``` r
# googledrive::
request_make <- function(x, ...) {
  gargle::request_make(x, ..., user_agent = drive_ua())
}
```

## Reference

*derived from the Discovery Document for the Discovery Service*

Properties of an endpoint

    NA description             string  Description of this method.
    NA etagRequired            boolean Whether this method requires an ETag to be
    NA                                 specified. The ETag is sent as an HTTP If-
    NA                                 Match or If-None-Match header.
    NA httpMethod              string  HTTP method used by this method.
    NA id                      string  A unique ID for this method. This property
    NA                                 can be used to match methods between
    NA                                 different versions of Discovery.
    NA mediaUpload             object  Media upload parameters.
    NA parameterOrder          array   Ordered list of required parameters, serves
    NA                                 as a hint to clients on how to structure
    NA                                 their method signatures. The array is ordered
    NA                                 such that the "most-significant" parameter
    NA                                 appears first.
    NA parameters              object  Details for all parameters in this method.
    NA path                    string  The URI path of this REST method. Should
    NA                                 be used in conjunction with the basePath
    NA                                 property at the api-level.
    NA request                 object  The schema for the request.
    NA response                object  The schema for the response.
    NA scopes                  array   OAuth 2.0 scopes applicable to this method.
    NA supportsMediaDownload   boolean Whether this method supports media downloads.
    NA supportsMediaUpload     boolean Whether this method supports media uploads.
    NA supportsSubscription    boolean Whether this method supports subscriptions.
    NA useMediaDownloadService boolean Indicates that downloads from this method
    NA                                 should use the download service URL (i.e.
    NA                                 "/download"). Only applies if the method
    NA                                 supports media download.

API-wide endpoint parameters (taken from Discovery API but, empirically,
are shared with other APIs):

    NA alt         string  Data format for the response.
    NA fields      string  Selector specifying which fields to include
    NA                     in a partial response.
    NA key         string  API key. Your API key identifies your project
    NA                     and provides you with API access, quota, and
    NA                     reports. Required unless you provide an OAuth
    NA                     2.0 token.
    NA oauth_token string  OAuth 2.0 token for the current user.
    NA prettyPrint boolean Returns response with indentations and line
    NA                     breaks.
    NA quotaUser   string  An opaque string that represents a user
    NA                     for quota purposes. Must not exceed 40
    NA                     characters.
    NA userIp      string  Deprecated. Please use quotaUser instead.

Properties of an endpoint parameters:

    NA $ref                 string  A reference to another schema. The value of
    NA                              this property is the "id" of another schema.
    NA additionalProperties NULL    If this is a schema for an object, this
    NA                              property is the schema for any additional
    NA                              properties with dynamic keys on this object.
    NA annotations          object  Additional information about this property.
    NA default              string  The default value of this property (if one
    NA                              exists).
    NA description          string  A description of this object.
    NA enum                 array   Values this parameter may take (if it is an
    NA                              enum).
    NA enumDescriptions     array   The descriptions for the enums. Each position
    NA                              maps to the corresponding value in the "enum"
    NA                              array.
    NA format               string  An additional regular expression or key that
    NA                              helps constrain the value. For more details
    NA                              see: http://tools.ietf.org/html/draft-zyp-
    NA                              json-schema-03#section-5.23
    NA id                   string  Unique identifier for this schema.
    NA items                NULL    If this is a schema for an array, this
    NA                              property is the schema for each element in
    NA                              the array.
    NA location             string  Whether this parameter goes in the query or
    NA                              the path for REST requests.
    NA maximum              string  The maximum value of this parameter.
    NA minimum              string  The minimum value of this parameter.
    NA pattern              string  The regular expression this parameter must
    NA                              conform to. Uses Java 6 regex format: http://
    NA                              docs.oracle.com/javase/6/docs/api/java/util/
    NA                              regex/Pattern.html
    NA properties           object  If this is a schema for an object, list the
    NA                              schema for each property of this object.
    NA readOnly             boolean The value is read-only, generated by the
    NA                              service. The value cannot be modified by the
    NA                              client. If the value is included in a POST,
    NA                              PUT, or PATCH request, it is ignored by the
    NA                              service.
    NA repeated             boolean Whether this parameter may appear multiple
    NA                              times.
    NA required             boolean Whether the parameter is required.
    NA type                 string  The value type for this schema. A list
    NA                              of values can be found here: http://
    NA                              tools.ietf.org/html/draft-zyp-json-
    NA                              schema-03#section-5.1
    NA variant              object  In a variant data type, the value of
    NA                              one property is used to determine how to
    NA                              interpret the entire entity. Its value must
    NA                              exist in a map of descriminant values to
    NA                              schema names.
