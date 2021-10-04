#' Download BFS metadata in a given language
#'
#' Returns a tibble containing the titles, publication dates,
#' observation periods, data source, metadata webpage urls and download link urls
#' in a given language of the current public BFS datasets available.
#'
#' @param language character The language of the metadata.
#'
#' @return A tibble
#'
#' @seealso \code{\link{bfs_get_dataset}}
#'
#' @export
bfs_get_metadata <- function(language = "de") {
  
  if (missing(language)) stop("must choose a language, either 'de', 'fr', 'it' or 'en'", call. = FALSE)
  language <- match.arg(arg = language, choices = c("de", "fr", "it", "en"))
  
  lifecycle::deprecate_warn("0.4.0", "bfs_get_metadata()", "bfs_get_catalog()")
  BFS::bfs_get_catalog(language = language)
  
}