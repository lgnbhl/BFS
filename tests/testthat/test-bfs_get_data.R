test_that("bfs_get_asset_metadata() works", {
  expect_identical(class(bfs_get_asset_metadata(number_asset = 24367729)), "list")
})
