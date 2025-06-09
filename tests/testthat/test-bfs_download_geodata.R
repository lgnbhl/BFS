test_that("bfs_download_geodata() works", {
  if (!curl::has_internet()) {
    skip("No internet connection")
  }
  # require "rstac" R package dependency, which should be installed by the user
  skip_on_cran()
  skip_on_ci()
  tmp <- tempdir()
  catalog_geodata <- BFS::bfs_get_catalog_geodata(include_metadata = FALSE)
  asset_path <- BFS::bfs_download_geodata(collection_id = catalog_geodata$collection_id[1], output_dir = tmp)
  expect_true(file.exists(asset_path[1]))
})
test_that("bfs_download_geodata() fails with missing arguments", {
  if (!curl::has_internet()) {
    skip("No internet connection")
  }
  expect_error(bfs_download_geodata())
})
