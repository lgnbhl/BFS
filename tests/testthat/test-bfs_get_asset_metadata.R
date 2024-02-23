test_that("bfs_get_asset_metadata() returns a none-empty list", {
  if (!curl::has_internet()) {
    skip("No internet connection")
  }
  asset_number_metadata <- bfs_get_asset_metadata(number_asset = "24367729")
  expect_type(asset_number_metadata, "list")
  expect_gt(length(asset_number_metadata), 1)
})

test_that("bfs_get_asset_metadata() returns a none-empty list", {
  if (!curl::has_internet()) {
    skip("No internet connection")
  }
  asset_bfs_metadata <- bfs_get_asset_metadata(number_bfs = "px-x-1502040100_131")
  expect_type(asset_bfs_metadata, "list")
  expect_gt(length(asset_bfs_metadata), 1)
})

test_that("bfs_get_asset_metadata() fails with missing arguments", {
  if (!curl::has_internet()) {
    skip("No internet connection")
  }
  expect_error(bfs_get_asset_metadata())
})

test_that("bfs_get_asset_metadata() fails with missing arguments", {
  if (!curl::has_internet()) {
    skip("No internet connection")
  }
  expect_error(bfs_get_asset_metadata(
    number_asset = "24367729",
    number_bfs = "px-x-1502040100_131"
    )
  )
})
