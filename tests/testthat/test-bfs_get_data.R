test_that("bfs_get_data() works", {
  expect_true(any(class(bfs_get_data(number_bfs = "px-x-1502040100_131")) == "data.frame"))
})
