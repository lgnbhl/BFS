#' Get Switzerland base maps data
#'
#' This functions helps to get base maps data from the ThemaKart project
#' as an sf object. The geom names and the general structure of the files
#' can be found in the offical BFS documentation,
#' see \url{https://www.bfs.admin.ch/asset/en/24025645}. When using this data, please read the condition of use
#' and copyright mentions.
#'
#' If you want to get ThemaKart data from previous years, you can change
#' the `asset_number` for the related zip file. For example, for the map
#' set of year 2020, the asset number is "11927607".
#'
#' This function is caching the base map data using `rappdirs::user_data_dir()`.
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
#'
#' @importFrom sf read_sf
#' @importFrom zip unzip
#'
#' @export
bfs_get_base_maps <- function(geom = NULL, category = "gf", type = "Poly", date = NULL, most_recent = TRUE, format = "shp", asset_number = "24025646") {
  if (is.null(geom)) {
    stop("Please choose a geom, such as 'suis', 'kant' or 'polg'.\nGeometry names are listed here: \nhttps://www.bfs.admin.ch/asset/en/24025645", call. = FALSE)
  }

  # get base map files if not present in cache folder
  dir <- tools::R_user_dir(package = "BFS")
  path_base_map <- paste0(dir, "/base_map_", asset_number)
  browser()

  if (!dir.exists(path_base_map)) {
    dir.create(path_base_map, recursive = TRUE, showWarnings = FALSE)
    BFS::bfs_download_asset(
      number_asset = asset_number,
      # number_bfs = "KM04-00-c-suis-2023-q",
      destfile = paste0(path_base_map, ".zip")
    )
    # unzip
    sysinf <- Sys.info()
    if (!is.null(sysinf)) {
      os <- sysinf["sysname"]
      if (os == "Darwin") {
        os <- "osx"
      }
    }

    if (os == "osx") {
      system2("unzip", paste0(path_base_map, ".zip"))
    } else {
      zip::unzip(
        zipfile = paste0(path_base_map, ".zip"),
        exdir = path_base_map
      )
    }
  }

  # list all files
  files_all <- list.files(path_base_map, recursive = TRUE, full.names = TRUE)

  if (identical(files_all, character(0))) {
    stop("Error in listing available base map files", call. = FALSE)
  }

  files_format <- grep(pattern = paste0(".", format, "$"), x = files_all, value = TRUE, useBytes = TRUE)
  # category, i.e. search file with "gf_ch" or "vf_ch"
  if (category == "total_area" || category == "gf") {
    category_selected <- "gf_ch"
  } else if (category == "vegetation_area" || category == "vf") {
    category_selected <- "gf_ch"
  } else {
    category_selected <- category # other options, for example for 'k4seenyyyymmdd11_ch2007Poly'
  }
  files_cat <- grep(pattern = category_selected, x = files_format, value = TRUE, useBytes = TRUE)
  # type, i.e. "Poly" or "Pnts"
  files_poly <- grep(pattern = paste0(type, ".", format, "$"), x = files_cat, value = TRUE, useBytes = TRUE)
  # by geom
  files_geom <- grep(pattern = geom, x = files_poly, value = TRUE, useBytes = TRUE)
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
  if (length(file_selected) > 1) {
    file_selected <- file_selected[1]
    warning(paste0("Multiple file selected.\nUsing the first file\n", file_selected), call. = FALSE)
  }
  if (identical(file_selected, character(0))) {
    stop("No related file found. Please use other argument values.", call. = FALSE)
  }
  # fix multibyte path bug #12
  Encoding(file_selected) <- "latin1"
  sf::read_sf(file_selected)
}
