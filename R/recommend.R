#' Build a taste fingerprint from library, heavy rotation, and recent history
#'
#' There's no song- or artist-level "recommended for you" field anywhere
#' in the Apple Music API (see `vignette("exploring-endpoints")` /
#' `mk_similar_artists()`'s docs for the one similarity signal that does
#' exist, at the artist level only). This builds the same kind of
#' genre/artist frequency profile by hand, combining three signals of
#' different recency: the whole library ([mk_library_songs()], long-term),
#' heavy rotation ([mk_heavy_rotation()], medium-term), and recently
#' played tracks ([mk_recently_played_tracks()], short-term). Rows with
#' no usable genre/artist data (playlists, stations pulled in via heavy
#' rotation) drop out naturally rather than erroring.
#'
#' @param limit_library Max library songs to sample (see
#'   [mk_library_songs()]).
#' @param limit_heavy_rotation Max heavy rotation entries to sample.
#' @param limit_recent Max recently played tracks to sample.
#' @param creds A credentials list from [mk_credentials()], including a
#'   `user_token`.
#' @return A list with three elements: `genres` (tibble of `genre`,
#'   `weight`, sorted descending), `artists` (tibble of `artist_name`,
#'   `weight`, sorted descending), and `n_tracks` (how many rows fed the
#'   profile, across all three sources).
#' @examples
#' \dontrun{
#' profile <- mk_taste_profile()
#' profile$genres
#' profile$artists
#' }
#' @export
mk_taste_profile <- function(limit_library = 200, limit_heavy_rotation = 10,
                              limit_recent = 30, creds = mk_credentials()) {
  library_songs <- tryCatch(
    mk_library_songs(limit = limit_library, creds = creds),
    error = function(e) tibble::tibble()
  )
  heavy <- tryCatch(
    mk_heavy_rotation(limit = limit_heavy_rotation, creds = creds),
    error = function(e) tibble::tibble()
  )
  recent <- tryCatch(
    mk_recently_played_tracks(limit = limit_recent, creds = creds),
    error = function(e) tibble::tibble()
  )

  combined <- dplyr::bind_rows(library_songs, heavy, recent)

  if (nrow(combined) == 0) {
    return(list(
      genres = tibble::tibble(genre = character(), weight = integer()),
      artists = tibble::tibble(artist_name = character(), weight = integer()),
      n_tracks = 0L
    ))
  }

  has_genres <- !is.na(combined$genres) & nzchar(combined$genres)
  genre_tokens <- unlist(strsplit(combined$genres[has_genres], ", ", fixed = TRUE))
  genres <- dplyr::count(
    tibble::tibble(genre = genre_tokens),
    .data$genre,
    sort = TRUE,
    name = "weight"
  )

  artists <- dplyr::count(
    dplyr::filter(combined, !is.na(.data$artist_name), nzchar(.data$artist_name)),
    .data$artist_name,
    sort = TRUE,
    name = "weight"
  )

  list(genres = genres, artists = artists, n_tracks = nrow(combined))
}

#' Fetch an artist's top songs
#'
#' Wraps the Apple Music "top songs" view
#' (`/v1/catalog/{storefront}/artists/{id}/view/top-songs`) -- songs
#' associated with the artist based on popularity in the current
#' storefront, the closest thing to a "start here" list for an artist
#' since there's no numeric popularity score to sort by directly.
#'
#' @param id Catalog artist ID (e.g. from [mk_search()]'s `id` column).
#' @param limit Max songs to fetch.
#' @param storefront Storefront code, e.g. `"us"`. Defaults to
#'   `creds$storefront`.
#' @param creds A credentials list from [mk_credentials()].
#' @return A tibble, same shape as [mk_song()]'s return value.
#' @examples
#' \dontrun{
#' mk_artist_top_songs("623897863") # Bad Suns
#' }
#' @export
mk_artist_top_songs <- function(id, limit = 10, storefront = NULL, creds = mk_credentials()) {
  sf <- storefront %||% creds$storefront
  resp <- mk_get(
    paste0("/v1/catalog/", sf, "/artists/", id, "/view/top-songs"),
    query = list(limit = limit),
    creds = creds
  )
  mk_tidy_songs(resp$data)
}

#' Recommend songs based on a listener's taste profile
#'
#' The pipeline this stitches together, end to end: take the listener's
#' most-played artists from [mk_taste_profile()], resolve each to a
#' catalog ID via [mk_search()] (library/history endpoints only return
#' artist *names*, not catalog IDs, unless you separately request the
#' `artists` relationship), expand each one hop outward with
#' [mk_similar_artists()] -- the same seed/hop mental model
#' [mk_similarity_graph()] uses -- then score every candidate artist
#' surfaced that way by genre overlap with the profile via [mk_jaccard()].
#' Candidates surfaced by more than one seed artist (the graph's
#' "convergence points") get a small bonus, on the theory that an artist
#' your library reaches from multiple directions is a stronger signal
#' than one reached from a single artist. The top-scoring candidate
#' artists' top songs ([mk_artist_top_songs()]) are the final
#' recommendations.
#'
#' Seed artists already present in the taste profile are excluded from
#' the candidate pool, so this surfaces new artists rather than just
#' echoing songs already in the library.
#'
#' @param profile A taste profile from [mk_taste_profile()]. Built fresh
#'   if omitted.
#' @param n_seed_artists How many of the profile's top artists to expand
#'   outward from.
#' @param n_similar_per_artist Max similar artists to pull per seed
#'   (Apple returns up to 10).
#' @param n_top_genres How many of the profile's top genres to score
#'   candidates against (keeps scoring focused on the listener's actual
#'   center of gravity rather than long-tail one-off genres).
#' @param n_candidate_artists How many top-scoring candidate artists to
#'   pull songs from.
#' @param n_songs_per_artist Max songs to pull per candidate artist.
#' @param storefront Storefront code, e.g. `"us"`. Defaults to
#'   `creds$storefront`.
#' @param delay Seconds to pause between API calls (see
#'   [mk_similarity_graph()]).
#' @param creds A credentials list from [mk_credentials()], including a
#'   `user_token` (needed by [mk_taste_profile()] if `profile` isn't
#'   supplied).
#' @return A tibble of recommended songs (same columns as [mk_song()]),
#'   plus `source_artist` (which candidate artist it came from) and
#'   `score` (that artist's genre-overlap score against the profile),
#'   sorted by score descending.
#' @examples
#' \dontrun{
#' mk_recommend_songs()
#' }
#' @export
mk_recommend_songs <- function(profile = NULL, n_seed_artists = 5,
                                n_similar_per_artist = 5, n_top_genres = 15,
                                n_candidate_artists = 10, n_songs_per_artist = 5,
                                storefront = NULL, delay = 0.1,
                                creds = mk_credentials()) {
  if (is.null(profile)) profile <- mk_taste_profile(creds = creds)

  if (nrow(profile$artists) == 0) {
    rlang::abort(
      "Taste profile has no artist data to seed recommendations from.",
      class = "musickitr_empty_profile"
    )
  }

  profile_genres <- utils::head(profile$genres$genre, n_top_genres)
  known_artist_names <- profile$artists$artist_name
  seed_names <- utils::head(profile$artists$artist_name, n_seed_artists)

  seed_ids <- purrr::map_chr(seed_names, function(nm) {
    hit <- tryCatch(
      mk_search(nm, types = "artists", storefront = storefront, limit = 1, creds = creds),
      error = function(e) list(artists = tibble::tibble())
    )
    if (delay > 0) Sys.sleep(delay)
    if (is.null(hit$artists) || nrow(hit$artists) == 0) return(NA_character_)
    hit$artists$id[1]
  })
  seed_ids <- unique(seed_ids[!is.na(seed_ids)])

  if (length(seed_ids) == 0) {
    rlang::abort(
      "Couldn't resolve any of the profile's top artists to a catalog ID.",
      class = "musickitr_no_seed_artists"
    )
  }

  candidates <- tibble::tibble(id = character(), name = character(), genres = character(), n_sources = integer())

  for (seed_id in seed_ids) {
    similar <- tryCatch(
      mk_similar_artists(seed_id, storefront = storefront, creds = creds),
      error = function(e) tibble::tibble()
    )
    if (delay > 0) Sys.sleep(delay)
    if (nrow(similar) == 0) next

    similar <- utils::head(similar, n_similar_per_artist)
    # Name-based, not ID-based: library/history endpoints only surface
    # artist names, so this is the only cross-reference available. A
    # false-positive exclusion on an ambiguous common name is possible
    # but low-stakes here (worst case, one fewer candidate considered).
    similar <- similar[!(similar$name %in% known_artist_names), , drop = FALSE]
    if (nrow(similar) == 0) next

    for (i in seq_len(nrow(similar))) {
      row <- similar[i, ]
      existing <- which(candidates$id == row$id)
      if (length(existing) > 0) {
        candidates$n_sources[existing] <- candidates$n_sources[existing] + 1L
      } else {
        candidates <- dplyr::bind_rows(candidates, tibble::tibble(
          id = row$id, name = row$name, genres = row$genres, n_sources = 1L
        ))
      }
    }
  }

  if (nrow(candidates) == 0) {
    rlang::abort(
      "No new candidate artists turned up from the profile's seed artists.",
      class = "musickitr_no_candidates"
    )
  }

  candidates$score <- purrr::map_dbl(candidates$genres, function(g) {
    mk_jaccard(profile_genres, strsplit(g, ", ", fixed = TRUE)[[1]])
  })
  # Small convergence bonus: an artist reached from multiple seed artists
  # is a stronger signal than one reached from just one (same idea as the
  # "convergence points" called out in mk_similarity_graph()'s docs).
  candidates$score <- candidates$score + 0.05 * (candidates$n_sources - 1)

  top_candidates <- utils::head(
    candidates[order(-candidates$score), , drop = FALSE],
    n_candidate_artists
  )

  songs <- purrr::map2(top_candidates$id, top_candidates$name, function(cid, cname) {
    s <- tryCatch(
      mk_artist_top_songs(cid, limit = n_songs_per_artist, storefront = storefront, creds = creds),
      error = function(e) tibble::tibble()
    )
    if (delay > 0) Sys.sleep(delay)
    if (nrow(s) == 0) return(NULL)
    s$source_artist <- cname
    s$score <- top_candidates$score[top_candidates$id == cid][1]
    s
  })

  result <- dplyr::bind_rows(purrr::compact(songs))
  if (nrow(result) == 0) {
    rlang::abort(
      "None of the candidate artists had any top songs to recommend.",
      class = "musickitr_no_recommendations"
    )
  }
  result[order(-result$score), , drop = FALSE]
}
