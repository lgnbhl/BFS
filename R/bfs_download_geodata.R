#' Download geodata from the Swiss geo-portal
#'
#' Download the files of a geodata collection from the STAC API of the Swiss
#' geo-portal (<https://data.geo.admin.ch/api/stac/v0.9/>). Requires the
#' rstac package.
#'
#' The use of the data is free but subject to the terms of use of the Swiss
#' geo-portal (<https://www.geo.admin.ch/terms-of-use>).
#'
#' @param collection_id The collection id, i.e. the `collection_id` column of
#'   [bfs_get_catalog_geodata()], e.g.
#'   `"ch.bfs.generalisierte-grenzen_agglomerationen_g1"`.
#' @param output_dir Folder of the downloaded files, a temporary folder by
#'   default.
#' @param overwrite If `TRUE`, overwrite existing files.
#' @param create_json If `TRUE`, also save the STAC items as a JSON file.
#' @param bbox,datetime,feature_id Optional filters of the items: bounding
#'   box, date-time or interval, and item id. See [rstac::items()].
#' @param asset_names Optional names of the assets to download. See
#'   [rstac::assets_download()].
#'
#' @importFrom magrittr %>%
#'
#' @return The paths of the downloaded files. Zip files are not extracted.
#'   Returns `NULL` if there is no internet connection.
#'
#' @seealso [bfs_get_catalog_geodata()]
#'
#' @examplesIf interactive()
#' files <- bfs_download_geodata(
#'   collection_id = "ch.bfs.generalisierte-grenzen_agglomerationen_g1"
#' )
#' files
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
