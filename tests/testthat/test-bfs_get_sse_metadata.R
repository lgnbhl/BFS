test_that("bfs_get_sse_metadata() works", {
  skip_on_cran()
  if (!curl::has_internet()) {
    skip("No internet connection")
  }
  meta <- BFS::bfs_get_sse_metadata(number_bfs = "DF_LWZ_1", language = "en")
  expect_s3_class(meta, "data.frame")
  expect_true(nrow(meta) > 1)
  expect_equal(ncol(meta), 5)
})
