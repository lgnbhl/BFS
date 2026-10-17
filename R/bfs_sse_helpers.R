#' Get the URL for the Swiss Stats Explorer (SSE) API based on the BFS number
#'
#' @param number_bfs The BFS number (FSO number) of a dataset.
#' @param metadata Logical; if TRUE, returns the URL for metadata instead of data.
#' @param version Version of the dataflow, the latest if `NULL`.
#'
#' @returns A character string containing the URL for the API of the specified BFS number.
#'
#' @importFrom magrittr %>%
#' @noRd
bfs_get_sse_url <- function(number_bfs, metadata = FALSE, version = NULL) {
  urls <- sse_dataflow(number_bfs, version)
  if (metadata) urls$metadata else urls$data
}

sse_base_url <- "https://disseminate.stats.swiss/rest"

# Request to the SSE API, retried once if the API is temporarily unavailable
sse_request <- function(url) {
  httr2::request(url) %>%
    httr2::req_user_agent("BFS R package (https://github.com/lgnbhl/BFS)") %>%
    httr2::req_retry(max_tries = 2, max_seconds = 10)
}

# Find the SSE dataflow `number_bfs` and return its data and metadata URLs.
# Without `version`, the latest version is used.
sse_dataflow <- function(number_bfs, version = NULL) {

  found <- function(flows) {
    nrow(flows) > 0 && (is.null(version) || version %in% flows$version)
  }

  # Get all available dataflows, cached for the R session
  fetched_now <- is.null(sse_cache$urns)
  flows <- sse_parse_urns(sse_dataflow_urns(sse_base_url), number_bfs)

  # the dataflow (or version) may have been published after the list was cached
  if (!found(flows) && !fetched_now) {
    flows <- sse_parse_urns(sse_dataflow_urns(sse_base_url, refresh = TRUE), number_bfs)
  }

  if (nrow(flows) == 0) {
    stop("The provided BFS number does not exist in the SSE API.")
  }

  if (!is.null(version)) {
    if (!version %in% flows$version) {
      rlang::abort(
        c(paste0("Version \"", version, "\" of \"", number_bfs, "\" does not exist in the SSE API."),
          i = paste0("Available versions: ", paste(flows$version, collapse = ", "), ".")),
        call = NULL
      )
    }
    flow <- flows[flows$version == version, ][1, ]
  } else {
    flows <- flows[order(numeric_version(flows$version, strict = FALSE), decreasing = TRUE), ]
    flow <- flows[1, ]
    if (nrow(flows) > 1) {
      message(paste0("\"", number_bfs, "\" has several versions (",
                     paste(flows$version, collapse = ", "), "): using the latest, ",
                     flow$version, ". Use `version` to choose another one."))
    }
  }
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
    dataflows <- sse_request(paste0(url_sse, "/dataflow")) %>%
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

# "agency:id:version" of SDMX nodes (e.g. a Codelist or a Ref to a codelist)
sse_ref_key <- function(nodes) {
  paste(xml2::xml_attr(nodes, "agencyID"), xml2::xml_attr(nodes, "id"),
        xml2::xml_attr(nodes, "version"), sep = ":")
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
