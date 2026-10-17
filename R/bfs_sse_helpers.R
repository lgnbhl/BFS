#' Get the URL for the Swiss Stats Explorer (SSE) API based on the BFS number
#'
#' @param number_bfs The BFS number (FSO number) of a dataset.
#' @param metadata Logical; if TRUE, returns the URL for metadata instead of data.
#'
#' @returns A character string containing the URL for the API of the specified BFS number.
#'
#' @importFrom magrittr %>%
#' @noRd
bfs_get_sse_url <- function(number_bfs, metadata = FALSE) {
  urls <- sse_dataflow(number_bfs)
  if (metadata) urls$metadata else urls$data
}

sse_base_url <- "https://disseminate.stats.swiss/rest"

# Find the SSE dataflow `number_bfs` and return its data and metadata URLs
sse_dataflow <- function(number_bfs) {

  # Get all available dataflows, cached for the R session
  fetched_now <- is.null(sse_cache$urns)
  flows <- sse_parse_urns(sse_dataflow_urns(sse_base_url), number_bfs)

  # the dataflow may have been published after the list was cached
  if (nrow(flows) == 0 && !fetched_now) {
    flows <- sse_parse_urns(sse_dataflow_urns(sse_base_url, refresh = TRUE), number_bfs)
  }

  if (nrow(flows) == 0) {
    stop("The provided BFS number does not exist in the SSE API.")
  }

  flow <- flows[1, ]
  ids <- c(flow$agency_id, flow$dataflow_id, flow$version)

  list(
    data = paste0(sse_base_url, "/data/", paste(ids, collapse = ","), "/"),
    metadata = paste0(sse_base_url, "/dataflow/", paste(ids, collapse = "/"), "?references=all")
  )
}

# Session cache of the SSE API, see bfs_clear_cache()
sse_cache <- new.env(parent = emptyenv())

# Get the URNs of all available SSE dataflows, cached for the R session
sse_dataflow_urns <- function(url_sse, refresh = FALSE) {
  if (refresh || is.null(sse_cache$urns)) {
    dataflows <- httr2::request(paste0(url_sse, "/dataflow")) %>%
      httr2::req_headers(Accept = "application/json") %>%
      httr2::req_perform() %>%
      httr2::resp_body_json(simplifyVector = TRUE) %>%
      abort_on_http_error()
    sse_cache$urns <- names(dataflows$references)
  }
  sse_cache$urns
}

# Agency, id and version of the dataflows of id `number_bfs`, one row per
# version, from URNs such as "...Dataflow=CH1.LWZ:DF_LWZ_1(1.1.0)"
sse_parse_urns <- function(urns, number_bfs) {
  parts <- regmatches(urns, regexec("Dataflow=([^:]+):([^(]+)\\(([^)]+)\\)", urns))
  parts <- parts[lengths(parts) == 4]
  flows <- tibble::tibble(
    agency_id = vapply(parts, `[`, character(1), 2),
    dataflow_id = vapply(parts, `[`, character(1), 3),
    version = vapply(parts, `[`, character(1), 4)
  )
  flows[flows$dataflow_id == number_bfs, ]
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
#' @noRd
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
