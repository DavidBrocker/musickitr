#' Build a similarity graph by expanding outward from a seed artist
#'
#' Repeatedly calls [mk_similar_artists()] breadth-first from `seed_id`,
#' the same "seed artist / hop" mental model the MusicMatchup app uses.
#' Growing one of these by hand tends to get crowded fast -- each artist
#' returns up to 10 similar artists, so an unbounded 2-hop expansion can
#' explode to 100+ nodes before accounting for overlap -- so this caps
#' both the branching factor per artist (`limit_per_artist`) and the
#' total graph size (`max_nodes`) by default, favoring a graph you can
#' actually look at over a complete one.
#'
#' Artists already discovered are never re-expanded (so the walk
#' terminates even though the underlying relationship isn't a strict
#' tree), but a re-discovered artist still gets a new edge recorded from
#' its new parent -- these convergence points, where two different
#' branches both lead back to the same artist, are usually the most
#' interesting part of the graph.
#'
#' @param seed_id Catalog ID of the artist to start from.
#' @param hops Number of hops to expand outward. Defaults to 2.
#' @param limit_per_artist Max similar artists to keep per node (Apple
#'   returns up to 10). Defaults to 5 to keep branching manageable.
#' @param max_nodes Hard cap on total nodes in the graph, including the
#'   seed. Expansion stops once reached, even mid-hop.
#' @param delay Seconds to pause between API calls, to stay polite to
#'   the rate limit on larger graphs. Defaults to 0.1.
#' @param storefront Storefront code, e.g. `"us"`. Defaults to
#'   `creds$storefront`.
#' @param image_width,image_height Pixel dimensions to resolve each
#'   node's artwork template to (see `image_url` in the return value).
#'   Defaults to 300x300.
#' @param creds A credentials list from [mk_credentials()].
#'
#' @return A list with two tibbles:
#'   \describe{
#'     \item{nodes}{One row per artist: `id`, `name`, `genres`, `url`,
#'       `image_url`, and `hop` (0 for the seed).}
#'     \item{edges}{One row per discovered similarity: `from`, `to`, and
#'       `similarity` (Jaccard overlap of the two artists' genres).}
#'   }
#' @examples
#' \dontrun{
#' graph <- mk_similarity_graph("623897863", hops = 2) # Bad Suns
#' nrow(graph$nodes)
#' graph$edges
#' }
#' @export
mk_similarity_graph <- function(seed_id, hops = 2, limit_per_artist = 5,
                                  max_nodes = 150, delay = 0.1,
                                  storefront = NULL, image_width = 300, image_height = 300,
                                  creds = mk_credentials()) {
  stopifnot(hops >= 1, limit_per_artist >= 1, max_nodes >= 1)

  seed <- mk_artist(
    seed_id,
    storefront = storefront,
    image_width = image_width,
    image_height = image_height,
    creds = creds
  )
  if (nrow(seed) == 0) {
    rlang::abort(
      paste("No artist found for id", seed_id),
      class = "musickitr_no_artist"
    )
  }
  seed$hop <- 0L

  nodes <- seed
  edges <- tibble::tibble(from = character(), to = character(), similarity = double())
  frontier <- seed_id

  genres_of <- function(artist_id) {
    genre_string <- nodes$genres[nodes$id == artist_id][1]
    strsplit(genre_string, ", ", fixed = TRUE)[[1]]
  }

  for (h in seq_len(hops)) {
    if (length(frontier) == 0 || nrow(nodes) >= max_nodes) break

    next_frontier <- character()

    for (parent_id in frontier) {
      if (nrow(nodes) >= max_nodes) break

      similar <- tryCatch(
        mk_similar_artists(
          parent_id,
          storefront = storefront,
          image_width = image_width,
          image_height = image_height,
          creds = creds
        ),
        error = function(e) tibble::tibble()
      )
      if (delay > 0) Sys.sleep(delay)
      if (nrow(similar) == 0) next

      similar <- utils::head(similar, limit_per_artist)
      parent_genres <- genres_of(parent_id)

      for (i in seq_len(nrow(similar))) {
        child <- similar[i, ]
        child_genres <- strsplit(child$genres, ", ", fixed = TRUE)[[1]]

        edges <- dplyr::bind_rows(edges, tibble::tibble(
          from = parent_id,
          to = child$id,
          similarity = mk_jaccard(parent_genres, child_genres)
        ))

        if (!(child$id %in% nodes$id) && nrow(nodes) < max_nodes) {
          child$hop <- h
          nodes <- dplyr::bind_rows(nodes, child)
          next_frontier <- c(next_frontier, child$id)
        }
      }
    }

    frontier <- unique(next_frontier)
  }

  list(nodes = nodes, edges = dplyr::distinct(edges, .data$from, .data$to, .keep_all = TRUE))
}
