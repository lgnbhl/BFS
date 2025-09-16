test_that("bfs_get_sse_url() works", {
  if (!curl::has_internet()) {
    skip("No internet connection")
  }
  url_data <- bfs_get_sse_url(number_bfs = "DF_LWZ_1")
  url_metadata <- bfs_get_sse_url(number_bfs = "DF_LWZ_1", metadata = TRUE)
  expect_type(url_data, "character")
  expect_false(identical(url_data, url_metadata))
  expect_error(bfs_get_sse_url(number_bfs = "non_existing"))
})
