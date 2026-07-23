# musickitr

Tidy, tibble-based access to the Apple Music Catalog API — search,
charts, and a few similarity utilities for building
recommendation/matchup tools, in the spirit of
[spotifyr](https://github.com/charlie86/spotifyr).

Everything runs in native R (auth included — JWT signing uses
[`openssl`](https://cran.r-project.org/package=openssl), no external
binaries or toolchains required).

## Bring your own credentials

Apple Music access requires an active [Apple Developer
Program](https://developer.apple.com/programs/) membership. musickitr
never stores, transmits, or logs your credentials anywhere but directly
to Apple.

1.  In [developer.apple.com](https://developer.apple.com) →
    **Certificates, IDs & Profiles → Keys**, create a key with
    **MusicKit** enabled and download the `.p8` file (this is a one-time
    download — save it somewhere durable).
2.  Find your **Team ID** under **Account → Membership**.
3.  Note the **Key ID** shown on the key’s page.
4.  Set the following environment variables (e.g. in `.Renviron` or
    before launching R):

``` sh
MUSICKIT_TEAM_ID=YOUR_TEAM_ID
MUSICKIT_KEY_ID=YOUR_KEY_ID
MUSICKIT_PRIVATE_KEY_PATH=~/path/to/AuthKey_YOUR_KEY_ID.p8
MUSICKIT_STOREFRONT=us
# Optional, only needed for /v1/me/* endpoints:
# MUSICKIT_USER_TOKEN=
```

## Installation

``` r

# install.packages("remotes")
remotes::install_github("DavidBrocker/musickitr")
```

## Usage

``` r

library(musickitr)

# Search the catalog -- returns a named list of tibbles, one per type
mk_search("Bad Suns", types = c("artists", "albums"))

# Charts include a `rank` column -- the closest thing Apple's API offers
# to a popularity signal (there's no numeric popularity score on artists
# or songs, unlike Spotify)
charts <- mk_charts(types = "songs", limit = 50)

# Jaccard similarity between two genre sets
mk_jaccard(c("Alternative", "Rock"), c("Rock", "Indie Rock"))

# Pairwise similarity matrix across a whole result set -- e.g. as edge
# weights for a network/graph visualization
mk_jaccard_matrix(charts$songs, id_col = "name", set_col = "genres")

# Anything not wrapped yet: call the API directly and get raw parsed JSON
mk_get("/v1/catalog/us/genres")
```

## Status

Early scaffold —
[`mk_search()`](https://davidbrocker.github.io/musickitr/reference/mk_search.md),
[`mk_charts()`](https://davidbrocker.github.io/musickitr/reference/mk_charts.md),
[`mk_get()`](https://davidbrocker.github.io/musickitr/reference/mk_get.md),
and the Jaccard utilities are working and tested against the live API.
Contributions (additional endpoint wrappers, visualization helpers,
etc.) welcome.
