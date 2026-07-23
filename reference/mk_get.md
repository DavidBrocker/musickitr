# Call an Apple Music API endpoint and return parsed JSON

Low-level building block behind the tidy `mk_*()` functions. Useful for
exploring endpoints musickitr doesn't have a dedicated wrapper for yet –
see `vignette("exploring-endpoints")`.

## Usage

``` r
mk_get(path, query = list(), creds = mk_credentials())
```

## Arguments

- path:

  API path, e.g. `"/v1/catalog/us/search"`.

- query:

  Named list of query parameters.

- creds:

  A credentials list from
  [`mk_credentials()`](https://davidbrocker.github.io/musickitr/reference/mk_credentials.md).

## Value

The parsed JSON response body, as a nested list.
