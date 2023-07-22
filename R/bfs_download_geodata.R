#' Download a geographic file from the Swiss Geo-portal
#' 
#' Download assets from the STAC API on the geodata catalog 
#' of the Swiss Confederation (\url{https://data.geo.admin.ch/api/stac/v0.9/}).
#' 
#' @details The use of the data and services is free but
#' subject to the provisions on fair use (see \url{https://www.geo.admin.ch/terms-of-use}).
#' 
#' @param collection_id collection_id
#' @param output_dir output_dir
#' @param overwrite overwrite
#' @param create_json create_json
#' @param bbox bbox
#' @param asset_names asset_names
#' @param datetime datetime
#' @param feature_id feature_id
#' 
#' @export
bfs_download_geodata <- function(
    collection_id = collection_id, 
    output_dir = tempdir(), 
    overwrite = FALSE,
    create_json = FALSE,
    bbox = NULL,
    asset_names = NULL, 
    datetime = NULL,
    feature_id = NULL) {
  
  if(!exists(output_dir)) dir.create(output_dir, showWarnings = FALSE)
  
  items <- rstac::stac("https://data.geo.admin.ch/api/stac/v0.9/") %>%
    rstac::collections(collection_id = collection_id) %>%
    rstac::items(bbox = bbox, datetime = datetime, feature_id = feature_id) %>%
    rstac::get_request() %>%
    rstac::assets_download(asset_names = asset_names, output_dir = output_dir, overwrite = overwrite, create_json = create_json)
  
  list_assets <- rstac::items_assets(items)
  
  files <- list.files(path = output_dir, pattern = paste0(list_assets, collapse = "|"), recursive = TRUE, full.names = TRUE)

  return(files)
}
