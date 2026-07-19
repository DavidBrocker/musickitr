#' Read MusicKit credentials from environment variables
#'
#' Looks for `MUSICKIT_TEAM_ID`, `MUSICKIT_KEY_ID`, and
#' `MUSICKIT_PRIVATE_KEY_PATH` (plus optional `MUSICKIT_STOREFRONT` and
#' `MUSICKIT_USER_TOKEN`). Bring your own credentials from an Apple
#' Developer Program membership -- musickitr never stores or transmits
#' them anywhere but directly to Apple.
#'
#' @return A list with `team_id`, `key_id`, `private_key_path`,
#'   `storefront`, and `user_token`.
#' @export
mk_credentials <- function() {
  team_id <- Sys.getenv("MUSICKIT_TEAM_ID")
  key_id <- Sys.getenv("MUSICKIT_KEY_ID")
  key_path <- Sys.getenv("MUSICKIT_PRIVATE_KEY_PATH")

  missing <- c(
    if (identical(team_id, "")) "MUSICKIT_TEAM_ID",
    if (identical(key_id, "")) "MUSICKIT_KEY_ID",
    if (identical(key_path, "")) "MUSICKIT_PRIVATE_KEY_PATH"
  )
  if (length(missing) > 0) {
    rlang::abort(
      c(
        "Missing MusicKit credentials.",
        i = paste("Set:", paste(missing, collapse = ", "))
      ),
      class = "musickitr_missing_credentials"
    )
  }

  list(
    team_id = team_id,
    key_id = key_id,
    private_key_path = path.expand(key_path),
    storefront = Sys.getenv("MUSICKIT_STOREFRONT", "us"),
    user_token = if (identical(Sys.getenv("MUSICKIT_USER_TOKEN"), "")) NULL else Sys.getenv("MUSICKIT_USER_TOKEN")
  )
}

#' Generate an Apple Music API developer token
#'
#' Builds and signs an ES256 JWT locally using your MusicKit private key --
#' the same token MusicKit.js/native MusicKit generates for you, but
#' produced entirely in R via \pkg{openssl}. Nothing is sent anywhere
#' except the final signed token, when you use it to call the API.
#'
#' @param creds A credentials list from [mk_credentials()]. Defaults to
#'   reading from the environment.
#' @param ttl Token lifetime in seconds. Defaults to 1 hour; Apple allows
#'   up to ~6 months, but shorter-lived tokens are safer to generate
#'   on demand.
#' @return A signed JWT string.
#' @export
mk_token <- function(creds = mk_credentials(), ttl = 3600) {
  header <- list(alg = "ES256", kid = creds$key_id)
  now <- as.integer(Sys.time())
  payload <- list(iss = creds$team_id, iat = now, exp = now + as.integer(ttl))

  signing_input <- paste(
    base64url_encode(jsonlite::toJSON(header, auto_unbox = TRUE)),
    base64url_encode(jsonlite::toJSON(payload, auto_unbox = TRUE)),
    sep = "."
  )

  key <- openssl::read_key(creds$private_key_path)
  der_signature <- openssl::signature_create(
    charToRaw(signing_input),
    hash = openssl::sha256,
    key = key
  )
  raw_signature <- der_ecdsa_to_raw(der_signature, coord_len = 32L)

  paste(signing_input, base64url_encode(raw_signature), sep = ".")
}

base64url_encode <- function(x) {
  if (is.character(x)) x <- charToRaw(x)
  out <- openssl::base64_encode(x)
  out <- gsub("+", "-", out, fixed = TRUE)
  out <- gsub("/", "_", out, fixed = TRUE)
  gsub("=+$", "", out)
}

#' Convert a DER-encoded ECDSA signature to fixed-length raw r||s
#'
#' JOSE/JWT (RFC 7518) ES256 signatures are the raw concatenation of the
#' r and s integers, each left-padded to the curve's coordinate length
#' (32 bytes for P-256). OpenSSL, by contrast, emits ECDSA signatures as
#' a DER `SEQUENCE { INTEGER r, INTEGER s }`. This unwraps that ASN.1
#' structure and repacks it into the fixed-length form the API expects.
#'
#' @param der Raw vector containing a DER-encoded ECDSA signature.
#' @param coord_len Byte length of each coordinate (32 for P-256/ES256).
#' @return A raw vector of length `2 * coord_len`.
#' @keywords internal
der_ecdsa_to_raw <- function(der, coord_len = 32L) {
  stopifnot(der[1] == as.raw(0x30))
  pos <- 3L # skip SEQUENCE tag + length byte

  read_integer <- function(bytes, pos) {
    stopifnot(bytes[pos] == as.raw(0x02))
    len <- as.integer(bytes[pos + 1L])
    start <- pos + 2L
    value <- bytes[start:(start + len - 1L)]
    # DER left-pads with 0x00 when the high bit would otherwise flag
    # the integer as negative; strip that padding byte if present.
    if (length(value) > coord_len && value[1] == as.raw(0x00)) {
      value <- value[-1]
    }
    # Left-pad with zeros if OpenSSL trimmed leading zero bytes.
    if (length(value) < coord_len) {
      value <- c(as.raw(rep(0x00, coord_len - length(value))), value)
    }
    list(value = value, next_pos = start + len)
  }

  r <- read_integer(der, pos)
  s <- read_integer(der, r$next_pos)
  c(r$value, s$value)
}
