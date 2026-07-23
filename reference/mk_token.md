# Generate an Apple Music API developer token

Builds and signs an ES256 JWT locally using your MusicKit private key –
the same token MusicKit.js/native MusicKit generates for you, but
produced entirely in R via openssl. Nothing is sent anywhere except the
final signed token, when you use it to call the API.

## Usage

``` r
mk_token(creds = mk_credentials(), ttl = 3600)
```

## Arguments

- creds:

  A credentials list from
  [`mk_credentials()`](https://davidbrocker.github.io/musickitr/reference/mk_credentials.md).
  Defaults to reading from the environment.

- ttl:

  Token lifetime in seconds. Defaults to 1 hour; Apple allows up to ~6
  months, but shorter-lived tokens are safer to generate on demand.

## Value

A signed JWT string.
