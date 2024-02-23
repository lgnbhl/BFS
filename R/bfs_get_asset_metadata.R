#' Get asset metadata in a given language
#'
#' This function uses the DAM API \url{https://dam-api.bfs.admin.ch/hub/swagger-ui/index.html}
#' to get the metadata of a BFS file by asset number or BFS number in a given language.
#'
#' @seealso [bfs_download_asset()]
#'
#' @param number_bfs The BFS number of a dataset.
#' @param number_asset The asset number of a dataset
#' @param language character The language of a BFS catalog, i.e. "de", "fr", "it" or "en".
#'
#' @importFrom httr2 request req_headers req_url_path_append req_perform resp_body_json
#' @importFrom magrittr %>%
#'
#' @return list Returns a list containing asset metadata information. Returns NULL if no connection.
#'
#' @export
bfs_get_asset_metadata <- function(number_asset = NULL, number_bfs = NULL, language = c("de", "fr", "it", "en")) {
  # fail gracefully if no internet connection
  if (!curl::has_internet()) {
    message("No internet connection")
    return(NULL)
  }
  if (is.null(number_asset) && is.null(number_bfs)) {
    stop("Please specify number_asset or number_bfs")
  } else if (!is.null(number_asset) && !is.null(number_bfs)) {
    stop("Please only specify number_asset or number_bfs")
  } else if (!is.null(number_asset)) {
    id <- number_asset
  } else if (!is.null(number_bfs)) {
    id <- paste0("orderNr:", number_bfs)
  }

  asset_metadata <- httr2::request(base_url = "https://dam-api.bfs.admin.ch/hub/api/dam/assets/") %>%
    httr2::req_headers("accept" = "application/json") %>%
    httr2::req_headers("accept-language" = language) %>%
    httr2::req_url_path_append(id) %>%
    httr2::req_perform() %>%
    httr2::resp_body_json(simplifyVector = TRUE)

  return(asset_metadata)
}
