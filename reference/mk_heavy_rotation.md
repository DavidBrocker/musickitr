# Fetch the user's heavy rotation content

Wraps `GET /v1/me/history/heavy-rotation`. Unlike
[`mk_library_songs()`](https://davidbrocker.github.io/musickitr/reference/mk_library_songs.md),
this endpoint returns a mix of resource types – songs, albums,
playlists, stations – whatever Apple considers "in heavy rotation" right
now. Reuses
[`mk_tidy_songs()`](https://davidbrocker.github.io/musickitr/reference/mk_tidy_songs.md)
as the tidier the same way
[`mk_charts()`](https://davidbrocker.github.io/musickitr/reference/mk_charts.md)
does for music videos: it degrades gracefully (`NA` for whatever
attributes a given type doesn't have), which is exactly what a
genre/artist taste signal needs – playlists and stations will come back
with `NA` genres/artist_name and drop out of
[`mk_taste_profile()`](https://davidbrocker.github.io/musickitr/reference/mk_taste_profile.md)
naturally.

## Usage

``` r
mk_heavy_rotation(limit = 10, creds = mk_credentials())
```

## Arguments

- limit:

  Max entries to fetch.

- creds:

  A credentials list from
  [`mk_credentials()`](https://davidbrocker.github.io/musickitr/reference/mk_credentials.md),
  including a `user_token`.

## Value

A tibble, same shape as
[`mk_song()`](https://davidbrocker.github.io/musickitr/reference/mk_song.md)'s
return value (some rows may have `NA` in song-specific columns like
`album_name` if the underlying resource was an album/playlist/station).

## Examples

``` r
if (FALSE) { # \dontrun{
mk_heavy_rotation(limit = 10)
} # }
```
