# Collapse a list-column into a single delimited string column

Apple Music API resources often carry multi-value fields (like
`genreNames`) that jsonlite parses into list-columns – one cell holding
a character vector. Most tidy workflows (and every flat file writer)
want a single string instead.

## Usage

``` r
mk_collapse(x, collapse = ", ")
```

## Arguments

- x:

  A list-column (list of character vectors).

- collapse:

  Delimiter to join multiple values with.

## Value

A character vector, one string per element of `x`.
