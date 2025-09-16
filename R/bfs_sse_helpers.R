#' Get the URL for the Swiss Stats Explorer (SSE) API based on the BFS number
#'
#' @param number_bfs The BFS number (FSO number) of a dataset.
#' @param metadata Logical; if TRUE, returns the URL for metadata instead of data.
#'
#' @returns A character string containing the URL for the API of the specified BFS number.
#' 
#' @importFrom magrittr %>%
#'
bfs_get_sse_url <- function(number_bfs, metadata = FALSE) {
  
  url_sse <- "https://disseminate.stats.swiss/rest"
  
  # Get all available dataflows
  dataflows <- httr2::request(paste0(url_sse, "/dataflow")) %>% 
    req_headers(Accept = "application/json") %>% 
    httr2::req_perform() %>% 
    httr2::resp_body_json(simplifyVector = TRUE)
  
  dataflows <- as.data.frame(names(dataflows$references))
  colnames(dataflows) <- "urn"
  
  # Create part of the URL required for the selected number_bfs
  part_url <- dataflows %>% 
    dplyr::mutate(urn = gsub(".*Dataflow=|\\)", "", .data$urn)) %>% 
    tidyr::separate(.data$urn, into = c("agency_id", "dataflow_id", "version"),
                    sep = ":|\\(") %>% 
    dplyr::filter(.data$dataflow_id == number_bfs) %>% 
    tidyr::unite("part_url", "agency_id":"version", sep = ",") %>% 
    dplyr::pull(.data$part_url)
  
  if (length(part_url) == 0) {
    stop("The provided BFS number does not exist in the SSE API.")
  }
  
  final_url <- paste0(url_sse, "/data/", part_url, "/")
  
  if (metadata) {
    final_url <- gsub(",", "/", final_url) %>% 
      gsub("data", "dataflow", .) %>% 
      gsub("\\/$", "?references=all", .)
  }
  
  return(final_url)
}

#' Get the name from an XML node for a specified language, with fallback
#' 
#' If the specified language is not found, it falls back to the first available name.
#'
#' @param node An XML node from which to extract the name.
#' @param language The desired language code ("de", "fr", "it", "en").
#' 
#' @importFrom magrittr %>%
#'
#' @returns A character string containing the name in the specified language or the first available name.
get_xml_name <- function(node, language) {
  
  # Try to find the requested language
  name_node <- 
    xml2::xml_find_first(node, paste0("common:Name[@xml:lang='", language, "']"))
  
  # If not found, fallback to the first Name
  if (is.na(name_node)) {
    name_node <- xml2::xml_find_first(node, "common:Name")
  }
  
  xml2::xml_text(name_node)
}
