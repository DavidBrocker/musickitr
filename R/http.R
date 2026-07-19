mk_base_url <- "https://api.music.apple.com"

#' Call an Apple Music API endpoint and return parsed JSON
#'
#' Low-level building block behind the tidy `mk_*()` functions. Useful
#' for exploring endpoints musickitr doesn't have a dedicated wrapper
#' for yet -- see `vignette("exploring-endpoints")`.
#'
#' @param path API path, e.g. `"/v1/catalog/us/search"`.
#' @param query Named list of query parameters.
#' @param creds A credentials list from [mk_credentials()].
#' @return The parsed JSON response body, as a nested list.
#' @export
mk_get <- function(path, query = list(), creds = mk_credentials()) {
  token <- mk_token(creds)

  req <- httr2::request(mk_base_url) |>
    httr2::req_url_path_append(path) |>
    httr2::req_url_query(!!!query) |>
    httr2::req_headers(Authorization = paste("Bearer", token)) |>
    httr2::req_error(is_error = function(resp) FALSE)

  if (!is.null(creds$user_token)) {
    req <- httr2::req_headers(req, "Music-User-Token" = creds$user_token)
  }

  resp <- httr2::req_perform(req)
  # flatten = TRUE mirrors jsonlite::fromJSON()'s behavior of turning
  # nested "attributes"/"relationships" objects into dotted column
  # names (e.g. attributes.name) instead of list-columns of lists.
  body <- jsonlite::fromJSON(httr2::resp_body_string(resp), flatten = TRUE)

  if (httr2::resp_status(resp) >= 400) {
    detail <- tryCatch(body$errors$detail[1], error = function(e) NULL)
    rlang::abort(
      c(
        paste("Apple Music API request failed:", httr2::resp_status(resp)),
        i = detail %||% "See response body for details."
      ),
      class = "musickitr_api_error",
      body = body
    )
  }

  body
}

`%||%` <- function(x, y) if (is.null(x)) y else x
