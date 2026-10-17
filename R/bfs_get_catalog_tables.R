#' Search the BFS tables catalog
#'
#' Search the tables of the BFS catalog
#' (<https://www.bfs.admin.ch/bfs/en/home/statistics/catalogue.html>, article
#' type "Tables"). Tables are mostly Excel or CSV files, not available in the
#' PXWeb API: download them with [bfs_download_asset()].
#'
#' The English and Italian catalogs have fewer tables than the German and
#' French ones. Arguments accept several values, e.g.
#' `prodima = c(900210, 900212)`.
#'
#' @inheritParams bfs_get_catalog_data
#'
#' @return A tibble with the columns:
#' \describe{
#'   \item{title}{Title of the table.}
#'   \item{language}{Language of the catalog.}
#'   \item{number_asset}{Asset number, to use in [bfs_download_asset()].}
#'   \item{publication_date}{Publication date.}
#'   \item{order_nr}{BFS number.}
#' }
#' Returns `NULL` if there is no internet connection.
#'
#' @importFrom httr2 req_headers req_url_path_append req_url_query req_retry req_perform resp_body_json
#' @importFrom dplyr filter pull as_tibble left_join select
#' @importFrom curl has_internet
#'
#' @seealso [bfs_download_asset()], [bfs_get_catalog_data()]
#'
#' @examplesIf interactive()
#' tables <- bfs_get_catalog_tables(language = "en", extended_search = "students")
#' tables
#'
#' # download the first table
#' bfs_download_asset(
#'   number_asset = tables$number_asset[1],
#'   destfile = file.path(tempdir(), "table.xlsx")
#' )
#'
#' @export
bfs_get_catalog_tables <- function(language = "de", title = NULL, extended_search = NULL, spatial_division = NULL, prodima = NULL, inquiry = NULL, institution = NULL, publishing_year_start = NULL, publishing_year_end = NULL, order_nr = NULL, limit = 1000, article_model = 900030, article_model_group = 900029, return_raw = FALSE) {
  bfs_get_catalog_dam(
    type = "tables",
    language = language,
    title = title,
    extended_search = extended_search,
    spatial_division = spatial_division,
    prodima = prodima,
    inquiry = inquiry,
    institution = institution,
    publishing_year_start = publishing_year_start,
    publishing_year_end = publishing_year_end,
    order_nr = order_nr,
    limit = limit,
    article_model = article_model,
    article_model_group = article_model_group,
    return_raw = return_raw
  )
}
