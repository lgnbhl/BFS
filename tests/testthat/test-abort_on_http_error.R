# no request is sent: the HTTP responses are mocked
mock_429 <- function(req) httr2::response(status_code = 429, url = req$url)

test_that("an unavailable API gives an informative bfs_http_error", {
  if (!curl::has_internet()) {
    skip("No internet connection")
  }
  httr2::with_mocked_responses(mock_429, {
    expect_error(bfs_get_metadata(number_bfs = "px-x-1502040100_131"), class = "bfs_http_error")
    expect_error(bfs_get_data(number_bfs = "px-x-1502040100_131"), class = "httr2_http_429")
    expect_error(bfs_get_catalog_tables(limit = 5), "The BFS API is not available")
    expect_error(bfs_get_asset_metadata(number_asset = "24367729"), class = "bfs_http_error")
    expect_error(bfs_get_sse_metadata(number_bfs = "DF_LWZ_1"), class = "bfs_http_error")
  })
})
