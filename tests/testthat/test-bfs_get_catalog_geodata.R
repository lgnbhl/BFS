test_that("bfs_get_catalog_geodata() works", {
  df_geodata <- bfs_get_catalog_geodata(include_metadata = FALSE)
  expect_s3_class(df_geodata, "data.frame")
  expect_gt(nrow(df_geodata), 1)
})
