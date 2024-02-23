test_that("bfs_download_asset() works", {
  if (!curl::has_internet()) {
    skip("No internet connection")
  }
  tmp <- tempfile()
  asset_path1 <- BFS::bfs_download_asset(number_asset = "24367729", destfile = tmp)
  expect_true(file.exists(asset_path1))
  asset_path2 <- BFS::bfs_download_asset(number_bfs = "px-x-1502040100_131", destfile = tmp)
  expect_true(file.exists(asset_path2))
})
test_that("bfs_download_asset() fails with missing arguments", {
  if (!curl::has_internet()) {
    skip("No internet connection")
  }
  expect_error(bfs_download_asset())
})
test_that("bfs_download_asset() fails with missing arguments", {
  if (!curl::has_internet()) {
    skip("No internet connection")
  }
  expect_error(bfs_download_asset(
    number_asset = "24367729",
    number_bfs = "px-x-1502040100_131"
  )
  )
})
