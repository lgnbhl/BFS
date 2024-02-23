#' Get the BFS data or table catalog
#'
#' This function scraps a given RSS Feed of the Swiss Federal Statistical Office.
#'
#' @param language character The language of a BFS catalog.
#' @param type character A BFS catalog
#'
#' @return A data frame. Returns NULL if no connection.
#'
#' @importFrom tidyRSS tidyfeed
#' @importFrom janitor clean_names
#' @importFrom lifecycle deprecate_warn
#'
#' @seealso \code{\link{bfs_get_data}}
#'
#' @export
bfs_get_catalog <- function(language = "de", type = "data") {
  lifecycle::deprecate_warn("0.5.6", "bfs_get_catalog()", details = "Please use `bfs_get_catalog_data()` or 'bfs_get_catalog_tables()' instead")
  language <- match.arg(arg = language, choices = c("de", "fr", "it", "en"))
  type <- match.arg(arg = type, choices = c("data", "tables"))
  # fail gracefully if no internet connection
  if (!curl::has_internet()) {
    message("No internet connection")
    return(NULL)
  }
  if (type == "data") {
    catalog <- BFS::bfs_get_catalog_data(language = language)
  }
  if (type == "tables") {
    catalog <- BFS::bfs_get_catalog_tables(language = language)
  }
  return(catalog)
}
