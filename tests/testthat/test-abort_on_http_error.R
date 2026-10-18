# no request is sent: the HTTP responses are mocked
mock_429 <- function(req) httr2::response(status_code = 429, url = req$url)

test_that("an unavailable API gives an informative bfs_http_error", {
  if (!curl::has_internet()) {
    skip("No internet connection")
  }
  rlang::local_options(lifecycle_verbosity = "quiet")
  httr2::with_mocked_responses(mock_429, {
    expect_error(bfs_get_metadata(number_bfs = "px-x-1502040100_131"), class = "bfs_http_error")
    expect_error(bfs_get_data(number_bfs = "px-x-1502040100_131"), class = "httr2_http_429")
    expect_error(bfs_get_catalog_tables(limit = 5), "The BFS API is not available")
    expect_error(bfs_get_asset_metadata(number_asset = "24367729"), class = "bfs_http_error")
    expect_error(bfs_get_sse_metadata(number_bfs = "DF_LWZ_1"), class = "bfs_http_error")
  })
})

test_that("bfs_http_error keeps the fields of the original error", {
  e <- tryCatch(
    httr2::with_mocked_responses(mock_429, {
      abort_on_http_error(httr2::req_perform(httr2::request("https://example.com")))
    }),
    error = function(e) e
  )
  expect_s3_class(e, "bfs_http_error")
  expect_s3_class(e, "httr2_http_429")
  expect_identical(httr2::resp_status(e$resp), 429L)
  expect_identical(e$status, 429L)
  expect_match(conditionMessage(e), "The BFS API is not available")
})
