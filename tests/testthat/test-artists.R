test_that("mk_similar_artists returns a tidy tibble of artists", {
  skip_if(identical(Sys.getenv("MUSICKIT_TEAM_ID"), ""), "no MusicKit credentials in this environment")

  result <- mk_similar_artists("623897863") # Bad Suns

  expect_s3_class(result, "tbl_df")
  expect_true(all(c("id", "name", "genres", "url", "image_url") %in% names(result)))
  expect_gt(nrow(result), 0)
})

test_that("mk_artist resolves the artwork template to a real image URL", {
  skip_if(identical(Sys.getenv("MUSICKIT_TEAM_ID"), ""), "no MusicKit credentials in this environment")

  default_size <- mk_artist("623897863") # Bad Suns
  expect_match(default_size$image_url, "300x300bb\\.jpg$")

  custom_size <- mk_artist("623897863", image_width = 600, image_height = 640)
  expect_match(custom_size$image_url, "600x640bb\\.jpg$")
})

test_that("mk_artwork_url substitutes {w}/{h} and passes through NA", {
  template <- "https://example.com/artwork/{w}x{h}bb.jpg"
  expect_equal(mk_artwork_url(template, 300, 300), "https://example.com/artwork/300x300bb.jpg")
  expect_equal(mk_artwork_url(NA_character_, 300, 300), NA_character_)
  expect_equal(mk_artwork_url("", 300, 300), NA_character_)
})
