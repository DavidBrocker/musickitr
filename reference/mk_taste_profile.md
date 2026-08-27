# Build a taste fingerprint from library, heavy rotation, and recent history

There's no song- or artist-level "recommended for you" field anywhere in
the Apple Music API (see `vignette("exploring-endpoints")` /
[`mk_similar_artists()`](https://davidbrocker.github.io/musickitr/reference/mk_similar_artists.md)'s
docs for the one similarity signal that does exist, at the artist level
only). This builds the same kind of genre/artist frequency profile by
hand, combining three signals of different recency: the whole library
([`mk_library_songs()`](https://davidbrocker.github.io/musickitr/reference/mk_library_songs.md),
long-term), heavy rotation
([`mk_heavy_rotation()`](https://davidbrocker.github.io/musickitr/reference/mk_heavy_rotation.md),
medium-term), and recently played tracks
([`mk_recently_played_tracks()`](https://davidbrocker.github.io/musickitr/reference/mk_recently_played_tracks.md),
short-term). Rows with no usable genre/artist data (playlists, stations
pulled in via heavy rotation) drop out naturally rather than erroring.

## Usage

``` r
mk_taste_profile(
  limit_library = 200,
  limit_heavy_rotation = 10,
  limit_recent = 30,
  creds = mk_credentials()
)
```

## Arguments

- limit_library:

  Max library songs to sample (see
  [`mk_library_songs()`](https://davidbrocker.github.io/musickitr/reference/mk_library_songs.md)).

- limit_heavy_rotation:

  Max heavy rotation entries to sample.

- limit_recent:

  Max recently played tracks to sample.

- creds:

  A credentials list from
  [`mk_credentials()`](https://davidbrocker.github.io/musickitr/reference/mk_credentials.md),
  including a `user_token`.

## Value

A list with three elements: `genres` (tibble of `genre`, `weight`,
sorted descending), `artists` (tibble of `artist_name`, `weight`, sorted
descending), and `n_tracks` (how many rows fed the profile, across all
three sources).

## Examples

``` r
if (FALSE) { # \dontrun{
profile <- mk_taste_profile()
profile$genres
profile$artists
} # }
```
