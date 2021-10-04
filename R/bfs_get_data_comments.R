#' Get the comments/footnotes of a BFS dataset in a given language
#'
#' @param url_bfs The URL page of a dataset.
#' @param number_bfs The BFS number of a dataset.
#' @param language Language of the dataset to be translated if exists.
#' @param query a list object of the variables to query
#' @param clean_names Clean column names using \code{janitor::clean_names()}
#'
#' @seealso \code{\link{bfs_get_data}}
#'
#' @export
bfs_get_data_comments <- function(url_bfs = NULL, language = "de", number_bfs = NULL, query = "all", clean_names = FALSE) {
  
  if(is.null(number_bfs) & is.null(url_bfs)) { stop("Please fill bfs_number or url_bfs", call. = FALSE) }
  if(!is.null(number_bfs) & !is.null(url_bfs)) { stop("Please fill only bfs_number or url_bfs", call. = FALSE) }
  
  if(!is.null(url_bfs) & is.null(number_bfs)) {
    html_raw <- xml2::read_html(url_bfs)
    html_table <- rvest::html_node(html_raw, ".table")
    df_table <- rvest::html_table(html_table)
    number_bfs <- df_table$X2[grepl("px", df_table$X2)]
    if(!startsWith(number_bfs, "px")) { stop("Failed to get the bfs number from: ", url_bfs, "\nPlease add manually the bfs number withs bfs_number.", call. = FALSE) }
    number_bfs  
  }
  
  pxweb_api_url <- paste0("https://www.pxweb.bfs.admin.ch/api/v1/", language, "/", number_bfs, "/", number_bfs, ".px")
  df_json <- jsonlite::fromJSON(txt = pxweb_api_url)
  
  if(query == "all") {
    variables <- df_json$variables$code
    values <- df_json$variables$values
    df <- rbind(c("*", "*","*","*"))
    names(df) <- variables
    dims <- as.list(df)
    pxq <- pxweb::pxweb_query(dims)
  } else {
    if(!is.list(query)) { 
      variables <- paste(df_json$variables$code, collapse = ", ")
      stop(paste0("`query` should be a list using the variables: ", variables, "."), call. = FALSE)
    }
    dims <- query
    pxq <- pxweb::pxweb_query(dims)
  }
  
  df_pxweb <- pxweb::pxweb_get(url = pxweb_api_url, query = pxq)
  comments <- pxweb::pxweb_data_comments(df_pxweb)
  df_comments <- as.data.frame(comments)
  tbl <- tibble::as_tibble(df_comments)
  
  if(clean_names) { tbl <- janitor::clean_names(tbl) }
  
  return(tbl)
}