test_that("bfs_get_catalog_tables() returns a data.frame of 5 rows", {
  if (!curl::has_internet()) {
    skip("No internet connection")
  }
  df_tables <- bfs_get_catalog_tables(limit = 5)
  expect_s3_class(df_tables, "data.frame")
  expect_true(nrow(df_tables) == 5)
})
test_that("bfs_get_catalog_tables() using title argument", {
  if (!curl::has_internet()) {
    skip("No internet connection")
  }
  df_tables <- bfs_get_catalog_tables(title = "student", limit = 5)
  expect_s3_class(df_tables, "data.frame")
})
test_that("bfs_get_catalog_tables() using prodima argument", {
  if (!curl::has_internet()) {
    skip("No internet connection")
  }
  df_tables <- bfs_get_catalog_tables(prodima = 900210, limit = 5)
  expect_s3_class(df_tables, "data.frame")
})
