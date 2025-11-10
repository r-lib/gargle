# Generate a field mask

Many Google API requests take a field mask, via a `fields` parameter, in
the URL and/or in the body. `field_mask()` generates such a field mask
from an R list, typically a list that is destined to be part of the body
of a request that writes or updates a resource. `field_mask()` is
designed to help in the common case where the attributes you wish to
modify are exactly the ones represented in the object. It is possible to
use a "larger" field mask, that is either less specific or that
explicitly includes other attributes, in which case the attributes
covered by the mask but absent from the object are reset to default
values. This is not exactly the use case `field_mask()` is designed for,
but its output could still be useful as a first step in constructing
such a mask.

## Usage

``` r
field_mask(x)
```

## Arguments

- x:

  A named R list, where the requirement for names applies at all levels,
  i.e. recursively.

## Value

A Google API field mask, as a string.

## See also

The documentation for the [JSON encoding of a Protocol Buffers
FieldMask](https://protobuf.dev/reference/protobuf/google.protobuf/#json-encoding-of-field-masks).

## Examples

``` r
x <- list(sheetId = 1234, title = "my_favorite_worksheet")
field_mask(x)
#> [1] "sheetId,title"

x <- list(
  userEnteredFormat = list(
    backgroundColor = list(
      red = 159 / 255, green = 183 / 255, blue = 196 / 255
    )
  )
)
field_mask(x)
#> [1] "userEnteredFormat.backgroundColor(red,green,blue)"

x <- list(
  sheetId = 1234,
  gridProperties = list(rowCount = 5, columnCount = 3)
)
field_mask(x)
#> [1] "sheetId,gridProperties(rowCount,columnCount)"
```
