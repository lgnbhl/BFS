#' Get the BFS tables catalog
#'
#' This function scraps the RSS Feed of the Swiss Federal Statistical Office tables catalog.
#' The tables are mostly datasets that are accessible as Excel files.
#'
#' @param language character The language of a BFS catalog.
#'
#' @return A data frame
#'
#' @importFrom tidyRSS tidyfeed
#' @importFrom janitor clean_names
#'
#' @examples
#' \donttest{bfs_get_catalog_tables(language = "de")}
#'
#' @export
bfs_get_catalog_tables <- function(language = "de") {
  
  if (missing(language)) stop("must choose a language, either 'de', 'fr', 'it' or 'en'", call. = FALSE)
  language <- match.arg(arg = language, choices = c("de", "fr", "it", "en"))
  
  feed <- paste0("https://www.bfs.admin.ch/bfs/", language, "/home/statistiken/kataloge-datenbanken/tabellen/_jcr_content/par/ws_catalog.rss.xml?skipLimit=true&prodima=&institution=&geography=&inquiry=&publishingyearstart=&publishingyearend=&title=&orderNr=")
  df_feed <- tidyRSS::tidyfeed(feed = feed)
  colnames(df_feed) <- gsub('feed_', '', colnames(df_feed)) # cleaning
  colnames(df_feed) <- gsub('item_', '', colnames(df_feed)) # cleaning
  df_feed <- janitor::clean_names(df_feed, "small_camel") # cleaning
  
  base_url_bfs <- paste0("https://www.bfs.admin.ch/content/bfs/", language, "/home/statistiken/kataloge-datenbanken/tabellen.assetdetail.")
  base_url_table <- "https://www.bfs.admin.ch/bfsstatic/dam/assets/"
  
  if(any("title_2" == names(df_feed))) df_feed$title <- df_feed$title_2
  if(any("link_2" == names(df_feed))) df_feed$url_bfs <- df_feed$link_2
  if(any("pubDate_2" == names(df_feed))) df_feed$published <- df_feed$title_2
  
  df_feed$url_table <- gsub(base_url_bfs, base_url_table, df_feed$url_bfs)
  df_feed$url_table <- gsub(".html$", "/master", df_feed$url_table)
  
  # select variables
  vars <- c("title", "language", "published", "url_bfs", "url_table")
  df <- df_feed[vars]
  
  return(df)
}
