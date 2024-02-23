test_that("bfs_get_catalog() returns a none-empty data.frame", {
  if (!curl::has_internet()) {
    skip("No internet connection")
  }
  df_catalog_data <- BFS::bfs_get_catalog()
  expect_s3_class(df_catalog_data, "data.frame")
  expect_true(nrow(df_catalog_data) > 1)
})