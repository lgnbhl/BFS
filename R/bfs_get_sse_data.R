#' Get Data from Swiss Stats Explorer (SSE) API
#'
#' @param number_bfs The BFS number (FSO number) of a dataset.
#' @param language Language of the dataset to be translated if exists, i.e. "de", "fr", "it" or "en".
#' @param start_period Start year of the requested data
#' @param end_period End year of the requested data
#' @param query A named list with dimension codes as names and desired values as values.
#' @param column_name_type Column name type as "text" or as "code".
#' @param variable_value_type Variable value type as "text" or as "code".
#' @param clean_names Logical, if TRUE, the column names are cleaned using janitor::clean_names().
#'
#' @returns A tibble with the requested data.
#' @export
#'
#' @examples 
#' bfs_get_sse_data(
#'   number_bfs = "DF_PASTA_552_MONTHLY", 
#'   language = "en", 
#'   query =  list("FREQ" = "M", "ACCOMMODATION_TYPE" = c("552001"), 
#'                 "COUNTRY_ORIGIN" = c("CH", "AUSL")),
#'   start_period = "2020",
#'   end_period = "2023"
#'   )
bfs_get_sse_data <- 
  function(number_bfs, language = "de", start_period = NULL, end_period = NULL, 
           query = NULL, column_name_type = "code", variable_value_type = "text", 
           clean_names = FALSE) {
    
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
    url_data <- bfs_get_sse_url(number_bfs)
    url_metadata <- gsub(",", "/", url_data) %>% 
      gsub("data", "dataflow", .) %>% 
      gsub("\\/$", "?references=all", .)
    
    # Request metadata
    metadata <- bfs_get_sse_metadata(number_bfs, language)
    
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
    res_xml <- httr2::request(url_sse) %>% 
      httr2::req_headers(
        Accept = "application/xml",
        `Accept-Language` = language
      ) %>% 
      httr2::req_perform() %>% 
      httr2::resp_body_xml()
    
    # Extract all Obs nodes
    obs_nodes <- xml2::xml_find_all(res_xml, ".//generic:Obs")
    
    # Extract dimension ids and values, and observation values
    obs_keys <- xml2::xml_find_all(obs_nodes, ".//generic:ObsKey//generic:Value")
    dim_ids <- xml2::xml_attr(obs_keys, "id")
    dim_values <- xml2::xml_attr(obs_keys, "value")
    
    obs_values <- xml2::xml_find_first(obs_nodes, "generic:ObsValue") %>% 
      xml2::xml_attr("value") %>% 
      as.numeric()
    
    # Create a data frame
    dim_df <- tibble::tibble(
      obs_index = rep(seq_along(obs_nodes), each = length(unique(dim_ids))),
      dimension = dim_ids,
      dim_value = dim_values
    ) %>% 
      left_join(metadata, by = c("dimension" = "code", "dim_value" = "value"))
    
    # Get observation names instead of codes if specified
    if (variable_value_type == "text") {
      dim_df <- dim_df %>% 
        dplyr::mutate(dim_value = dplyr::coalesce(.data$valueTexts, .data$dim_value))
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
