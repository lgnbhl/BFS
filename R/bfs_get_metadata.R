#' Get metadata of a BFS data in a given language
#'
#' Get the metadata of a BFS dataset using the PXWEB API v1.
#' You should choose either the bfs number of the bfs offical url of a given dataset.
#'
#' @param url_bfs The URL page of a dataset.
#' @param number_bfs The BFS number of a dataset.
#' @param language Language of the dataset to be translated if exists.
#'
#' @return A tbl_df (a type of data frame; see tibble or dplyr packages).
#'
#' @importFrom magrittr %>%
#'
#' @export
bfs_get_metadata <- function(number_bfs = NULL, url_bfs = NULL, language = "de") {
  language <- match.arg(arg = language, choices = c("de", "fr", "it", "en"))

  if (is.null(number_bfs) && is.null(url_bfs)) {
    stop("Please fill url_bfs or number_bfs", call. = FALSE)
  }
  if (!is.null(number_bfs) && !is.null(url_bfs)) {
    stop("Please fill only url_bfs or number_bfs", call. = FALSE)
  }

  if (!is.null(url_bfs) && is.null(number_bfs)) {
    html_raw <- xml2::read_html(url_bfs)
    html_table <- rvest::html_node(html_raw, ".table")
    df_table <- rvest::html_table(html_table)
    number_bfs <- df_table$X2[grepl("px", df_table$X2)]
    if (!startsWith(number_bfs, "px")) {
      stop("The bfs number extracted do not start with 'px' from URL: ", url_bfs, "\nPlease add manually the bfs number with bfs_number.", call. = FALSE)
    }
    number_bfs
  }

  # if too many requests HTTP 429
  df <- httr2::request("https://www.pxweb.bfs.admin.ch/api/v1") %>%
    httr2::req_url_path_append(paste0(language, "/", number_bfs, "/", number_bfs, ".px")) %>%
    httr2::req_retry(max_tries = 2, max_seconds = 10) %>%
    httr2::req_perform() %>%
    httr2::resp_body_json(simplifyVector = TRUE)

  df2 <- df$variables

  # add title to dataset
  df2$title <- df$title

  tibble::as_tibble(df2)
}
