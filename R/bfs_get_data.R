#' Get a BFS dataset in a given language
#'
#' Get a dataset using the PXWEB API v1. 
#' You should choose either the BFS number (FSO number) of the BFS offical url
#' of a given dataset. You can query particulary variables using the `query` argument.
#'
#' @param number_bfs The BFS number (FSO number) of a dataset.
#' @param language Language of the dataset to be translated if exists, i.e. "de", "fr", "it" or "en".
#' @param url_bfs The URL page of a dataset.
#' @param query A list with named values, a json query file or json query string using \code{pxweb::pxweb_query()}.
#' @param column_name_type Column name type as "text" or as "code".
#' @param variable_value_type Variable value type as "text" or as "code".
#' @param clean_names Clean column names using \code{janitor::clean_names()}.
#'
#' @seealso \code{\link{bfs_get_data_comments}}
#'
#' @return A tbl_df (a type of data frame; see tibble or
#' dplyr packages).
#' 
#' @export
bfs_get_data <- function(number_bfs = NULL, language = "de", url_bfs = NULL, query = NULL, column_name_type = "text", variable_value_type = "text", clean_names = FALSE) {
  
  #if (missing(language)) stop("must choose a language, either 'de', 'fr', 'it' or 'en'", call. = FALSE)
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
  
  # if too many requests HTTP 429
  df_json <- httr2::request("https://www.pxweb.bfs.admin.ch/api/v1") %>% 
    httr2::req_url_path_append(paste0(language, "/", number_bfs, "/", number_bfs, ".px")) %>% 
    httr2::req_retry(max_tries = 2, max_seconds = 5) %>%
    httr2::req_perform() %>% 
    httr2::resp_body_json(simplifyVector = TRUE)
  
  if(is.null(query)) {
    variables <- df_json$variables$code
    values <- df_json$variables$values
    df <- rbind(rep("*", length(values)))
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
  
  df_pxweb <- pxweb::pxweb_get_data(url = pxweb_api_url, query = pxq, column.name.type = column_name_type, variable.value.type = variable_value_type)
  tbl <- tibble::as_tibble(df_pxweb, .name_repair = "minimal")
  
  if(clean_names) { tbl <- janitor::clean_names(tbl) }
  
  return(tbl)
}
