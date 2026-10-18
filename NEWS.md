# BFS 0.8.0

The main change: new functions for the Swiss Stats Explorer (SSE), which
replaces STAT-TAB. The old SSE functions are deprecated, but they still work.
Please read "Breaking changes" before you update.

## Breaking changes

- **SSE labels (data change).** `bfs_get_sse_metadata()` and
  `bfs_get_sse_data()` gave wrong labels, or failed, when some codes of a
  codelist have no name in the requested language:
  - if only one code had a name, this label was used for all the codes. For
    example, in `DF_SSV_POL_LEG` with `language = "de"`, "fr" or "it", all 181
    cities were labelled "Gesamtwert für Schweizer Städte" / "Total des
    villes suisses";
  - if no code, or several codes (but not all), had a name, the functions
    stopped with the error "Tibble columns must have compatible sizes".

  Each code now gets its own label, with a fallback to another language. The
  values don't change. But if you filter, group, pivot or join on these
  labels (`variable_value_type = "text"`, the default of `bfs_get_sse_data()`),
  your results can change.
- **`bfs_get_asset_metadata()` accepts only one language.** An error is
  given for several languages, e.g. `language = c("fr", "de")`. Before, the
  API used only the first one. The default value `c("de", "fr", "it", "en")`,
  e.g. forwarded by a wrapper function, still works and uses "de".
- **New class and message for API errors.** See "Errors when an API is not
  available" below. If your code tests `class(e)[1]`, use `inherits()`
  instead.
- **R >= 4.0.0 is required** (needed by `tools::R_user_dir()` and httr2), as
  well as httr2 >= 1.0.0 and purrr >= 1.0.0.

## New Swiss Stats Explorer functions

- `bfs_sse_datasets()` lists the datasets of the Swiss Stats Explorer,
  `bfs_sse_dimensions()` gives their dimensions and values, and
  `bfs_sse_data()` downloads their data. They are a thin wrapper of the SDMX
  REST API: they use only what the SDMX standard defines and leave the rest
  to the API (latest version, labels in a language, checks of the codes), so
  they keep working if the API changes its internals.
- Compared to `bfs_get_sse_metadata()` and `bfs_get_sse_data()`, they:
  - **are faster**: the data is downloaded in the SDMX-CSV format, with the
    labels given by the API (about 5 times faster and 6 times less memory for
    344,000 values);
  - **stop on filters that would not filter the data**, before downloading
    anything: an unknown dimension, `TIME_PERIOD`, a dimension given twice,
    an empty vector of codes or `NA`;
  - **can use any version of a dataset** with `version` (by default the
    latest, chosen by the API), so a data pipeline keeps the same structure.
    The data always has the same version as the dimensions used to build the
    query;
  - **get only the first or last periods** of each series with `first_n` and
    `last_n` (the SDMX parameters `firstNObservations` and
    `lastNObservations`), e.g. `last_n = 1` for the latest value;
  - always name the columns with the dimension ids. They return the codes and
    the labels (`labels = "both"`, the default, as two codes can have the
    same label), only the codes or only the labels, and optionally the
    attributes such as `OBS_STATUS` (`attributes = TRUE`);
  - give more information:
    - the description of each dataset (`description` column of
      `bfs_sse_datasets()`), to search the datasets by their content;
    - the label of each dimension from its SDMX concept (e.g. "Country of
      origin"), and the values of all the constraints of a dataset;
    - the parent of each value in its codelist (`parent` column of
      `bfs_sse_dimensions()`), e.g. the district of a commune and the canton
      of a district, to select all the communes of a canton;
  - return `TIME_PERIOD` as text, as given by the API;
  - cache nothing, so a new version or new data is used at once;
  - give errors with a class: `bfs_no_records`, `bfs_sse_filter_error`,
    `bfs_sse_argument_error`, `bfs_sse_dataset_error`, `bfs_sse_query_error`
    (a query refused by the API, with its message, e.g. a wrong period or a
    too long URL), `bfs_sse_format_error` and `bfs_http_error`;
  - need all their arguments after `dataset` to be named. An argument of the
    old functions gives an error that names the new argument (e.g.
    `number_bfs` is now `dataset`, `query` is now `filters`).

## Deprecated functions

- `bfs_get_sse_metadata()` and `bfs_get_sse_data()` are deprecated
  (`lifecycle::deprecate_soft()`). They warn when called from your code or
  from the tests of a package, not when called inside another package. They
  are kept for the data pipelines using them and get only bug fixes (see
  "Breaking changes" and "Bug fixes and improvements"). The new article
  "Moving to the new Swiss Stats Explorer functions" explains the
  differences and how to move your code.

## Errors when an API is not available

- All the functions using the BFS APIs now give an error of class
  `bfs_http_error` if the API is not available (e.g. HTTP 429 Too Many
  Requests, timeout, server error). This includes the data downloads of
  `bfs_get_data()` and `bfs_get_data_comments()` and the file download of
  `bfs_download_asset()`.
  - The original error classes and fields are kept (e.g. `httr2_http_429`,
    `http_429` or `curl_error_couldnt_connect`), so existing error handlers
    still work, e.g.
    `tryCatch(..., httr2_http_429 = function(e) httr2::resp_retry_after(e$resp))`.
  - The message starts with "The BFS API is not available.", followed by the
    original message and the original error ("Caused by error in ..."), so it
    has several lines.
  - The first class is `bfs_http_error`: test the class with `inherits()`
    instead of `class(e)[1]`. `conditionCall(e)` is `NULL`, the original call
    is in `conditionCall(e$parent)`.
- `bfs_get_sse_data()` gives a `bfs_http_error` only for HTTP 429 and server
  errors. A query refused by the API (other HTTP 4xx, e.g. a wrong period)
  gives the same error as before, "HTTP error: <status> <message of the
  API>", without a class.

## Bug fixes and improvements

### Swiss Stats Explorer (old functions)

- `bfs_get_sse_data()` no longer fails with the error "Tibble columns must
  have compatible sizes" if an observation has fewer dimensions than the
  others.
- The list of SSE dataflows is cached for the R session, so
  `bfs_get_sse_data()` and `bfs_get_sse_metadata()` send one request fewer
  after the first call. If a dataset is not in the cached list, the list is
  downloaded again, so a dataset published since the first call is found.
  `bfs_get_sse_data()` also sends one request fewer for the metadata.

### Data catalog and assets

- `bfs_get_catalog_data()` and `bfs_get_catalog_tables()`:
  - accept several values for an argument, e.g.
    `prodima = c(900210, 900212)`, as documented;
  - give a message if the catalog has as many results as `limit`, as more
    results may be available. Use `suppressMessages()` if you don't want
    this message;
  - return the same columns, in the same order, when no dataset is found as
    when datasets are found. The empty result of `bfs_get_catalog_data()` no
    longer has the columns `url_structure_json` and `damId`. In the empty
    result of `bfs_get_catalog_tables()`, the column `number_asset` now comes
    before `publication_date`.
- `bfs_get_asset_metadata()` sends only one language to the API (by default
  "de", which returns the same metadata as before).
- Fix the example of `bfs_get_catalog_tables()`.

### Base maps, geodata and cache

- New `bfs_clear_cache()` to delete the cached base maps and SSE dataflows.
- `bfs_get_base_maps()`:
  - no longer leaves an empty cache folder if the download fails, nor a
    partly extracted cache folder if the extraction fails;
  - creates the cache folder if it doesn't exist yet;
  - uses the cached base maps when there is no internet connection;
  - no longer keeps the zip file once extracted;
  - gives a clear error if `geom` is missing.
- `bfs_download_geodata()` creates the `output_dir` folder correctly and gives
  a clear error if `collection_id` is missing.
- `bfs_get_catalog_geodata()` retries the metadata requests of the
  collections. It gives a message listing the collections whose metadata
  could not be retrieved (NA metadata), instead of hiding them.

## Documentation

- New "Get started" vignette: which API to use for which data, and the move
  from STAT-TAB to the Swiss Stats Explorer. The BFS is replacing STAT-TAB,
  and its PXWeb API used by `bfs_get_data()`, `bfs_get_metadata()` and
  `bfs_get_data_comments()`.
- Rewritten documentation: clearer help pages with examples for all
  functions, a shorter README and new guides (Swiss Stats Explorer, data
  catalog and PXWeb datasets, tables and files, geodata and base maps, API
  errors and rate limits).
- Roxygen markdown is turned on, so the links and the formatting of the help
  pages are now rendered.
- Examples calling the BFS APIs only run in interactive sessions.
- Fix the size of `register_kt_seeanteile` (41 rows, 3 columns) in its
  documentation.
- The internal functions `bfs_get_sse_url()` and `get_xml_name()` no longer
  have help pages.
- pkgdown site: new look with a dark mode, a "Get started" tab, the articles
  in their own tabs and a link to its `llms.txt`. It is built and published
  by GitHub Actions on each release, and the built site (`docs/`) is no
  longer tracked in git.

## Tests

- Skip all the tests calling the BFS APIs on CRAN (`skip_on_cran()`), as the
  PXWeb API can rate-limit the CRAN check machines.
- New offline tests (mocked HTTP responses), which also run on CRAN.

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
