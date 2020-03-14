
test_that("bfs_get_metadata() returns a data frame with positive length", {
  skip_on_cran()
  meta_de <- bfs_get_metadata()
  expect_equal(class(meta_de), c("tbl_df", "tbl", "data.frame"))
  expect_true(nrow(meta_de) > 0)
})

test_that("bfs_get_dataset() returns a data frame with positive length", {
  skip_on_cran()
  meta_de <- bfs_get_metadata()
  data_bfs <- bfs_get_dataset(meta_de$url_px[1])
  expect_equal(class(data_bfs), c("tbl_df", "tbl", "data.frame"))
  expect_true(nrow(data_bfs) > 0)
})

test_that("bfs_search('kanton') returns a data frame with positive length and more than one column", {
  skip_on_cran()
  meta_de <- bfs_get_metadata()
  meta_kanton <- bfs_search(data = meta_de, string = 'kanton')
  expect_equal(class(meta_kanton), c("tbl_df", "tbl", "data.frame"))
  expect_true(nrow(meta_kanton) > 0)
  expect_true(ncol(meta_kanton) > 1)
})