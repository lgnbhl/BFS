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
bfs_get_sse_metadata <- function(number_bfs, language = "de") {
  
  language <- match.arg(arg = language, choices = c("de", "fr", "it", "en"))
  
  # fail gracefully if no internet connection
  if (!curl::has_internet()) {
    message("No internet connection")
    return(NULL)
  }
  
  # Get URL based on number_bfs
  meta_url <- bfs_get_sse_url(number_bfs, metadata = TRUE)[1]

  sse_metadata_from_url(meta_url, language)
}

#' Get the SSE metadata (codelists) from a metadata URL
#'
#' Used by [bfs_get_sse_metadata()] and [bfs_get_sse_data()], which already
#' knows the metadata URL and so avoids requesting the dataflow list twice.
#'
#' @param meta_url The SSE metadata URL, see [bfs_get_sse_url()].
#' @param language The desired language code ("de", "fr", "it", "en").
#'
#' @importFrom magrittr %>%
#'
#' @returns A tibble containing the codelists of the dataset.
#' @noRd
sse_metadata_from_url <- function(meta_url, language) {

  # Request Metadata
  res_xml <- httr2::request(meta_url) %>% 
    httr2::req_headers(Accept = "application/xml") %>% 
    httr2::req_perform() %>% 
    httr2::resp_body_xml() %>% 
    abort_on_http_error()
  
  # Dimensions
  # ..........
  
  dimensions <- 
    xml2::xml_find_all(res_xml, ".//structure:DimensionList/structure:Dimension")
  
  dim_info <- tibble::tibble(
    dimension_id = xml2::xml_attr(dimensions, "id"),
    position = as.integer(xml2::xml_attr(dimensions, "position")),
    codelist_ref = xml2::xml_attr(xml2::xml_find_first(dimensions, ".//structure:Enumeration/Ref"), "id")
  ) %>%
    dplyr::arrange(.data$position)
  
  # Codelists
  # .........
  
  all_codelist_nodes <- xml2::xml_find_all(res_xml, ".//structure:Codelist")
  names(all_codelist_nodes) <- xml2::xml_attr(all_codelist_nodes, "id")
  
  # Only codelists needed for the dataset
  needed_codelists <- 
    all_codelist_nodes[dim_info$codelist_ref[!is.na(dim_info$codelist_ref)]]
  
  # Extract codes for all dimensions
  all_codes <- purrr::map(names(needed_codelists), function(cl_id) {
    cl_node <- needed_codelists[[cl_id]]
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
  
  rel_options <- xml2::xml_find_all(res_xml, ".//structure:CubeRegion")
  
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
  
  return(codelist)
}
