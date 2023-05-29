#' Get the BFS tables catalog
#'
#' Get the list of the tables available in the official \href{https://www.bfs.admin.ch/bfs/en/home/statistiken/kataloge-datenbanken/daten/_jcr_content/par/ws_catalog.rss.xml}{RSS Feed} of the Swiss Federal Statistical Office tables catalog.
#'
#' @param language character The language of a BFS catalog, i.e. "de", "fr", "it" or "en".
#' @param title character String to search in title, subtitle and supertitle
#' @param spatial_division BFS datasets by spatial division, choose between "Switzerland", "Cantons", "Districts", "Communes", "Other spatial divisions" or "International"
#' @param prodima numeric Get only specific BFS themes using one or multiple prodima numbers
#' @param inquiry character BFS datasets for an inquiry
#' @param institution character BFS datasets for an institution
#' @param publishing_year_start character BFS datasets for a publishing year start
#' @param publishing_year_end character BFS datasets for a publishing year end
#' @param order_nr character Filter by BFS Number (FSO number)
#' @param skip_limit boolean skip limit, TRUE or FALSE
#' 
#' @return A data frame
#'
#' @importFrom tidyRSS tidyfeed
#' @importFrom janitor clean_names
#' @importFrom purrr pmap_dfr possibly
#' @importFrom tibble tibble
#'
#' @seealso \code{\link{bfs_get_data}}
#'
#' @return A tbl_df (a type of data frame; see tibble or
#' dplyr packages).
#'
#' \describe{
#'   \item{title}{A character column with the title of the BFS dataset}
#'   \item{language}{A character column with the language of the BFS dataset}
#'   \item{publication_date}{The published date of the BFS dataset in the tables catalog}
#'   \item{url_bfs}{A character column with the URL of the related BFS 
#'   webpage}
#'   \item{url_table}{A character column with the URL of the PX file}
#'   \item{guid}{Globally Unique Identifier from the item from the RSS document}
#'   \item{catalog_date}{The released date of the current BFS tables catalog}
#' }
#'
#' @examples
#' \donttest{bfs_get_catalog_tables(language = "en", title = "students", prodima = c(900212))}
#'
#' @export
bfs_get_catalog_tables <- function(language = "de", title = NULL, spatial_division = NULL, prodima = NULL, inquiry = NULL, institution = NULL, publishing_year_start = NULL, publishing_year_end = NULL, order_nr = NULL, skip_limit = TRUE) {
  
  #if (missing(language)) stop("must choose a language, either 'de', 'fr', 'it' or 'en'", call. = FALSE)
  language <- match.arg(arg = language, choices = c("de", "fr", "it", "en"))
  
  # Construct geography query based on spatial division names
  geography_names <- c("Switzerland", "Cantons", "Districts", "Communes", "Other spatial divisions", "International")
  geography_numbers <- c(900091,900092,900093,900004,900008,900068)
  names(geography_numbers) <- geography_names
  
  if(is.null(spatial_division)) {
    geography <- ""
  } else {
    spatial_division <- match.arg(arg = spatial_division, choices = geography_names)
    geography <- geography_numbers[names(geography_numbers) == spatial_division]
  }
  
  if(length(institution) != 1 & !is.null(institution)) stop("`institution` should be unique")
  if(is.null(institution)) institution <- ""
  
  if(length(inquiry) != 1 & !is.null(inquiry)) stop("`inquiry` should be unique")
  if(is.null(inquiry)) inquiry <- ""
  
  if(length(publishing_year_start) != 1 & !is.null(publishing_year_start)) stop("`publishing_year_start` should be unique")
  if(is.null(publishing_year_start)) publishing_year_start <- ""
  
  if(length(publishing_year_end) != 1 & !is.null(publishing_year_end)) stop("`publishing_year_end` should be unique")
  if(is.null(publishing_year_end)) publishing_year_end <- ""
  
  if(length(title) != 1 & !is.null(title)) stop("`title` should be unique")
  if(is.null(title)) title <- ""
  
  if(length(order_nr) != 1 & !is.null(order_nr)) stop("`order_nr` should be unique")
  if(is.null(order_nr)) order_nr <- ""
  
  # Construct prodima query 
  #themes_names <- c("Statistical basis and overviews 00", "Population 01", "Territory and environment 02", "Work and income 03", "National economy 04", "Prices 05", "Industry and services 06", "Agriculture and forestry 07", "Energy 08", "Construction and housing 09", "Tourism 10", "Mobility and transport 11", "Money, banks and insurance 12", "Social security 13", "Health 14", "Education and science 15", "Culture, media, information society, sports 16", "Politics 17", "General Government and finance 18", "Crime and criminal justice 19", "Economic and social situation of the population 20", "Sustainable development, regional and international disparities 21")
  themes_prodima <- c(900001,900010,900035,900051,900075,900084,900092,900104,900127,900140,900160,900169,900191,900198,900210,900212,900214,900226,900239,900257,900269,900276)
  
  # query by prodima (theme) because RSS feed limitation to 350 entities, see issue #5
  if(is.null(prodima)) {
    prodima <- themes_prodima
  } else {
    prodima <- prodima 
  }
  
  # # TODO: allow multiple elements queries for each argument
  # 
  # queries <- list(
  #   prodima = prodima,
  #   language = language,
  #   skipLimit = skip_limit,
  #   institution = institution,
  #   geography = geography,
  #   inquiry = inquiry,
  #   publishingyearstart = publishing_year_start,
  #   publishingyearend = publishing_year_end,
  #   title = title,
  #   orderNr = order_nr
  # )
  # 
  # # test if multiple elements in arguments
  # lengths_rss_queries <- lengths(queries)
  
  # final list for querying with a loop ---------------------------------------
  
  # get lenght prodima to create list to loop on
  length_prodima <- length(prodima)
  
  rss_queries <- list(
    prodima = prodima,
    language = rep(language, length_prodima),
    skipLimit = rep(skip_limit, length_prodima),
    institution = rep(institution, length_prodima),
    geography = rep(geography, length_prodima),
    inquiry = rep(inquiry, length_prodima),
    publishingyearstart = rep(publishing_year_start, length_prodima),
    publishingyearend = rep(publishing_year_end, length_prodima),
    title = rep(title, length_prodima),
    orderNr = rep(order_nr, length_prodima)
  )
  
  get_rss_feed_data <- function(language, skipLimit, prodima, institution, geography, inquiry, publishingyearstart, publishingyearend, title, orderNr) {
    feed <- paste0("https://www.bfs.admin.ch/bfs/", language, "/home/statistiken/kataloge-datenbanken/tabellen/_jcr_content/par/ws_catalog.rss.xml?skipLimit=", skipLimit, "&prodima=", prodima, "&institution=", institution, "&geography=", geography, "&inquiry=", inquiry, "&publishingyearstart=", publishingyearstart, "&publishingyearend=", publishingyearend, "&title=", title, "&orderNr=", orderNr)
    df_feed <- tidyRSS::tidyfeed(feed = feed)
    colnames(df_feed) <- gsub('feed_', '', colnames(df_feed)) # cleaning
    colnames(df_feed) <- gsub('item_', '', colnames(df_feed)) # cleaning
    df_feed <- janitor::clean_names(df_feed, "small_camel") # cleaning
    
    base_url_bfs <- paste0("https://www.bfs.admin.ch/content/bfs/", language, "/home/statistiken/kataloge-datenbanken/tabellen.assetdetail.")
    base_url_table <- "https://www.bfs.admin.ch/bfsstatic/dam/assets/"
    
    if(any("title_2" == names(df_feed))) df_feed$title <- df_feed$title_2
    if(any("link_2" == names(df_feed))) df_feed$url_bfs <- df_feed$link_2
    if(any("pubDate_2" == names(df_feed))) df_feed$publication_date <- df_feed$pubDate_2
    if(any("pubDate" == names(df_feed))) df_feed$catalog_date <- df_feed$pubDate
    
    df_feed$url_table <- gsub(base_url_bfs, base_url_table, df_feed$url_bfs)
    df_feed$url_table <- gsub(".html$", "/master", df_feed$url_table)
    
    # select variables
    vars <- c("title", "language", "publication_date", "url_bfs", "url_table", "guid", "catalog_date")
    df <- df_feed[vars]
  }
  
  df <- purrr::pmap_dfr(rss_queries, purrr::possibly(get_rss_feed_data, otherwise = tibble::tibble()), .progress = TRUE)
  
  df2 <- df[!duplicated(df), ] # no duplication
  
  return(df2)
}
