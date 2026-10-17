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
    meta <- sse_metadata_from_url("https://disseminate.stats.swiss/rest/dataflow/x", language = "en")$codelist
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

# mocked SSE API, counting the requests of the dataflow list and keeping the
# URL of the last request
sse_requests <- new.env()
mock_sse <- function(req) {
  sse_requests$last_url <- req$url
  if (grepl("/rest/dataflow$", req$url)) {
    sse_requests$dataflow <- sse_requests$dataflow + 1
    return(mock_json(sse_dataflows_json)(req))
  }
  body <- if (grepl("references=all", req$url, fixed = TRUE)) sse_metadata_xml else sse_data_xml
  httr2::response(status_code = 200, url = req$url, headers = "Content-Type: application/xml", body = charToRaw(body))
}

test_that("bfs_get_sse_data() keeps values on the right observation", {with_empty_sse_cache({
  local_mocked_bindings(has_internet = function() TRUE, .package = "curl")
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

test_that("the SSE data and metadata URLs are built from the dataflow URN", {with_empty_sse_cache({
  sse_requests$dataflow <- 0
  httr2::with_mocked_responses(mock_sse, {
    expect_identical(
      bfs_get_sse_url("DF_TEST"),
      "https://disseminate.stats.swiss/rest/data/CH1,DF_TEST,1.0.0/"
    )
    expect_identical(
      bfs_get_sse_url("DF_TEST", metadata = TRUE),
      "https://disseminate.stats.swiss/rest/dataflow/CH1/DF_TEST/1.0.0?references=all"
    )
  })
})})

test_that("bfs_get_sse_data() sends the time period only if given", {with_empty_sse_cache({
  local_mocked_bindings(has_internet = function() TRUE, .package = "curl")
  sse_requests$dataflow <- 0
  httr2::with_mocked_responses(mock_sse, {
    bfs_get_sse_data("DF_TEST", query = list(SEX = "M"))
    expect_identical(
      sse_requests$last_url,
      "https://disseminate.stats.swiss/rest/data/CH1,DF_TEST,1.0.0/M?dimensionAtObservation=AllDimensions"
    )
    bfs_get_sse_data("DF_TEST", query = list(SEX = "M"), start_period = 2020, end_period = "2023")
    expect_identical(
      sse_requests$last_url,
      "https://disseminate.stats.swiss/rest/data/CH1,DF_TEST,1.0.0/M?startPeriod=2020&endPeriod=2023&dimensionAtObservation=AllDimensions"
    )
  })
})})

# a dataflow with several versions, whose structure has:
# - a codelist CL_AGE of another agency, listed first, with other labels
# - a dimension (SEX) missing from the constraint
# - a region excluding the value Y99 of AGE
# - a second constraint with another value of AGE
sse_versions_json <- '{"references": {
  "urn:sdmx:org.sdmx.infomodel.datastructure.Dataflow=CH1:DF_V(1.2.0)": {},
  "urn:sdmx:org.sdmx.infomodel.datastructure.Dataflow=CH1:DF_V(1.10.0)": {},
  "urn:sdmx:org.sdmx.infomodel.datastructure.Dataflow=CH1:DF_V(1.0.0)": {}
}}'

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
        <common:Name xml:lang="en">Age</common:Name>
        <structure:Code id="Y0"><common:Name xml:lang="en">0 years</common:Name></structure:Code>
        <structure:Code id="Y1"><common:Name xml:lang="en">1 year</common:Name></structure:Code>
        <structure:Code id="Y99"><common:Name xml:lang="en">99 years</common:Name></structure:Code>
      </structure:Codelist>
    </structure:Codelists>
    <structure:DataStructures>
      <structure:DataStructure id="DSD">
        <structure:DataStructureComponents>
          <structure:DimensionList id="DimensionDescriptor">
            <structure:Dimension id="AGE" position="2">
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

mock_sse_versions <- function(req) {
  sse_requests$last_url <- req$url
  if (grepl("/rest/dataflow$", req$url)) {
    return(mock_json(sse_versions_json)(req))
  }
  body <- if (grepl("references=all", req$url, fixed = TRUE)) sse_structure_xml else sse_data_xml
  httr2::response(status_code = 200, url = req$url, headers = "Content-Type: application/xml", body = charToRaw(body))
}

test_that("the latest SSE dataflow version is used, unless one is given", {with_empty_sse_cache({
  httr2::with_mocked_responses(mock_sse_versions, {
    expect_message(
      url <- bfs_get_sse_url("DF_V"),
      "several versions \\(1.10.0, 1.2.0, 1.0.0\\): using the latest, 1.10.0"
    )
    expect_identical(url, "https://disseminate.stats.swiss/rest/data/CH1,DF_V,1.10.0/")
    expect_identical(
      bfs_get_sse_url("DF_V", version = "1.2.0"),
      "https://disseminate.stats.swiss/rest/data/CH1,DF_V,1.2.0/"
    )
    expect_error(bfs_get_sse_url("DF_V", version = "9.9.9"), "Available versions: 1.2.0, 1.10.0, 1.0.0")
  })
})})

test_that("SSE metadata uses the referenced codelist and skips excluded values", {with_empty_sse_cache({
  local_mocked_bindings(has_internet = function() TRUE, .package = "curl")
  httr2::with_mocked_responses(mock_sse_versions, {
    meta <- bfs_get_sse_metadata("DF_V", language = "en", version = "1.0.0")
  })
  # the values of both constraints, without the excluded one
  expect_identical(meta$value, c("Y0", "Y1"))
  expect_identical(meta$valueText, c("0 years", "1 year"))
  expect_identical(meta$text, c("Age", "Age"))
  sse_meta <- httr2::with_mocked_responses(mock_sse_versions, {
    sse_metadata_from_url("https://disseminate.stats.swiss/rest/dataflow/x?references=all", language = "en")
  })
  expect_identical(sse_meta$dimensions, c("SEX", "AGE"))
})})

test_that("the SSE key has one part per dimension of the data structure", {with_empty_sse_cache({
  local_mocked_bindings(has_internet = function() TRUE, .package = "curl")
  httr2::with_mocked_responses(mock_sse_versions, {
    # SEX is not in the constraint, but keeps its position in the key
    df <- bfs_get_sse_data("DF_V", language = "en", version = "1.0.0", query = list(SEX = "M", AGE = "Y0"))
    expect_identical(
      sse_requests$last_url,
      "https://disseminate.stats.swiss/rest/data/CH1,DF_V,1.0.0/M.Y0?dimensionAtObservation=AllDimensions"
    )
  })
})})

test_that("the SSE dataflow list is requested once per session", {with_empty_sse_cache({
  local_mocked_bindings(has_internet = function() TRUE, .package = "curl")
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
