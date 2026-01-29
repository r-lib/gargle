# Google Compute Engine

``` r
library(gargle)
```

This article has two purposes:

- Document how I create VMs on GCE when I work on
  [`credentials_gce()`](https://gargle.r-lib.org/reference/credentials_gce.md).
- Document how instance scopes relate to GCE access token scopes, in my
  hands.

## Preparation

I use the [googleComputeEngineR
package](https://cloudyr.github.io/googleComputeEngineR/) to work with
GCE VMs.

I have done the required setup for this package:

- Identify (or get) a Google Cloud Platform (GCP) project, with billing
  enabled.

- Download the JSON for the default service account for said GCP
  project.

- Configure env vars in `.Renviron`:

      GCE_AUTH_FILE="/path/to/that/json/mentioned/above.json"
      GCE_DEFAULT_PROJECT_ID="gargle-gce"
      GCE_DEFAULT_ZONE="us-west1-a"

Having done this setup, this is how attaching the package looks:

``` r
library(googleComputeEngineR)
#> ✔ Setting scopes to https://www.googleapis.com/auth/cloud-platform
#> ✔ Successfully auto-authenticated via /path/to/that/json/mentioned/above.json
#> Set default project ID to 'gargle-gce'
#> Set default zone to 'us-west1-a'
```

Note that (I think) the scopes mentioned above are about
googleComputeEngineR’s activities. I don’t think this has any direct
connection to instance scopes for VMs created by googleComputeEngineR.
(Although, of course, `"https://www.googleapis.com/auth/cloud-platform"`
is the default, recommended scope for both contexts.)

You can see your current instances with `gce_list_instances()`:

``` r
gce_list_instances()
#> ==Google Compute Engine Instance List==
#>                        name   machineType     status       zone     externalIP   creationTimestamp
#> 1 gargle-gce-rstudio-server e2-standard-4 TERMINATED us-west1-a No external IP 2022-10-21 14:41:46
#> 2           majestic-cuckoo e2-standard-4 TERMINATED us-west1-a No external IP 2023-04-11 18:56:14
#> 3            piggish-salmon e2-standard-4 TERMINATED us-west1-a No external IP 2023-04-12 07:22:26
#> 4                tricky-fox e2-standard-4 TERMINATED us-west1-a No external IP 2023-04-12 12:00:52
```

The above reflects how things look after I’ve been mucking around a bit
and have several VMs that are currently stopped.

## Creating a VM on GCE

Here’s my basic way of creating a VM:

``` r
vm <- gce_vm(
  template = "rstudio",
  name = "cerebral-lion",
  username = "jenny",
  password = "jenny1234",
  predefined_type = "e2-standard-4"
)
```

I can no longer remember why I settled on
`predefined_type = "e2-standard-4"`.

Here’s what you’ll see:

``` r
#> ── ## VM Template: ' rstudio' running at http://{IP_ADDRESS} ─────────────────────────────────────────────────────
#> ℹ 2023-04-13 12:03:05 > On first boot, wait a few minutes for docker container to install before logging in.
#> ==Google Compute Engine Instance==
#> 
#> Name:                cerebral-lion
#> Created:             2023-04-13 12:02:44
#> Machine Type:        e2-standard-4
#> Status:              RUNNING
#> Zone:                us-west1-a
#> External IP:         {IP_ADDRESS}
#> Disks: 
#>                deviceName       type       mode boot autoDelete
#> 1 cerebral-lion-boot-disk PERSISTENT READ_WRITE TRUE       TRUE
#> 
#> Metadata:  
#>                      key            value
#> 2               template          rstudio
#> 3 google-logging-enabled             true
#> 4           rstudio_user            jenny
#> 5             rstudio_pw        jenny1234
#> 6      gcer_docker_image rocker/tidyverse
```

You can then log in to RStudio Server at the given `{IP_ADDRESS}`.
Helpful snippets for getting that on the clipboard:

``` r
# if you, e.g., just created `vm`
paste0("http://", gce_get_external_ip(vm)) |>
  clipr::write_clip()

# if you want to refer to the instance by name
paste0("http://", gce_get_external_ip("cerebral-lion")) |>
  clipr::write_clip()
```

Under the hood, googleComputeEngineR is inserting its own default
choices for the associated service account and scopes. It’s actually as
if you had done:

``` r
gce_vm(
  ...,
  serviceAccounts = list(
    email = "{EMAIL_OF_THE_DEFAULT_SERVICE_ACCOUNT}",
    scopes = "https://www.googleapis.com/auth/cloud-platform"
  )
)
```

Below we will create another VM and pass `serviceAccounts` explicitly,
so we can also specify the scopes.

To learn more:
<https://cloud.google.com/compute/docs/access/create-enable-service-accounts-for-instances>.

## Do some work in the VM

Log in to RStudio Server in the VM (see above for getting the IP
address). First, for my current exploration, I want to install gargle
from a specific branch:

``` r
install.packages("pak")
pak::pak("r-lib/gargle@gce-improvements")
```

Now attach gargle and set verbosity level to `"debug"`.

``` r
library(gargle)
local_gargle_verbosity("debug")
```

Let’s look at the service accounts available to this running instance:

``` r
gce_instance_service_accounts()
#>                                     name                                  email aliases
#> 1 {EMAIL_OF_THE_DEFAULT_SERVICE_ACCOUNT} {EMAIL_OF_THE_DEFAULT_SERVICE_ACCOUNT} default
#> 2                                default {EMAIL_OF_THE_DEFAULT_SERVICE_ACCOUNT} default
#>                                           scopes
#> 1 https://www.googleapis.com/auth/cloud-platform
#> 2 https://www.googleapis.com/auth/cloud-platform
```

> You can enable multiple virtual machine instances to use the same
> service account, **but a virtual machine instance can only have one
> service account identity**.

So there will only ever be 1 actual service account identify, but you
might see two rows here, as we do above, because the default service
account can be referred to by 2 names: its email and as `default`.

Let’s get a token with
[`token_fetch()`](https://gargle.r-lib.org/reference/token_fetch.md) and
inspect it.

``` r
t <- token_fetch()
#> trying `token_fetch()`
#> ...
#> Trying `credentials_gce()` ...
#> GceToken initialize
#> GceToken init_credentials
#> GCE service account email: '{EMAIL_OF_THE_DEFAULT_SERVICE_ACCOUNT}'
#> GCE service account name: "default"
#> GCE access token scopes: "...cloud-platform"
t
#> 
#> ── <GceToken (via gargle)> ──────────────────────────────────────────────────────────────────────────────────────────────────────
#>      scopes: ...cloud-platform
#> credentials: access_token, expires_in, token_type
```

By default,
[`credentials_gce()`](https://gargle.r-lib.org/reference/credentials_gce.md)
uses the `default` service account and the `"cloud-platform"` scope.

What if we want to do something with the Google Drive API and we request
that scope?

``` r
t <- token_fetch(c(
  "https://www.googleapis.com/auth/cloud-platform",
  "https://www.googleapis.com/auth/drive"
))
#> trying `token_fetch()`
#> ...
#> Trying `credentials_gce()` ...
#> ! This requested scope is not among the scopes for the "default" service account:
#> ✖ https://www.googleapis.com/auth/drive
#> ℹ If there are problems downstream, this might be the root cause.
#> GceToken initialize
#> GceToken init_credentials
#> ! This requested scope is not among the scopes for the access token returned by the metadata server:
#> ✖ https://www.googleapis.com/auth/drive
#> ℹ If there are problems downstream, this might be the root cause.
#> ! Updating token scopes to reflect its actual scopes:
#> • https://www.googleapis.com/auth/cloud-platform
#> GCE service account email: '{EMAIL_OF_THE_DEFAULT_SERVICE_ACCOUNT}'
#> GCE service account name: "default"
#> GCE access token scopes: "...cloud-platform"
t
#> 
#> ── <GceToken (via gargle)> ──────────────────────────────────────────────────────────────────────────────────────────────────────
#>      scopes: ...cloud-platform
#> credentials: access_token, expires_in, token_type
```

We get a token, but still with only the `"cloud-platform"` scope,
because the Drive scope was not specified when this VM was created:

> You can use the access token only for scopes that you specified when
> you created the instance. For example, if the instance has been
> granted only the `https://www.googleapis.com/auth/storage-full` scope
> for Cloud Storage, then it can’t use the access token to make a
> request to BigQuery.

And, indeed, this lack of an explicit Drive scope means that, e.g., the
googledrive package can’t do operations that require auth:

``` r
library(googledrive)
drive_find()
#> attempt to access internal gargle data from: googledrive
#> Error in `gargle::response_process()`:
#> ! Client error: (403) Forbidden
#> Request had insufficient authentication scopes.
#> PERMISSION_DENIED
#> • message: Insufficient Permission
#> • domain: global
#> • reason: insufficientPermissions
#> Backtrace:
#>     ▆
#>  1. └─googledrive::drive_find()
#>  2.   └─googledrive::do_paginated_request(request, n_max = n_max, n = function(x) length(x$files))
#>  3.     └─gargle::response_process(page)
#>  4.       └─gargle:::gargle_abort_request_failed(error_message(resp), resp)
#>  5.         └─gargle:::gargle_abort(...)
#>  6.           └─cli::cli_abort(...)
#>  7.             └─rlang::abort(...)
```

## Suspend, resume, or stop the VM

If you’re not actively working on the VM, you should at least suspend
it. Then you could resume it to pick up where you left off. To ensure
that you aren’t incurring any charges, you should stop the machine, but
then you’ll have to start over if you’ve, e.g., installed dev packages
or downloaded/created any files.

``` r
gce_vm_suspend("cerebral-lion")
gce_vm_resume("cerebral-lion")
gce_vm_stop("cerebral-lion")
```

It’s a good idea to check that you’ve done whatever you intended with
the instance. Check its status here:

``` r
gce_list_instances()
#> ==Google Compute Engine Instance List==
#>                        name   machineType     status       zone     externalIP   creationTimestamp
#> 1             cerebral-lion e2-standard-4  SUSPENDED us-west1-a No external IP 2023-04-13 12:02:44
#> 2 gargle-gce-rstudio-server e2-standard-4 TERMINATED us-west1-a No external IP 2022-10-21 14:41:46
#> 3           majestic-cuckoo e2-standard-4 TERMINATED us-west1-a No external IP 2023-04-11 18:56:14
#> 4            piggish-salmon e2-standard-4 TERMINATED us-west1-a No external IP 2023-04-12 07:22:26
#> 5                tricky-fox e2-standard-4 TERMINATED us-west1-a No external IP 2023-04-12 12:00:52
```

## Creating a VM and specifying scopes

Now we’re going to specifically request Drive scope for a VM. AFAICT
googleComputeEngineR only helps you set scopes at the time of VM
creation, so I’m going to create a new instance. It seems possible to
change scopes for pre-existing instance as long as it is stopped, so
maybe that could be a feature request for googleComputeEngineR (or maybe
I’m overlooking that there’s already a way to do this). Further reading:
<https://cloud.google.com/compute/docs/access/create-enable-service-accounts-for-instances#changeserviceaccountandscopes>.

``` r
vm <- gce_vm(
  template = "rstudio",
  name = "trustful-bull",
  username = "jenny",
  password = "jenny1234",
  predefined_type = "e2-standard-4",
  serviceAccounts = list(
    list(
      email = "{EMAIL_OF_THE_DEFAULT_SERVICE_ACCOUNT}",
      scopes = c(
        "https://www.googleapis.com/auth/cloud-platform",
        "https://www.googleapis.com/auth/drive"
      )
    )
  ),
)
```

I get the IP address, log in to RStudio Server, and install the desired
version of gargle (not shown).
[`gce_instance_service_accounts()`](https://gargle.r-lib.org/reference/gce_instance_service_accounts.md)
shows that we have, in fact, managed to change the `scopes` available to
the default service account:

``` r
gce_instance_service_accounts()
#>                                     name                                  email aliases
#> 1 {EMAIL_OF_THE_DEFAULT_SERVICE_ACCOUNT} {EMAIL_OF_THE_DEFAULT_SERVICE_ACCOUNT} default
#> 2                                default {EMAIL_OF_THE_DEFAULT_SERVICE_ACCOUNT} default
#>                                                                                 scopes
#> 1 https://www.googleapis.com/auth/cloud-platform,https://www.googleapis.com/auth/drive
#> 2 https://www.googleapis.com/auth/cloud-platform,https://www.googleapis.com/auth/drive
```

We see this in actual tokens as well. Note that we get `"drive"` scope
*even if we don’t ask for it*.

``` r
t <- token_fetch()
#> trying `token_fetch()`
#> ...
#> Trying `credentials_gce()` ...
#> GceToken initialize
#> GceToken init_credentials
#> ! Updating token scopes to reflect its actual scopes:
#> • https://www.googleapis.com/auth/cloud-platform
#> • https://www.googleapis.com/auth/drive
#> GCE service account email: '{EMAIL_OF_THE_DEFAULT_SERVICE_ACCOUNT}'
#> GCE service account name: "default"
#> GCE access token scopes: "...cloud-platform, ...drive"
t
#> 
#> ── <GceToken (via gargle)> ──────────────────────────────────────────────────────────────────────────────────────────────────────
#>      scopes: ...cloud-platform, ...drive
#> credentials: access_token, expires_in, token_type
```

And, as one would expect, it’s now possible to work with the googledrive
package.

``` r
library(googledrive)
drive_find()
#> # A dribble: 0 × 3
#> # ℹ 3 variables: name <chr>, id <drv_id>, drive_resource <list>

drive_user()
#> Logged in as:
#> • displayName: '{EMAIL_OF_THE_DEFAULT_SERVICE_ACCOUNT}'
#> • emailAddress: '{EMAIL_OF_THE_DEFAULT_SERVICE_ACCOUNT}'
```
