#' Download a BFS dataset in a given language
#'
#' Download a dataset using the BFS offical API v1. You should choose either the bfs number of the bfs offical url
#' of a given dataset. You can query particulary variables using the `query` argument.
#'
#' @param url_bfs The URL page of a dataset.
#' @param number_bfs The BFS number of a dataset.
#' @param language Language of the dataset to be translated if exists.
#' @param query a list with named values, a json query file or json query string using \code{pxweb::pxweb_query()}.
#' @param column_name_type column name type as "text" or as "code".
#' @param variable_value_type variable value type as "text" or as "code".
#' @param clean_names Clean column names using \code{janitor::clean_names()}.
#'
#' @seealso \code{\link{bfs_get_catalog}}
#'
#' @return A tbl_df (a type of data frame; see tibble or
#' dplyr packages).
#'
#' @export
bfs_get_dataset <- function(url_bfs = NULL, language = "de", number_bfs = NULL, query = "all", column_name_type = "text", variable_value_type = "text", clean_names = FALSE) {
  
  lifecycle::deprecate_warn("0.4.0", "bfs_get_metadata()", "bfs_get_data()")
  BFS::bfs_get_data(language = language)
  
}