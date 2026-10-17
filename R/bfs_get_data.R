#' Get a BFS dataset
#'
#' Download a dataset from the PXWeb API of the BFS with its BFS number.
#' Find the BFS number with [bfs_get_catalog_data()] or on the BFS website.
#'
#' Large datasets can exceed the limits of the API: select only the data you
#' need with `query`, or download the whole file with [bfs_download_asset()].
#'
#' The PXWeb API is the API of STAT-TAB, which the BFS is replacing with the
#' Swiss Stats Explorer: check first if the statistic is on
#' <https://stats.swiss/> and use [bfs_get_sse_data()].
#'
#' @param number_bfs The BFS number of a dataset, e.g.
#'   `"px-x-1502040100_131"`.
#' @param language Language of the dataset: `"de"` (default), `"fr"`, `"it"`
#'   or `"en"`.
#' @param query Optional selection of the data: a named list with the
#'   variable codes as names and the value codes as values (columns `code`
#'   and `values` of [bfs_get_metadata()]), e.g.
#'   `list(Jahr = c("40", "41"), Geschlecht = "*")`. `"*"` selects all values.
#'   A variable not in `query` is left out of the result (totals over it),
#'   if the dataset allows it. If `NULL` (default), the whole dataset is
#'   downloaded.
#' @param column_name_type Column names as `"text"` (label, default) or
#'   `"code"`.
#' @param variable_value_type Values as `"text"` (label, default) or `"code"`.
#' @param clean_names If `TRUE`, clean the column names with
#'   [janitor::clean_names()].
#' @param delay Optional number of seconds to wait before downloading the
#'   data, to avoid "Too Many Requests" errors when calling the API in a loop.
#'
#' @importFrom magrittr %>%
#'
#' @seealso [bfs_get_catalog_data()], [bfs_get_metadata()],
#'   [bfs_get_data_comments()]
#'
#' @return A tibble. Returns `NULL` if there is no internet connection.
#'
#' @examplesIf interactive()
#' # whole dataset
#' bfs_get_data(number_bfs = "px-x-1502040100_131", language = "en")
#'
#' # only some years and levels of study
#' bfs_get_data(
#'   number_bfs = "px-x-1502040100_131",
#'   language = "en",
#'   query = list(Jahr = c("40", "41"), Studienstufe = c("2", "3"))
#' )
#'
#' @export
bfs_get_data <- function(number_bfs, language = "de", query = NULL, column_name_type = "text", variable_value_type = "text", clean_names = FALSE, delay = NULL) {
  language <- match.arg(arg = language, choices = c("de", "fr", "it", "en"))
  # fail gracefully if no internet connection
  if (!curl::has_internet()) {
    message("No internet connection")
    return(NULL)
  }
  pxweb_api_url <- pxweb_bfs_url(number_bfs, language)
  pxq <- pxweb_bfs_query(number_bfs, language, query = query, delay = delay)
  df_pxweb <- pxweb::pxweb_get_data(url = pxweb_api_url, query = pxq, column.name.type = column_name_type, variable.value.type = variable_value_type) %>%
    abort_on_http_error()
  tbl <- tibble::as_tibble(df_pxweb, .name_repair = "minimal")
  if (clean_names) {
    tbl <- janitor::clean_names(tbl)
  }
  return(tbl)
}
