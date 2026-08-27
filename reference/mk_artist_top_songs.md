# Fetch an artist's top songs

Wraps the Apple Music "top songs" view
(`/v1/catalog/{storefront}/artists/{id}/view/top-songs`) – songs
associated with the artist based on popularity in the current
storefront, the closest thing to a "start here" list for an artist since
there's no numeric popularity score to sort by directly.

## Usage

``` r
mk_artist_top_songs(
  id,
  limit = 10,
  storefront = NULL,
  creds = mk_credentials()
)
```

## Arguments

- id:

  Catalog artist ID (e.g. from
  [`mk_search()`](https://davidbrocker.github.io/musickitr/reference/mk_search.md)'s
  `id` column).

- limit:

  Max songs to fetch.

- storefront:

  Storefront code, e.g. `"us"`. Defaults to `creds$storefront`.

- creds:

  A credentials list from
  [`mk_credentials()`](https://davidbrocker.github.io/musickitr/reference/mk_credentials.md).

## Value

A tibble, same shape as
[`mk_song()`](https://davidbrocker.github.io/musickitr/reference/mk_song.md)'s
return value.

## Examples

``` r
if (FALSE) { # \dontrun{
mk_artist_top_songs("623897863") # Bad Suns
} # }
```
