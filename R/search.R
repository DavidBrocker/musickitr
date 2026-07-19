#' Search the Apple Music catalog
#'
#' @param term Search term.
#' @param types Character vector of resource types to search, from
#'   `"artists"`, `"songs"`, `"albums"`. Defaults to all three.
#' @param storefront Storefront code, e.g. `"us"`. Defaults to
#'   `creds$storefront`.
#' @param limit Max results per type (Apple's ceiling is 25).
#' @param creds A credentials list from [mk_credentials()].
#'
#' @return A named list of tibbles, one per requested type that returned
#'   results. Types with no matches are omitted.
#' @examples
#' \dontrun{
#' mk_search("Bad Suns", types = c("artists", "albums"))
#' }
#' @export
mk_search <- function(term, types = c("artists", "songs", "albums"),
                       storefront = NULL, limit = 25,
                       creds = mk_credentials()) {
  types <- match.arg(types, names(mk_tidiers), several.ok = TRUE)
  sf <- storefront %||% creds$storefront

  resp <- mk_get(
    paste0("/v1/catalog/", sf, "/search"),
    query = list(term = term, types = paste(types, collapse = ","), limit = limit),
    creds = creds
  )

  results <- purrr::imap(resp$results, function(section, type) {
    tidier <- mk_tidiers[[type]]
    if (is.null(tidier)) return(NULL)
    tidier(section$data)
  })

  purrr::compact(results)
}
