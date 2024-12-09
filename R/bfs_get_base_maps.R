#' Get Switzerland base maps data
#'
#' This functions helps to get base maps data from the ThemaKart project
#' as an sf object. The geom names and the general structure of the files
#' can be found in the offical BFS documentation,
#' see \url{https://www.bfs.admin.ch/bfs/en/home/statistics/regional-statistics/base-maps/cartographic-bases.html}. 
#' When using this data, please read the condition of use and copyright mentions.
#'
#' If you want to get ThemaKart data from previous years, you can change
#' the `asset_number` for the related zip file. For example, for the map
#' set of year 2020, the asset number is "11927607".
#'
#' This function is caching the base map data using
#' `tools::R_user_dir(package = "BFS")`.
#'
#' @param geom Geometry such as "suis", "kant", "bezk", "polg", "voge", etc.
#' @param category Category such as 'total_area' ("gf" for "Gesamtflaeche") or
#'  'vegetation_area' ("vf" for "Vegetationsflaeche").
#' @param type The type of data, i.e. "Poly" or "Pnts".
#' @param date Date (yyyymmdd) of reference / validity. If not specified, the
#'  `most_recent` argument is used.
#' @param most_recent Get the most recent by sorting the files in decreasing order,
#'  if FALSE then read the first file available.
#' @param format Format of the file, by default SHP format.
#' @param asset_number Asset number of the base maps zip file.
#' @param return_sf if TRUE, read file path and return sf object. If FALSE, return file path
#'
#' @importFrom sf read_sf
#' @importFrom tools R_user_dir
#' @importFrom fs dir_create dir_ls
#' @importFrom zip unzip
#'
#' @return sf object with geometries. Returns NULL if no connection.
#'
#' @export
bfs_get_base_maps <- function(geom = NULL, category = "gf", type = "Poly", date = NULL, most_recent = TRUE, format = "shp", asset_number = "30566934", return_sf = TRUE) {
  # fail gracefully if no internet connection
  if (!curl::has_internet()) {
    message("No internet connection")
    return(NULL)
  }
  # get base map files if not present in cache folder
  dir <- tools::R_user_dir(package = "BFS")
  path_base_map <- paste0(dir, "/base_maps_", asset_number)
  if (!fs::dir_exists(path_base_map)) {
    fs::dir_create(path_base_map, showWarnings = FALSE)
    BFS::bfs_download_asset(
      number_asset = asset_number,
      destfile = paste0(path_base_map, ".zip")
    )
    # unzip all files in same directory because of encoding issues with subfolders
    zip::unzip(zipfile = paste0(path_base_map, ".zip"), junkpaths = TRUE, exdir = path_base_map)
  }

  # list all files
  files_all <- fs::dir_ls(path_base_map, recurse = TRUE, type = "file")

  if (identical(files_all, character(0))) {
    stop("Error in listing available base map files", call. = FALSE)
  }

  files_format <- grep(pattern = paste0(".", format, "$"), x = files_all, value = TRUE)
  # category, i.e. search file with "gf_ch" or "vf_ch"
  if (category == "total_area" || category == "gf") {
    category_selected <- "gf_ch"
  } else if (category == "vegetation_area" || category == "vf") {
    category_selected <- "vf_ch"
  } else {
    category_selected <- category # other options, for example for 'k4seenyyyymmdd11_ch2007Poly'
  }
  files_cat <- grep(pattern = category_selected, x = files_format, value = TRUE)
  # type, i.e. "Poly" or "Pnts"
  files_poly <- grep(pattern = paste0(type, ".", format, "$"), x = files_cat, value = TRUE)
  # by geom
  files_geom <- grep(pattern = geom, x = files_poly, value = TRUE)
  # by date
  if (!is.null(date)) {
    file_selected <- grep(pattern = date, x = files_geom, value = TRUE)
  } else if (isTRUE(most_recent)) { # get most recent file by sorting in decreasing order
    files_geom_sorted <- sort(files_geom, decreasing = TRUE)
    # get first file
    file_selected <- files_geom_sorted[1]
  } else {
    file_selected <- files_geom[1]
  }
  # return sf object or file path
  if(return_sf) {
    if (length(file_selected) > 1) {
      file_selected <- file_selected[1]
      warning(paste0("Multiple file selected.\nUsing the first file\n", file_selected), call. = FALSE)
    }
    if (identical(file_selected, character(0))) {
      stop("No related file found. Please use other argument values.", call. = FALSE)
    }
    sf::read_sf(file_selected)
  } else {
    file_selected
  }
}
