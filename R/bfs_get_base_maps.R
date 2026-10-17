#' Get the Swiss base maps
#'
#' Get the cartographic base maps of the BFS ThemaKart project: the borders
#' of Switzerland, cantons, districts and communes, lakes, rivers, ... The
#' names of the geometries and files are in the BFS documentation
#' (<https://www.bfs.admin.ch/bfs/en/home/statistics/regional-statistics/base-maps/cartographic-bases.html>).
#' Please read its terms of use and copyright notices.
#'
#' The base maps are a zip file of several hundred files, downloaded once and
#' cached in `tools::R_user_dir("BFS")`. Use [bfs_clear_cache()] to delete it.
#' Each file name combines the arguments, e.g.
#' `K4kant20220101gf_ch2007Poly.shp`: geometry `kant`, date `20220101`,
#' category `gf`, type `Poly`, format `shp`.
#'
#' @param geom Geometry, e.g. `"suis"` (Switzerland), `"kant"` (cantons),
#'   `"bezk"` (districts), `"polg"` (communes), `"seen"` (lakes) or
#'   `"flus"` (rivers).
#' @param category Category: `"gf"` or `"total_area"` (total area, default),
#'   `"vf"` or `"vegetation_area"` (vegetation area), or another part of the
#'   file name, e.g. `"11"` for the lakes.
#' @param type `"Poly"` (polygons, default) or `"Pnts"` (points). Use `""`
#'   for files without type, e.g. the rivers.
#' @param date Optional date of validity, as `"yyyymmdd"`, e.g.
#'   `"20230101"`.
#' @param most_recent If `TRUE` (default) and `date` is `NULL`, get the most
#'   recent file. If `FALSE`, get the first file found.
#' @param format File format, `"shp"` (shapefile) by default.
#' @param asset_number Asset number of the ThemaKart zip file. The default is
#'   the 2024 edition; e.g. `"11927607"` is the 2020 edition.
#' @param return_sf If `TRUE` (default), return an sf object (requires the sf
#'   package). If `FALSE`, return the path of the file. With `date = ""`,
#'   return the paths of all the matching files: use it, with `""` for the
#'   other arguments, to list the available files.
#'
#' @importFrom tools R_user_dir
#' @importFrom fs dir_create dir_ls
#' @importFrom zip unzip
#'
#' @return An sf object, or with `return_sf = FALSE` the file path(s). Returns `NULL` if there is no internet connection and
#'   the base maps are not cached yet.
#'
#' @seealso [bfs_clear_cache()]
#'
#' @examplesIf interactive()
#' cantons <- bfs_get_base_maps(geom = "kant")
#' plot(sf::st_geometry(cantons))
#'
#' lakes <- bfs_get_base_maps(geom = "seen", category = "11")
#' rivers <- bfs_get_base_maps(geom = "flus", category = "22", type = "")
#'
#' # list all river files
#' bfs_get_base_maps(geom = "flus", category = "", type = "", date = "", return_sf = FALSE)
#'
#' @export
bfs_get_base_maps <- function(geom = NULL, category = "gf", type = "Poly", date = NULL, most_recent = TRUE, format = "shp", asset_number = "30566934", return_sf = TRUE) {
  if (is.null(geom)) {
    stop("Please specify `geom`, for example \"suis\", \"kant\", \"bezk\" or \"polg\".", call. = FALSE)
  }
  # get base map files if not present in cache folder
  dir <- tools::R_user_dir(package = "BFS")
  path_base_map <- paste0(dir, "/base_maps_", asset_number)
  if (!fs::dir_exists(path_base_map)) {
    # fail gracefully if no internet connection
    if (!curl::has_internet()) {
      message("No internet connection")
      return(NULL)
    }
    # the cache folder doesn't exist on a fresh install
    fs::dir_create(dir)
    BFS::bfs_download_asset(
      number_asset = asset_number,
      destfile = paste0(path_base_map, ".zip")
    )
    fs::dir_create(path_base_map)
    # unzip all files in same directory because of encoding issues with subfolders
    tryCatch(
      zip::unzip(zipfile = paste0(path_base_map, ".zip"), junkpaths = TRUE, exdir = path_base_map),
      error = function(e) {
        # don't keep a partially extracted cache
        fs::dir_delete(path_base_map)
        stop(e)
      }
    )
    # the extracted files are enough
    fs::file_delete(paste0(path_base_map, ".zip"))
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
    rlang::check_installed("sf")
    sf::read_sf(file_selected)
  } else {
    file_selected
  }
}
