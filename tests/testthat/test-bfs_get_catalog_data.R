test_that("bfs_get_catalog_data() returns a none-empty data.frame", {
  if (!curl::has_internet()) {
    skip("No internet connection")
  }
  df_catalog_data <- bfs_get_catalog_data(prodima = c(900210, 900212), skip_limit = FALSE)
  expect_s3_class(df_catalog_data, "data.frame")
  expect_equal(nrow(df_catalog_data), 40)
})
test_that("bfs_get_catalog_data() using some arguments", {
  if (!curl::has_internet()) {
    skip("No internet connection")
  }
  df_catalog_data <- bfs_get_catalog_data(title = "studierende", prodima = c(900210, 900212), spatial_division = "Switzerland", skip_limit = FALSE)
  expect_s3_class(df_catalog_data, "data.frame")
})
test_that("bfs_get_catalog_data() using order_nr argument", {
  if (!curl::has_internet()) {
    skip("No internet connection")
  }
  df_catalog_data <- bfs_get_catalog_data(order_nr = "px-x-1502040100_131", prodima = c(900210, 900212), skip_limit = FALSE)
  expect_s3_class(df_catalog_data, "data.frame")
})
