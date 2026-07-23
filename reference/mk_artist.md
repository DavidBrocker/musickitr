# Fetch a single artist by catalog ID

Fetch a single artist by catalog ID

## Usage

``` r
mk_artist(id, storefront = NULL, creds = mk_credentials())
```

## Arguments

- id:

  Catalog artist ID.

- storefront:

  Storefront code, e.g. `"us"`. Defaults to `creds$storefront`.

- creds:

  A credentials list from
  [`mk_credentials()`](https://davidbrocker.github.io/musickitr/reference/mk_credentials.md).

## Value

A one-row tibble, same shape as the `artists` tibble returned by
[`mk_search()`](https://davidbrocker.github.io/musickitr/reference/mk_search.md).

## Examples

``` r
if (FALSE) { # \dontrun{
mk_artist("623897863") # Bad Suns
} # }
```
