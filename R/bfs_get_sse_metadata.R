#' Get the codelists of a Swiss Stats Explorer dataset
#'
#' Get the dimensions of a dataset of the Swiss Stats Explorer (SSE) API
#' (<https://stats.swiss/>) and the values each dimension can take. Use them
#' to build the `query` of [bfs_get_sse_data()].
#'
#' @param number_bfs The id of an SSE dataset (dataflow), e.g. `"DF_LWZ_1"`.
#'   It is shown in the URL of the dataset on <https://stats.swiss/>.
#' @param language Language of the labels: `"de"` (default), `"fr"`, `"it"`
#'   or `"en"`. A label missing in this language falls back to another
#'   language.
#' @param version Version of the dataflow, e.g. `"1.1.0"`. If `NULL`
#'   (default), the latest version is used. Set it to keep the same version
#'   when a new one is published.
#'
#' @returns A tibble with one row per value of each dimension:
#' \describe{
#'   \item{code}{The dimension code, to use as a name in `query`.}
#'   \item{text}{The dimension label.}
#'   \item{value}{The value code, to use as a value in `query`.}
#'   \item{valueText}{The value label.}
#'   \item{position_dimension}{The position of the dimension in the dataset.}
#' }
#' Returns `NULL` if there is no internet connection.
#'
#' @seealso [bfs_get_sse_data()]
#' @export
#'
#' @importFrom magrittr %>%
#'
#' @examplesIf interactive()
#' codelist <- bfs_get_sse_metadata("DF_LWZ_1", language = "en")
#' codelist
#'
#' # the dimensions and their codes
#' unique(codelist[c("code", "text")])
bfs_get_sse_metadata <- function(number_bfs, language = "de", version = NULL) {
  
  language <- match.arg(arg = language, choices = c("de", "fr", "it", "en"))
  
  # fail gracefully if no internet connection
  if (!curl::has_internet()) {
    message("No internet connection")
    return(NULL)
  }
  
  urls <- sse_dataflow(number_bfs, version)

  sse_metadata_from_url(urls$metadata, language)$codelist
}

#' Get the SSE metadata (codelists) from a metadata URL
#'
#' Used by [bfs_get_sse_metadata()] and [bfs_get_sse_data()], which already
#' knows the metadata URL and so avoids requesting the dataflow list twice.
#'
#' @param meta_url The SSE metadata URL, see [sse_dataflow()].
#' @param language The desired language code ("de", "fr", "it", "en").
#'
#' @importFrom magrittr %>%
#'
#' @returns A list with `codelist`, a tibble of the codelists of the dataset,
#'   and `dimensions`, the ids of its dimensions (without the time dimension)
#'   in the order of the SDMX key.
#' @noRd
sse_metadata_from_url <- function(meta_url, language) {

  # Request Metadata
  res_xml <- sse_request(meta_url) %>%
    httr2::req_headers(Accept = "application/xml") %>%
    httr2::req_perform() %>%
    httr2::resp_body_xml() %>%
    abort_on_http_error()

  # Codelists
  # .........

  all_codelist_nodes <- xml2::xml_find_all(res_xml, ".//structure:Codelist")

  # Dimensions
  # ..........

  dimensions <-
    xml2::xml_find_all(res_xml, ".//structure:DimensionList/structure:Dimension")

  # codelist of each dimension, matched on its agency, id and version, so
  # codelists with the same id in another agency or version are not mixed up
  refs <- xml2::xml_find_first(dimensions, ".//structure:Enumeration/Ref")
  codelist_index <- match(sse_ref_key(refs), sse_ref_key(all_codelist_nodes))
  # a reference without agency or version: match on the id alone
  by_id <- is.na(codelist_index)
  codelist_index[by_id] <- match(xml2::xml_attr(refs[by_id], "id"),
                                 xml2::xml_attr(all_codelist_nodes, "id"))

  dim_info <- tibble::tibble(
    dimension_id = xml2::xml_attr(dimensions, "id"),
    position = as.integer(xml2::xml_attr(dimensions, "position")),
    codelist_ref = codelist_index
  ) %>%
    dplyr::arrange(.data$position)

  # Extract codes for all dimensions, from the codelists needed for the dataset
  needed_codelists <- unique(dim_info$codelist_ref[!is.na(dim_info$codelist_ref)])
  all_codes <- purrr::map(needed_codelists, function(cl_id) {
    cl_node <- all_codelist_nodes[[cl_id]]
    codes <- xml2::xml_find_all(cl_node, ".//structure:Code")
    
    # name of each code in the requested language, with fallback to the
    # first available name (one result per code, so labels stay aligned)
    label <- xml2::xml_text(
      xml2::xml_find_first(codes, paste0("common:Name[@xml:lang='", language, "']"))
    )
    label_fallback <- xml2::xml_text(xml2::xml_find_first(codes, "common:Name"))
    label <- ifelse(is.na(label), label_fallback, label)

    tibble::tibble(
      codelist_id = cl_id,
      codelist_text = get_xml_name(cl_node, language = language),
      code = xml2::xml_attr(codes, "id"),
      label = label
    )
  })
  
  all_codes <- dplyr::bind_rows(all_codes)
  
  # Options that are actually present in the dataset
  # ................................................
  
  # a region with include="false" lists values excluded from the dataset
  rel_options <-
    xml2::xml_find_all(res_xml, ".//structure:CubeRegion[not(@include='false')]")
  
  # Extract KeyValue nodes
  kv_nodes <- xml2::xml_find_all(rel_options, ".//common:KeyValue")
  names(kv_nodes) <- xml2::xml_attr(kv_nodes, "id")
  
  # Extract codes for all dimensions
  rel_codes <- purrr::map(names(kv_nodes), function(kv_id) {
    
    kv_node <- kv_nodes[[kv_id]]
    values <- xml2::xml_find_all(kv_node, ".//common:Value")
    
    tibble::tibble(
      codelist_id = kv_id,
      code = xml2::xml_text(values)
    )
  })
  
  codelist <- dplyr::bind_rows(rel_codes) %>% 
    dplyr::left_join(dim_info, by = c("codelist_id" = "dimension_id")) %>% 
    dplyr::left_join(all_codes, by = c("codelist_ref" = "codelist_id", "code")) %>% 
    dplyr::select(code = "codelist_id", text = "codelist_text", 
                  value = "code", valueText = "label", 
                  position_dimension = "position") %>% 
    dplyr::distinct()

  list(codelist = codelist, dimensions = dim_info$dimension_id)
}
