test_that("mk_similar_artists returns a tidy tibble of artists", {
  skip_if(identical(Sys.getenv("MUSICKIT_TEAM_ID"), ""), "no MusicKit credentials in this environment")

  result <- mk_similar_artists("623897863") # Bad Suns

  expect_s3_class(result, "tbl_df")
  expect_true(all(c("id", "name", "genres", "url") %in% names(result)))
  expect_gt(nrow(result), 0)
})
