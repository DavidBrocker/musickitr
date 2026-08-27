#' Require a Music-User-Token before calling a `/v1/me/*` endpoint
#'
#' The catalog endpoints (`mk_search()`, `mk_artist()`, etc.) only need a
#' developer token, but everything under `/v1/me` -- library, heavy
#' rotation, recently played -- is scoped to a specific listener and needs
#' a Music-User-Token on top of that (see [mk_credentials()]'s
#' `MUSICKIT_USER_TOKEN` environment variable). This gives a clear error
#' up front instead of a generic 403 from Apple.
#'
#' @param creds A credentials list from [mk_credentials()].
#' @keywords internal
require_user_token <- function(creds) {
  if (is.null(creds$user_token)) {
    rlang::abort(
      c(
        "This endpoint requires a Music-User-Token.",
        i = "Set MUSICKIT_USER_TOKEN (see mk_credentials())."
      ),
      class = "musickitr_missing_user_token"
    )
  }
  invisible(TRUE)
}

#' Fetch songs in the user's library
#'
#' Wraps `GET /v1/me/library/songs`. Library songs carry the same
#' shape as catalog songs (name, artistName, genreNames, ...) but no
#' `url`, since they're personal library entries rather than public
#' catalog pages -- that column comes back `NA`.
#'
#' Apple caps this endpoint at 100 items per request; this wraps a
#' single page rather than following pagination, so a library larger
#' than `limit` will be truncated. Fine for building a taste profile
#' (which just needs a representative sample), not a full library
#' export.
#'
#' @param limit Max songs to fetch (Apple's ceiling is 100 per page).
#' @param creds A credentials list from [mk_credentials()], including a
#'   `user_token` (see [require_user_token()]).
#' @return A tibble, same shape as [mk_song()]'s return value.
#' @examples
#' \dontrun{
#' mk_library_songs(limit = 50)
#' }
#' @export
mk_library_songs <- function(limit = 100, creds = mk_credentials()) {
  require_user_token(creds)
  resp <- mk_get("/v1/me/library/songs", query = list(limit = min(limit, 100)), creds = creds)
  mk_tidy_songs(resp$data)
}

#' Fetch the user's heavy rotation content
#'
#' Wraps `GET /v1/me/history/heavy-rotation`. Unlike [mk_library_songs()],
#' this endpoint returns a mix of resource types -- songs, albums,
#' playlists, stations -- whatever Apple considers "in heavy rotation"
#' right now. Reuses [mk_tidy_songs()] as the tidier the same way
#' [mk_charts()] does for music videos: it degrades gracefully (`NA` for
#' whatever attributes a given type doesn't have), which is exactly what
#' a genre/artist taste signal needs -- playlists and stations will come
#' back with `NA` genres/artist_name and drop out of [mk_taste_profile()]
#' naturally.
#'
#' @param limit Max entries to fetch.
#' @param creds A credentials list from [mk_credentials()], including a
#'   `user_token`.
#' @return A tibble, same shape as [mk_song()]'s return value (some rows
#'   may have `NA` in song-specific columns like `album_name` if the
#'   underlying resource was an album/playlist/station).
#' @examples
#' \dontrun{
#' mk_heavy_rotation(limit = 10)
#' }
#' @export
mk_heavy_rotation <- function(limit = 10, creds = mk_credentials()) {
  require_user_token(creds)
  resp <- mk_get("/v1/me/history/heavy-rotation", query = list(limit = limit), creds = creds)
  mk_tidy_songs(resp$data)
}

#' Fetch the user's recently played tracks
#'
#' Wraps `GET /v1/me/recent/played/tracks` -- note this is a different,
#' narrower endpoint than `/v1/me/recent/played` (which returns albums,
#' playlists, and stations, not individual tracks). `types` is required
#' by the endpoint; defaults to catalog and library songs.
#'
#' @param limit Max tracks to fetch (Apple's ceiling is 30).
#' @param types Character vector of track types to include, from
#'   `"songs"`, `"library-songs"`, `"music-videos"`,
#'   `"library-music-videos"`.
#' @param creds A credentials list from [mk_credentials()], including a
#'   `user_token`.
#' @return A tibble, same shape as [mk_song()]'s return value.
#' @examples
#' \dontrun{
#' mk_recently_played_tracks(limit = 30)
#' }
#' @export
mk_recently_played_tracks <- function(limit = 30, types = c("songs", "library-songs"),
                                        creds = mk_credentials()) {
  require_user_token(creds)
  resp <- mk_get(
    "/v1/me/recent/played/tracks",
    query = list(limit = min(limit, 30), types = paste(types, collapse = ",")),
    creds = creds
  )
  mk_tidy_songs(resp$data)
}
