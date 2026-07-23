# Fetch a single artist by catalog ID

Fetch a single artist by catalog ID

## Usage

``` r
mk_artist(
  id,
  storefront = NULL,
  image_width = 300,
  image_height = 300,
  creds = mk_credentials()
)
```

## Arguments

- id:

  Catalog artist ID.

- storefront:

  Storefront code, e.g. `"us"`. Defaults to `creds$storefront`.

- image_width, image_height:

  Pixel dimensions to resolve the artist's artwork template to (see
  `image_url` in the return value). Defaults to 300x300.

- creds:

  A credentials list from
  [`mk_credentials()`](https://davidbrocker.github.io/musickitr/reference/mk_credentials.md).

## Value

A one-row tibble, same shape as the `artists` tibble returned by
[`mk_search()`](https://davidbrocker.github.io/musickitr/reference/mk_search.md),
including an `image_url` column ready to use directly (e.g. as
`circularImage` node icons in visNetwork).

## Examples

``` r
if (FALSE) { # \dontrun{
mk_artist("623897863") # Bad Suns
mk_artist("623897863", image_width = 600, image_height = 600)
} # }
```
