test_that("bfs_download_asset() works", {
  tmp <- tempfile()
  asset_path <- bfs_download_asset(number_asset = "24025646", destfile = tmp)
  expect_true(file.exists(asset_path))
})
