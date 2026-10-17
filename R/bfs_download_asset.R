#' Download a BFS file
#'
#' Download any file of the BFS (Excel, CSV, PX, PDF, zip, ...) from the DAM
#' API (<https://dam-api.bfs.admin.ch/hub/swagger-ui/index.html>) with its
#' asset number or its BFS number. Use it for the tables of
#' [bfs_get_catalog_tables()], or for datasets too large for
#' [bfs_get_data()].
#'
#' @param number_asset The asset number of the file, e.g. `"24025646"`. It
#'   is the `number_asset` column of [bfs_get_catalog_tables()] and
#'   [bfs_get_catalog_data()], and the number at the end of the "assetdetail"
#'   URLs of the BFS website.
#' @param number_bfs The BFS number of the file, e.g.
#'   `"px-x-1502040100_131"`. Use either `number_asset` or `number_bfs`.
#' @param destfile Path of the downloaded file.
#' @param quiet If `FALSE`, show the download progress.
#' @param mode,handle Passed to [curl::curl_download()].
#'
#' @importFrom curl curl_download
#'
#' @return The path of the downloaded file. Returns `NULL` if there is no
#'   internet connection.
#'
#' @seealso [bfs_get_asset_metadata()], [bfs_get_catalog_tables()]
#'
#' @examplesIf interactive()
#' # a PX file, read it with pxR::read.px()
#' bfs_download_asset(
#'   number_bfs = "px-x-1502040100_131",
#'   destfile = file.path(tempdir(), "px-x-1502040100_131.px")
#' )
#'
#' @export
bfs_download_asset <- function(number_asset = NULL, number_bfs = NULL, destfile, quiet = TRUE, mode = "wb", handle = curl::new_handle()) {
  # fail gracefully if no internet connection
  if (!curl::has_internet()) {
    message("No internet connection")
    return(NULL)
  }
  if (is.null(number_asset) && is.null(number_bfs)) {
    stop("Please specify number_bfs or number_asset")
  } else if (!is.null(number_asset) && !is.null(number_bfs)) {
    stop("Please only specify number_bfs or number_asset")
  } else if (!is.null(number_asset)) {
    id <- number_asset
  } else if (!is.null(number_bfs)) {
    id <- paste0("orderNr:", number_bfs)
  }

  file_path <- curl::curl_download(
    url = paste0("https://dam-api.bfs.admin.ch/hub/api/dam/assets/", id, "/master"),
    destfile = destfile,
    quiet = quiet,
    mode = mode,
    handle = handle
  ) %>%
    abort_on_http_error()

  file_path
}
