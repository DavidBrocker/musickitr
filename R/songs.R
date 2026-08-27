#' Fetch a single song by catalog ID
#'
#' @param id Catalog song ID (e.g. from [mk_search()]'s `id` column).
#' @param storefront Storefront code, e.g. `"us"`. Defaults to
#'   `creds$storefront`.
#' @param creds A credentials list from [mk_credentials()].
#' @return A one-row tibble, same shape as the `songs` tibble returned
#'   by [mk_search()] (id, name, artist_name, album_name, duration_ms,
#'   release_date, genres, url, preview_url). `preview_url` (a 30-second
#'   `.m4a` clip) feeds [mk_play_preview()]; it's `NA` for songs that
#'   don't have one.
#' @examples
#' \dontrun{
#' mk_song("1516773561") # "Molecules" - Aesop Rock
#' }
#' @export
mk_song <- function(id, storefront = NULL, creds = mk_credentials()) {
  sf <- storefront %||% creds$storefront
  resp <- mk_get(paste0("/v1/catalog/", sf, "/songs/", id), creds = creds)
  mk_tidy_songs(resp$data)
}
