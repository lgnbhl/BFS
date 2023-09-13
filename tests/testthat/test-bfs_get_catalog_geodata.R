test_that("bfs_get_catalog_geodata() works", {
  expect_s3_class(bfs_get_catalog_geodata(include_metadata = FALSE), "data.frame")
})
