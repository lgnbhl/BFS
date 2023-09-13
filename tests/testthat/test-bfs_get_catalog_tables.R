test_that("bfs_get_catalog_tables() works", {
  expect_s3_class(bfs_get_catalog_tables(language = "en", title = "students"), "data.frame")
})
