#' Get the comments of a BFS dataset
#'
#' Get the comments (footnotes) of a dataset of the PXWeb API, e.g. on
#' provisional values or changes of definition.
#'
#' The PXWeb API is the API of STAT-TAB, which the BFS is replacing with the
#' Swiss Stats Explorer.
#'
#' @inheritParams bfs_get_data
#'
#' @seealso [bfs_get_data()]
#'
#' @return A tibble with one row per comment. Returns `NULL` if there is no
#'   internet connection.
#'
#' @examplesIf interactive()
#' bfs_get_data_comments(number_bfs = "px-x-1502040100_131", language = "en")
#'
#' @importFrom magrittr %>%
#'
#' @export
bfs_get_data_comments <- function(number_bfs, language = "de", query = NULL, clean_names = FALSE, delay = NULL) {
  language <- match.arg(arg = language, choices = c("de", "fr", "it", "en"))
  # fail gracefully if no internet connection
  if (!curl::has_internet()) {
    message("No internet connection")
    return(NULL)
  }
  pxweb_api_url <- pxweb_bfs_url(number_bfs, language)
  pxq <- pxweb_bfs_query(number_bfs, language, query = query, delay = delay)
  df_pxweb <- pxweb::pxweb_get(url = pxweb_api_url, query = pxq) %>%
    abort_on_http_error()
  comments <- pxweb::pxweb_data_comments(df_pxweb)
  df_comments <- as.data.frame(comments)
  tbl <- tibble::as_tibble(df_comments)
  if (clean_names) {
    tbl <- janitor::clean_names(tbl)
  }
  return(tbl)
}
