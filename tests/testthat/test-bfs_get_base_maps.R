test_that("Get Switzerland base map data as sf works", {
  if (!curl::has_internet()) {
    skip("No internet connection")
  }
  sf_suis <- bfs_get_base_maps(geom = "suis")
  expect_s3_class(sf_suis, "sf")
  expect_equal(nrow(sf_suis), 1)
})
test_that("Get Cantons base map data as sf works", {
  if (!curl::has_internet()) {
    skip("No internet connection")
  }
  sf_kant <- bfs_get_base_maps(geom = "kant")
  expect_s3_class(sf_kant, "sf")
  expect_equal(nrow(sf_kant), 26)
})
test_that("Get Canton Capitals base map data as sf works", {
  if (!curl::has_internet()) {
    skip("No internet connection")
  }
  sf_stkt <- bfs_get_base_maps(geom = "stkt", type = "Pnts", category = "kk")
  expect_s3_class(sf_stkt, "sf")
  expect_gt(nrow(sf_stkt), 1)
})
test_that("Get Lake base map data as sf works", {
  if (!curl::has_internet()) {
    skip("No internet connection")
  }
  sf_seen <- bfs_get_base_maps(geom = "seen", category = "11")
  expect_s3_class(sf_seen, "sf")
  expect_gt(nrow(sf_seen), 1)
})
test_that("bfs_get_base_maps() fails with missing arguments", {
  if (!curl::has_internet()) {
    skip("No internet connection")
  }
  expect_error(BFS::bfs_get_base_maps())
})
test_that("bfs_get_base_maps() with gf_ch category", {
  if (!curl::has_internet()) {
    skip("No internet connection")
  }
  sf_suis_gf <- BFS::bfs_get_base_maps(geom = "suis", category = "gf_ch")
  expect_s3_class(sf_suis_gf, "sf")
  expect_equal(nrow(sf_suis_gf), 1)
})
test_that("bfs_get_base_maps() with 'polg' geom and date", {
  if (!curl::has_internet()) {
    skip("No internet connection")
  }
  communes_sf <- BFS::bfs_get_base_maps(geom = "polg", date = "20230101")
  expect_s3_class(communes_sf, "sf")
  expect_equal(nrow(communes_sf), 2136)
})
test_that("bfs_get_base_maps() with 'polg' geom and recent date different", {
  if (!curl::has_internet()) {
    skip("No internet connection")
  }
  sf_kant_recent <- BFS::bfs_get_base_maps(geom = "kant", most_recent = TRUE)
  sf_kant_not_recent <- BFS::bfs_get_base_maps(geom = "kant", most_recent = FALSE)
  expect_false(identical(sf_kant_recent, sf_kant_not_recent))
})
