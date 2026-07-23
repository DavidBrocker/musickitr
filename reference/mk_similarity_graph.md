# Build a similarity graph by expanding outward from a seed artist

Repeatedly calls
[`mk_similar_artists()`](https://davidbrocker.github.io/musickitr/reference/mk_similar_artists.md)
breadth-first from `seed_id`, the same "seed artist / hop" mental model
the MusicMatchup app uses. Growing one of these by hand tends to get
crowded fast – each artist returns up to 10 similar artists, so an
unbounded 2-hop expansion can explode to 100+ nodes before accounting
for overlap – so this caps both the branching factor per artist
(`limit_per_artist`) and the total graph size (`max_nodes`) by default,
favoring a graph you can actually look at over a complete one.

## Usage

``` r
mk_similarity_graph(
  seed_id,
  hops = 2,
  limit_per_artist = 5,
  max_nodes = 150,
  delay = 0.1,
  storefront = NULL,
  creds = mk_credentials()
)
```

## Arguments

- seed_id:

  Catalog ID of the artist to start from.

- hops:

  Number of hops to expand outward. Defaults to 2.

- limit_per_artist:

  Max similar artists to keep per node (Apple returns up to 10).
  Defaults to 5 to keep branching manageable.

- max_nodes:

  Hard cap on total nodes in the graph, including the seed. Expansion
  stops once reached, even mid-hop.

- delay:

  Seconds to pause between API calls, to stay polite to the rate limit
  on larger graphs. Defaults to 0.1.

- storefront:

  Storefront code, e.g. `"us"`. Defaults to `creds$storefront`.

- creds:

  A credentials list from
  [`mk_credentials()`](https://davidbrocker.github.io/musickitr/reference/mk_credentials.md).

## Value

A list with two tibbles:

- nodes:

  One row per artist: `id`, `name`, `genres`, `url`, and `hop` (0 for
  the seed).

- edges:

  One row per discovered similarity: `from`, `to`, and `similarity`
  (Jaccard overlap of the two artists' genres).

## Details

Artists already discovered are never re-expanded (so the walk terminates
even though the underlying relationship isn't a strict tree), but a
re-discovered artist still gets a new edge recorded from its new parent
– these convergence points, where two different branches both lead back
to the same artist, are usually the most interesting part of the graph.

## Examples

``` r
if (FALSE) { # \dontrun{
graph <- mk_similarity_graph("623897863", hops = 2) # Bad Suns
nrow(graph$nodes)
graph$edges
} # }
```
