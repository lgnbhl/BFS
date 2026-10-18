# no request is sent: the HTTP responses and the internet check are mocked,
# so these tests also run on CRAN

mock_json <- function(json) {
  function(req) {
    httr2::response(
      status_code = 200,
      url = req$url,
      headers = "Content-Type: application/json",
      body = charToRaw(json)
    )
  }
}

catalog_json <- '{"data": [{
  "ids": {"damId": 1},
  "description": {"titles": {"main": "Students"}},
  "shop": {"orderNr": "px-x-1502040100_131"},
  "bfs": {"embargo": "2024-01-01T00:00:00"},
  "links": [
    {"rel": "self", "href": "https://dam-api.bfs.admin.ch/hub/api/dam/assets/111"},
    {"rel": "related", "href": "https://www.pxweb.bfs.admin.ch/px.px"}
  ]
}]}'

test_that("bfs_get_catalog_data() sends multiple prodima values", {
  local_mocked_bindings(has_internet = function() TRUE, .package = "curl")
  last_req <- NULL
  mock <- function(req) {
    last_req <<- req
    mock_json(catalog_json)(req)
  }
  httr2::with_mocked_responses(mock, {
    df <- bfs_get_catalog_data(language = "en", prodima = c(900210, 900212))
  })
  expect_match(last_req$url, "prodima=900210&prodima=900212", fixed = TRUE)
  expect_equal(nrow(df), 1)
  expect_equal(df$number_asset, "111")
})

test_that("an empty catalog has the same columns as a non-empty catalog", {
  local_mocked_bindings(has_internet = function() TRUE, .package = "curl")
  httr2::with_mocked_responses(mock_json(catalog_json), {
    data_full <- bfs_get_catalog_data()
    tables_full <- bfs_get_catalog_tables()
  })
  httr2::with_mocked_responses(mock_json('{"data": []}'), {
    data_empty <- bfs_get_catalog_data()
    tables_empty <- bfs_get_catalog_tables()
  })
  expect_equal(nrow(data_empty), 0)
  expect_equal(nrow(tables_empty), 0)
  expect_identical(lapply(data_empty, class), lapply(data_full, class))
  expect_identical(lapply(tables_empty, class), lapply(tables_full, class))
})

test_that("bfs_get_asset_metadata() sends a single language", {
  local_mocked_bindings(has_internet = function() TRUE, .package = "curl")
  last_req <- NULL
  mock <- function(req) {
    last_req <<- req
    mock_json('{"ids": {"damId": 1}}')(req)
  }
  httr2::with_mocked_responses(mock, {
    bfs_get_asset_metadata(number_asset = "24367729")
  })
  expect_identical(last_req$headers[["accept-language"]], "de")
  # values accepted before are still sent unchanged
  httr2::with_mocked_responses(mock, {
    bfs_get_asset_metadata(number_asset = "24367729", language = "EN")
  })
  expect_identical(last_req$headers[["accept-language"]], "EN")
  # a wrapper forwarding the default language vector still works
  wrapper <- function(language = c("de", "fr", "it", "en")) {
    bfs_get_asset_metadata(number_asset = "24367729", language = language)
  }
  httr2::with_mocked_responses(mock, wrapper())
  expect_identical(last_req$headers[["accept-language"]], "de")
  expect_error(
    bfs_get_asset_metadata(number_asset = "24367729", language = c("fr", "de")),
    "Please specify only one language", fixed = TRUE
  )
})

sse_metadata_xml <- '<message:Structure
  xmlns:message="http://www.sdmx.org/resources/sdmxml/schemas/v2_1/message"
  xmlns:structure="http://www.sdmx.org/resources/sdmxml/schemas/v2_1/structure"
  xmlns:common="http://www.sdmx.org/resources/sdmxml/schemas/v2_1/common">
  <message:Structures>
    <structure:Codelists>
      <structure:Codelist id="CL_SEX">
        <common:Name xml:lang="de">Geschlecht</common:Name>
        <common:Name xml:lang="en">Sex</common:Name>
        <structure:Code id="M">
          <common:Name xml:lang="de">Mann</common:Name>
          <common:Name xml:lang="en">Man</common:Name>
        </structure:Code>
        <structure:Code id="F">
          <common:Name xml:lang="de">Frau</common:Name>
        </structure:Code>
      </structure:Codelist>
    </structure:Codelists>
    <structure:DataStructures>
      <structure:DataStructure id="DSD">
        <structure:DataStructureComponents>
          <structure:DimensionList id="DimensionDescriptor">
            <structure:Dimension id="SEX" position="1">
              <structure:LocalRepresentation>
                <structure:Enumeration><Ref id="CL_SEX"/></structure:Enumeration>
              </structure:LocalRepresentation>
            </structure:Dimension>
          </structure:DimensionList>
        </structure:DataStructureComponents>
      </structure:DataStructure>
    </structure:DataStructures>
    <structure:Constraints>
      <structure:ContentConstraint id="CC">
        <structure:CubeRegion include="true">
          <common:KeyValue id="SEX">
            <common:Value>M</common:Value>
            <common:Value>F</common:Value>
          </common:KeyValue>
        </structure:CubeRegion>
      </structure:ContentConstraint>
    </structure:Constraints>
  </message:Structures>
</message:Structure>'

test_that("SSE metadata falls back to another language for a missing name", {
  mock <- function(req) {
    httr2::response(
      status_code = 200,
      url = req$url,
      headers = "Content-Type: application/xml",
      body = charToRaw(sse_metadata_xml)
    )
  }
  httr2::with_mocked_responses(mock, {
    meta <- sse_metadata_from_url("https://disseminate.stats.swiss/rest/dataflow/x", language = "en")
  })
  expect_equal(nrow(meta), 2)
  expect_equal(meta$text, c("Sex", "Sex"))
  expect_equal(meta$valueText[meta$value == "M"], "Man")
  expect_equal(meta$valueText[meta$value == "F"], "Frau")
})

# evaluate code with tools::R_user_dir() pointing to a new, empty folder
with_fresh_cache <- function(code) {
  old_dir <- Sys.getenv("R_USER_DATA_DIR", unset = NA)
  Sys.setenv(R_USER_DATA_DIR = tempfile("bfs_cache_"))
  on.exit({
    unlink(Sys.getenv("R_USER_DATA_DIR"), recursive = TRUE)
    if (is.na(old_dir)) Sys.unsetenv("R_USER_DATA_DIR") else Sys.setenv(R_USER_DATA_DIR = old_dir)
  })
  code
}

test_that("bfs_get_base_maps() works with a fresh cache and offline afterwards", {with_fresh_cache({
  expect_false(dir.exists(tools::R_user_dir(package = "BFS")))

  # fake base maps zip, written where the real download would be saved
  local_mocked_bindings(bfs_download_asset = function(number_asset, destfile, ...) {
    shp_dir <- tempfile("bfs_shp_")
    dir.create(shp_dir)
    shp <- file.path(shp_dir, "K4suis20240101gf_ch2007Poly.shp")
    file.create(shp)
    zip::zip(destfile, files = shp, mode = "cherry-pick")
    destfile
  })

  local_mocked_bindings(has_internet = function() TRUE, .package = "curl")
  path <- bfs_get_base_maps(geom = "suis", return_sf = FALSE)
  expect_match(path, "K4suis20240101gf_ch2007Poly.shp", fixed = TRUE)

  # cached base maps are used without internet connection
  local_mocked_bindings(has_internet = function() FALSE, .package = "curl")
  expect_identical(bfs_get_base_maps(geom = "suis", return_sf = FALSE), path)
  # the zip file is deleted once extracted
  expect_length(list.files(tools::R_user_dir(package = "BFS"), pattern = "\\.zip$"), 0)
})})

test_that("bfs_get_base_maps() gives an informative error without geom", {
  expect_error(bfs_get_base_maps(), "Please specify `geom`", fixed = TRUE)
})

# ---- catalogs ----------------------------------------------------------------

test_that("bfs_get_catalog_data() and bfs_get_catalog_tables() return the expected columns", {
  local_mocked_bindings(has_internet = function() TRUE, .package = "curl")
  httr2::with_mocked_responses(mock_json(catalog_json), {
    df_data <- bfs_get_catalog_data(language = "en")
    df_tables <- bfs_get_catalog_tables(language = "en")
  })
  expect_identical(df_data, tibble::tibble(
    title = "Students",
    language = "en",
    number_bfs = "px-x-1502040100_131",
    number_asset = "111",
    publication_date = as.Date("2024-01-01"),
    url_px = "https://www.pxweb.bfs.admin.ch/px.px"
  ))
  expect_identical(df_tables, tibble::tibble(
    title = "Students",
    language = "en",
    number_asset = "111",
    publication_date = as.Date("2024-01-01"),
    order_nr = "px-x-1502040100_131"
  ))
})

test_that("a catalog with as many results as `limit` gives a message", {
  local_mocked_bindings(has_internet = function() TRUE, .package = "curl")
  httr2::with_mocked_responses(mock_json(catalog_json), {
    expect_message(bfs_get_catalog_data(limit = 1), "More results may be available")
    expect_message(bfs_get_catalog_tables(limit = 1), "More results may be available")
    expect_message(bfs_get_catalog_data(limit = 1, return_raw = TRUE), "More results may be available")
    expect_message(bfs_get_catalog_data(), NA)
  })
})

# ---- PXWeb -------------------------------------------------------------------

pxweb_metadata_json <- '{"title": "Students", "variables": [
  {"code": "Jahr", "text": "Year", "values": ["40", "41"], "valueTexts": ["2020", "2021"]},
  {"code": "Geschlecht", "text": "Sex", "values": ["0", "1"], "valueTexts": ["Man", "Woman"]}
]}'

test_that("bfs_get_data() builds the pxweb query", {
  local_mocked_bindings(has_internet = function() TRUE, .package = "curl")
  args <- NULL
  local_mocked_bindings(pxweb_get_data = function(...) {
    args <<- list(...)
    data.frame(`Year` = "2020", `Students count` = 1, check.names = FALSE)
  }, .package = "pxweb")
  httr2::with_mocked_responses(mock_json(pxweb_metadata_json), {
    df <- bfs_get_data(number_bfs = "px-x-1502040100_131", language = "en")
  })
  expect_identical(args$url, "https://www.pxweb.bfs.admin.ch/api/v1/en/px-x-1502040100_131/px-x-1502040100_131.px")
  expect_identical(args$query, pxweb::pxweb_query(list(Jahr = "*", Geschlecht = "*")))
  expect_identical(args$column.name.type, "text")
  expect_identical(args$variable.value.type, "text")
  expect_identical(df, tibble::tibble(`Year` = "2020", `Students count` = 1))

  httr2::with_mocked_responses(mock_json(pxweb_metadata_json), {
    df <- bfs_get_data(number_bfs = "px-x-1502040100_131", query = list(Jahr = "40"),
                       column_name_type = "code", variable_value_type = "code", clean_names = TRUE)
    expect_error(
      bfs_get_data(number_bfs = "px-x-1502040100_131", query = "Jahr"),
      "`query` should be a list using the variables: Jahr, Geschlecht.", fixed = TRUE
    )
  })
  expect_identical(args$query, pxweb::pxweb_query(list(Jahr = "40")))
  expect_identical(args$column.name.type, "code")
  expect_identical(args$variable.value.type, "code")
  expect_named(df, c("year", "students_count"))
})

test_that("bfs_get_data_comments() builds the pxweb query", {
  local_mocked_bindings(has_internet = function() TRUE, .package = "curl")
  args <- NULL
  local_mocked_bindings(
    pxweb_get = function(...) {
      args <<- list(...)
      "pxweb_data"
    },
    pxweb_data_comments = function(x) data.frame(`Comment Text` = "a comment", check.names = FALSE),
    .package = "pxweb"
  )
  httr2::with_mocked_responses(mock_json(pxweb_metadata_json), {
    df <- bfs_get_data_comments(number_bfs = "px-x-1502040100_131", language = "fr", clean_names = TRUE)
  })
  expect_identical(args$url, "https://www.pxweb.bfs.admin.ch/api/v1/fr/px-x-1502040100_131/px-x-1502040100_131.px")
  expect_identical(args$query, pxweb::pxweb_query(list(Jahr = "*", Geschlecht = "*")))
  expect_identical(df, tibble::tibble(comment_text = "a comment"))
})

http_429_error <- function() {
  # condition as raised by httr::stop_for_status(), used by pxweb
  stop(structure(
    class = c("http_429", "http_400", "http_error", "error", "condition"),
    list(message = "Too Many Requests (RFC 6585) (HTTP 429).", call = NULL)
  ))
}

test_that("an unavailable PXWeb API gives a bfs_http_error and keeps the httr class", {
  local_mocked_bindings(has_internet = function() TRUE, .package = "curl")
  local_mocked_bindings(
    pxweb_get_data = function(...) http_429_error(),
    pxweb_get = function(...) http_429_error(),
    .package = "pxweb"
  )
  httr2::with_mocked_responses(mock_json(pxweb_metadata_json), {
    expect_error(bfs_get_data(number_bfs = "px-x-1502040100_131"), class = "bfs_http_error")
    expect_error(bfs_get_data(number_bfs = "px-x-1502040100_131"), class = "http_429")
    expect_error(bfs_get_data_comments(number_bfs = "px-x-1502040100_131"), class = "bfs_http_error")
  })
})

# ---- DAM API downloads -------------------------------------------------------

test_that("an unavailable DAM API gives a bfs_http_error when downloading", {
  local_mocked_bindings(has_internet = function() TRUE, .package = "curl")
  local_mocked_bindings(curl_download = function(...) {
    stop(structure(
      class = c("curl_error_couldnt_connect", "curl_error", "error", "condition"),
      list(message = "Could not connect to server", call = NULL)
    ))
  }, .package = "curl")
  expect_error(bfs_download_asset(number_asset = "1", destfile = tempfile()), class = "bfs_http_error")
  expect_error(bfs_download_asset(number_asset = "1", destfile = tempfile()), class = "curl_error_couldnt_connect")
})

test_that("a local download error is not reported as an unavailable API", {
  local_mocked_bindings(has_internet = function() TRUE, .package = "curl")
  local_mocked_bindings(curl_download = function(...) stop("Failed to open file x.curltmp."), .package = "curl")
  e <- tryCatch(bfs_download_asset(number_asset = "1", destfile = tempfile()), error = identity)
  expect_false(inherits(e, "bfs_http_error"))
  expect_match(conditionMessage(e), "Failed to open file")
})

# ---- geodata catalog ---------------------------------------------------------

test_that("bfs_get_catalog_geodata() reports collections without metadata", {
  local_mocked_bindings(has_internet = function() TRUE, .package = "curl")
  read_html <- xml2::read_html
  local_mocked_bindings(read_html = function(x, ...) read_html(
    '<html><body><div id="data">
      <a href="https://data.geo.admin.ch/api/stac/v0.9/collections/ch.bfs.a">API</a>
      <a href="https://data.geo.admin.ch/api/stac/v0.9/collections/ch.bfs.b">API</a>
    </div></body></html>'
  ), .package = "xml2")
  collection_json <- '{"id": "ch.bfs.a", "title": "A", "description": "d",
    "created": "2020-01-01", "updated": "2021-01-01", "crs": ["http://www.opengis.net/def/crs/OGC/1.3/CRS84"],
    "license": "proprietary", "providers": [{"name": "BFS"}],
    "extent": {"spatial": {"bbox": [[5.9, 45.8, 10.5, 47.8]]}, "temporal": {"interval": [["2020-01-01", null]]}}}'
  mock <- function(req) {
    if (grepl("ch.bfs.a$", req$url)) mock_json(collection_json)(req) else httr2::response(status_code = 404, url = req$url)
  }
  httr2::with_mocked_responses(mock, {
    expect_message(df <- bfs_get_catalog_geodata(), "1 collection(s) could not be retrieved and is NA: ch.bfs.b", fixed = TRUE)
  })
  expect_identical(df$collection_id, c("ch.bfs.a", "ch.bfs.b"))
  expect_identical(df$title, c("A", NA))
})

# ---- Swiss Stats Explorer ----------------------------------------------------

sse_dataflows_json <- '{"references": {
  "urn:sdmx:org.sdmx.infomodel.datastructure.Dataflow=CH1:DF_TEST(1.0.0)": {},
  "urn:sdmx:org.sdmx.infomodel.datastructure.Dataflow=CH1:DF_OTHER(1.0.0)": {}
}}'

# the third observation has no SEX dimension
sse_data_xml <- '<message:GenericData
  xmlns:message="http://www.sdmx.org/resources/sdmxml/schemas/v2_1/message"
  xmlns:generic="http://www.sdmx.org/resources/sdmxml/schemas/v2_1/data/generic">
  <message:DataSet>
    <generic:Obs>
      <generic:ObsKey><generic:Value id="SEX" value="M"/><generic:Value id="TIME_PERIOD" value="2023"/></generic:ObsKey>
      <generic:ObsValue value="10"/>
    </generic:Obs>
    <generic:Obs>
      <generic:ObsKey><generic:Value id="SEX" value="F"/><generic:Value id="TIME_PERIOD" value="2023"/></generic:ObsKey>
      <generic:ObsValue value="20"/>
    </generic:Obs>
    <generic:Obs>
      <generic:ObsKey><generic:Value id="TIME_PERIOD" value="2024"/></generic:ObsKey>
      <generic:ObsValue value="30"/>
    </generic:Obs>
  </message:DataSet>
</message:GenericData>'

# evaluate code with an empty SSE session cache, emptied again afterwards so
# the mocked dataflows are never used by other tests
with_empty_sse_cache <- function(code) {
  sse_cache$urns <- NULL
  on.exit(sse_cache$urns <- NULL)
  code
}

# mocked SSE API, counting the requests of the dataflow list
sse_requests <- new.env()
mock_sse <- function(req) {
  if (grepl("/rest/dataflow$", req$url)) {
    sse_requests$dataflow <- sse_requests$dataflow + 1
    return(mock_json(sse_dataflows_json)(req))
  }
  body <- if (grepl("references=all", req$url, fixed = TRUE)) sse_metadata_xml else sse_data_xml
  httr2::response(status_code = 200, url = req$url, headers = "Content-Type: application/xml", body = charToRaw(body))
}

test_that("bfs_get_sse_data() keeps values on the right observation", {with_empty_sse_cache({
  local_mocked_bindings(has_internet = function() TRUE, .package = "curl")
  rlang::local_options(lifecycle_verbosity = "quiet")
  sse_requests$dataflow <- 0
  httr2::with_mocked_responses(mock_sse, {
    df <- bfs_get_sse_data("DF_TEST", language = "en", query = list(SEX = c("M", "F")))
  })
  expect_identical(df, tibble::tibble(
    SEX = c("Man", "Frau", NA),
    TIME_PERIOD = c("2023", "2023", "2024"),
    value = c(10, 20, 30)
  ))
})})

test_that("the SSE dataflow list is requested once per session", {with_empty_sse_cache({
  local_mocked_bindings(has_internet = function() TRUE, .package = "curl")
  rlang::local_options(lifecycle_verbosity = "quiet")
  sse_requests$dataflow <- 0
  httr2::with_mocked_responses(mock_sse, {
    bfs_get_sse_data("DF_TEST", language = "en", query = list(SEX = "M"))
    bfs_get_sse_metadata("DF_OTHER", language = "en")
    expect_equal(sse_requests$dataflow, 1)
    # an unknown BFS number requests the list again before failing
    expect_error(bfs_get_sse_metadata("DF_UNKNOWN"), "does not exist in the SSE API")
    expect_equal(sse_requests$dataflow, 2)
  })
})})

test_that("bfs_get_sse_data() gives a bfs_http_error only if the API is not available", {with_empty_sse_cache({
  local_mocked_bindings(has_internet = function() TRUE, .package = "curl")
  rlang::local_options(lifecycle_verbosity = "quiet")
  sse_requests$dataflow <- 0
  mock_sse_status <- function(status, body) function(req) {
    if (grepl("/rest/dataflow$", req$url) || grepl("references=all", req$url, fixed = TRUE)) {
      return(mock_sse(req))
    }
    httr2::response(status_code = status, url = req$url, body = charToRaw(body))
  }
  httr2::with_mocked_responses(mock_sse_status(503, "Service Unavailable"), {
    e <- expect_error(bfs_get_sse_data("DF_TEST", query = list(SEX = "M")), class = "bfs_http_error")
  })
  expect_s3_class(e, "httr2_http_503")
  expect_s3_class(e$resp, "httr2_response")
  httr2::with_mocked_responses(mock_sse_status(400, "Semantic error"), {
    e <- expect_error(bfs_get_sse_data("DF_TEST", query = list(SEX = "M")), "HTTP error: 400 Semantic error")
  })
  expect_false(inherits(e, "bfs_http_error"))
  httr2::with_mocked_responses(mock_sse_status(404, "NoRecordsFound"), {
    expect_error(bfs_get_sse_data("DF_TEST", query = list(SEX = "M")), "No records found")
  })
})})

# ---- Swiss Stats Explorer: bfs_sse_*() ---------------------------------------

# DF_V has several versions, listed in no particular order
sse_dataflows_all_json <- '{"data": {"dataflows": [
  {"id": "DF_V", "version": "1.2.0", "agencyID": "CH1", "name": "Population 1.2",
   "description": "The population by age and sex."},
  {"id": "DF_V", "version": "1.10.0", "agencyID": "CH1", "name": "Population 1.10"},
  {"id": "DF_V", "version": "1.0.0", "agencyID": "CH1", "name": "Population 1.0"},
  {"id": "DF_ONE", "version": "1.0.0", "agencyID": "CH1.SUB", "name": "One"}
]}}'

# the structure of DF_V has:
# - a codelist CL_AGE of another agency, listed first, with other labels
# - a concept for AGE, but not for SEX, labelled with its codelist name
# - a dimension (SEX) missing from the constraints
# - a region excluding the value Y99 of AGE
# - a second constraint with another value of AGE
# - a code (Y1) with a parent (Y0)
sse_structure_xml <- '<message:Structure
  xmlns:message="http://www.sdmx.org/resources/sdmxml/schemas/v2_1/message"
  xmlns:structure="http://www.sdmx.org/resources/sdmxml/schemas/v2_1/structure"
  xmlns:common="http://www.sdmx.org/resources/sdmxml/schemas/v2_1/common">
  <message:Structures>
    <structure:Codelists>
      <structure:Codelist id="CL_AGE" agencyID="OTHER" version="2.0.0">
        <common:Name xml:lang="en">Wrong</common:Name>
        <structure:Code id="Y0"><common:Name xml:lang="en">Wrong</common:Name></structure:Code>
      </structure:Codelist>
      <structure:Codelist id="CL_SEX" agencyID="CH1" version="1.0.0">
        <common:Name xml:lang="en">Sex</common:Name>
        <structure:Code id="M"><common:Name xml:lang="en">Man</common:Name></structure:Code>
      </structure:Codelist>
      <structure:Codelist id="CL_AGE" agencyID="CH1" version="1.0.0">
        <common:Name xml:lang="en">Age codelist</common:Name>
        <structure:Code id="Y0"><common:Name xml:lang="en">0 years</common:Name></structure:Code>
        <structure:Code id="Y1"><common:Name xml:lang="en">1 year</common:Name><structure:Parent><Ref id="Y0"/></structure:Parent></structure:Code>
        <structure:Code id="Y99"><common:Name xml:lang="en">99 years</common:Name></structure:Code>
      </structure:Codelist>
    </structure:Codelists>
    <structure:Concepts>
      <structure:ConceptScheme id="CS" agencyID="CH1" version="1.0.0">
        <structure:Concept id="AGE">
          <common:Name xml:lang="de">Alter</common:Name>
          <common:Name xml:lang="en">Age</common:Name>
        </structure:Concept>
      </structure:ConceptScheme>
    </structure:Concepts>
    <structure:DataStructures>
      <structure:DataStructure id="DSD">
        <structure:DataStructureComponents>
          <structure:DimensionList id="DimensionDescriptor">
            <structure:Dimension id="AGE" position="2">
              <structure:ConceptIdentity>
                <Ref id="AGE" maintainableParentID="CS" maintainableParentVersion="1.0.0" agencyID="CH1"/>
              </structure:ConceptIdentity>
              <structure:LocalRepresentation>
                <structure:Enumeration><Ref id="CL_AGE" agencyID="CH1" version="1.0.0"/></structure:Enumeration>
              </structure:LocalRepresentation>
            </structure:Dimension>
            <structure:Dimension id="SEX" position="1">
              <structure:LocalRepresentation>
                <structure:Enumeration><Ref id="CL_SEX" agencyID="CH1" version="1.0.0"/></structure:Enumeration>
              </structure:LocalRepresentation>
            </structure:Dimension>
            <structure:TimeDimension id="TIME_PERIOD" position="3"/>
          </structure:DimensionList>
        </structure:DataStructureComponents>
      </structure:DataStructure>
    </structure:DataStructures>
    <structure:Constraints>
      <structure:ContentConstraint id="CC">
        <structure:CubeRegion include="true">
          <common:KeyValue id="AGE"><common:Value>Y0</common:Value></common:KeyValue>
          <common:KeyValue id="TIME_PERIOD"/>
        </structure:CubeRegion>
        <structure:CubeRegion include="false">
          <common:KeyValue id="AGE"><common:Value>Y99</common:Value></common:KeyValue>
        </structure:CubeRegion>
      </structure:ContentConstraint>
      <structure:ContentConstraint id="CC2">
        <structure:CubeRegion include="true">
          <common:KeyValue id="AGE"><common:Value>Y1</common:Value></common:KeyValue>
        </structure:CubeRegion>
      </structure:ContentConstraint>
    </structure:Constraints>
  </message:Structures>
</message:Structure>'

# real responses of the SSE API for DF_LWZ_1, see fixtures/sse/README.md
sse_fixture <- function(file) {
  path <- test_path("fixtures", "sse", file)
  readChar(path, file.size(path), useBytes = TRUE)
}

# mocked SSE API, recording the requests: DF_V has the structure
# `sse_structure_xml`, DF_LWZ_1 the real structure and data, another dataset
# doesn't exist. `data_*` replace the response to the data request
mock_sse_api <- function(data_status = 200, data_body = NULL,
                         data_type = "application/vnd.sdmx.data+csv; charset=utf-8") {
  function(req) {
    sse_requests$urls <- c(sse_requests$urls, req$url)
    sse_requests$last_req <- req
    response <- function(status, type, body) {
      httr2::response(status_code = status, url = req$url,
                      headers = paste0("Content-Type: ", type), body = charToRaw(body))
    }
    if (grepl("/rest/dataflow/all/all/all$", req$url)) {
      return(response(200, "application/vnd.sdmx.structure+json; charset=utf-8; version=1.0",
                      sse_dataflows_all_json))
    }
    if (grepl("/rest/dataflow/all/DF_V/", req$url, fixed = TRUE)) {
      return(response(200, "application/xml", sse_structure_xml))
    }
    if (grepl("/rest/dataflow/all/DF_LWZ_1/", req$url, fixed = TRUE)) {
      return(response(200, "application/xml", sse_fixture("structure-DF_LWZ_1.xml")))
    }
    if (grepl("/rest/dataflow/", req$url, fixed = TRUE)) {
      return(response(404, "text/plain", "Could not find requested structures"))
    }
    labels <- grepl("labels=both", req$headers$accept, fixed = TRUE)
    body <- data_body %||% sse_fixture(if (labels) "data-DF_LWZ_1-both.csv" else "data-DF_LWZ_1-code.csv")
    response(data_status, data_type, body)
  }
}

# evaluate code with the requests to the mocked SSE API recorded from scratch
with_sse_api <- function(code, ...) {
  sse_requests$urls <- NULL
  sse_requests$last_req <- NULL
  local_mocked_bindings(has_internet = function() TRUE, .package = "curl")
  httr2::with_mocked_responses(mock_sse_api(...), code)
}

test_that("bfs_sse_datasets() lists all the versions, the latest first", {
  with_sse_api({
    datasets <- bfs_sse_datasets(language = "en")
  })
  expect_named(datasets, c("dataset", "name", "version", "agency", "description"))
  expect_identical(datasets$dataset, c("DF_ONE", "DF_V", "DF_V", "DF_V"))
  expect_identical(datasets$version, c("1.0.0", "1.10.0", "1.2.0", "1.0.0"))
  # a dataset without description has NA
  expect_identical(datasets$description, c(NA, NA, "The population by age and sex.", NA))
  expect_identical(sse_requests$last_req$headers[["Accept-Language"]], "en")
})

test_that("bfs_sse_dimensions() uses the concepts, codelists and constraints", {
  with_sse_api({
    dims <- bfs_sse_dimensions("DF_V", language = "en", version = "1.0.0")
  })
  expect_identical(
    sse_requests$urls,
    "https://disseminate.stats.swiss/rest/dataflow/all/DF_V/1.0.0?references=all"
  )
  # the values of both constraints, without the excluded one, labelled from
  # the referenced codelist
  expect_identical(dims, tibble::tibble(
    dimension = c("AGE", "AGE"),
    dimension_label = c("Age", "Age"),
    value = c("Y0", "Y1"),
    value_label = c("0 years", "1 year"),
    position = c(2L, 2L),
    parent = c(NA, "Y0")
  ))
  # the API chooses the latest version
  with_sse_api(bfs_sse_dimensions("DF_V"))
  expect_identical(
    sse_requests$urls,
    "https://disseminate.stats.swiss/rest/dataflow/all/DF_V/latest?references=all"
  )
})

test_that("dimensions sharing a codelist are labelled with it", {
  # a second dimension without concept using CL_SEX, as the two partners of a
  # couple, listed before the codelist of AGE
  xml <- sub(
    '<structure:Dimension id="SEX" position="1">',
    paste0(
      '<structure:Dimension id="SEX2" position="0">',
      '<structure:LocalRepresentation><structure:Enumeration>',
      '<Ref id="CL_SEX" agencyID="CH1" version="1.0.0"/>',
      '</structure:Enumeration></structure:LocalRepresentation>',
      '</structure:Dimension>',
      '<structure:Dimension id="SEX" position="1">'
    ),
    sse_structure_xml,
    fixed = TRUE
  )
  xml <- sub(
    '<common:KeyValue id="TIME_PERIOD"/>',
    paste0('<common:KeyValue id="TIME_PERIOD"/>',
           '<common:KeyValue id="SEX"><common:Value>M</common:Value></common:KeyValue>',
           '<common:KeyValue id="SEX2"><common:Value>M</common:Value></common:KeyValue>'),
    xml,
    fixed = TRUE
  )
  xml <- xml2::read_xml(xml)
  expect_identical(sse_dimension_ids(xml), c("SEX2", "SEX", "AGE"))
  expect_identical(
    dplyr::distinct(sse_structure(xml, language = "en"), dimension, dimension_label, value_label),
    tibble::tibble(
      dimension = c("SEX2", "SEX", "AGE", "AGE"),
      dimension_label = c("Sex", "Sex", "Age", "Age"),
      value_label = c("Man", "Man", "0 years", "1 year")
    )
  )
})

test_that("an unknown dataset or version gives a classed error", {
  with_sse_api({
    expect_error(bfs_sse_dimensions("DF_UNKNOWN"), "Dataset \"DF_UNKNOWN\" doesn't exist",
                 class = "bfs_sse_dataset_error")
    expect_error(bfs_sse_data("DF_UNKNOWN", version = "1.0.0"),
                 "Version \"1.0.0\" of dataset \"DF_UNKNOWN\" doesn't exist",
                 class = "bfs_sse_dataset_error")
  })
})

test_that("bfs_sse_data() requests the version of the structure, with one key part per dimension", {
  with_sse_api({
    bfs_sse_data("DF_LWZ_1", filters = list(GR_KT_GDE = c("ZH", "ZG"), MEASURE_DIMENSION = "OBS"),
                 start_period = 2025, language = "en")
  })
  expect_identical(sse_requests$urls, c(
    "https://disseminate.stats.swiss/rest/dataflow/all/DF_LWZ_1/latest?references=datastructure",
    "https://disseminate.stats.swiss/rest/data/CH1.LWZ,DF_LWZ_1,1.1.0/ZH+ZG...OBS.?startPeriod=2025"
  ))
  headers <- sse_requests$last_req$headers
  expect_identical(headers$Accept, "application/vnd.sdmx.data+csv;version=1.0.0;labels=both")
  expect_identical(headers[["Accept-Language"]], "en")

  with_sse_api({
    bfs_sse_data("DF_LWZ_1", version = "1.1.0", end_period = "2023", labels = "code")
  })
  expect_identical(sse_requests$urls, c(
    "https://disseminate.stats.swiss/rest/dataflow/all/DF_LWZ_1/1.1.0?references=datastructure",
    "https://disseminate.stats.swiss/rest/data/CH1.LWZ,DF_LWZ_1,1.1.0/all?endPeriod=2023"
  ))
  expect_identical(sse_requests$last_req$headers$Accept, "application/vnd.sdmx.data+csv;version=1.0.0")

  # the numbers of observations are sent as SDMX parameters
  with_sse_api({
    bfs_sse_data("DF_LWZ_1", start_period = "2020", last_n = 1)
  })
  expect_identical(
    sse_requests$urls[2],
    "https://disseminate.stats.swiss/rest/data/CH1.LWZ,DF_LWZ_1,1.1.0/all?startPeriod=2020&lastNObservations=1"
  )
  with_sse_api({
    bfs_sse_data("DF_LWZ_1", first_n = 1e5)
  })
  expect_identical(
    sse_requests$urls[2],
    "https://disseminate.stats.swiss/rest/data/CH1.LWZ,DF_LWZ_1,1.1.0/all?firstNObservations=100000"
  )
})

test_that("bfs_sse_data() returns the codes and labels given by the API", {
  with_sse_api({
    code <- bfs_sse_data("DF_LWZ_1", labels = "code")
    both <- bfs_sse_data("DF_LWZ_1", attributes = TRUE)
    label <- bfs_sse_data("DF_LWZ_1", labels = "label", attributes = TRUE)
  })
  expect_identical(code, tibble::tibble(
    GR_KT_GDE = c("ZH", "ZH", "ZG", "ZG"),
    WOHN_ANZAHL = "_T",
    LEERWOHN_TYP = "_T",
    MEASURE_DIMENSION = "OBS",
    FREQ = "A",
    TIME_PERIOD = c("2025", "2026", "2025", "2026"),
    value = c(3815, 4189, 261, 126)
  ))
  # the attribute DATAFLOW, empty, has the same id as the first column: it's
  # not mixed up with it and not returned
  expect_named(both, c(
    "GR_KT_GDE", "GR_KT_GDE_label", "WOHN_ANZAHL", "WOHN_ANZAHL_label",
    "LEERWOHN_TYP", "LEERWOHN_TYP_label", "MEASURE_DIMENSION", "MEASURE_DIMENSION_label",
    "FREQ", "FREQ_label", "TIME_PERIOD", "value",
    "DECIMALS", "DECIMALS_label", "OBS_STATUS", "OBS_STATUS_label"
  ))
  expect_identical(both$GR_KT_GDE, code$GR_KT_GDE)
  expect_identical(both$GR_KT_GDE_label, c("Zurich", "Zurich", "Zug", "Zug"))
  expect_identical(both$TIME_PERIOD, code$TIME_PERIOD)
  expect_identical(both$value, code$value)
  expect_identical(both$OBS_STATUS_label, rep("Normal value", 4))
  expect_identical(label$GR_KT_GDE, both$GR_KT_GDE_label)
  expect_identical(label$OBS_STATUS, both$OBS_STATUS_label)
})

test_that("SDMX-CSV values are split into codes and labels", {
  x <- c("ZH: Zurich", "552001: Holiday homes: apartments", "2024", "_T", NA)
  expect_identical(sse_csv_code(x), c("ZH", "552001", "2024", "_T", NA))
  expect_identical(sse_csv_label(x), c("Zurich", "Holiday homes: apartments", NA, NA, NA))
})

test_that("the codes \"NA\" and empty values are kept apart", {
  csv <- paste(
    "DATAFLOW,GR_KT_GDE,WOHN_ANZAHL,LEERWOHN_TYP,MEASURE_DIMENSION,FREQ,TIME_PERIOD,OBS_VALUE,DATAFLOW,DECIMALS,OBS_STATUS",
    "CH1.LWZ:DF_LWZ_1(1.1.0),NA,_T,_T,OBS,A,2025,,,0,",
    sep = "\n"
  )
  with_sse_api(df <- bfs_sse_data("DF_LWZ_1", labels = "code", attributes = TRUE), data_body = csv)
  expect_identical(df$GR_KT_GDE, "NA")
  expect_identical(df$value, NA_real_)
  expect_identical(df$OBS_STATUS, NA_character_)
})

test_that("bfs_sse_data() checks its arguments before sending a request", {
  with_sse_api({
    expect_error(bfs_sse_data("DF_LWZ_1", filters = list("ZH")), "must be named",
                 class = "bfs_sse_filter_error")
    expect_error(bfs_sse_data("DF_LWZ_1", filters = c(GR_KT_GDE = "ZH")), "must be a named list",
                 class = "bfs_sse_filter_error")
    expect_error(bfs_sse_data("DF_LWZ_1", filters = list(GR_KT_GDE = "ZH", GR_KT_GDE = "ZG")),
                 "more than once in `filters`: GR_KT_GDE", class = "bfs_sse_filter_error")
    # a filter that would be ignored, so the data would not be filtered
    expect_error(bfs_sse_data("DF_LWZ_1", filters = list(GR_KT_GDE = character(0))),
                 "`filters\\$GR_KT_GDE` must be a vector", class = "bfs_sse_filter_error")
    expect_error(bfs_sse_data("DF_LWZ_1", filters = list(GR_KT_GDE = NA)),
                 class = "bfs_sse_filter_error")
    expect_error(bfs_sse_data("DF_LWZ_1", filters = list(TIME_PERIOD = "2023")), "start_period",
                 class = "bfs_sse_filter_error")
    expect_error(bfs_sse_data(c("DF_LWZ_1", "DF_LWZ_2")), "`dataset` must be a single string",
                 class = "bfs_sse_argument_error")
    expect_error(bfs_sse_data(NA), class = "bfs_sse_argument_error")
    expect_error(bfs_sse_data("DF_LWZ_1", start_period = c("2020", "2021")),
                 "`start_period` must be a single string", class = "bfs_sse_argument_error")
    for (n in list(0, 1.5, -1, NA, Inf, "1", c(1, 2))) {
      expect_error(bfs_sse_data("DF_LWZ_1", last_n = n), "`last_n` must be a whole number",
                   class = "bfs_sse_argument_error")
    }
    expect_error(bfs_sse_data("DF_LWZ_1", first_n = 0), "`first_n` must be a whole number",
                 class = "bfs_sse_argument_error")
    expect_error(bfs_sse_data("DF_LWZ_1", version = 1), NA)
    expect_error(bfs_sse_data("DF_LWZ_1", labels = "text"), "must be one of")
    expect_error(bfs_sse_data("DF_LWZ_1", language = "EN"), "must be one of")
  })
  # only the call with valid arguments sent requests
  expect_length(sse_requests$urls, 2)
})

test_that("an unknown dimension in `filters` is an error", {
  with_sse_api({
    expect_error(
      bfs_sse_data("DF_LWZ_1", filters = list(GR_KT_GED = "ZH")),
      "Unknown dimension in `filters`: GR_KT_GED",
      class = "bfs_sse_filter_error"
    )
  })
  # the data is not requested
  expect_length(sse_requests$urls, 1)
})

test_that("the errors of the API are classed", {
  # the API answers either, depending on the dataset
  for (body in c("NoRecordsFound", "NoResultsFound")) {
    with_sse_api(
      expect_error(bfs_sse_data("DF_LWZ_1"), "No records found for the specified query.",
                   class = "bfs_no_records"),
      data_status = 404, data_body = body, data_type = "text/plain"
    )
  }
  # a query rejected by the API, with its message
  with_sse_api(
    expect_error(bfs_sse_data("DF_LWZ_1", start_period = "foo"),
                 "HTTP 422 Unprocessable Entity: Semantic Error - Invalid Date Format `foo`",
                 class = "bfs_sse_query_error"),
    data_status = 422, data_body = "Semantic Error - Invalid Date Format `foo`", data_type = "text/plain"
  )
  # a too long URL, answered without body
  with_sse_api(
    expect_error(bfs_sse_data("DF_LWZ_1"), "split `filters`", class = "bfs_sse_query_error"),
    data_status = 414, data_body = "", data_type = "text/plain"
  )
  with_sse_api(
    expect_error(bfs_sse_data("DF_LWZ_1"), "HTTP 500", class = "bfs_http_error"),
    data_status = 500, data_body = "Error", data_type = "text/plain"
  )
  # the classes and the response of the httr2 error are kept
  with_sse_api(
    expect_error(bfs_sse_data("DF_LWZ_1"), class = "httr2_http_500"),
    data_status = 500, data_body = "Error", data_type = "text/plain"
  )
  with_sse_api(
    expect_error(bfs_sse_data("DF_LWZ_1"), "unexpected format", class = "bfs_sse_format_error"),
    data_type = "application/vnd.sdmx.genericdata+xml"
  )
})

# ---- cache -------------------------------------------------------------------

test_that("bfs_clear_cache() deletes the cached base maps and SSE dataflows", {with_fresh_cache({with_empty_sse_cache({
  cache_dir <- tools::R_user_dir(package = "BFS")
  expect_message(bfs_clear_cache(), "No BFS cache to clear")
  dir.create(file.path(cache_dir, "base_maps_1"), recursive = TRUE)
  sse_cache$urns <- "urn"
  expect_message(expect_identical(bfs_clear_cache(), cache_dir), "BFS cache cleared")
  expect_false(dir.exists(cache_dir))
  expect_null(sse_cache$urns)
})})})

test_that("the old SSE functions are deprecated", {
  local_mocked_bindings(has_internet = function() FALSE, .package = "curl")
  rlang::local_options(lifecycle_verbosity = "warning")
  expect_message(
    lifecycle::expect_deprecated(bfs_get_sse_data("DF_TEST", query = list(SEX = "M")), "bfs_sse_data"),
    "No internet connection"
  )
  expect_message(
    lifecycle::expect_deprecated(bfs_get_sse_metadata("DF_TEST"), "bfs_sse_dimensions"),
    "No internet connection"
  )
})

test_that("the arguments of the old SSE functions give their new name", {
  # no request is sent: the arguments are checked first
  expect_error(
    bfs_sse_data(number_bfs = "DF_TEST", query = list(SEX = "M")),
    "`number_bfs` is now `dataset`.*`query` is now `filters`",
    class = "bfs_sse_argument_error"
  )
  expect_error(
    bfs_sse_data("DF_TEST", variable_value_type = "code", clean_names = TRUE),
    "`variable_value_type` is now `labels`.*`clean_names` is removed",
    class = "bfs_sse_argument_error"
  )
  expect_error(
    bfs_sse_dimensions(number_bfs = "DF_TEST"),
    "`number_bfs` is now `dataset`",
    class = "bfs_sse_argument_error"
  )
  # an old positional call, e.g. bfs_get_sse_data("DF_TEST", "en")
  expect_error(bfs_sse_data("DF_TEST", "en"), class = "rlib_error_dots_nonempty")
  expect_error(bfs_sse_dimensions("DF_TEST", "en"), class = "rlib_error_dots_nonempty")
  # a typo in an argument name
  expect_error(bfs_sse_data("DF_TEST", filter = list(SEX = "M")), class = "rlib_error_dots_nonempty")
})
