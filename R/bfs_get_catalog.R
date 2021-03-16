#' Get the Swiss Federal Statistical Office data catalog in a given language
#' 
#' This function scraps the RSS Feed of the Swiss Federal Statistical Office data catalog.
#' 
#' @param language character The language of a BFS catalog.
#'
#' @return A data frame
#'
#' @importFrom tidyRSS tidyfeed
#' @importFrom janitor clean_names
#' @importFrom dplyr select mutate
#' 
#' @seealso \code{\link{bfs_get_metadata}}
#'
#' @examples
#' \donttest{bfs_get_catalog(language = "de")}
#' 
#' @export

bfs_get_catalog <- function(language = c("de", "fr", "it", "en")) {
  
  if(missing(language)) stop("must choose a language, either 'de', 'fr', 'it' or 'en'", call. = FALSE)
  
  language <- match.arg(arg = language, choices = c("de", "fr", "it", "en"))
  
  feed <- paste0("https://www.bfs.admin.ch/bfs/", language, "/home/statistiken/kataloge-datenbanken/daten/_jcr_content/par/ws_catalog.rss.xml?skipLimit=true")
  
  df <- tidyRSS::tidyfeed(feed = feed)
  
  colnames(df) <- gsub('feed_', '', colnames(df))
  colnames(df) <- gsub('item_', '', colnames(df))
  
  df <- janitor::clean_names(df, "small_camel")
  
  base_url_bfs <- paste0("https://www.bfs.admin.ch/content/bfs/", language, "/home/statistiken/kataloge-datenbanken/daten.assetdetail.")
  base_url_px <- "https://www.bfs.admin.ch/bfsstatic/dam/assets/"
  
  df <- df %>%
    dplyr::select(title = title_2, url_bfs = link_2, published = pubDate_2) %>%
    dplyr::mutate(language = language) %>%
    dplyr::mutate(url_px = gsub(base_url_bfs, base_url_px, url_bfs),
                  url_px = gsub(".html$", "/master", url_px)) %>%
    dplyr::select(title, language, published, url_bfs, url_px)
  
  return(df)
}

