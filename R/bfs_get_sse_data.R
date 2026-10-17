#' Get data from the Swiss Stats Explorer
#'
#' Download a dataset of the Swiss Stats Explorer (SSE) API
#' (<https://stats.swiss/>). Select the data you need with `query`, built
#' from the codelists of [bfs_get_sse_metadata()].
#'
#' @inheritParams bfs_get_sse_metadata
#' @param version Version of the dataflow, e.g. `"1.1.0"`. If `NULL`
#'   (default), the latest version is used. Set it in a data pipeline to keep
#'   the same structure when a new version is published.
#' @param language Language of the labels: `"de"` (default), `"fr"`, `"it"`
#'   or `"en"`.
#' @param start_period,end_period Optional first and last period of the data,
#'   e.g. `"2020"`.
#' @param query A named list: the names are dimension codes (column `code` of
#'   [bfs_get_sse_metadata()]) and the values are value codes (column
#'   `value`), e.g. `list(FREQ = "M", COUNTRY_ORIGIN = c("CH", "AUSL"))`.
#'   A dimension not in `query` keeps all its values. If `NULL` (default),
#'   the whole dataset is downloaded, which can be large and slow. A name
#'   that isn't a dimension of the dataset (e.g. a typo, or `TIME_PERIOD`:
#'   use `start_period` and `end_period`) is an error, a value not in the
#'   codelist a warning.
#' @param column_name_type Column names as dimension `"code"` (default) or
#'   `"text"` (label).
#' @param variable_value_type Values as `"text"` (label, default) or `"code"`.
#' @param clean_names If `TRUE`, clean the column names with
#'   [janitor::clean_names()].
#'
#' @returns A tibble with one column per dimension and the observations in
#'   the `value` column. Returns `NULL` if there is no internet connection.
#'   If no data matches the query, an error of class `bfs_no_records` is
#'   signalled.
#'
#' @seealso [bfs_get_sse_metadata()]
#' @export
#'
#' @examplesIf interactive()
#' bfs_get_sse_data(
#'   number_bfs = "DF_PASTA_552_MONTHLY",
#'   language = "en",
#'   query = list(
#'     FREQ = "M",
#'     ACCOMMODATION_TYPE = "552001",
#'     COUNTRY_ORIGIN = c("CH", "AUSL")
#'   ),
#'   start_period = "2020",
#'   end_period = "2023"
#' )
bfs_get_sse_data <- 
  function(number_bfs, language = "de", start_period = NULL, end_period = NULL, 
           query = NULL, column_name_type = "code", variable_value_type = "text", 
           clean_names = FALSE, version = NULL) {
    
    language <- match.arg(arg = language, choices = c("de", "fr", "it", "en"))

    # an invalid value falls back to codes, as in previous versions
    for (arg in c("column_name_type", "variable_value_type")) {
      value <- get(arg)
      if (!(is.character(value) && length(value) == 1 && value %in% c("code", "text"))) {
        rlang::warn(paste0("`", arg, "` must be \"code\" or \"text\": codes are returned."))
      }
    }

    if (length(query) > 0 && (is.null(names(query)) || any(names(query) == ""))) {
      rlang::abort(
        "All the elements of `query` must be named with a dimension code.",
        class = "bfs_sse_query_error",
        call = NULL
      )
    }

    if (is.null(query)) {
      message(paste("Parameter 'query' is NULL. This will return all data for the specified BFS number,", 
                    "which may take a long time and result in a large dataset."))
    }
    
    # fail gracefully if no internet connection
    if (!curl::has_internet()) {
      message("No internet connection")
      return(NULL)
    }
    
    # Get API URLs
    urls <- sse_dataflow(number_bfs, version)

    # Request metadata
    sse_meta <- sse_metadata_from_url(urls$metadata, language)
    metadata <- sse_meta$codelist

    # Construct part of URL for filtering in the API request: one part per
    # dimension of the data structure, in the order of the SDMX key
    ordered_codes <- sse_meta$dimensions

    # a name of `query` that isn't a dimension would be ignored, returning
    # unfiltered data
    sse_check_query(query, ordered_codes, metadata)

    url_parts <-
      sapply(ordered_codes, function(dim) {
        if (dim %in% names(query)) paste(query[[dim]], collapse = "+") else ""
      } 
    )
    
    if (all(url_parts == "")) {
      url_query <- "all"
    } else {
      url_query <- paste(url_parts, collapse = ".")
    }
    
    # Add time period filtering if specified (c() drops the NULL ones). Not
    # httr2::req_url_query(), which would escape the commas of the URL path
    params <- c(startPeriod = start_period, endPeriod = end_period,
                dimensionAtObservation = "AllDimensions")
    url_sse <- paste0(urls$data, url_query, "?",
                      paste(names(params), params, sep = "=", collapse = "&"))

    # Request data
    resp <- sse_request(url_sse) %>%
      httr2::req_headers(
        # the SDMX format parsed below
        Accept = "application/vnd.sdmx.genericdata+xml;version=2.1",
        `Accept-Language` = language
      ) %>%
      httr2::req_error(is_error = ~ FALSE) %>% 
      httr2::req_perform() %>% 
      abort_on_http_error()
    
    # Check status of request
    status <- httr2::resp_status(resp)
    # Meaningfull error message
    if (status != 200) {
      body <- httr2::resp_body_string(resp)
      if (body == "NoRecordsFound") {
        rlang::abort(
          "No records found for the specified query.",
          class = "bfs_no_records",
          call = NULL
        )
      }
      rlang::abort(
        c("The BFS API is not available.", i = paste0("HTTP error: ", status, " ", body)),
        class = "bfs_http_error",
        call = NULL
      )
    }
    
    # Any other format would be parsed as a dataset without observations
    content_type <- httr2::resp_content_type(resp)
    if (!identical(content_type, "application/vnd.sdmx.genericdata+xml")) {
      rlang::abort(
        c("The SSE API returned data in an unexpected format.",
          i = paste0("Content type: ", content_type, ", expected SDMX generic data.")),
        class = "bfs_sse_format_error",
        call = NULL
      )
    }

    # Parse XML response
    res_xml <- httr2::resp_body_xml(resp)
    
    # Extract all Obs nodes
    obs_nodes <- xml2::xml_find_all(res_xml, ".//generic:Obs")
    
    # Extract dimension ids and values, and observation values
    obs_keys <- xml2::xml_find_all(obs_nodes, ".//generic:ObsKey//generic:Value")
    dim_ids <- xml2::xml_attr(obs_keys, "id")
    dim_values <- xml2::xml_attr(obs_keys, "value")
    
    obs_values <- xml2::xml_find_first(obs_nodes, "generic:ObsValue") %>% 
      xml2::xml_attr("value") %>% 
      as.numeric()
    
    # Number of dimension values of each observation, so values stay on the
    # right observation even if one has fewer dimensions
    n_keys <- xml2::xml_length(xml2::xml_find_first(obs_nodes, "generic:ObsKey"))

    # Create a data frame
    dim_df <- tibble::tibble(
      obs_index = rep(seq_along(obs_nodes), times = n_keys),
      dimension = dim_ids,
      dim_value = dim_values
    ) %>% 
      dplyr::left_join(metadata, by = c("dimension" = "code", "dim_value" = "value"))
    
    # Get observation names instead of codes if specified
    if (variable_value_type == "text") {
      dim_df <- dim_df %>% 
        dplyr::mutate(dim_value = dplyr::coalesce(.data$valueText, .data$dim_value))
    }
    
    # Get dimension names instead of codes if specified
    if (column_name_type == "text") {
      dim_df <- dim_df %>% 
        dplyr::mutate(dimension = dplyr::coalesce(.data$text, .data$dimension))
    }
    
    # Reshape data to wide format
    dat <- dim_df %>% 
      tidyr::pivot_wider(names_from = "dimension", values_from = "dim_value", 
                         id_cols = "obs_index") %>% 
      dplyr::mutate(value = obs_values) %>% 
      dplyr::select(-"obs_index")
    
    # Clean column names if specified
    if (clean_names) {
      dat <- janitor::clean_names(dat)
    }
    
    return(dat)
  }
