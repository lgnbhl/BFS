test_that("bfs_get_metadata() works", {
  if (!curl::has_internet()) {
    skip("No internet connection")
  }
  df <- BFS::bfs_get_metadata(number_bfs = "px-x-1502040100_131")
  expect_s3_class(df, "data.frame")
  expect_equal(ncol(df), 7)
})
