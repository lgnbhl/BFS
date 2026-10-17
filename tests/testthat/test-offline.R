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
  expect_error(bfs_get_asset_metadata(number_asset = "24367729", language = "xx"))
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
})})

test_that("bfs_get_base_maps() gives an informative error without geom", {
  expect_error(bfs_get_base_maps(), "Please specify `geom`", fixed = TRUE)
})
