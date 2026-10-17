#' Get the BFS data or tables catalog (deprecated)
#'
#' Deprecated since BFS 0.5.6: use [bfs_get_catalog_data()] or
#' [bfs_get_catalog_tables()] instead.
#'
#' @param language Language of the catalog: `"de"` (default), `"fr"`, `"it"`
#'   or `"en"`.
#' @param type `"data"` (default) or `"tables"`.
#'
#' @return The result of [bfs_get_catalog_data()] or
#'   [bfs_get_catalog_tables()].
#'
#' @importFrom lifecycle deprecate_warn
#'
#' @keywords internal
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
