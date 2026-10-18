test_that("bfs_sse_datasets() works", {
  skip_on_cran()
  if (!curl::has_internet()) {
    skip("No internet connection")
  }
  datasets <- BFS::bfs_sse_datasets(language = "en")
  expect_named(datasets, c("dataset", "name", "version", "agency", "description"))
  expect_true("DF_LWZ_1" %in% datasets$dataset)
})

test_that("bfs_sse_dimensions() works", {
  skip_on_cran()
  if (!curl::has_internet()) {
    skip("No internet connection")
  }
  dims <- BFS::bfs_sse_dimensions("DF_LWZ_1", language = "en")
  expect_named(dims, c("dimension", "dimension_label", "value", "value_label", "position", "parent"))
  expect_true(all(c("GR_KT_GDE", "WOHN_ANZAHL", "LEERWOHN_TYP") %in% dims$dimension))
  # the city of Zurich is in a district of the canton of Zurich
  district <- dims$parent[dims$dimension == "GR_KT_GDE" & dims$value == "261"]
  expect_identical(dims$parent[dims$dimension == "GR_KT_GDE" & dims$value == district], "ZH")
  expect_error(BFS::bfs_sse_dimensions("DF_LWZ_1", version = "9.9.9"), class = "bfs_sse_dataset_error")
})

test_that("bfs_sse_data() works", {
  skip_on_cran()
  if (!curl::has_internet()) {
    skip("No internet connection")
  }
  filters <- list(GR_KT_GDE = c("ZH", "ZG"), WOHN_ANZAHL = "_T", LEERWOHN_TYP = "_T")
  df <- BFS::bfs_sse_data("DF_LWZ_1", filters = filters, start_period = 2020,
                          end_period = 2025)
  expect_s3_class(df, "tbl_df")
  expect_setequal(unique(df$GR_KT_GDE), c("ZH", "ZG"))
  expect_setequal(unique(df$GR_KT_GDE_label), c("Zürich", "Zug"))
  expect_equal(min(df$TIME_PERIOD), "2020")
  expect_equal(max(df$TIME_PERIOD), "2025")
  expect_type(df$value, "double")

  # the same observations as bfs_get_sse_data()
  rlang::local_options(lifecycle_verbosity = "quiet")
  old <- BFS::bfs_get_sse_data("DF_LWZ_1", query = filters, start_period = 2020,
                               end_period = 2025, variable_value_type = "code")
  expect_equal(sort(df$value), sort(old$value))

  # the last period of each canton
  last <- BFS::bfs_sse_data("DF_LWZ_1", filters = filters, end_period = 2025, last_n = 1,
                            labels = "code")
  expect_setequal(last$GR_KT_GDE, c("ZH", "ZG"))
  expect_true(all(last$TIME_PERIOD == "2025"))

  # the API checks the values and the periods
  expect_error(BFS::bfs_sse_data("DF_LWZ_1", filters = list(GR_KT_GDE = "XX")),
               class = "bfs_no_records")
  expect_error(BFS::bfs_sse_data("DF_LWZ_1", filters = filters, start_period = "foo"),
               class = "bfs_sse_query_error")
})
