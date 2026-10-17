test_that("bfs_get_catalog_geodata() works", {
  skip_on_cran()
  if (!curl::has_internet()) {
    skip("No internet connection")
  }
  df_geodata <- BFS::bfs_get_catalog_geodata(include_metadata = FALSE)
  expect_s3_class(df_geodata, "data.frame")
  expect_gt(nrow(df_geodata), 1)
})

test_that("bfs_get_catalog_geodata() with metadata", {
  skip_on_cran()
  if (!curl::has_internet()) {
    skip("No internet connection")
  }
  df_geodata <- BFS::bfs_get_catalog_geodata(include_metadata = TRUE)
  expect_s3_class(df_geodata, "data.frame")
  expect_gt(nrow(df_geodata), 12)
})
