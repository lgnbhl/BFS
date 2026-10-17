# Shared code of bfs_get_catalog_data() and bfs_get_catalog_tables():
# query the DAM API asset catalog and return the "data" or "tables" catalog
bfs_get_catalog_dam <- function(type = c("data", "tables"), language, title, extended_search, spatial_division, prodima, inquiry, institution, publishing_year_start, publishing_year_end, order_nr, limit, article_model, article_model_group, return_raw) {
  type <- match.arg(type)
  # fail gracefully if no internet connection
  if (!curl::has_internet()) {
    message("No internet connection")
    return(NULL)
  }
  language <- match.arg(arg = language, choices = c("de", "fr", "it", "en"))

  # Construct spatial_division query based on spatial division names
  spatial_division_names <- c("Switzerland", "Cantons", "Districts", "Communes", "Other spatial divisions", "International")
  spatial_division_numbers <- c(900091, 900092, 900093, 900004, 900008, 900068)
  names(spatial_division_numbers) <- spatial_division_names

  if (is.null(spatial_division)) {
    spatial_division_selected <- NULL
  } else {
    spatial_division <- match.arg(arg = spatial_division, choices = spatial_division_names)
    spatial_division_selected <- spatial_division_numbers[names(spatial_division_numbers) == spatial_division]
  }

  # articleModelGroup 900029 with articleModel 900033 seems to be for 'article type' = "data",
  # with articleModel 900030 for 'article type' = "table"
  df_raw <- request("https://dam-api.bfs.admin.ch/hub/api") %>%
    req_headers(
      `accept` = "application/json",
      `Accept-Language` = language
    ) %>%
    req_url_path_append("dam/assets") %>%
    req_url_query(
      `language` = language,
      `articleModelGroup` = article_model_group, `articleModel` = article_model,
      `title` = title,
      `extendedSearch` = extended_search,
      `spatialdivision` = spatial_division_selected,
      `prodima` = prodima,
      `inquiry` = inquiry,
      `institution` = institution,
      `periodStart` = publishing_year_start,
      `periodEnd` = publishing_year_end,
      `orderNr` = order_nr,
      `limit` = limit,
      .multi = "explode") %>%
    req_retry(max_tries = 2, max_seconds = 10) %>%
    req_perform() %>%
    resp_body_json(simplifyVector = TRUE) %>%
    abort_on_http_error()

  df <- as_tibble(df_raw$data)

  # the API returns at most `limit` results
  if (!is.null(limit) && nrow(df) > 0 && nrow(df) >= as.numeric(limit)) {
    message(
      "The catalog has ", nrow(df), " results, the value of `limit`. ",
      "More results may be available: use a larger `limit` or more specific arguments."
    )
  }

  if(return_raw == TRUE) {
    return(df)
  }

  # same columns as a non-empty catalog
  if(nrow(df) == 0) {
    if (type == "data") {
      df_final <- dplyr::tibble(
        title = character(0),
        language = character(0),
        number_bfs = character(0),
        number_asset = character(0),
        publication_date = as.Date(x = integer(0)),
        url_px = character(0)
      )
    } else {
      df_final <- dplyr::tibble(
        title = character(0),
        language = character(0),
        number_asset = character(0),
        publication_date = as.Date(x = integer(0)),
        order_nr = character(0)
      )
    }
    return(df_final)
  }

  df_catalog_metadata <- dplyr::tibble(
    title = df$description$titles$main,
    language = language,
    order_nr = df$shop$orderNr,
    publication_date = as.Date(df$bfs$embargo),
    damId = df$ids$damId
  )

  get_catalog_links_metadata <- function(i) {

    damId <- df$ids$damId[i]

    df_links <- df$links[[i]] %>%
      as_tibble()

    if(nrow(df_links) == 0) {
      df_links_cleaned <- dplyr::tibble(
        number_asset = NA_character_,
        url_px = NA_character_,
        damId = damId
      )
      return(df_links_cleaned)
    }

    url_asset <- df_links %>%
      filter(rel == "self") %>%
      pull(href)

    url_px <- df_links %>%
      filter(rel == "related") %>%
      pull(href)

    number_asset <- basename(url_asset)

    df_links_cleaned <- dplyr::tibble(
      number_asset = number_asset[1],
      url_px = url_px[1],
      damId = damId
    )
    return(df_links_cleaned)
  }

  df_catalog_links_metadata <- purrr::map_dfr(
    .x = seq_along(df$links),
    .f = get_catalog_links_metadata
  )

  df_final <- df_catalog_metadata %>%
    left_join(df_catalog_links_metadata, by = "damId")

  if (type == "data") {
    df_final <- df_final %>%
      select(title, language, number_bfs = order_nr, number_asset, publication_date, url_px)
  } else {
    df_final <- df_final %>%
      select(title, language, number_asset, publication_date, order_nr)
  }

  return(df_final)
}
