#' Get the BFS data or table catalog
#'
#' This function scraps a given RSS Feed of the Swiss Federal Statistical Office.
#'
#' @param language character The language of a BFS catalog.
#' @param type character A BFS catalog
#'
#' @return A data frame
#'
#' @importFrom tidyRSS tidyfeed
#' @importFrom janitor clean_names
#'
#' @seealso \code{\link{bfs_get_data}}
#'
#' @examples
#' \donttest{bfs_get_catalog(language = "de", type = "data")}
#'
#' @export
bfs_get_catalog <- function(language = "de", type = "data") {
  
  if (missing(language)) stop("must choose a language, either 'de', 'fr', 'it' or 'en'", call. = FALSE)
  language <- match.arg(arg = language, choices = c("de", "fr", "it", "en"))
  if (missing(type)) stop("must choose a type, either 'data' or 'tables'", call. = FALSE)
  type <- match.arg(arg = type, choices = c("data", "tables"))
    
  if(type == "data") { BFS::bfs_get_catalog_data(language = language) }
  if(type == "tables") { BFS::bfs_get_catalog_tables(language = language) }
  
}
