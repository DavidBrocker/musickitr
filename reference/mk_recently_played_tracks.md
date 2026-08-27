# Fetch the user's recently played tracks

Wraps `GET /v1/me/recent/played/tracks` – note this is a different,
narrower endpoint than `/v1/me/recent/played` (which returns albums,
playlists, and stations, not individual tracks). `types` is required by
the endpoint; defaults to catalog and library songs.

## Usage

``` r
mk_recently_played_tracks(
  limit = 30,
  types = c("songs", "library-songs"),
  creds = mk_credentials()
)
```

## Arguments

- limit:

  Max tracks to fetch (Apple's ceiling is 30).

- types:

  Character vector of track types to include, from `"songs"`,
  `"library-songs"`, `"music-videos"`, `"library-music-videos"`.

- creds:

  A credentials list from
  [`mk_credentials()`](https://davidbrocker.github.io/musickitr/reference/mk_credentials.md),
  including a `user_token`.

## Value

A tibble, same shape as
[`mk_song()`](https://davidbrocker.github.io/musickitr/reference/mk_song.md)'s
return value.

## Examples

``` r
if (FALSE) { # \dontrun{
mk_recently_played_tracks(limit = 30)
} # }
```
