test_that("bfs_get_sse_data() works", { 
  if (!curl::has_internet()) {
    skip("No internet connection")
  }
  df <- BFS::bfs_get_sse_data(
    number_bfs = "DF_LWZ_1", 
    query = list(
      "GR_KT_GDE" = c("ZH", "ZG"),
      "WOHN_ANZAHL" = c("_T"),
      "LEERWOHN_TYP" = c("_T")
    ), 
    start_period = 2020, 
    end_period = 2025, 
    variable_value_type = "code"
  )
  
  expect_s3_class(df, "data.frame")
  expect_true(nrow(df) > 1)
  expect_equal(unique(df$GR_KT_GDE), c("ZH", "ZG"))
  expect_equal(min(df$TIME_PERIOD), "2020")
  expect_equal(max(df$TIME_PERIOD), "2025")
  
  df2 <- BFS::bfs_get_sse_data(
    number_bfs = "DF_LWZ_1", 
    query = list(
      "GR_KT_GDE" = c("ZH", "ZG"),
      "WOHN_ANZAHL" = c("_T"),
      "LEERWOHN_TYP" = c("_T")
    ), 
    start_period = 2020, 
    end_period = 2025, 
    variable_value_type = "text",
    column_name_type = "text",
    clean_names = TRUE
  )
  
  expect_s3_class(df2, "data.frame")
  expect_equal(nrow(df), nrow(df2))
  expect_equal(unique(df2[[2]]), c("Zürich", "Zug"))
  expect_false(identical(names(df), names(df2)))
  
  expect_message(bfs_get_sse_data("DF_SSV_POL_EXE"))
})
