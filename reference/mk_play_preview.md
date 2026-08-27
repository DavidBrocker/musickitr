# Play a song's preview clip, with a confirmation prompt

Neither R nor RStudio has anything resembling a native audio engine –
base R can't decode or play audio at all. Apple Music previews are
`.m4a` (AAC) files, which rules out most audio-adjacent CRAN packages as
a clean fit (tuneR/audio only handle WAV; av can decode AAC but doesn't
play it back). The practical fix is shelling out to `afplay`, the
command-line player already built into macOS, which handles `.m4a`
natively. `afplay` given the URL directly is unreliable, though – some
of Apple's CDN redirects trip it up – so this downloads the preview to a
temporary file first (via httr2, already a dependency) and plays that
instead, deleting it afterward. This is macOS-only by construction;
there's no cross-platform fallback (yet).

## Usage

``` r
mk_play_preview(song, ask = TRUE)
```

## Arguments

- song:

  A one-row tibble with `name`, `artist_name`, `album_name`, and
  `preview_url` columns – i.e. a single row from
  [`mk_song()`](https://davidbrocker.github.io/musickitr/reference/mk_song.md),
  [`mk_search()`](https://davidbrocker.github.io/musickitr/reference/mk_search.md)'s
  `songs` tibble,
  [`mk_recommend_songs()`](https://davidbrocker.github.io/musickitr/reference/mk_recommend_songs.md),
  or anything else built on
  [`mk_tidy_songs()`](https://davidbrocker.github.io/musickitr/reference/mk_tidy_songs.md)
  (which is everything song-shaped in this package).

- ask:

  Whether to prompt for confirmation before playing. Defaults to `TRUE`,
  so nothing plays without you saying yes first. If R isn't running
  interactively (`Rscript`, a knitted document), there's no one to
  answer the prompt, so playback is skipped entirely rather than
  silently proceeding.

## Value

Invisibly, `TRUE` if playback happened, `FALSE` if it was skipped
(declined at the prompt, skipped non-interactively, or `ask = FALSE` was
never actually reached because there's no preview available).

## Examples

``` r
if (FALSE) { # \dontrun{
song <- mk_song("1516773561") # "Molecules" - Aesop Rock
mk_play_preview(song)
} # }
```
