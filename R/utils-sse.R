# Helpers of bfs_sse_datasets(), bfs_sse_dimensions() and bfs_sse_data().
# They are separate from the helpers of bfs_get_sse_data() and
# bfs_get_sse_metadata() (see bfs_sse_helpers.R), which are kept unchanged
# for the data pipelines using them.
#
# The new functions are a thin wrapper of the SDMX REST API: they use only
# what the SDMX standard defines (structure messages, SDMX-CSV with labels)
# and leave the rest (latest version, labels in a language, checks of the
# values) to the API, so they keep working if the API changes its internals.

sse_base_url <- "https://disseminate.stats.swiss/rest"

# Request to the SSE API, retried once if the API is temporarily unavailable
sse_request <- function(url) {
  httr2::request(url) %>%
    httr2::req_user_agent(paste0(
      "BFS R package ", utils::packageVersion("BFS"), " (https://github.com/lgnbhl/BFS)"
    )) %>%
    httr2::req_retry(max_tries = 2, max_seconds = 10) %>%
    httr2::req_error(is_error = ~ FALSE)
}

# Perform an SSE request and signal a classed error if it fails:
# `bfs_no_records` if no data matches the query, `not_found` (a function) for
# another 404, `bfs_sse_query_error` if the API rejects the query (4xx) and
# `bfs_http_error` if the API is not available
sse_perform <- function(req, not_found = NULL) {
  resp <- abort_on_http_error(httr2::req_perform(req))
  status <- httr2::resp_status(resp)
  if (status < 400) {
    return(resp)
  }
  # some errors, e.g. 414 URI Too Long, have no body
  body <- if (httr2::resp_has_body(resp)) trimws(httr2::resp_body_string(resp)) else ""
  detail <- paste0("HTTP ", status, " ", httr2::resp_status_desc(resp),
                   if (body != "") paste0(": ", substr(body, 1, 500)))

  # the API answers "NoRecordsFound" or "NoResultsFound" depending on the
  # dataset
  if (status == 404 && grepl("^No(Records|Results)Found", body)) {
    rlang::abort("No records found for the specified query.", class = "bfs_no_records", call = NULL)
  }
  if (status == 404 && !is.null(not_found)) {
    not_found()
  }
  if (status >= 400 && status < 500 && status != 429) {
    rlang::abort(
      c("The SSE API rejected the query.", i = detail,
        i = if (status == 414) "The URL is too long: split `filters` into several queries."),
      class = "bfs_sse_query_error",
      call = NULL
    )
  }
  # the error of httr2, so the classes (e.g. "httr2_http_429") and the
  # response (`e$resp`) are kept, see abort_on_http_error()
  abort_on_http_error(httr2::resp_check_status(resp))
}

# All the SSE dataflows, one row per version, with their name in `language`.
# Not the plain "/dataflow" list, which only has the latest version of each
# dataflow
sse_dataflows <- function(language) {
  flows <- sse_request(paste0(sse_base_url, "/dataflow/all/all/all")) %>%
    httr2::req_headers(
      Accept = "application/vnd.sdmx.structure+json;version=1.0",
      `Accept-Language` = language
    ) %>%
    sse_perform() %>%
    httr2::resp_body_json()
  flows <- flows$data$dataflows
  field <- function(name) {
    vapply(flows, function(flow) flow[[name]] %||% NA_character_, character(1))
  }
  tibble::tibble(
    dataset = field("id"),
    name = field("name"),
    version = field("version"),
    agency = field("agencyID"),
    description = field("description")
  )
}

# SDMX structure message of the version `version` (the latest if NULL) of the
# dataflow `dataset`, with the `references` of the dataflow: "datastructure"
# for its dimensions only, "all" for its codelists, concepts and constraints
sse_get_structure <- function(dataset, version, references) {
  url <- paste0(sse_base_url, "/dataflow/all/", dataset, "/", version %||% "latest",
                "?references=", references)
  sse_request(url) %>%
    httr2::req_headers(Accept = "application/xml") %>%
    sse_perform(not_found = function() {
      rlang::abort(
        c(paste0(
          if (is.null(version)) "Dataset " else paste0("Version \"", version, "\" of dataset "),
          "\"", dataset, "\" doesn't exist in the Swiss Stats Explorer."
        ),
        i = "See the columns `dataset` and `version` of `bfs_sse_datasets()`."),
        class = "bfs_sse_dataset_error",
        call = NULL
      )
    }) %>%
    httr2::resp_body_xml()
}

# "agency,id,version" of the dataflow of a structure message, as used in the
# data URL
sse_flow_ref <- function(xml) {
  flow <- xml2::xml_find_first(xml, ".//structure:Dataflow")
  paste(xml2::xml_attr(flow, "agencyID"), xml2::xml_attr(flow, "id"),
        xml2::xml_attr(flow, "version"), sep = ",")
}

# Ids of the dimensions of a structure message, without the time dimension,
# in the order of the SDMX key
sse_dimension_ids <- function(xml) {
  nodes <- xml2::xml_find_all(xml, ".//structure:DimensionList/structure:Dimension")
  ids <- xml2::xml_attr(nodes, "id")
  ids[order(as.integer(xml2::xml_attr(nodes, "position")))]
}

# Check that `x` is a single string (or number), or NULL if `null` is TRUE
sse_check_string <- function(x, arg, null = TRUE) {
  if (null && is.null(x)) {
    return(invisible())
  }
  if (!(is.character(x) || is.numeric(x)) || length(x) != 1 || is.na(x) || x == "") {
    rlang::abort(
      paste0("`", arg, "` must be a single string", if (null) " or `NULL`", "."),
      class = "bfs_sse_argument_error",
      call = NULL
    )
  }
}

# Check that `x` is a single whole number of at least 1, or NULL
sse_check_count <- function(x, arg) {
  if (is.null(x)) {
    return(invisible())
  }
  if (!is.numeric(x) || length(x) != 1 || !is.finite(x) || x < 1 || x != round(x)) {
    rlang::abort(
      paste0("`", arg, "` must be a whole number of at least 1, or `NULL`."),
      class = "bfs_sse_argument_error",
      call = NULL
    )
  }
}

# Check the shape of the `filters` of bfs_sse_data(), without the API: a
# filter that would be ignored is an error, so the data is never silently
# unfiltered
sse_check_filters <- function(filters) {
  if (is.null(filters)) {
    return(invisible())
  }
  abort_filters <- function(...) {
    rlang::abort(c(...), class = "bfs_sse_filter_error", call = NULL)
  }
  if (!is.list(filters) || is.data.frame(filters)) {
    abort_filters("`filters` must be a named list, e.g. `list(FREQ = \"M\")`.")
  }
  if (length(filters) > 0 && (is.null(names(filters)) || any(names(filters) == ""))) {
    abort_filters("All the elements of `filters` must be named with a dimension.")
  }
  duplicated <- unique(names(filters)[duplicated(names(filters))])
  if (length(duplicated) > 0) {
    abort_filters(
      paste0("Dimension given more than once in `filters`: ", paste(duplicated, collapse = ", "), "."),
      i = "Give all the values of a dimension in one vector, e.g. `list(GR_KT_GDE = c(\"ZH\", \"ZG\"))`."
    )
  }
  if ("TIME_PERIOD" %in% names(filters)) {
    abort_filters("`filters` can't filter `TIME_PERIOD`.", i = "Use `start_period` and `end_period` instead.")
  }
  for (dim in names(filters)) {
    values <- filters[[dim]]
    if (!(is.character(values) || is.numeric(values)) || length(values) == 0 ||
        anyNA(values) || any(values == "")) {
      abort_filters(paste0(
        "`filters$", dim, "` must be a vector of value codes, without `NA` or \"\"."
      ))
    }
  }
}

# Check that the names of `filters` are dimensions of the dataflow: an
# unknown dimension would not filter the data
sse_check_filter_names <- function(filters, keys) {
  unknown <- setdiff(names(filters), keys)
  if (length(unknown) > 0) {
    rlang::abort(
      c(paste0("Unknown dimension in `filters`: ", paste(unknown, collapse = ", "), "."),
        i = paste0("The dimensions of the dataset are: ", paste(keys, collapse = ", "), "."),
        i = "See the column `dimension` of `bfs_sse_dimensions()`."),
      class = "bfs_sse_filter_error",
      call = NULL
    )
  }
}

# SDMX key of `filters`: one part per dimension, in the order of `keys`, the
# values joined with "+", or "all" if nothing is filtered
sse_key <- function(filters, keys) {
  # format() writes 1e5 as "100000"
  key <- vapply(keys, function(dim) {
    values <- filters[[dim]]
    if (is.numeric(values)) values <- format(values, scientific = FALSE, trim = TRUE)
    paste(values, collapse = "+")
  }, character(1))
  if (all(key == "")) "all" else paste(key, collapse = ".")
}

# Periods and numbers of observations of an SSE query as URL parameters, ""
# if none
sse_query_params <- function(start_period = NULL, end_period = NULL,
                             first_n = NULL, last_n = NULL) {
  # c() drops the NULL arguments. format() writes 1e5 as "100000"
  count <- function(n) if (!is.null(n)) format(n, scientific = FALSE)
  params <- c(startPeriod = as.character(start_period), endPeriod = as.character(end_period),
              firstNObservations = count(first_n), lastNObservations = count(last_n))
  if (length(params) == 0) "" else paste(names(params), params, sep = "=", collapse = "&")
}

# Codes and labels of SDMX-CSV values read with "labels=both", e.g.
# "ZH: Zurich". SDMX ids can't have ":", so the code ends at the first ": ".
# A value without label (e.g. a period or an empty attribute) is its own code
sse_csv_code <- function(x) {
  sub(": .*$", "", x)
}
sse_csv_label <- function(x) {
  ifelse(grepl(": ", x, fixed = TRUE), sub("^.*?: ", "", x, perl = TRUE), NA_character_)
}

# Values of the regions of SDMX constraints, without the regions with
# include="false", which list excluded values
sse_constraint_values <- function(xml) {
  regions <-
    xml2::xml_find_all(xml, ".//structure:CubeRegion[not(@include='false')]")
  key_values <- xml2::xml_find_all(regions, ".//common:KeyValue")
  purrr::map(key_values, function(node) {
    tibble::tibble(
      dimension = xml2::xml_attr(node, "id"),
      value = xml2::xml_text(xml2::xml_find_all(node, ".//common:Value"))
    )
  }) %>%
    dplyr::bind_rows(tibble::tibble(dimension = character(), value = character()))
}

# Dimensions of an SSE dataflow and the values allowed in it, from its
# structure message with all its references: a tibble with one row per
# allowed value
sse_structure <- function(res_xml, language) {

  codelist_nodes <- xml2::xml_find_all(res_xml, ".//structure:Codelist")
  dimension_nodes <-
    xml2::xml_find_all(res_xml, ".//structure:DimensionList/structure:Dimension")

  # codelist of each dimension, matched on its agency, id and version, so
  # codelists with the same id in another agency or version are not mixed up
  refs <- xml2::xml_find_first(dimension_nodes, ".//structure:Enumeration/Ref")
  codelist_index <- match(sse_ref_key(refs), sse_ref_key(codelist_nodes))
  # a reference without agency or version: match on the id alone
  by_id <- is.na(codelist_index)
  codelist_index[by_id] <- match(xml2::xml_attr(refs[by_id], "id"),
                                 xml2::xml_attr(codelist_nodes, "id"))

  # label of each dimension: the name of its concept, else of its codelist
  concept_refs <- xml2::xml_find_first(dimension_nodes, "structure:ConceptIdentity/Ref")
  concept_label <- vapply(seq_along(concept_refs), function(i) {
    ref <- concept_refs[[i]]
    concept <- xml2::xml_find_first(res_xml, sprintf(
      ".//structure:ConceptScheme[@id='%s' and @agencyID='%s' and @version='%s']/structure:Concept[@id='%s']",
      xml2::xml_attr(ref, "maintainableParentID"), xml2::xml_attr(ref, "agencyID"),
      xml2::xml_attr(ref, "maintainableParentVersion"), xml2::xml_attr(ref, "id")
    ))
    if (inherits(concept, "xml_missing")) NA_character_ else sse_name(concept, language)
  }, character(1))
  codelist_label <- rep(NA_character_, length(dimension_nodes))
  has_codelist <- !is.na(codelist_index)
  # index the names, not the nodes: subsetting a nodeset drops the duplicates
  # of a codelist used by several dimensions
  codelist_label[has_codelist] <-
    sse_name(codelist_nodes, language)[codelist_index[has_codelist]]

  dims <- tibble::tibble(
    dimension = xml2::xml_attr(dimension_nodes, "id"),
    dimension_label = dplyr::coalesce(concept_label, codelist_label),
    position = as.integer(xml2::xml_attr(dimension_nodes, "position")),
    codelist = codelist_index
  ) %>%
    dplyr::arrange(.data$position)

  # labels and parents (e.g. the canton of a district) of the codes of the
  # codelists used by the dataflow
  codelists <- unique(dims$codelist[!is.na(dims$codelist)])
  codes <- purrr::map(codelists, function(i) {
    code_nodes <- xml2::xml_find_all(codelist_nodes[[i]], ".//structure:Code")
    tibble::tibble(
      codelist = i,
      value = xml2::xml_attr(code_nodes, "id"),
      value_label = sse_name(code_nodes, language),
      parent = xml2::xml_attr(xml2::xml_find_first(code_nodes, "structure:Parent/Ref"), "id")
    )
  }) %>%
    dplyr::bind_rows(tibble::tibble(codelist = integer(), value = character(),
                                    value_label = character(), parent = character()))

  # values allowed in the dataflow: those of all its constraints ("Allowed"
  # and "Actual")
  sse_constraint_values(res_xml) %>%
    dplyr::inner_join(dims, by = "dimension") %>%
    dplyr::left_join(codes, by = c("codelist", "value")) %>%
    dplyr::distinct(.data$dimension, .data$value, .keep_all = TRUE) %>%
    dplyr::arrange(.data$position) %>%
    dplyr::select("dimension", "dimension_label", "value", "value_label", "position", "parent")
}

# "agency:id:version" of SDMX nodes (e.g. a Codelist or a Ref to a codelist)
sse_ref_key <- function(nodes) {
  paste(xml2::xml_attr(nodes, "agencyID"), xml2::xml_attr(nodes, "id"),
        xml2::xml_attr(nodes, "version"), sep = ":")
}

# Name of each SDMX node in `language`, else its first name
sse_name <- function(nodes, language) {
  name <- xml2::xml_text(
    xml2::xml_find_first(nodes, paste0("common:Name[@xml:lang='", language, "']"))
  )
  fallback <- xml2::xml_text(xml2::xml_find_first(nodes, "common:Name"))
  ifelse(is.na(name), fallback, name)
}

# The arguments of bfs_get_sse_data() and bfs_get_sse_metadata(), and what
# replaces them in bfs_sse_data() and bfs_sse_dimensions()
sse_old_args <- c(
  number_bfs = "`number_bfs` is now `dataset`.",
  query = "`query` is now `filters`.",
  variable_value_type = "`variable_value_type` is now `labels`: use `labels = \"label\"` or `\"code\"`.",
  column_name_type = "`column_name_type` is removed: the columns are always named with the dimension ids.",
  clean_names = "`clean_names` is removed: use `janitor::clean_names()` on the result."
)

# Check the dots of bfs_sse_data() and bfs_sse_dimensions(): an argument of
# the old functions gives its new name, so code where only the function name
# was changed gets a clear error. The dots are not evaluated
sse_check_dots <- function(fn, ...) {
  old <- intersect(names(rlang::enquos(...)), names(sse_old_args))
  if (length(old) > 0) {
    rlang::abort(
      c(paste0("`", fn, "` has new argument names."),
        rlang::set_names(sse_old_args[old], "x"),
        i = "See <https://felixluginbuhl.com/BFS/articles/sse-migration.html>"),
      class = "bfs_sse_argument_error",
      call = NULL
    )
  }
  # the error of rlang, with the class of the other argument errors
  tryCatch(
    rlang::check_dots_empty(env = rlang::current_env(), call = NULL),
    rlib_error_dots_nonempty = function(e) {
      rlang::abort(conditionMessage(e), class = c("bfs_sse_argument_error", class(e)[1]),
                   call = NULL)
    }
  )
}
