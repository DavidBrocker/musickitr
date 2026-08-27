# Fetch songs in the user's library

Wraps `GET /v1/me/library/songs`. Library songs carry the same shape as
catalog songs (name, artistName, genreNames, ...) but no `url`, since
they're personal library entries rather than public catalog pages – that
column comes back `NA`.

## Usage

``` r
mk_library_songs(limit = 100, creds = mk_credentials())
```

## Arguments

- limit:

  Max songs to fetch (Apple's ceiling is 100 per page).

- creds:

  A credentials list from
  [`mk_credentials()`](https://davidbrocker.github.io/musickitr/reference/mk_credentials.md),
  including a `user_token` (see
  [`require_user_token()`](https://davidbrocker.github.io/musickitr/reference/require_user_token.md)).

## Value

A tibble, same shape as
[`mk_song()`](https://davidbrocker.github.io/musickitr/reference/mk_song.md)'s
return value.

## Details

Apple caps this endpoint at 100 items per request; this wraps a single
page rather than following pagination, so a library larger than `limit`
will be truncated. Fine for building a taste profile (which just needs a
representative sample), not a full library export.

## Examples

``` r
if (FALSE) { # \dontrun{
mk_library_songs(limit = 50)
} # }
```
