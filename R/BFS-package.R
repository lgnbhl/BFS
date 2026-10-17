#' @details
#' The BFS package downloads the open data of the Swiss Federal Statistical
#' Office (BFS, *Bundesamt für Statistik*) from its APIs:
#'
#' - **Swiss Stats Explorer**: [bfs_get_sse_metadata()] and
#'   [bfs_get_sse_data()].
#' - **Data catalog and PXWeb datasets**: [bfs_get_catalog_data()],
#'   [bfs_get_metadata()], [bfs_get_data()] and [bfs_get_data_comments()].
#' - **Tables and files**: [bfs_get_catalog_tables()],
#'   [bfs_get_asset_metadata()] and [bfs_download_asset()].
#' - **Geodata and base maps**: [bfs_get_catalog_geodata()],
#'   [bfs_download_geodata()] and [bfs_get_base_maps()].
#'
#' The BFS is replacing STAT-TAB, and its PXWeb API, with the Swiss Stats
#' Explorer.
#'
#' If an API is not available (e.g. too many requests, timeout or server
#' error), the functions give an error of class `bfs_http_error`. Without
#' internet connection, they give a message and return `NULL`.
#'
#' The package is not affiliated with the BFS.
#'
#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom rlang .data
## usethis namespace: end
NULL
