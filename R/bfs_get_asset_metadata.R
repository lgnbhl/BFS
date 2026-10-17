#' Get the metadata of a BFS file
#'
#' Get the metadata of a BFS file from the DAM API
#' (<https://dam-api.bfs.admin.ch/hub/swagger-ui/index.html>) with its asset
#' number or its BFS number: title, description, publication date, contact,
#' links, ...
#'
#' @inheritParams bfs_download_asset
#' @param language Language of the metadata: `"de"` (default), `"fr"`, `"it"`
#'   or `"en"`.
#'
#' @importFrom httr2 request req_headers req_url_path_append req_perform resp_body_json
#' @importFrom magrittr %>%
#'
#' @return A nested list with the metadata. Returns `NULL` if there is no
#'   internet connection.
#'
#' @seealso [bfs_download_asset()]
#'
#' @examplesIf interactive()
#' metadata <- bfs_get_asset_metadata(number_bfs = "px-x-1502040100_131", language = "en")
#' metadata$description$titles$main
#'
#' @export
bfs_get_asset_metadata <- function(number_asset = NULL, number_bfs = NULL, language = c("de", "fr", "it", "en")) {
  # the API only uses one language; single values it accepts (e.g. "EN") still work,
  # and so does the default vector forwarded by a wrapper function
  if (length(language) > 1 && !identical(language, c("de", "fr", "it", "en"))) {
    stop("Please specify only one language, i.e. \"de\", \"fr\", \"it\" or \"en\".", call. = FALSE)
  }
  language <- language[1]
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
    httr2::resp_body_json(simplifyVector = TRUE) %>%
    abort_on_http_error()

  return(asset_metadata)
}
