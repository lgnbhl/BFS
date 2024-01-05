test_that("bfs_get_data() works", {
  df <- BFS::bfs_get_data(
    number_bfs = "px-x-1502040100_131", 
    language = "en", 
    delay = 10
  )
  expect_s3_class(df, "data.frame")
  expect_true(nrow(df) > 1)
})
test_that("bfs_get_data() query argument", {
  df <- BFS::bfs_get_data(
    number_bfs = "px-x-1502040100_131", 
    language = "en", 
    delay = 10,
    query = list(
      "Jahr" = c("40", "41"),
      "Studienstufe" = c("2", "3"),
      "Geschlecht" = c("0", "1")
    ))
  expect_s3_class(df, "data.frame")
  expect_true(nrow(df) > 1)
  # arg clean_name gives different column names
  df_clean_names <- BFS::bfs_get_data(
    clean_names = TRUE,
    number_bfs = "px-x-1502040100_131", 
    language = "en", 
    delay = 10,
    query = list(
      "Jahr" = c("40", "41"),
      "Studienstufe" = c("2", "3"),
      "Geschlecht" = c("0", "1")
    ))
  expect_false(identical(names(df), names(df_clean_names)))
})
test_that("bfs_get_data() query argument not list", {
  expect_error(BFS::bfs_get_data(
    number_bfs = "px-x-1502040100_131", 
    language = "en", 
    delay = 10,
    query = data.frame()
  ))
})