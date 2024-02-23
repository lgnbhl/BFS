#' Get metadata of a BFS data in a given language
#'
#' Get the metadata of a BFS dataset using the PXWEB API v1.
#' You should choose either the bfs number of the bfs offical url of a given dataset.
#'
#' @param number_bfs The BFS number of a dataset.
#' @param language Language of the dataset to be translated if exists.
#'
#' @return A tbl_df (a type of data frame; see tibble or dplyr packages). Returns NULL if no connection.
#'
#' @importFrom magrittr %>%
#' @importFrom tibble as_tibble
#'
#' @export
bfs_get_metadata <- function(number_bfs, language = "de") {
  language <- match.arg(arg = language, choices = c("de", "fr", "it", "en"))
  # fail gracefully if no internet connection
  if (!curl::has_internet()) {
    message("No internet connection")
    return(NULL)
  }
  # if too many requests HTTP 429
  df <- httr2::request("https://www.pxweb.bfs.admin.ch/api/v1") %>%
    httr2::req_url_path_append(paste0(language, "/", number_bfs, "/", number_bfs, ".px")) %>%
    httr2::req_retry(max_tries = 2, max_seconds = 10) %>%
    httr2::req_perform() %>%
    httr2::resp_body_json(simplifyVector = TRUE)
  df2 <- df$variables
  df2$title <- df$title
  tibble::as_tibble(df2)
}
