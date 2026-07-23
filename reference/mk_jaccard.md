# Jaccard similarity between two sets

\\J(A, B) = \|A \cap B\| / \|A \cup B\|\\. Useful for comparing artists
by genre overlap, or any other set-shaped feature (shared albums, shared
collaborators, etc.).

## Usage

``` r
mk_jaccard(a, b)
```

## Arguments

- a, b:

  Character vectors to compare.

## Value

A single number between 0 (no overlap) and 1 (identical sets). Returns 0
if both sets are empty.

## Examples

``` r
mk_jaccard(c("Alternative", "Rock"), c("Rock", "Indie Rock"))
#> [1] 0.3333333
```
