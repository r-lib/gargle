# Get a token from the Google metadata server

If your code is running on Google Cloud, we can often obtain a token for
an attached service account directly from a metadata server. This is
more secure than working with an explicit a service account key, as
[`credentials_service_account()`](https://gargle.r-lib.org/reference/credentials_service_account.md)
does, and is the preferred method of auth for workloads running on
Google Cloud.

The most straightforward scenario is when you are working in a VM on
Google Compute Engine and it's OK to use the default service account.
This should "just work" automatically.

`credentials_gce()` supports other use cases (such as GKE Workload
Identity), but may require some explicit setup, such as:

- Create a service account, grant it appropriate scopes(s) and IAM
  roles, attach it to the target resource. This prep work happens
  outside of R, e.g., in the Google Cloud Console. On the R side,
  provide the email address of this appropriately configured service
  account via `service_account`.

- Specify details for constructing the root URL of the metadata service:

  - The logical option `"gargle.gce.use_ip"`. If undefined, this
    defaults to `FALSE`.

  - The environment variable `GCE_METADATA_URL` is consulted when
    `"gargle.gce.use_ip"` is `FALSE`. If undefined, the default is
    `metadata.google.internal`.

  - The environment variable `GCE_METADATA_IP` is consulted when
    `"gargle.gce.use_ip"` is `TRUE`. If undefined, the default is
    `169.254.169.254`.

- Change (presumably increase) the timeout for requests to the metadata
  server via the `"gargle.gce.timeout"` global option. This timeout is
  given in seconds and is set to a value (strategy, really) that often
  works well in practice. However, in some cases it may be necessary to
  increase the timeout with code such as:

    options(gargle.gce.timeout = 3)

For details on specific use cases, such as Google Kubernetes Engine
(GKE), see
[`vignette("non-interactive-auth")`](https://gargle.r-lib.org/articles/non-interactive-auth.md).

## Usage

``` r
credentials_gce(
  scopes = "https://www.googleapis.com/auth/cloud-platform",
  service_account = "default",
  ...
)
```

## Arguments

- scopes:

  A character vector of scopes to request. Pick from those listed at
  <https://developers.google.com/identity/protocols/oauth2/scopes>.

  For certain token flows, the
  `"https://www.googleapis.com/auth/userinfo.email"` scope is
  unconditionally included. This grants permission to retrieve the email
  address associated with a token; gargle uses this to index cached
  OAuth tokens. This grants no permission to view or send email and is
  generally considered a low-value scope.

- service_account:

  Name of the GCE service account to use.

- ...:

  Additional arguments passed to all credential functions.

## Value

A [`GceToken()`](https://gargle.r-lib.org/reference/GceToken.md) or
`NULL`.

## See also

A related auth flow that can be used on certain non-Google cloud
providers is workload identity federation, which is implemented in
[`credentials_external_account()`](https://gargle.r-lib.org/reference/credentials_external_account.md).

<https://docs.cloud.google.com/compute/docs/access/service-accounts>

<https://docs.cloud.google.com/iam/docs/best-practices-service-accounts>

How to attach a service account to a resource:
<https://cloud.google.com/iam/docs/impersonating-service-accounts#attaching-to-resources>

<https://docs.cloud.google.com/kubernetes-engine/docs/concepts/workload-identity>

<https://docs.cloud.google.com/kubernetes-engine/docs/how-to/workload-identity>

<https://docs.cloud.google.com/compute/docs/metadata/overview>

Other credential functions:
[`credentials_app_default()`](https://gargle.r-lib.org/reference/credentials_app_default.md),
[`credentials_byo_oauth2()`](https://gargle.r-lib.org/reference/credentials_byo_oauth2.md),
[`credentials_external_account()`](https://gargle.r-lib.org/reference/credentials_external_account.md),
[`credentials_service_account()`](https://gargle.r-lib.org/reference/credentials_service_account.md),
[`credentials_user_oauth2()`](https://gargle.r-lib.org/reference/credentials_user_oauth2.md),
[`token_fetch()`](https://gargle.r-lib.org/reference/token_fetch.md)

## Examples

``` r
if (FALSE) { # \dontrun{
credentials_gce()
} # }
```
