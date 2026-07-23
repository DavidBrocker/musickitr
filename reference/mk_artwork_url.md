# Resolve an Apple Music artwork template into a real image URL

Apple Music artwork URLs are templates like
`".../623897863/{w}x{h}bb.jpg"` – the literal `{w}`/`{h}` placeholders
have to be substituted with actual pixel dimensions before the URL
points at a real image (e.g. for `circularImage` nodes in visNetwork).

## Usage

``` r
mk_artwork_url(template, width = 300, height = 300)
```

## Arguments

- template:

  Character vector of artwork URL templates (may contain `NA`).

- width, height:

  Pixel dimensions to request.

## Value

A character vector of resolved image URLs.
