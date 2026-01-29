# Access the last response

These functions give access to the most recent response processed by
[`response_process(..., remember = TRUE)`](https://gargle.r-lib.org/reference/response_process.md).
They can be useful for *post mortem* analysis of puzzling or failed API
interactions.

## Usage

``` r
gargle_last_response()

gargle_last_content()
```

## Value

- `gargle_last_response()` returns the most recent
  [`httr::response()`](https://httr.r-lib.org/reference/response.html)
  object.

- `gargle_last_content()` returns the parsed JSON content from the most
  recent response or an empty list if unavailable.
