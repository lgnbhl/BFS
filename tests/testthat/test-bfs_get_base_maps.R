test_that("Get Switzerland base map data as sf works", {
  expect_true(any(class(bfs_get_base_maps(geom = "suis")) == "sf"))
  expect_equal(nrow(bfs_get_base_maps(geom = "suis")), 1)
})
test_that("Get Cantons base map data as sf works", {
  expect_true(any(class(bfs_get_base_maps(geom = "kant")) == "sf"))
  expect_equal(nrow(bfs_get_base_maps(geom = "kant")), 26)
})
test_that("Get Canton Capitals base map data as sf works", {
  expect_true(any(class(bfs_get_base_maps(geom = "stkt", type = "Pnts", category = "kk")) == "sf"))
})
test_that("Get Lake base map data as sf works", {
  expect_true(any(class(bfs_get_base_maps(geom = "seen", category = "11")) == "sf"))
})
