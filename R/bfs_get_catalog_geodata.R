#' Get the geodata catalog of the Swiss Confederation
#'
#' List the geodata collections of the STAC API of the Swiss geo-portal
#' (<https://data.geo.admin.ch/>), from the BFS and other federal offices.
#' Download a collection with [bfs_download_geodata()].
#'
#' @param include_metadata If `TRUE` (default), add the metadata of each
#'   collection (title, description, dates, license, ...). This sends one
#'   request per collection (several hundred), so it takes a few minutes:
#'   save the result rather than calling it often. If `FALSE`, return
#'   only the collection ids and URLs.
#'
#' @return A tibble with one row per collection: `collection_id`, `type` and
#'   `href`, and with `include_metadata = TRUE`, `title`, `description`,
#'   `created`, `updated`, `crs`, `license`, `provider_name`, `bbox` and
#'   `inverval`. Returns `NULL` if there is no internet connection.
#'
#' @seealso [bfs_download_geodata()]
#'
#' @examplesIf interactive()
#' catalog_geodata <- bfs_get_catalog_geodata()
#'
#' # the collections of the BFS
#' catalog_geodata[grepl("^ch.bfs", catalog_geodata$collection_id), ]
#'
#' @export
bfs_get_catalog_geodata <- function(include_metadata = TRUE) {
  # fail gracefully if no internet connection
  if (!curl::has_internet()) {
    message("No internet connection")
    return(NULL)
  }
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
        httr2::req_retry(max_tries = 3, max_seconds = 30) %>%
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

    # a collection whose metadata can't be retrieved keeps NA metadata
    failed <- character(0)
    geo_get_metadata_safely <- function(collection_id) {
      tryCatch(geo_get_metadata(collection_id), error = function(e) {
        failed <<- c(failed, collection_id)
        tibble::tibble()
      })
    }
    df <- purrr::map_dfr(collection_ids$collection_id, geo_get_metadata_safely, .progress = TRUE)
    if (length(failed) > 0) {
      message(
        "The metadata of ", length(failed), " collection(s) could not be retrieved ",
        "and is NA: ", paste(failed, collapse = ", ")
      )
    }

    collection_ids <- collection_ids %>%
      dplyr::left_join(df, by = "collection_id")
  }

  return(collection_ids)
}
