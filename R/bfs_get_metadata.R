#' Get the variables of a BFS dataset
#'
#' Get the variables of a dataset of the PXWeb API and the values each
#' variable can take. Use them to build the `query` of [bfs_get_data()].
#'
#' The PXWeb API is the API of STAT-TAB, which the BFS is replacing with the
#' Swiss Stats Explorer (see [bfs_sse_dimensions()]).
#'
#' @inheritParams bfs_get_data
#'
#' @return A tibble with one row per variable and the columns `code` and
#'   `text` (variable code and label), `values` and `valueTexts` (list
#'   columns with the value codes and labels) and `title` (title of the
#'   dataset). Use `tidyr::unnest_longer(metadata, c(values, valueTexts))` to
#'   get one row per value. Returns `NULL` if there is no internet
#'   connection.
#'
#' @seealso [bfs_get_data()]
#'
#' @examplesIf interactive()
#' metadata <- bfs_get_metadata(number_bfs = "px-x-1502040100_131", language = "en")
#' metadata
#'
#' # one row per value
#' tidyr::unnest_longer(metadata, c(values, valueTexts))
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
    httr2::resp_body_json(simplifyVector = TRUE) %>%
    abort_on_http_error()
  df2 <- df$variables
  df2$title <- df$title
  tibble::as_tibble(df2)
}
