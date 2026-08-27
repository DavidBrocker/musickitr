# Recommend songs based on a listener's taste profile

The pipeline this stitches together, end to end: take the listener's
most-played artists from
[`mk_taste_profile()`](https://davidbrocker.github.io/musickitr/reference/mk_taste_profile.md),
resolve each to a catalog ID via
[`mk_search()`](https://davidbrocker.github.io/musickitr/reference/mk_search.md)
(library/history endpoints only return artist *names*, not catalog IDs,
unless you separately request the `artists` relationship), expand each
one hop outward with
[`mk_similar_artists()`](https://davidbrocker.github.io/musickitr/reference/mk_similar_artists.md)
– the same seed/hop mental model
[`mk_similarity_graph()`](https://davidbrocker.github.io/musickitr/reference/mk_similarity_graph.md)
uses – then score every candidate artist surfaced that way by genre
overlap with the profile via
[`mk_jaccard()`](https://davidbrocker.github.io/musickitr/reference/mk_jaccard.md).
Candidates surfaced by more than one seed artist (the graph's
"convergence points") get a small bonus, on the theory that an artist
your library reaches from multiple directions is a stronger signal than
one reached from a single artist. The top-scoring candidate artists' top
songs
([`mk_artist_top_songs()`](https://davidbrocker.github.io/musickitr/reference/mk_artist_top_songs.md))
are the final recommendations.

## Usage

``` r
mk_recommend_songs(
  profile = NULL,
  n_seed_artists = 5,
  n_similar_per_artist = 5,
  n_top_genres = 15,
  n_candidate_artists = 10,
  n_songs_per_artist = 5,
  storefront = NULL,
  delay = 0.1,
  creds = mk_credentials()
)
```

## Arguments

- profile:

  A taste profile from
  [`mk_taste_profile()`](https://davidbrocker.github.io/musickitr/reference/mk_taste_profile.md).
  Built fresh if omitted.

- n_seed_artists:

  How many of the profile's top artists to expand outward from.

- n_similar_per_artist:

  Max similar artists to pull per seed (Apple returns up to 10).

- n_top_genres:

  How many of the profile's top genres to score candidates against
  (keeps scoring focused on the listener's actual center of gravity
  rather than long-tail one-off genres).

- n_candidate_artists:

  How many top-scoring candidate artists to pull songs from.

- n_songs_per_artist:

  Max songs to pull per candidate artist.

- storefront:

  Storefront code, e.g. `"us"`. Defaults to `creds$storefront`.

- delay:

  Seconds to pause between API calls (see
  [`mk_similarity_graph()`](https://davidbrocker.github.io/musickitr/reference/mk_similarity_graph.md)).

- creds:

  A credentials list from
  [`mk_credentials()`](https://davidbrocker.github.io/musickitr/reference/mk_credentials.md),
  including a `user_token` (needed by
  [`mk_taste_profile()`](https://davidbrocker.github.io/musickitr/reference/mk_taste_profile.md)
  if `profile` isn't supplied).

## Value

A tibble of recommended songs (same columns as
[`mk_song()`](https://davidbrocker.github.io/musickitr/reference/mk_song.md)),
plus `source_artist` (which candidate artist it came from) and `score`
(that artist's genre-overlap score against the profile), sorted by score
descending.

## Details

Seed artists already present in the taste profile are excluded from the
candidate pool, so this surfaces new artists rather than just echoing
songs already in the library.

## Examples

``` r
if (FALSE) { # \dontrun{
mk_recommend_songs()
} # }
```
