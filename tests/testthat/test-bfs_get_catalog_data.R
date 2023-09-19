test_that("bfs_get_catalog_data() returns a none-empty data.frame", {
  df_catalog_data <- bfs_get_catalog_data(prodima = c(900210, 900212), skip_limit = FALSE)
  expect_s3_class(df_catalog_data, "data.frame")
  expect_equal(nrow(df_catalog_data), 40)
})
