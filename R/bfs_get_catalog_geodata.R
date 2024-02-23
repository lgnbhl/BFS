#' Get the geodata catalog of the Swiss Confederation
#'
#' Display geo-information catalog of the Swiss Confederation (\url{https://data.geo.admin.ch/}),
#' including some geographic datasets provided by the Swiss Federal Statistical Office.
#' Note that this geodata catalog is not hosted by the Swiss Federal Statistical Office.
#'
#' @param include_metadata boolean TRUE to loop on each geodata to add metadata.
#'
#' @details
#' For now only Stac API datasets are accessible.
#'
#' @return A tbl_df (a type of data frame; see tibble or
#' dplyr packages).
#'
#' @export
bfs_get_catalog_geodata <- function(include_metadata = TRUE) {
  elements_html <- xml2::read_html("https://data.geo.admin.ch/") %>%
    rvest::html_element("#data") %>%
    rvest::html_elements("a")

  collection_ids <- tibble::tibble(
    type = rvest::html_text2(elements_html),
    href = rvest::html_attr(elements_html, "href")
  ) %>%
    dplyr::filter(type %in% c("API", "download")) %>%
    dplyr::mutate(
      collection_id = gsub(".*collections/", "", href),
      collection_id = gsub("collections/", "", collection_id)
    ) %>%
    dplyr::group_by(collection_id) %>%
    dplyr::arrange(collection_id, type) %>%
    dplyr::filter(dplyr::row_number() == 1) %>%
    dplyr::ungroup() %>%
    dplyr::select(collection_id, type, href) %>%
    # fix "h.bafu.wasserbau-vermessungsstrecken"
    dplyr::mutate(collection_id = ifelse(collection_id == "h.bafu.wasserbau-vermessungsstrecken", "ch.bafu.wasserbau-vermessungsstrecken", collection_id)) %>%
    # ONLY STAC API FOR NOW
    dplyr::filter(type == "API")

  # loop on each href to get metadata
  if (include_metadata) {
    geo_get_metadata <- function(collection_id) {
      # if too many requests HTTP 429
      json <- httr2::request("https://data.geo.admin.ch/api/stac/v0.9/collections/") %>%
        httr2::req_url_path_append(collection_id) %>%
        httr2::req_perform() %>%
        httr2::resp_body_json()

      tibble::tibble(
        collection_id = json$id,
        title = json$title,
        description = json$description,
        created = json$created,
        updated = json$updated,
        crs = json$crs[[1]],
        license = json$license,
        provider_name = json$providers[[1]]$name,
        bbox = json$extent$spatial$bbox,
        inverval = json$extent$temporal$interval
      )
    }

    df <- purrr::map_dfr(collection_ids$collection_id, purrr::possibly(geo_get_metadata, otherwise = tibble::tibble()), .progress = TRUE)

    collection_ids <- collection_ids %>%
      dplyr::left_join(df, by = "collection_id")
  }

  return(collection_ids)
}
