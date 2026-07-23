# Convert a DER-encoded ECDSA signature to fixed-length raw r\|\|s

JOSE/JWT (RFC 7518) ES256 signatures are the raw concatenation of the r
and s integers, each left-padded to the curve's coordinate length (32
bytes for P-256). OpenSSL, by contrast, emits ECDSA signatures as a DER
`SEQUENCE { INTEGER r, INTEGER s }`. This unwraps that ASN.1 structure
and repacks it into the fixed-length form the API expects.

## Usage

``` r
der_ecdsa_to_raw(der, coord_len = 32L)
```

## Arguments

- der:

  Raw vector containing a DER-encoded ECDSA signature.

- coord_len:

  Byte length of each coordinate (32 for P-256/ES256).

## Value

A raw vector of length `2 * coord_len`.
