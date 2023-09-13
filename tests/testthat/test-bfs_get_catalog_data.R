test_that("bfs_get_catalog_data() works", {
  expect_s3_class(bfs_get_catalog_data(), "data.frame")
})
