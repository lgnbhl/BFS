#' Get Metadata (Codelists) from Swiss Stats Explorer (SSE) API
#' 
#' Retrieve metadata codelists for a specified BFS dataset from the Swiss Stats Explorer (SSE) API.
#' This function is required to built queries for \link{bfs_get_sse_data}.
#'
#' @param number_bfs The BFS number (FSO number) of a dataset.
#' @param language Language of the codelists ("de", "fr", "it", "en").
#'
#' @returns A tibble containing the codelists of the specified BFS dataset.
#' @export
#' 
#' @importFrom magrittr %>%
#'
#' @examples bfs_get_sse_metadata("DF_SSV_POL_LEG", language = "de")
bfs_get_sse_metadata <- function(number_bfs, language = "de") {
  
  language <- match.arg(arg = language, choices = c("de", "fr", "it", "en"))
  
  # fail gracefully if no internet connection
  if (!curl::has_internet()) {
    message("No internet connection")
    return(NULL)
  }
  
  # Get URL based on number_bfs
  meta_url <- bfs_get_sse_url(number_bfs, metadata = TRUE)[1]
  
  # Request Metadata
  res_xml <- httr2::request(meta_url) %>% 
    httr2::req_headers(Accept = "application/xml") %>% 
    httr2::req_perform() %>% 
    httr2::resp_body_xml()
  
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
    
    # extract code IDs
    ids <- xml2::xml_attr(codes, "id")
    
    # extract all <Name> children of all codes in one pass
    name_nodes <- xml2::xml_find_all(codes, ".//common:Name")
    langs <- xml2::xml_attr(name_nodes, "lang")
    texts <- xml2::xml_text(name_nodes)
    label <- texts[langs == language]
    
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
