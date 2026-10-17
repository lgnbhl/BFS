#' Search the BFS data catalog
#'
#' Search the datasets of the BFS catalog
#' (<https://www.bfs.admin.ch/bfs/en/home/statistics/catalogue.html>, article
#' type "Data") that can be downloaded with [bfs_get_data()].
#'
#' The English and Italian catalogs have fewer datasets than the German and
#' French ones. Arguments accept several values, e.g.
#' `prodima = c(900210, 900212)`.
#'
#' @param language Language of the catalog: `"de"` (default), `"fr"`, `"it"`
#'   or `"en"`.
#' @param title Text to search in the titles.
#' @param extended_search Text to search in the titles, BFS number and
#'   summaries.
#' @param spatial_division Spatial division of the datasets: `"Switzerland"`,
#'   `"Cantons"`, `"Districts"`, `"Communes"`, `"Other spatial divisions"` or
#'   `"International"`.
#' @param prodima Theme number(s) of the BFS, e.g. `900212` for "Education
#'   and science". See the "Data catalog and PXWeb datasets" article for the
#'   list.
#' @param inquiry Inquiry (survey) id.
#' @param institution Institution id.
#' @param publishing_year_start,publishing_year_end First and last publishing
#'   year.
#' @param order_nr BFS number, e.g. `"px-x-1502040100_131"`.
#' @param limit Maximum number of results (1000 by default). A message tells
#'   you when the catalog has as many results as `limit`.
#' @param article_model,article_model_group Article type ids of the DAM API.
#'   The defaults select the "Data" (or "Tables") article type; you don't
#'   need to change them.
#' @param return_raw If `TRUE`, return the catalog as returned by the API,
#'   with all its metadata in nested data frames.
#'
#' @return A tibble with the columns:
#' \describe{
#'   \item{title}{Title of the dataset.}
#'   \item{language}{Language of the catalog.}
#'   \item{number_bfs}{BFS number, to use in [bfs_get_data()].}
#'   \item{number_asset}{Asset number, to use in [bfs_download_asset()].}
#'   \item{publication_date}{Publication date.}
#'   \item{url_px}{URL of the dataset in the PXWeb API.}
#' }
#' Returns `NULL` if there is no internet connection.
#'
#' @importFrom httr2 req_headers req_url_path_append req_url_query req_retry req_perform resp_body_json
#' @importFrom dplyr filter pull as_tibble left_join select
#' @importFrom purrr pmap_dfr
#' @importFrom curl has_internet
#'
#' @seealso [bfs_get_data()], [bfs_get_catalog_tables()]
#'
#' @examplesIf interactive()
#' bfs_get_catalog_data(language = "en", extended_search = "student")
#'
#' # by theme ("Education and science")
#' bfs_get_catalog_data(language = "en", prodima = 900212)
#'
#' @export
bfs_get_catalog_data <- function(language = "de", title = NULL, extended_search = NULL, spatial_division = NULL, prodima = NULL, inquiry = NULL, institution = NULL, publishing_year_start = NULL, publishing_year_end = NULL, order_nr = NULL, limit = 1000, article_model = 900033, article_model_group = 900029, return_raw = FALSE) {
  bfs_get_catalog_dam(
    type = "data",
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
