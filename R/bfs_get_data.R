#' Get BFS data in a given language
#'
#' Get a dataset using the PXWEB API v1.
#' You should choose either the BFS number (FSO number) of the BFS offical url
#' of a given dataset. You can query particulary variables using the `query` argument.
#'
#' @param number_bfs The BFS number (FSO number) of a dataset.
#' @param language Language of the dataset to be translated if exists, i.e. "de", "fr", "it" or "en".
#' @param query A list with named values, a json query file or json query string using \code{pxweb::pxweb_query()}.
#' @param column_name_type Column name type as "text" or as "code".
#' @param variable_value_type Variable value type as "text" or as "code".
#' @param clean_names Clean column names using \code{janitor::clean_names()}.
#' @param delay Integer Number of seconds to wait before query using \code{Sys.sleep()}.
#'
#' @importFrom magrittr %>%
#'
#' @seealso \code{\link{bfs_get_data_comments}}
#'
#' @return A tbl_df (a type of data frame; see tibble or
#' dplyr packages). Returns NULL if no connection.
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
