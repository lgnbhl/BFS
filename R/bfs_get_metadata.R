#' Get metadata of a BFS data in a given language
#'
#' Get the metadata of a BFS dataset using the BFS offical API v1. 
#' You should choose either the bfs number of the bfs offical url of a given dataset. 
#' 
#' @param url_bfs The URL page of a dataset.
#' @param number_bfs The BFS number of a dataset.
#' @param language Language of the dataset to be translated if exists.
#' 
#' @return A tbl_df (a type of data frame; see tibble or dplyr packages).
#' 
#' @examples
#' \donttest{bfs_get_metadata(number_bfs = "px-x-2105000000_501", language = "fr")}
#' 
#' @export
bfs_get_metadata <- function(url_bfs = NULL, language = "de", number_bfs = NULL) {
  
  if (missing(language)) stop("must choose a language, either 'de', 'fr', 'it' or 'en'", call. = FALSE)
  language <- match.arg(arg = language, choices = c("de", "fr", "it", "en"))
  
  if(is.null(number_bfs) & is.null(url_bfs)) { stop("Please fill url_bfs or number_bfs", call. = FALSE) }
  if(!is.null(number_bfs) & !is.null(url_bfs)) { stop("Please fill only url_bfs or number_bfs", call. = FALSE) }
  
  if(!is.null(url_bfs) & is.null(number_bfs)) {
    html_raw <- xml2::read_html(url_bfs)
    html_table <- rvest::html_node(html_raw, ".table")
    df_table <- rvest::html_table(html_table)
    number_bfs <- df_table$X2[grepl("px", df_table$X2)]
    if(!startsWith(number_bfs, "px")) { stop("The bfs number extracted do not start with 'px' from URL: ", url_bfs, "\nPlease add manually the bfs number with bfs_number.", call. = FALSE) }
    number_bfs  
  }
  
  pxweb_api_url <- paste0("https://www.pxweb.bfs.admin.ch/api/v1/", language, "/", number_bfs, "/", number_bfs, ".px")
  df_json <- jsonlite::fromJSON(txt = pxweb_api_url, simplifyDataFrame = TRUE)
  df <- df_json$variables
  
  tibble::as_tibble(df)
}
