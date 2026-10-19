#' Get data from the Swiss Stats Explorer (deprecated)
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' Deprecated since BFS 0.8.0: use [bfs_sse_data()] instead. It downloads the
#' data faster and stops on a query that wouldn't filter the data. This
#' function still works and gets only bug fixes, e.g. the labels of codes
#' with no name in `language` (see NEWS). To move your code, see the article
#' [Moving to the new Swiss Stats Explorer functions](https://felixluginbuhl.com/BFS/articles/sse-migration.html).
#'
#' Download a dataset of the Swiss Stats Explorer (SSE) API
#' (<https://stats.swiss/>). Select the data you need with `query`, built
#' from the codelists of [bfs_get_sse_metadata()].
#'
#' @details
#' The list of the SSE datasets is cached for the R session. A long-running
#' R session, e.g. a Shiny app, keeps using the version of a dataset it saw
#' first: call [bfs_clear_cache()] to use a new version, or use
#' [bfs_sse_data()], which caches nothing.
#'
#' @inheritParams bfs_get_sse_metadata
#' @param language Language of the labels: `"de"` (default), `"fr"`, `"it"`
#'   or `"en"`.
#' @param start_period,end_period Optional first and last period of the data,
#'   e.g. `"2020"`.
#' @param query A named list: the names are dimension codes (column `code` of
#'   [bfs_get_sse_metadata()]) and the values are value codes (column
#'   `value`), e.g. `list(FREQ = "M", COUNTRY_ORIGIN = c("CH", "AUSL"))`.
#'   A dimension not in `query` keeps all its values. If `NULL` (default),
#'   the whole dataset is downloaded, which can be large and slow.
#' @param column_name_type Column names as dimension `"code"` (default) or
#'   `"text"` (label).
#' @param variable_value_type Values as `"text"` (label, default) or `"code"`.
#' @param clean_names If `TRUE`, clean the column names with
#'   [janitor::clean_names()].
#'
#' @returns A tibble with one column per dimension and the observations in
#'   the `value` column. Returns `NULL` if there is no internet connection.
#'
#' @author Marius Hodel
#' @seealso [bfs_sse_data()], [bfs_get_sse_metadata()]
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
           clean_names = FALSE) {

    lifecycle::deprecate_soft(
      "0.8.0", "bfs_get_sse_data()", "bfs_sse_data()",
      details = c(
        i = "`bfs_sse_data()` is faster and stops on filters that don't filter the data.",
        i = "Arguments: `number_bfs` is now `dataset`, `query` is now `filters`, `variable_value_type` is now `labels`.",
        i = "How to move your code: <https://felixluginbuhl.com/BFS/articles/sse-migration.html>"
      )
    )

    language <- match.arg(arg = language, choices = c("de", "fr", "it", "en"))
    
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
    url_data <- bfs_get_sse_url(number_bfs)[1]
    url_metadata <- gsub(",", "/", url_data) %>% 
      gsub("data", "dataflow", .) %>% 
      gsub("\\/$", "?references=all", .)
    
    # Request metadata
    metadata <- sse_metadata_from_url(url_metadata, language)
    
    # Construct part of URL for filtering in the API request
    ordered_codes <- metadata %>%
      dplyr::arrange(.data$position_dimension) %>% 
      dplyr::pull(.data$code) %>% unique()
    
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
    
    # Add time period filtering if specified
    url_start_period <- 
      ifelse(!is.null(start_period), paste0("startPeriod=", start_period), "")
    url_end_period <-
      ifelse(!is.null(end_period), paste0("endPeriod=", end_period), "")
    
    url_sse <- 
      paste0(url_data, url_query, "?",
             paste(c(url_start_period, url_end_period, 
                     "dimensionAtObservation=AllDimensions"), collapse = "&"))
    
    # Request data
    resp <- httr2::request(url_sse) %>% 
      httr2::req_headers(
        Accept = "application/xml",
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
        stop("No records found for the specified query.")
      }
      # the API is not available: error of class "bfs_http_error", keeping
      # the httr2 classes and fields (e.g. `e$resp`)
      if (status == 429 || status >= 500) {
        abort_on_http_error(httr2::resp_check_status(resp))
      }
      # the API refuses the query (e.g. a wrong period): same error as before
      stop("HTTP error: ", status, " ", body)
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
      left_join(metadata, by = c("dimension" = "code", "dim_value" = "value"))
    
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
