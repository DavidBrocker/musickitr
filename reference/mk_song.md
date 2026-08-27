# Fetch a single song by catalog ID

Fetch a single song by catalog ID

## Usage

``` r
mk_song(id, storefront = NULL, creds = mk_credentials())
```

## Arguments

- id:

  Catalog song ID (e.g. from
  [`mk_search()`](https://davidbrocker.github.io/musickitr/reference/mk_search.md)'s
  `id` column).

- storefront:

  Storefront code, e.g. `"us"`. Defaults to `creds$storefront`.

- creds:

  A credentials list from
  [`mk_credentials()`](https://davidbrocker.github.io/musickitr/reference/mk_credentials.md).

## Value

A one-row tibble, same shape as the `songs` tibble returned by
[`mk_search()`](https://davidbrocker.github.io/musickitr/reference/mk_search.md)
(id, name, artist_name, album_name, duration_ms, release_date, genres,
url, preview_url). `preview_url` (a 30-second `.m4a` clip) feeds
[`mk_play_preview()`](https://davidbrocker.github.io/musickitr/reference/mk_play_preview.md);
it's `NA` for songs that don't have one.

## Examples

``` r
if (FALSE) { # \dontrun{
mk_song("1516773561") # "Molecules" - Aesop Rock
} # }
```
