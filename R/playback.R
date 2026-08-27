#' Play a song's preview clip, with a confirmation prompt
#'
#' Neither R nor RStudio has anything resembling a native audio engine --
#' base R can't decode or play audio at all. Apple Music previews are
#' `.m4a` (AAC) files, which rules out most audio-adjacent CRAN packages
#' as a clean fit (\pkg{tuneR}/\pkg{audio} only handle WAV; \pkg{av} can
#' decode AAC but doesn't play it back). The practical fix is shelling
#' out to `afplay`, the command-line player already built into macOS,
#' which handles `.m4a` natively. `afplay` given the URL directly is
#' unreliable, though -- some of Apple's CDN redirects trip it up -- so
#' this downloads the preview to a temporary file first (via
#' \pkg{httr2}, already a dependency) and plays that instead, deleting
#' it afterward. This is macOS-only by construction; there's no
#' cross-platform fallback (yet).
#'
#' @param song A one-row tibble with `name`, `artist_name`,
#'   `album_name`, and `preview_url` columns -- i.e. a single row from
#'   [mk_song()], [mk_search()]'s `songs` tibble, [mk_recommend_songs()],
#'   or anything else built on [mk_tidy_songs()] (which is everything
#'   song-shaped in this package).
#' @param ask Whether to prompt for confirmation before playing. Defaults
#'   to `TRUE`, so nothing plays without you saying yes first. If R
#'   isn't running interactively (`Rscript`, a knitted document), there's
#'   no one to answer the prompt, so playback is skipped entirely rather
#'   than silently proceeding.
#' @return Invisibly, `TRUE` if playback happened, `FALSE` if it was
#'   skipped (declined at the prompt, skipped non-interactively, or
#'   `ask = FALSE` was never actually reached because there's no preview
#'   available).
#' @examples
#' \dontrun{
#' song <- mk_song("1516773561") # "Molecules" - Aesop Rock
#' mk_play_preview(song)
#' }
#' @export
mk_play_preview <- function(song, ask = TRUE) {
  if (nrow(song) != 1) {
    rlang::abort(
      "song must be a single-row tibble -- try song[1, ] if you have a multi-row result.",
      class = "musickitr_multiple_songs"
    )
  }
  if (!identical(Sys.info()[["sysname"]], "Darwin")) {
    rlang::abort(
      c(
        "mk_play_preview() shells out to afplay, which only exists on macOS.",
        i = "On another OS, play song$preview_url yourself with your own audio tool."
      ),
      class = "musickitr_unsupported_platform"
    )
  }
  if (is.null(song$preview_url) || is.na(song$preview_url)) {
    rlang::abort(
      "This song has no preview_url to play.",
      class = "musickitr_no_preview"
    )
  }

  label <- if (!is.na(song$album_name) && nzchar(song$album_name)) {
    paste0(song$name, " — ", song$album_name)
  } else {
    paste0(song$name, " — ", song$artist_name)
  }

  if (ask) {
    if (!interactive()) {
      message("Skipping preview (not running interactively): ", label)
      return(invisible(FALSE))
    }
    play <- isTRUE(utils::askYesNo(paste0("Play preview of \"", label, "\"?")))
    if (!play) return(invisible(FALSE))
  }

  message("♪ Now playing: ", label)

  tmp <- tempfile(fileext = ".m4a")
  on.exit(unlink(tmp), add = TRUE)
  httr2::req_perform(httr2::request(song$preview_url), path = tmp)

  system2("afplay", tmp, wait = TRUE)
  invisible(TRUE)
}
