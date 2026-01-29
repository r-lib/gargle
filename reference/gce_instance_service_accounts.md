# List all service accounts available on this GCE instance

List all service accounts available on this GCE instance

## Usage

``` r
gce_instance_service_accounts()
```

## Value

A data frame, where each row is a service account. Due to aliasing,
there is no guarantee that each row represents a distinct service
account.

## See also

The return value is built from a recursive query of the so-called
"directory" of the instance's service accounts as documented in
<https://cloud.google.com/compute/docs/metadata/default-metadata-values#vm_instance_metadata>.

## Examples

``` r
if (FALSE) { # gargle:::is_gce()
credentials_gce()
}
```
