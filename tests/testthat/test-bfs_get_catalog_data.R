test_that("check bfs_get_catalog_* functions work correctly", {
  expect_equal(is.data.frame(bfs_get_catalog_data("en")), TRUE)
  expect_equal(is.data.frame(bfs_get_catalog_tables("en")), TRUE)
  expect_equal(names(bfs_get_catalog_data("de")), c("title", "language", "published", "url_bfs", "url_px"))
  expect_equal(names(bfs_get_catalog_tables("de")), c("title", "language", "published", "url_bfs", "url_table"))
})
