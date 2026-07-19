#' Collapse a list-column into a single delimited string column
#'
#' Apple Music API resources often carry multi-value fields (like
#' `genreNames`) that jsonlite parses into list-columns -- one cell
#' holding a character vector. Most tidy workflows (and every flat file
#' writer) want a single string instead.
#'
#' @param x A list-column (list of character vectors).
#' @param collapse Delimiter to join multiple values with.
#' @return A character vector, one string per element of `x`.
#' @export
mk_collapse <- function(x, collapse = ", ") {
  vapply(x, function(v) paste(v, collapse = collapse), character(1))
}

# Pull a column out of a data frame by name if present, else a vector of NA.
column_or_na <- function(df, name, n = nrow(df)) {
  if (name %in% names(df)) df[[name]] else rep(NA, n)
}

#' @keywords internal
mk_tidy_artists <- function(data) {
  if (is.null(data) || nrow(data) == 0) return(tibble::tibble())
  tibble::tibble(
    id = column_or_na(data, "id"),
    name = column_or_na(data, "attributes.name"),
    genres = mk_collapse(column_or_na(data, "attributes.genreNames")),
    url = column_or_na(data, "attributes.url")
  )
}

#' @keywords internal
mk_tidy_songs <- function(data) {
  if (is.null(data) || nrow(data) == 0) return(tibble::tibble())
  tibble::tibble(
    id = column_or_na(data, "id"),
    name = column_or_na(data, "attributes.name"),
    artist_name = column_or_na(data, "attributes.artistName"),
    album_name = column_or_na(data, "attributes.albumName"),
    duration_ms = column_or_na(data, "attributes.durationInMillis"),
    release_date = column_or_na(data, "attributes.releaseDate"),
    genres = mk_collapse(column_or_na(data, "attributes.genreNames")),
    url = column_or_na(data, "attributes.url")
  )
}

#' @keywords internal
mk_tidy_albums <- function(data) {
  if (is.null(data) || nrow(data) == 0) return(tibble::tibble())
  tibble::tibble(
    id = column_or_na(data, "id"),
    name = column_or_na(data, "attributes.name"),
    artist_name = column_or_na(data, "attributes.artistName"),
    release_date = column_or_na(data, "attributes.releaseDate"),
    track_count = column_or_na(data, "attributes.trackCount"),
    genres = mk_collapse(column_or_na(data, "attributes.genreNames")),
    url = column_or_na(data, "attributes.url")
  )
}

mk_tidiers <- list(
  artists = mk_tidy_artists,
  songs = mk_tidy_songs,
  albums = mk_tidy_albums
)
