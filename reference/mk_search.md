# Search the Apple Music catalog

Search the Apple Music catalog

## Usage

``` r
mk_search(
  term,
  types = c("artists", "songs", "albums"),
  storefront = NULL,
  limit = 25,
  creds = mk_credentials()
)
```

## Arguments

- term:

  Search term.

- types:

  Character vector of resource types to search, from `"artists"`,
  `"songs"`, `"albums"`. Defaults to all three.

- storefront:

  Storefront code, e.g. `"us"`. Defaults to `creds$storefront`.

- limit:

  Max results per type (Apple's ceiling is 25).

- creds:

  A credentials list from
  [`mk_credentials()`](https://davidbrocker.github.io/musickitr/reference/mk_credentials.md).

## Value

A named list of tibbles, one per requested type that returned results.
Types with no matches are omitted.

## Examples

``` r
if (FALSE) { # \dontrun{
mk_search("Bad Suns", types = c("artists", "albums"))
} # }
```
