#' Get the comments/footnotes of a BFS dataset in a given language
#'
#' Get the comments/footnotes of a BFS dataset using PXWEB BFS API v1.
#'
#' @param number_bfs The BFS number of a dataset.
#' @param language Language of the dataset to be translated if exists, i.e. "de", "fr", "it" or "en".
#' @param url_bfs The URL page of a dataset.
#' @param query a list with named values, a json query file or json query string using \code{pxweb::pxweb_query()}.
#' @param clean_names Clean column names using \code{janitor::clean_names()}
#'
#' @seealso \code{\link{bfs_get_data}}
#'
#' @return A tbl_df (a type of data frame; see tibble or
#' dplyr packages).
#'
#' @importFrom magrittr %>%
#'
#' @export
bfs_get_data_comments <- function(number_bfs = NULL, language = "de", url_bfs = NULL, query = NULL, clean_names = FALSE) {
  if (is.null(number_bfs) && is.null(url_bfs)) {
    stop("Please fill bfs_number or url_bfs", call. = FALSE)
  }
  if (!is.null(number_bfs) && !is.null(url_bfs)) {
    stop("Please fill only bfs_number or url_bfs", call. = FALSE)
  }

  if (!is.null(url_bfs) && is.null(number_bfs)) {
    html_raw <- xml2::read_html(url_bfs)
    html_table <- rvest::html_node(html_raw, ".table")
    df_table <- rvest::html_table(html_table)
    number_bfs <- df_table$X2[grepl("px", df_table$X2)]
    if (!startsWith(number_bfs, "px")) {
      stop("Failed to get the bfs number from: ", url_bfs, "\nPlease add manually the bfs number withs bfs_number.", call. = FALSE)
    }
    number_bfs
  }

  pxweb_api_url <- paste0("https://www.pxweb.bfs.admin.ch/api/v1/", language, "/", number_bfs, "/", number_bfs, ".px")

  # check if too many requests HTTP 429
  df_json <- httr2::request("https://www.pxweb.bfs.admin.ch/api/v1") %>%
    httr2::req_url_path_append(paste0(language, "/", number_bfs, "/", number_bfs, ".px")) %>%
    httr2::req_perform() %>%
    httr2::resp_body_json(simplifyVector = TRUE)

  if (query == "all" || is.null(query)) {
    variables <- df_json$variables$code
    values <- df_json$variables$values
    df <- rbind(rep("*", length(values)))
    names(df) <- variables
    dims <- as.list(df)
    pxq <- pxweb::pxweb_query(dims)
  } else {
    if (!is.list(query)) {
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

  if (clean_names) {
    tbl <- janitor::clean_names(tbl)
  }

  return(tbl)
}
