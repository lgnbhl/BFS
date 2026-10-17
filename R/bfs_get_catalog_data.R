#' Get the BFS data catalog
#'
#' Get the list of the data available in the official DAM-API of the Swiss Federal Statistical Office asset catalog.
#'
#' @param language character The language of a BFS catalog, i.e. "de", "fr", "it" or "en".
#' @param title character String to search in (sub/super)title
#' @param extended_search character String for an extended search in (sub/super)title, orderNr, summary, shortSummary, shortTextGNP
#' @param spatial_division BFS datasets by spatial division, choose between "Switzerland", "Cantons", "Districts", "Communes", "Other spatial divisions" or "International"
#' @param prodima numeric Get only specific BFS themes using one or multiple prodima numbers
#' @param inquiry character BFS datasets for an inquiry
#' @param institution character BFS datasets for an institution
#' @param publishing_year_start character BFS datasets for a publishing year start
#' @param publishing_year_end character BFS datasets for a publishing year end
#' @param order_nr character Filter by BFS Number (FSO number)
#' @param limit integer limit of query results (1000 by default)
#' @param article_model_group integer articleModel parameter query
#' @param article_model integer articleModel parameter query
#' @param return_raw boolean Return raw data from json structure as a tibble data.frame
#'
#' @return A tbl_df (a type of data frame; see tibble or
#' dplyr packages) with the columns:
#' \describe{
#'   \item{title}{A character column with the title of the BFS dataset}
#'   \item{language}{A character column with the language of the BFS dataset}
#'   \item{number_bfs}{The BFS number (FSO number), named orderNr in the API}
#'   \item{number_asset}{The BFS asset number}
#'   \item{publication_date}{The published date of the BFS dataset, named embargo in the API}
#'   \item{url_px}{A character column with the URL of the PX file}
#' }
#' Returns NULL if no connection.
#'
#' @importFrom httr2 req_headers req_url_path_append req_url_query req_retry req_perform resp_body_json
#' @importFrom dplyr filter pull as_tibble left_join select
#' @importFrom purrr pmap_dfr
#' @importFrom curl has_internet
#'
#' @seealso \code{\link{bfs_get_data}}
#'
#' @examplesIf interactive()
#' bfs_get_catalog_data(language = "en", title = "students", prodima = c(900212))
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
