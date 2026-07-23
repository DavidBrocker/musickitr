# Find artists similar to a given artist

Wraps the Apple Music "similar artists" view
(`/v1/catalog/{storefront}/artists/{id}/view/similar-artists`) –
undocumented in Apple's official REST reference, but confirmed stable
and callable with a plain developer token. It's the same relationship
the MusicMatchup app already uses via native MusicKit's
`Artist.similarArtists`. Since the Catalog API has no numeric popularity
score, this is the closest thing to a recommendation signal available
for a given artist.

## Usage

``` r
mk_similar_artists(
  id,
  storefront = NULL,
  image_width = 300,
  image_height = 300,
  creds = mk_credentials()
)
```

## Arguments

- id:

  Catalog artist ID (e.g. from
  [`mk_search()`](https://davidbrocker.github.io/musickitr/reference/mk_search.md)'s
  `id` column).

- storefront:

  Storefront code, e.g. `"us"`. Defaults to `creds$storefront`.

- image_width, image_height:

  Pixel dimensions to resolve each similar artist's artwork template to.
  Defaults to 300x300.

- creds:

  A credentials list from
  [`mk_credentials()`](https://davidbrocker.github.io/musickitr/reference/mk_credentials.md).

## Value

A tibble of similar artists, same shape as the `artists` tibble returned
by
[`mk_search()`](https://davidbrocker.github.io/musickitr/reference/mk_search.md),
including an `image_url` column.

## Examples

``` r
if (FALSE) { # \dontrun{
mk_similar_artists("623897863") # Bad Suns
} # }
```
