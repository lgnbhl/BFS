# Shared code of bfs_get_data() and bfs_get_data_comments()

# URL of a BFS dataset in the PXWEB API v1
pxweb_bfs_url <- function(number_bfs, language) {
  paste0("https://www.pxweb.bfs.admin.ch/api/v1/", language, "/", number_bfs, "/", number_bfs, ".px")
}

# Get the variables of a dataset and build the pxweb query: all values of all
# variables if `query` is NULL, otherwise `query`
pxweb_bfs_query <- function(number_bfs, language, query = NULL, delay = NULL) {
  # if too many requests HTTP 429
  df_json <- httr2::request("https://www.pxweb.bfs.admin.ch/api/v1") %>%
    httr2::req_url_path_append(paste0(language, "/", number_bfs, "/", number_bfs, ".px")) %>%
    httr2::req_retry(max_tries = 2, max_seconds = 10) %>%
    httr2::req_perform() %>%
    httr2::resp_body_json(simplifyVector = TRUE) %>%
    abort_on_http_error()
  if(!is.null(delay)) {
    Sys.sleep(delay) # waiting time in seconds before query
  }
  if (is.null(query)) {
    variables <- df_json$variables$code
    values <- df_json$variables$values
    df <- rbind(rep("*", length(values)))
    names(df) <- variables
    dims <- as.list(df)
  } else {
    if (!is.list(query)) {
      variables <- paste(df_json$variables$code, collapse = ", ")
      stop(paste0("`query` should be a list using the variables: ", variables, "."), call. = FALSE)
    }
    dims <- query
  }
  pxweb::pxweb_query(dims)
}
