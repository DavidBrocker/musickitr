# Pairwise Jaccard similarity matrix across a tidy tibble

Takes a tibble like the one returned by
[`mk_search()`](https://davidbrocker.github.io/musickitr/reference/mk_search.md)
or
[`mk_charts()`](https://davidbrocker.github.io/musickitr/reference/mk_charts.md)
– with an identifying column (e.g. `name`) and a delimited-string column
(e.g. `genres`, as produced by
[`mk_collapse()`](https://davidbrocker.github.io/musickitr/reference/mk_collapse.md))
– and returns every pairwise similarity as a long tibble, ready to feed
into a network/graph visualization (e.g. edge weights between star
nodes).

## Usage

``` r
mk_jaccard_matrix(data, id_col = "name", set_col = "genres", delim = ", ")
```

## Arguments

- data:

  A tibble with an id column and a delimited-string column.

- id_col:

  Column of labels to compare (e.g. artist name).

- set_col:

  Column of delimiter-joined values (e.g. genres).

- delim:

  Delimiter used within `set_col`. Must match whatever
  [`mk_collapse()`](https://davidbrocker.github.io/musickitr/reference/mk_collapse.md)
  (or your own tidying) used to join the values.

## Value

A tibble with columns `item_a`, `item_b`, `similarity` – one row per
unique pair.

## Examples

``` r
if (FALSE) { # \dontrun{
artists <- mk_search("indie rock", types = "artists")$artists
mk_jaccard_matrix(artists, id_col = "name", set_col = "genres")
} # }
```
