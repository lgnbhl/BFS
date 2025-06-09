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
