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
#'
#' @return A data frame. Returns NULL if no connection.
#'
#' @importFrom httr2 req_headers req_url_path_append req_url_query req_retry req_perform resp_body_json
#' @importFrom dplyr filter pull as_tibble left_join select
#' @importFrom curl has_internet
#'
#' @seealso \code{\link{bfs_get_data}}
#'
#' \describe{
#'   \item{title}{A character column with the title of the BFS dataset}
#'   \item{language}{A character column with the language of the BFS dataset}
#'   \item{publication_date}{The published date of the BFS dataset in the data catalog}
#'   \item{number_asset}{The BFS asset number}
#'   \item{url_px}{A character column with the URL of the PX file}
#'   \item{url_bfs}{A character column with the URL of the related BFS
#'   webpage}
#' }
#'
#' @examples
#' \donttest{
#' bfs_get_catalog_data(language = "en", title = "students", prodima = c(900212))
#' }
#'
#' @return A tbl_df (a type of data frame; see tibble or
#' dplyr packages). Returns NULL if no connection.
#'
#' @export
bfs_get_catalog_data <- function(language = "de", title = NULL, extended_search = NULL, spatial_division = NULL, prodima = NULL, inquiry = NULL, institution = NULL, publishing_year_start = NULL, publishing_year_end = NULL, order_nr = NULL, limit = 1000, article_model = 900033, article_model_group = 900029) {
  # fail gracefully if no internet connection
  if (!curl::has_internet()) {
    message("No internet connection")
    return(NULL)
  }
  language <- match.arg(arg = language, choices = c("de", "fr", "it", "en"))
  
  # Construct spatial_division query based on spatial division names
  spatial_division_names <- c("Switzerland", "Cantons", "Districts", "Communes", "Other spatial divisions", "International")
  spatial_division_numbers <- c(900091, 900092, 900093, 900004, 900008, 900068)
  names(spatial_division_numbers) <- spatial_division_names
  
  if (is.null(spatial_division)) {
    spatial_division_selected <- NULL
  } else {
    spatial_division <- match.arg(arg = spatial_division, choices = spatial_division_names)
    spatial_division_selected <- spatial_division_numbers[names(spatial_division_numbers) == spatial_division]
  }
  
  df_raw <- request("https://dam-api.bfs.admin.ch/hub/api") %>%
    req_headers(
      `accept` = "application/json",
      `Accept-Language` = language
    ) %>%
    req_url_path_append("dam/assets") %>%
    req_url_query(
      `language` = language, 
      `articleModelGroup` = article_model_group, `articleModel` = article_model, # 900029 and 900033 seems to be for 'article type' = "data"
      `title` = title,
      `extendedSearch` = extended_search,
      `spatialdivision` = spatial_division_selected,
      `prodima` = prodima,
      `inquiry` = inquiry,
      `institution` = institution,
      `periodStart` = publishing_year_start,
      `periodEnd` = publishing_year_end,
      `orderNr` = order_nr,
      `limit` = limit) %>%
    req_retry(max_tries = 2, max_seconds = 10) %>%
    req_perform() %>%
    resp_body_json(simplifyVector = TRUE)
  
  df <- as_tibble(df_raw$data)
  
  if(nrow(df) == 0) {
    df_final <- dplyr::tibble(
      title = NA_character_,
      language = NA_character_,
      publication_date = as.Date(x = integer(0)),
      number_asset = NA_character_,
      order_nr = NA_character_,
      url_px = NA_character_,
      language_available = list(),
      url_bfs = NA_character_,
      url_structure_json = NA_character_
    )
    return(df_final)
  }
  
  language_available <- strsplit(tolower(df$description$language), split = "/")
  
  df_catalog_metadata <- dplyr::tibble(
    title = df$description$titles$main,
    language = language,
    publication_date = as.Date(df$bfs$embargo),
    order_nr = df$shop$orderNr,
    language_available = language_available,
    damId = df$ids$damId
  )
  
  get_catalog_links_metadata <- function(i) {
    
    damId <- df$ids$damId[i]
    
    df_links <- df$links[[i]] %>%
      as_tibble()
    
    if(nrow(df_links) == 0) {
      df_links_cleaned <- dplyr::tibble(
        number_asset = NA_character_,
        url_px = NA_character_,
        url_structure_json = NA_character_,
        damId = damId
      )
      return(df_links_cleaned)
    }
    
    url_bfs <- df_links %>%
      filter(rel == "self") %>%
      pull(href)
    
    url_px <- df_links %>%
      filter(rel == "related") %>%
      pull(href)
    
    url_structure_json <- df_links %>%
      filter(rel == "related-further") %>%
      pull(href)
    
    number_asset <- basename(url_bfs)

    df_links_cleaned <- dplyr::tibble(
      number_asset = number_asset[1],
      url_bfs = url_bfs[1],
      url_px = url_px[1],
      url_structure_json = url_structure_json[1],
      damId = damId
    )
    return(df_links_cleaned)
  }
  
  df_catalog_links_metadata <- purrr::map_dfr(
    .x = seq_along(df$links), 
    .f = get_catalog_links_metadata
  )
  
  df_final <- df_catalog_metadata |>
    left_join(df_catalog_links_metadata, by = "damId") |>
    select(title, language, number_asset, publication_date, order_nr, url_px, url_bfs, language_available, url_structure_json, damId)
  
  return(df_final)
}
