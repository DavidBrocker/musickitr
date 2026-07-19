#' Fetch Apple Music charts
#'
#' Chart position is the closest thing the Apple Music API offers to a
#' popularity signal (there is no numeric popularity score on artist or
#' song resources) -- so tidied chart results include a `rank` column,
#' 1-indexed by array order.
#'
#' @param types Character vector of chart types: `"songs"`, `"albums"`,
#'   or `"music-videos"`. Note: Apple does not offer an `"artists"`
#'   chart type.
#' @param storefront Storefront code, e.g. `"us"`. Defaults to
#'   `creds$storefront`.
#' @param genre Optional genre ID to scope the chart to.
#' @param limit Max entries per chart (Apple's ceiling is 200, paginated
#'   in pages of up to 50).
#' @param creds A credentials list from [mk_credentials()].
#'
#' @return A named list of tibbles, one per requested chart type, each
#'   with a `rank` column.
#' @examples
#' \dontrun{
#' mk_charts(types = "songs", limit = 50)
#' }
#' @export
mk_charts <- function(types = c("songs", "albums"), storefront = NULL,
                       genre = NULL, limit = 20, creds = mk_credentials()) {
  types <- match.arg(types, c("songs", "albums", "music-videos"), several.ok = TRUE)
  sf <- storefront %||% creds$storefront

  query <- list(types = paste(types, collapse = ","), limit = limit)
  if (!is.null(genre)) query$genre <- genre

  resp <- mk_get(paste0("/v1/catalog/", sf, "/charts"), query = query, creds = creds)

  results <- purrr::imap(resp$results, function(chart_groups, type) {
    # music-videos shares song-shaped attributes closely enough to reuse the songs tidier
    tidier <- mk_tidiers[[type]] %||% mk_tidy_songs
    entries <- chart_groups$data[[1]]
    tidied <- tidier(entries)
    if (nrow(tidied) > 0) tidied$rank <- seq_len(nrow(tidied))
    tidied
  })

  purrr::compact(results)
}
