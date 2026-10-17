#' Download a geographic file from the Swiss geo-portal
#'
#' Download assets from the STAC API on the geodata catalog
#' of the Swiss Confederation (\url{https://data.geo.admin.ch/api/stac/v0.9/}).
#'
#' @details The use of the data and services is free but
#' subject to the provisions on fair use (see \url{https://www.geo.admin.ch/terms-of-use}).
#'
#' @param collection_id The STAC collection id, see the `collection_id` column
#'  of [bfs_get_catalog_geodata()].
#' @param output_dir The directory where the files are downloaded.
#' @param overwrite If TRUE, overwrite existing files.
#' @param create_json If TRUE, also save the STAC items as a json file.
#' @param bbox Optional bounding box to filter the items, see `rstac::items()`.
#' @param asset_names Optional names of the assets to download, see `rstac::assets_download()`.
#' @param datetime Optional date-time or interval to filter the items, see `rstac::items()`.
#' @param feature_id Optional id of a single item, see `rstac::items()`.
#'
#' @importFrom magrittr %>%
#'
#' @return Returns the file path where the file has been downloaded. Returns NULL if no connection.
#'
#' @export
bfs_download_geodata <- function(
    collection_id,
    output_dir = tempdir(),
    overwrite = FALSE,
    create_json = FALSE,
    bbox = NULL,
    asset_names = NULL,
    datetime = NULL,
    feature_id = NULL) {
  
  # fail gracefully if no internet connection
  if (!curl::has_internet()) {
    message("No internet connection")
    return(NULL)
  }
  
  rlang::check_installed("rstac")
  
  if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

  items <- rstac::stac("https://data.geo.admin.ch/api/stac/v0.9/") %>%
    rstac::collections(collection_id = collection_id) %>%
    rstac::items(bbox = bbox, datetime = datetime, feature_id = feature_id) %>%
    rstac::get_request() %>%
    rstac::assets_download(asset_names = asset_names, output_dir = output_dir, overwrite = overwrite, create_json = create_json)

  list_assets <- rstac::items_assets(items)

  files <- list.files(path = output_dir, pattern = paste0(list_assets, collapse = "|"), recursive = TRUE, full.names = TRUE)

  return(files)
}
