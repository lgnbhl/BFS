#' Get the comments/footnotes of a BFS dataset in a given language
#'
#' Get the comments/footnotes of a BFS dataset using PXWEB BFS API v1.
#'
#' @param number_bfs The BFS number of a dataset.
#' @param language Language of the dataset to be translated if exists, i.e. "de", "fr", "it" or "en".
#' @param query a list with named values, a json query file or json query string using \code{pxweb::pxweb_query()}.
#' @param clean_names Clean column names using \code{janitor::clean_names()}
#' @param delay Integer Number of seconds to wait before query using \code{Sys.sleep()}.
#'
#' @seealso \code{\link{bfs_get_data}}
#'
#' @return A tbl_df (a type of data frame; see tibble or
#' dplyr packages). Returns NULL if no connection.
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
