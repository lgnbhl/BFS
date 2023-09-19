test_that("bfs_get_catalog_tables() returns a none-empty data.frame", {
  df_tables <- bfs_get_catalog_tables(prodima = c(900210, 900212), skip_limit = FALSE)
  expect_s3_class(df_tables, "data.frame")
  expect_equal(nrow(df_tables), 40)
})
