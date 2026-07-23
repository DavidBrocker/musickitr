# Fetch Apple Music charts

Chart position is the closest thing the Apple Music API offers to a
popularity signal (there is no numeric popularity score on artist or
song resources) – so tidied chart results include a `rank` column,
1-indexed by array order.

## Usage

``` r
mk_charts(
  types = c("songs", "albums"),
  storefront = NULL,
  genre = NULL,
  limit = 20,
  creds = mk_credentials()
)
```

## Arguments

- types:

  Character vector of chart types: `"songs"`, `"albums"`, or
  `"music-videos"`. Note: Apple does not offer an `"artists"` chart
  type.

- storefront:

  Storefront code, e.g. `"us"`. Defaults to `creds$storefront`.

- genre:

  Optional genre ID to scope the chart to.

- limit:

  Max entries per chart (Apple's ceiling is 200, paginated in pages of
  up to 50).

- creds:

  A credentials list from
  [`mk_credentials()`](https://davidbrocker.github.io/musickitr/reference/mk_credentials.md).

## Value

A named list of tibbles, one per requested chart type, each with a
`rank` column.

## Examples

``` r
if (FALSE) { # \dontrun{
mk_charts(types = "songs", limit = 50)
} # }
```
