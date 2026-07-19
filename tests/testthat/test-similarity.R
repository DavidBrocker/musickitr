test_that("mk_jaccard handles the basic cases", {
  expect_equal(mk_jaccard(c("a", "b"), c("b", "c")), 1 / 3)
  expect_equal(mk_jaccard(c("a", "b"), c("a", "b")), 1)
  expect_equal(mk_jaccard(c("a"), c("b")), 0)
  expect_equal(mk_jaccard(character(0), character(0)), 0)
})

test_that("mk_jaccard ignores duplicates and NAs", {
  expect_equal(mk_jaccard(c("a", "a", "b"), c("b", "b")), mk_jaccard(c("a", "b"), c("b")))
  expect_equal(mk_jaccard(c("a", NA), c("a")), 1)
})

test_that("mk_jaccard_matrix produces one row per unique pair", {
  data <- tibble::tibble(
    name = c("Artist A", "Artist B", "Artist C"),
    genres = c("Rock, Pop", "Pop, Indie", "Jazz")
  )
  result <- mk_jaccard_matrix(data)

  expect_equal(nrow(result), 3) # choose(3, 2)
  expect_true(all(c("item_a", "item_b", "similarity") %in% names(result)))
  expect_true(all(result$similarity >= 0 & result$similarity <= 1))
})
