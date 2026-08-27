# Require a Music-User-Token before calling a `/v1/me/*` endpoint

The catalog endpoints
([`mk_search()`](https://davidbrocker.github.io/musickitr/reference/mk_search.md),
[`mk_artist()`](https://davidbrocker.github.io/musickitr/reference/mk_artist.md),
etc.) only need a developer token, but everything under `/v1/me` –
library, heavy rotation, recently played – is scoped to a specific
listener and needs a Music-User-Token on top of that (see
[`mk_credentials()`](https://davidbrocker.github.io/musickitr/reference/mk_credentials.md)'s
`MUSICKIT_USER_TOKEN` environment variable). This gives a clear error up
front instead of a generic 403 from Apple.

## Usage

``` r
require_user_token(creds)
```

## Arguments

- creds:

  A credentials list from
  [`mk_credentials()`](https://davidbrocker.github.io/musickitr/reference/mk_credentials.md).
