test_that("Get Switzerland base map data as sf works", {
  sf_suis <- bfs_get_base_maps(geom = "suis")
  expect_s3_class(sf_suis, "sf")
  expect_equal(nrow(sf_suis), 1)
})
test_that("Get Cantons base map data as sf works", {
  sf_kant <- bfs_get_base_maps(geom = "kant")
  expect_s3_class(sf_kant, "sf")
  expect_equal(nrow(sf_kant), 26)
})
test_that("Get Canton Capitals base map data as sf works", {
  sf_stkt <- bfs_get_base_maps(geom = "stkt", type = "Pnts", category = "kk")
  expect_s3_class(sf_stkt, "sf")
  expect_gt(nrow(sf_stkt), 1)
})
test_that("Get Lake base map data as sf works", {
  sf_seen <- bfs_get_base_maps(geom = "seen", category = "11")
  expect_s3_class(sf_seen, "sf")
  expect_gt(nrow(sf_seen), 1)
})
