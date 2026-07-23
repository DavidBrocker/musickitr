#' Fetch a single artist by catalog ID
#'
#' @param id Catalog artist ID.
#' @param storefront Storefront code, e.g. `"us"`. Defaults to
#'   `creds$storefront`.
#' @param creds A credentials list from [mk_credentials()].
#' @return A one-row tibble, same shape as the `artists` tibble returned
#'   by [mk_search()].
#' @examples
#' \dontrun{
#' mk_artist("623897863") # Bad Suns
#' }
#' @export
mk_artist <- function(id, storefront = NULL, creds = mk_credentials()) {
  sf <- storefront %||% creds$storefront
  resp <- mk_get(paste0("/v1/catalog/", sf, "/artists/", id), creds = creds)
  mk_tidy_artists(resp$data)
}

#' Find artists similar to a given artist
#'
#' Wraps the Apple Music "similar artists" view
#' (`/v1/catalog/{storefront}/artists/{id}/view/similar-artists`) --
#' undocumented in Apple's official REST reference, but confirmed stable
#' and callable with a plain developer token. It's the same relationship
#' the MusicMatchup app already uses via native MusicKit's
#' `Artist.similarArtists`. Since the Catalog API has no numeric
#' popularity score, this is the closest thing to a recommendation
#' signal available for a given artist.
#'
#' @param id Catalog artist ID (e.g. from [mk_search()]'s `id` column).
#' @param storefront Storefront code, e.g. `"us"`. Defaults to
#'   `creds$storefront`.
#' @param creds A credentials list from [mk_credentials()].
#' @return A tibble of similar artists, same shape as the `artists`
#'   tibble returned by [mk_search()].
#' @examples
#' \dontrun{
#' mk_similar_artists("623897863") # Bad Suns
#' }
#' @export
mk_similar_artists <- function(id, storefront = NULL, creds = mk_credentials()) {
  sf <- storefront %||% creds$storefront

  resp <- mk_get(
    paste0("/v1/catalog/", sf, "/artists/", id, "/view/similar-artists"),
    creds = creds
  )

  mk_tidy_artists(resp$data)
}
