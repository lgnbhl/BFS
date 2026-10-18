#' List the datasets of the Swiss Stats Explorer
#'
#' List the datasets (dataflows) of the Swiss Stats Explorer (SSE) API
#' (<https://stats.swiss/>), to find the id of a dataset for
#' [bfs_sse_dimensions()] and [bfs_sse_data()].
#'
#' @param language Language of the names: `"de"` (default), `"fr"`, `"it"`
#'   or `"en"`.
#'
#' @returns A tibble with one row per version of each dataset, the latest
#'   version first:
#' \describe{
#'   \item{dataset}{The id of the dataset, e.g. `"DF_LWZ_1"`.}
#'   \item{name}{The name of the dataset.}
#'   \item{version}{The version of the dataset.}
#'   \item{agency}{The agency publishing the dataset.}
#'   \item{description}{The description of the dataset version, or `NA`, as
#'     given by the API: it can contain HTML tags such as `<br>`.}
#' }
#' Returns `NULL` if there is no internet connection.
#'
#' @author Felix Luginbuhl
#' @seealso [bfs_sse_dimensions()], [bfs_sse_data()]
#' @export
#'
#' @importFrom rlang %||%
#'
#' @examplesIf interactive()
#' datasets <- bfs_sse_datasets(language = "en")
#' datasets
#'
#' # datasets about tourism, in their name or description
#' datasets[grepl("touris", paste(datasets$name, datasets$description), ignore.case = TRUE), ]
bfs_sse_datasets <- function(language = "de") {

  language <- rlang::arg_match(language, c("de", "fr", "it", "en"))

  # fail gracefully if no internet connection
  if (!curl::has_internet()) {
    message("No internet connection")
    return(NULL)
  }

  flows <- sse_dataflows(language)
  flows[order(flows$dataset, -xtfrm(numeric_version(flows$version, strict = FALSE))), ]
}

#' Get the dimensions of a Swiss Stats Explorer dataset
#'
#' Get the dimensions of a dataset of the Swiss Stats Explorer (SSE) API
#' (<https://stats.swiss/>) and the values allowed in each dimension. Use
#' them to build the `filters` of [bfs_sse_data()].
#'
#' @param dataset The id of a dataset, e.g. `"DF_LWZ_1"`: the column
#'   `dataset` of [bfs_sse_datasets()], also shown in the URL of the dataset
#'   on <https://stats.swiss/>.
#' @param ... These dots are for future extensions and must be empty: the
#'   arguments after `dataset` must be named. The arguments of
#'   [bfs_get_sse_metadata()], such as `number_bfs`, give an error that names
#'   their new name.
#' @param language Language of the labels: `"de"` (default), `"fr"`, `"it"`
#'   or `"en"`. A label missing in this language falls back to another
#'   language.
#' @param version Version of the dataset, e.g. `"1.1.0"`: the column
#'   `version` of [bfs_sse_datasets()]. If `NULL` (default), the API uses the
#'   latest version. Set it in a data pipeline to keep the same structure
#'   when a new version is published.
#'
#' @returns A tibble with one row per value allowed in each dimension (some
#'   values may have no data):
#' \describe{
#'   \item{dimension}{The dimension id, to use as a name in `filters`.}
#'   \item{dimension_label}{The dimension label.}
#'   \item{value}{The value code, to use as a value in `filters`.}
#'   \item{value_label}{The value label.}
#'   \item{position}{The position of the dimension in the dataset.}
#'   \item{parent}{The code of the parent value in the codelist, e.g. the
#'     district of a commune and the canton of a district, or `NA`. Use it to
#'     select all the values under a value.}
#' }
#' Returns `NULL` if there is no internet connection.
#'
#' @author Felix Luginbuhl
#' @seealso [bfs_sse_datasets()], [bfs_sse_data()]
#' @export
#'
#' @examplesIf interactive()
#' dimensions <- bfs_sse_dimensions("DF_PASTA_552_MONTHLY", language = "en")
#' dimensions
#'
#' # the dimensions only
#' unique(dimensions[c("dimension", "dimension_label")])
#'
#' # the communes of the canton of Geneva: the values whose parent is a
#' # district of Geneva
#' regions <- bfs_sse_dimensions("DF_LWZ_1", language = "en")
#' districts <- regions$value[regions$parent %in% "GE"]
#' regions[regions$parent %in% districts, ]
bfs_sse_dimensions <- function(dataset, ..., language = "de", version = NULL) {

  sse_check_dots("bfs_sse_dimensions()", ...)
  sse_check_string(dataset, "dataset", null = FALSE)
  sse_check_string(version, "version")
  language <- rlang::arg_match(language, c("de", "fr", "it", "en"))

  # fail gracefully if no internet connection
  if (!curl::has_internet()) {
    message("No internet connection")
    return(NULL)
  }

  sse_structure(sse_get_structure(dataset, version, "all"), language)
}

#' Get data from the Swiss Stats Explorer
#'
#' Download the data of a dataset of the Swiss Stats Explorer (SSE) API
#' (<https://stats.swiss/>). Select the data you need with `filters`, built
#' from [bfs_sse_dimensions()].
#'
#' The data is downloaded in the SDMX-CSV format, with the labels in
#' `language` given by the API. It is smaller and faster to read than the
#' SDMX-ML format used by [bfs_get_sse_data()].
#'
#' The function sends two requests: one for the dimensions of the dataset, to
#' build the query from `filters`, and one for the data. The values in
#' `filters` are checked by the API: a value not in the dataset gives no
#' data.
#'
#' @inheritParams bfs_sse_dimensions
#' @param ... These dots are for future extensions and must be empty: the
#'   arguments after `dataset` must be named. The arguments of
#'   [bfs_get_sse_data()], such as `number_bfs` or `query`, give an error that
#'   names their new name.
#' @param filters A named list: the names are dimensions (column `dimension`
#'   of [bfs_sse_dimensions()]) and the values are value codes (column
#'   `value`), e.g. `list(FREQ = "M", COUNTRY_ORIGIN = c("CH", "AUSL"))`. A
#'   dimension not in `filters` keeps all its values. If `NULL` (default),
#'   the whole dataset is downloaded, which can be large and slow. An unknown
#'   dimension is an error, as the data wouldn't be filtered on it.
#' @param start_period,end_period Optional first and last period of the data,
#'   e.g. `"2020"` or `"2020-01"`.
#' @param first_n,last_n Optional number of first or last periods of each
#'   series (each combination of the dimensions), e.g. `last_n = 1` for the
#'   latest value. Sent to the API as the SDMX parameters
#'   `firstNObservations` and `lastNObservations`. They can be combined with
#'   `start_period` and `end_period`.
#' @param labels The values of the dimensions and attributes: `"both"`
#'   (default) to keep the codes and add a column `<dimension>_label` after
#'   each dimension, `"code"` for the codes only, or `"label"` for the labels
#'   only. Different codes can have the same label (e.g. the canton and the
#'   commune of Bern), so use `"label"` only to display the data.
#' @param attributes If `TRUE`, add the attributes of the observations after
#'   `value`, e.g. `OBS_STATUS` (status of the value, e.g. provisional). They
#'   can change from one version of a dataset to another.
#'
#' @returns A tibble with one column per dimension, named with the dimension
#'   id whatever the `language`, then `TIME_PERIOD` as text (e.g. `"2024"`,
#'   `"2024-Q1"`, `"2024-01"`), as given by the API, and the observations in
#'   the numeric `value` column. Returns `NULL` if there is no internet
#'   connection. The errors have a class, to handle them with
#'   [tryCatch()]:
#' \describe{
#'   \item{`bfs_no_records`}{No data matches the query.}
#'   \item{`bfs_sse_filter_error`}{`filters` wouldn't filter the data, e.g.
#'     an unknown dimension.}
#'   \item{`bfs_sse_argument_error`}{Another argument is not valid.}
#'   \item{`bfs_sse_dataset_error`}{The dataset or the version doesn't exist.}
#'   \item{`bfs_sse_query_error`}{The API rejects the query, e.g. a period in
#'     a wrong format or a URL too long. The error gives the message of the
#'     API.}
#'   \item{`bfs_http_error`}{The API is not available.}
#' }
#'
#' @author Felix Luginbuhl
#' @seealso [bfs_sse_datasets()], [bfs_sse_dimensions()]
#' @export
#'
#' @examplesIf interactive()
#' bfs_sse_data(
#'   "DF_PASTA_552_MONTHLY",
#'   filters = list(
#'     FREQ = "M",
#'     ACCOMMODATION_TYPE = "552001",
#'     COUNTRY_ORIGIN = c("CH", "AUSL")
#'   ),
#'   start_period = "2020",
#'   end_period = "2023",
#'   language = "en"
#' )
#'
#' # the latest vacancy rate of each canton
#' bfs_sse_data(
#'   "DF_LWZ_1",
#'   filters = list(
#'     GR_KT_GDE = c("GE", "ZH", "BE"),
#'     WOHN_ANZAHL = "_T",
#'     LEERWOHN_TYP = "_T",
#'     MEASURE_DIMENSION = "RATE"
#'   ),
#'   last_n = 1,
#'   language = "en"
#' )
bfs_sse_data <- function(dataset, ..., filters = NULL, start_period = NULL, end_period = NULL,
                         first_n = NULL, last_n = NULL, language = "de",
                         labels = c("both", "code", "label"), attributes = FALSE, version = NULL) {

  sse_check_dots("bfs_sse_data()", ...)
  sse_check_string(dataset, "dataset", null = FALSE)
  sse_check_string(version, "version")
  sse_check_string(start_period, "start_period")
  sse_check_string(end_period, "end_period")
  sse_check_count(first_n, "first_n")
  sse_check_count(last_n, "last_n")
  sse_check_filters(filters)
  language <- rlang::arg_match(language, c("de", "fr", "it", "en"))
  labels <- rlang::arg_match(labels)

  # fail gracefully if no internet connection
  if (!curl::has_internet()) {
    message("No internet connection")
    return(NULL)
  }

  # the dimensions, to build the key, and the exact version, so the data is
  # of the same version as the dimensions
  structure <- sse_get_structure(dataset, version, "datastructure")
  keys <- sse_dimension_ids(structure)
  sse_check_filter_names(filters, keys)

  params <- sse_query_params(start_period, end_period, first_n, last_n)
  url <- paste0(sse_base_url, "/data/", sse_flow_ref(structure), "/", sse_key(filters, keys),
                if (params != "") "?", params)

  resp <- sse_request(url) %>%
    httr2::req_headers(
      Accept = paste0("application/vnd.sdmx.data+csv;version=1.0.0",
                      if (labels != "code") ";labels=both"),
      `Accept-Language` = language
    ) %>%
    sse_perform()

  content_type <- httr2::resp_content_type(resp)
  if (!identical(content_type, "application/vnd.sdmx.data+csv")) {
    rlang::abort(
      c("The SSE API returned data in an unexpected format.",
        i = paste0("Content type: ", content_type, ", expected SDMX-CSV.")),
      class = "bfs_sse_format_error",
      call = NULL
    )
  }

  # all columns as text: codes such as "001" or "NA" (Namibia) are kept.
  # Read from a file, faster than from a string for large datasets, ending
  # with a newline to avoid the warning "incomplete final line"
  path <- tempfile(fileext = ".csv")
  on.exit(unlink(path), add = TRUE)
  con <- file(path, open = "wb")
  writeBin(httr2::resp_body_raw(resp), con)
  writeBin(charToRaw("\n"), con)
  close(con)
  csv <- utils::read.csv(path, colClasses = "character", na.strings = "",
                         check.names = FALSE, encoding = "UTF-8")

  # SDMX-CSV columns: DATAFLOW, the dimensions, TIME_PERIOD, OBS_VALUE and
  # the attributes, named "<id>: <label>" with labels. Columns are taken by
  # position, as the attribute DATAFLOW has the same id as the first column
  ids <- sse_csv_code(names(csv))
  obs <- match("OBS_VALUE", ids)
  time <- match("TIME_PERIOD", ids)
  attribute_cols <- if (attributes) setdiff(which(seq_along(csv) > obs), which(ids == "DATAFLOW"))

  dat <- list()
  for (i in which(ids %in% keys)) {
    dat <- sse_add_column(dat, ids[i], csv[[i]], labels)
  }
  if (!is.na(time)) dat$TIME_PERIOD <- sse_csv_code(csv[[time]])
  dat$value <- as.numeric(csv[[obs]])
  for (i in attribute_cols) {
    dat <- sse_add_column(dat, ids[i], csv[[i]], labels)
  }

  tibble::as_tibble(dat)
}

# Add the SDMX-CSV column `x` to `dat` as codes, labels or both
sse_add_column <- function(dat, id, x, labels) {
  if (labels == "code") {
    dat[[id]] <- x
    return(dat)
  }
  code <- sse_csv_code(x)
  label <- sse_csv_label(x)
  if (labels == "label") {
    dat[[id]] <- dplyr::coalesce(label, code)
  } else {
    dat[[id]] <- code
    dat[[paste0(id, "_label")]] <- label
  }
  dat
}
