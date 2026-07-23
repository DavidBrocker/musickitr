test_that("mk_similarity_graph respects its caps and returns a sane shape", {
  skip_if(identical(Sys.getenv("MUSICKIT_TEAM_ID"), ""), "no MusicKit credentials in this environment")

  graph <- mk_similarity_graph("623897863", hops = 2, limit_per_artist = 5, max_nodes = 150) # Bad Suns

  expect_true(all(c("nodes", "edges") %in% names(graph)))
  expect_true(all(c("id", "name", "genres", "url", "hop") %in% names(graph$nodes)))
  expect_true(all(c("from", "to", "similarity") %in% names(graph$edges)))

  # seed is present, at hop 0, and not duplicated
  expect_equal(sum(graph$nodes$id == "623897863"), 1)
  expect_equal(graph$nodes$hop[graph$nodes$id == "623897863"], 0)

  expect_lte(nrow(graph$nodes), 150)
  expect_true(all(graph$edges$similarity >= 0 & graph$edges$similarity <= 1))

  # every edge endpoint should correspond to a discovered node
  expect_true(all(graph$edges$from %in% graph$nodes$id))
  expect_true(all(graph$edges$to %in% graph$nodes$id))
})

test_that("mk_similarity_graph enforces a small max_nodes cap", {
  skip_if(identical(Sys.getenv("MUSICKIT_TEAM_ID"), ""), "no MusicKit credentials in this environment")

  graph <- mk_similarity_graph("623897863", hops = 2, limit_per_artist = 5, max_nodes = 6, delay = 0)

  expect_lte(nrow(graph$nodes), 6)
})
