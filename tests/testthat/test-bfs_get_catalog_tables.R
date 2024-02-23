test_that("bfs_get_catalog_tables() returns a none-empty data.frame", {
  if (!curl::has_internet()) {
    skip("No internet connection")
  }
  df_tables <- bfs_get_catalog_tables(prodima = c(900210, 900212), skip_limit = FALSE)
  expect_s3_class(df_tables, "data.frame")
  expect_equal(nrow(df_tables), 40)
})
test_that("bfs_get_catalog_data() using some arguments", {
  if (!curl::has_internet()) {
    skip("No internet connection")
  }
  df_catalog_data <- bfs_get_catalog_tables(title = "studierende", prodima = c(900210, 900212), spatial_division = "Switzerland", skip_limit = FALSE)
  expect_s3_class(df_catalog_data, "data.frame")
})
