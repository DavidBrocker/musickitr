test_that("der_ecdsa_to_raw always returns 64 bytes, across many real signatures", {
  skip_if_not_installed("openssl")
  key <- openssl::ec_keygen("P-256")

  # DER encoding trims/pads leading zero bytes based on the sign bit of
  # each integer, so signing many random messages exercises both the
  # "needs stripping" and "needs left-padding" branches organically.
  for (i in 1:50) {
    msg <- as.raw(sample(0:255, 32, replace = TRUE))
    der <- openssl::signature_create(msg, hash = openssl::sha256, key = key)
    raw_sig <- der_ecdsa_to_raw(der, coord_len = 32L)
    expect_equal(length(raw_sig), 64L)
  }
})

test_that("mk_credentials errors clearly when env vars are missing", {
  withr::local_envvar(
    MUSICKIT_TEAM_ID = "",
    MUSICKIT_KEY_ID = "",
    MUSICKIT_PRIVATE_KEY_PATH = ""
  )
  expect_error(mk_credentials(), class = "musickitr_missing_credentials")
})
