test_that("bfs_get_catalog_data() returns a data.frame of 5 rows", {
  if (!curl::has_internet()) {
    skip("No internet connection")
  }
  df_catalog_data <- bfs_get_catalog_data(limit = 5)
  expect_s3_class(df_catalog_data, "data.frame")
  expect_true(nrow(df_catalog_data) == 5)
})
test_that("bfs_get_catalog_data() using some arguments", {
  if (!curl::has_internet()) {
    skip("No internet connection")
  }
  df_catalog_data <- bfs_get_catalog_data(title = "studierende", spatial_division = "Switzerland", limit = 5)
  expect_s3_class(df_catalog_data, "data.frame")
})
test_that("bfs_get_catalog_data() using order_nr argument", {
  if (!curl::has_internet()) {
    skip("No internet connection")
  }
  df_catalog_data <- bfs_get_catalog_data(order_nr = "px-x-1502040100_131")
  expect_s3_class(df_catalog_data, "data.frame")
})
test_that("bfs_get_catalog_data() using order_nr argument", {
  if (!curl::has_internet()) {
    skip("No internet connection")
  }
  df_catalog_data <- bfs_get_catalog_data(order_nr = "px-x-1502040100_131")
  expect_s3_class(df_catalog_data, "data.frame")
})
test_that("bfs_get_catalog_data() using prodima argument", {
  if (!curl::has_internet()) {
    skip("No internet connection")
  }
  df_catalog_data <- bfs_get_catalog_data(prodima = 900210, limit = 5)
  expect_s3_class(df_catalog_data, "data.frame")
})