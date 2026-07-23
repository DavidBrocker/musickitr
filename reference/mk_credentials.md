# Read MusicKit credentials from environment variables

Looks for `MUSICKIT_TEAM_ID`, `MUSICKIT_KEY_ID`, and
`MUSICKIT_PRIVATE_KEY_PATH` (plus optional `MUSICKIT_STOREFRONT` and
`MUSICKIT_USER_TOKEN`). Bring your own credentials from an Apple
Developer Program membership – musickitr never stores or transmits them
anywhere but directly to Apple.

## Usage

``` r
mk_credentials()
```

## Value

A list with `team_id`, `key_id`, `private_key_path`, `storefront`, and
`user_token`.
