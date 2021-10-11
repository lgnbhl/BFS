# BFS (development version)

# BFS 0.4.0

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
