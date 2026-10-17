# BFS 0.7.3
- new "Get started" vignette: which API to use for which data, and the move
  from STAT-TAB to the Swiss Stats Explorer. The BFS is replacing STAT-TAB,
  and its PXWeb API used by `bfs_get_data()`, `bfs_get_metadata()` and
  `bfs_get_data_comments()`.
- the pkgdown site has a "Get started" tab, the articles in their own tabs,
  and a link to its `llms.txt`.
- the pkgdown site is built and published by GitHub Actions on each release;
  the built site (`docs/`) is no longer tracked in git.
- functions using the BFS APIs now give an informative error of class
  `bfs_http_error` if the API is not available (e.g. HTTP 429 Too Many
  Requests, timeout, server error). The original httr2 error classes and
  fields are kept, so existing error handlers still work, e.g.
  `tryCatch(..., httr2_http_429 = function(e) httr2::resp_retry_after(e$resp))`.
  The error message now starts with "The BFS API is not available.", followed
  by the original message and the original error ("Caused by error in ..."),
  so it has several lines. The first class is `bfs_http_error`: test the
  class with `inherits()` instead of `class(e)[1]`. `conditionCall(e)` is
  `NULL`, the original call is in `conditionCall(e$parent)`.
- skip all tests calling the BFS APIs on CRAN (`skip_on_cran()`), as the
  PXWeb API can rate-limit the CRAN check machines.
- examples calling the BFS APIs are only run in interactive sessions.
- `bfs_get_base_maps()` no longer leaves an empty cache folder if the
  download of the base maps fails, nor a partially extracted cache folder if
  the extraction fails. It also creates the cache folder if it doesn't exist
  yet, and uses the cached base maps when there is no internet connection.
- `bfs_get_base_maps()` gives an informative error if `geom` is missing.
- fix the example of `bfs_get_catalog_tables()`.
- `bfs_get_catalog_data()` and `bfs_get_catalog_tables()` accept multiple
  values for an argument, e.g. `prodima = c(900210, 900212)`, as documented.
- `bfs_get_catalog_data()` and `bfs_get_catalog_tables()` return the same
  columns, in the same order, when no dataset is found as when datasets are
  found. The empty result of `bfs_get_catalog_data()` no longer has the
  columns `url_structure_json` and `damId`, and in the empty result of
  `bfs_get_catalog_tables()` the column `number_asset` now comes before
  `publication_date`.
- `bfs_get_asset_metadata()` sends only one language to the API (by default
  "de", which returns the same metadata as before).
- BREAKING CHANGE: `bfs_get_asset_metadata()` gives an error if several
  languages are passed, e.g. `language = c("fr", "de")`. Before, only the first
  language was used by the API. Pass a single language instead. The default
  value `c("de", "fr", "it", "en")`, e.g. forwarded by a wrapper function,
  still uses "de".
- BREAKING CHANGE (data): `bfs_get_sse_metadata()` and `bfs_get_sse_data()`
  returned wrong labels when some codes of a codelist have no name in the
  requested language. Before, the few available labels were recycled over all
  codes, e.g. in `DF_SSV_POL_LEG` with `language = "de"`, "fr" or "it" all 181
  cities were labelled "Gesamtwert für Schweizer Städte" / "Total des villes
  suisses". Each code now gets its own label, with fallback to another
  language if it has no name in the requested language. The values were not
  affected, but results filtered, grouped, pivoted or joined on these labels
  (`variable_value_type = "text"`, the default of `bfs_get_sse_data()`) can
  change. `bfs_get_sse_data()` sends one request fewer to the API.
- `bfs_download_geodata()` creates the `output_dir` folder correctly and gives
  a clear error if `collection_id` is missing.
- the data download of `bfs_get_data()` and `bfs_get_data_comments()` and the
  file download of `bfs_download_asset()` also give an error of class
  `bfs_http_error` if the API is not available. The original error classes
  (e.g. `http_429` or `curl_error_couldnt_connect`) are kept.
- `bfs_get_catalog_data()` and `bfs_get_catalog_tables()` give a message if
  the catalog has as many results as `limit`, as more results may be
  available. Use `suppressMessages()` if this message is not wanted.
- `bfs_get_catalog_geodata()` retries the metadata requests of the collections
  and gives a message listing the collections whose metadata could not be
  retrieved (NA metadata), instead of hiding them.
- `bfs_get_sse_data()` keeps the values on the right observation if an
  observation has fewer dimensions.
- the list of Swiss Stats Explorer dataflows is cached for the R session, so
  `bfs_get_sse_data()` and `bfs_get_sse_metadata()` send one request fewer
  after the first call.
- new `bfs_clear_cache()` to delete the cached base maps and SSE dataflows.
  `bfs_get_base_maps()` no longer keeps the zip file once extracted.
- require R >= 4.0.0 (needed by `tools::R_user_dir()` and httr2), httr2 >= 1.0.0
  and purrr >= 1.0.0.
- add offline tests (mocked HTTP responses) that also run on CRAN, and skip
  a remaining base maps test calling the BFS API on CRAN.
- rewrite the documentation: clearer help pages with examples for all
  functions, a shorter README and new guides on the pkgdown site (Swiss Stats
  Explorer, data catalog and PXWeb datasets, tables and files, geodata and
  base maps, API errors and rate limits). Fix the size of
  `register_kt_seeanteile` (41 rows, 3 columns) in its documentation.
- the internal functions `bfs_get_sse_url()` and `get_xml_name()` no longer
  have help pages.
- new look of the pkgdown site, with a dark mode.

# BFS 0.7.2
- wrap the network-dependent examples of `bfs_get_sse_data()` and
  `bfs_get_sse_metadata()` in `\donttest{}` to avoid CRAN/CI check failures
  when the Swiss Stats Explorer API is unreachable or times out.

# BFS 0.7.1
- test fails for a specific test for `bfs_get_sse_data()` on Debian-clang.

# BFS 0.7.0
- Add new functions to access the data and metadata of the new Swiss Stats
  Explorer API.

# BFS 0.5.2
- remove "rstac" and "sf" R package dependencies to make the package lighter
  and easier to install. When using the functions `bfs_download_geodata()` and
  `bfs_get_base_maps()`, the user will be asked to install "rstac" and "sf" if
  they are not installed locally. Tests using these dependencies are skipped
  in CRAN and CI.
- removing `bfs_download_geodata()` automated tests will reduce API calls on
  "data.geo.admin.ch" server.

# BFS 0.5.13
- fix CRAN NOTE: remove native pipes for older R version compatibility.

# BFS 0.5.12
- improve `bfs_get_base_maps()` with new `return_sf` argument,
  which allows to return all file path available (see README).
- improve README related to `bfs_get_base_maps()`

# BFS 0.5.11
- BREAKING CHANGE: column `orderNr` returned by `bfs_get_catalog()` renamed 
  as `number_bfs` for more clarity. Unnecessary new variables also removed in
  profit of the `return_raw` argument.
- add `return_raw` in `bfs_get_catalog()` and `bfs_get_tables()`, which returns
  all metadata in an raw / unstructured tibble.
- update to last available BFS geodata asset imported using `bfs_get_base_maps()`
  - https://www.bfs.admin.ch/bfs/en/home/statistics/catalogues-databases.assetdetail.30606132.html
- Use new **swissMunicipalities** R package to ease geodata analysis 

# BFS 0.5.10
- fix bug in metadata extraction in `bfs_get_catalog()`, 
  `bfs_get_catalog_data()` and `bfs_get_catalog_tables()`

# BFS 0.5.9
- fix `bfs_get_catalog()`, `bfs_get_catalog_data()` and `bfs_get_catalog_tables()`

# BFS 0.5.8
- All functions return NULL if no internet connection.
- Tests skipped if no internet connection.

# BFS 0.5.6
- add "delay" argument in `bfs_get_data()` and `bfs_get_data_comments()`
  - using `Sys.sleep()` of 10 seconds to avoid reaching API limits
  - the "delay" arg allows to loop on large datasets, for example see #7
- BREAKING CHANGE: remove "bfs_url" argument in `bfs_get_data()` and
  `bfs_get_data_comments()`
  - "bfs_url" argument unstable and slow. See README for recommended workflow 
    using `bfs_get_catalog_data()` and `bfs_get_asset_metadata()`
- add deprecation warning for `bfs_get_catalog()`
- add more tests
- add test coverage

# BFS 0.5.5
- fix encoding bug in `bfs_get_base_maps()` #12
- add fs R package dependency
- add unit tests
- remove unnecessary messages when calling `bfs_get_catalog_*()`
- use tools instead of rappdirs
- improve docs related to query dimensions

# BFS 0.5.4
- using only magrittr pipe to allow older R versions, fix #11

# BFS 0.5.3
- add `bfs_get_base_maps()`.
- add data from the Swiss official commune register.
- update README.

# BFS 0.5.2
- BREAKING CHANGE: `bfs_get_catalog_data()` and `bfs_get_catalog_tables()` return now in the dataframe "number_asset" instead of "guid" as variables.
- add `bfs_download_asset()`
- add `bfs_get_asset_metadata()`
- "number_bfs" as first argument in `bfs_get_metadata()`
- improve docs

# BFS 0.5.1
- BREAKING CHANGE: fix BFS version 0.5 broke `bfs_get_data()`. Fix now #10 by removing "all" default argument to `query`.

# BFS 0.5
- fix bug #10
- add `bfs_get_catalog_geodata()`
- add `bfs_download_geodata()`
- improve docs

# BFS 0.4.8
- BREAKING CHANGE: reorder arguments in functions for consistency
- `bfs_get_catalog_tables()` now gets full catalog, fixing #5
- `bfs_get_catalog_tables()` has new functions to filter datasets directly
- use "httr2" instead of "jsonlite" for better console messages
- improve README, docs and sticker.

# BFS 0.4.7
- add new function `bfs_get_metadata()`
- fix bug duplicated column names with `as_tibble(. .name_repair = "minimal")` 

# BFS 0.4.5
- Fix bug in `bfs_get_data_comments()` #8.
- improve README by adding info about dependencies.

# BFS 0.4.4
- Fix bug using `query` argument in `bfs_get_data()`
- remove depreciated function `bfs_get_metadata()` and `bfs_get_dataset()`

# BFS 0.4.3
* Fixed `bfs_get_catalog_data()` and `bfs_get_catalog_tables()` bug #6.
* tidyRSS GitHub dependency version is 2.0.5.
* Add tests for `bfs_get_catalog_*` functions.

# BFS 0.4.2
* Fixed `bfs_get_catalog_data()` and `bfs_get_catalog_tables()` bug #6.
* tidyRSS dependency version is 2.0.4.
* Improved README.

# BFS 0.4.1

* BREAKING CHANGE: `clean_names` of `bfs_get_data()` is now FALSE by default.
* `bfs_get_data()` uses BFS API v1.
* `bfs_get_metadata()` deprecated. Please use only `bfs_get_catalog_data()`.
* add `bfs_get_catalog_tables()`.
* add `bfs_get_catalog()`.
* pxweb and jsonlite dependency added. dplyr dependency removed.

# BFS 0.3.1

* fix issue #3 with pull request #1

# BFS 0.3.0

* fix critical bug in `bfs_get_dataset()`
* add new function `bfs_get_catalog()`

# BFS 0.2.6

* Added a `NEWS.md` file to track changes to the package.
* Added `bfs_get_catalog()` function, that scraps the RSS feed
