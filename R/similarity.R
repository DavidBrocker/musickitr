#' Jaccard similarity between two sets
#'
#' \eqn{J(A, B) = |A \cap B| / |A \cup B|}. Useful for comparing artists
#' by genre overlap, or any other set-shaped feature (shared albums,
#' shared collaborators, etc.).
#'
#' @param a,b Character vectors to compare.
#' @return A single number between 0 (no overlap) and 1 (identical
#'   sets). Returns 0 if both sets are empty.
#' @examples
#' mk_jaccard(c("Alternative", "Rock"), c("Rock", "Indie Rock"))
#' @export
mk_jaccard <- function(a, b) {
  a <- unique(a[!is.na(a)])
  b <- unique(b[!is.na(b)])
  if (length(a) == 0 && length(b) == 0) return(0)
  length(intersect(a, b)) / length(union(a, b))
}

#' Pairwise Jaccard similarity matrix across a tidy tibble
#'
#' Takes a tibble like the one returned by [mk_search()] or [mk_charts()]
#' -- with an identifying column (e.g. `name`) and a delimited-string
#' column (e.g. `genres`, as produced by [mk_collapse()]) -- and returns
#' every pairwise similarity as a long tibble, ready to feed into a
#' network/graph visualization (e.g. edge weights between star nodes).
#'
#' @param data A tibble with an id column and a delimited-string column.
#' @param id_col Column of labels to compare (e.g. artist name).
#' @param set_col Column of delimiter-joined values (e.g. genres).
#' @param delim Delimiter used within `set_col`. Must match whatever
#'   [mk_collapse()] (or your own tidying) used to join the values.
#' @return A tibble with columns `item_a`, `item_b`, `similarity` -- one
#'   row per unique pair.
#' @examples
#' \dontrun{
#' artists <- mk_search("indie rock", types = "artists")$artists
#' mk_jaccard_matrix(artists, id_col = "name", set_col = "genres")
#' }
#' @export
mk_jaccard_matrix <- function(data, id_col = "name", set_col = "genres", delim = ", ") {
  ids <- data[[id_col]]
  sets <- strsplit(data[[set_col]], delim, fixed = TRUE)

  pairs <- utils::combn(seq_along(ids), 2, simplify = FALSE)
  rows <- purrr::map(pairs, function(p) {
    tibble::tibble(
      item_a = ids[p[1]],
      item_b = ids[p[2]],
      similarity = mk_jaccard(sets[[p[1]]], sets[[p[2]]])
    )
  })

  dplyr::bind_rows(rows)
}
