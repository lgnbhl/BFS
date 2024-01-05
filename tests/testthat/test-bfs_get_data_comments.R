test_that("bfs_get_data_comments() works", {
  df <- BFS::bfs_get_data_comments(
    number_bfs = "px-x-1502040100_131", 
    language = "en", 
    delay = 10
  )
  expect_s3_class(df, "data.frame")
})
test_that("bfs_get_data_comments() query argument", {
  df <- BFS::bfs_get_data_comments(
    number_bfs = "px-x-1502040100_131", 
    language = "en", 
    delay = 10,
    query = list(
      "Jahr" = c("40", "41"),
      "Studienstufe" = c("2", "3"),
      "Geschlecht" = c("0", "1")
    ))
  expect_s3_class(df, "data.frame")
})
test_that("bfs_get_data_comments() query argument not list", {
  expect_error(BFS::bfs_get_data_comments(
    number_bfs = "px-x-1502040100_131", 
    language = "en", 
    delay = 10,
    query = data.frame()
  ))
})