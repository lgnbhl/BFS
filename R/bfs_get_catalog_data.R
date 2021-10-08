#' Get the BFS data catalog
#'
#' This function scraps the RSS Feed of the Swiss Federal Statistical Office data catalog.
#'
#' @param language character The language of a BFS catalog.
#'
#' @return A data frame
#'
#' @importFrom tidyRSS tidyfeed
#' @importFrom janitor clean_names
#'
#' @seealso \code{\link{bfs_get_data}}
#'
#' @examples
#' \donttest{bfs_get_catalog_data(language = "de")}
#'
#' @export
bfs_get_catalog_data <- function(language = "de") {
  
  if (missing(language)) stop("must choose a language, either 'de', 'fr', 'it' or 'en'", call. = FALSE)
  language <- match.arg(arg = language, choices = c("de", "fr", "it", "en"))
  
  feed <- paste0("https://www.bfs.admin.ch/bfs/", language, "/home/statistiken/kataloge-datenbanken/daten/_jcr_content/par/ws_catalog.rss.xml?skipLimit=true&prodima=&institution=&geography=&inquiry=&publishingyearstart=&publishingyearend=&title=&orderNr=")
  df_feed <- tidyRSS::tidyfeed(feed = feed)
  colnames(df_feed) <- gsub('feed_', '', colnames(df_feed)) # cleaning
  colnames(df_feed) <- gsub('item_', '', colnames(df_feed)) # cleaning
  df_feed <- janitor::clean_names(df_feed, "small_camel") # cleaning
  
  base_url_bfs <- paste0("https://www.bfs.admin.ch/content/bfs/", language, "/home/statistiken/kataloge-datenbanken/daten.assetdetail.")
  base_url_px <- "https://www.bfs.admin.ch/bfsstatic/dam/assets/"
  
  if(any("title_2" == names(df_feed))) df_feed$title <- df_feed$title_2
  if(any("link_2" == names(df_feed))) df_feed$url_bfs <- df_feed$link_2
  if(any("pubDate_2" == names(df_feed))) df_feed$published <- df_feed$title_2
  
  df_feed$url_px <- gsub(base_url_bfs, base_url_px, df_feed$url_bfs)
  df_feed$url_px <- gsub(".html$", "/master", df_feed$url_px)
  
  # select variables
  vars <- c("title", "language", "published", "url_bfs", "url_px")
  df <- df_feed[vars]
  
  return(df)
}
