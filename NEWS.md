# BFS 0.4.0

* `bfs_get_dataset()` uses BFS API v1. `clean_names` is now FALSE by default. 
* `bfs_get_metadata()` removed because not working. Use only `bfs_get_catalog()` for now.
* pxweb and jsonlite dependency added. dbplyr dependency removed.

# BFS 0.3.1

* fix issue #3 with pull request #1

# BFS 0.3.0

* fix critical bug in `bfs_get_dataset()`
* add new function `bfs_get_catalog()`

# BFS 0.2.6

* Added a `NEWS.md` file to track changes to the package.
* Added `bfs_get_catalog()` function, that scraps the RSS feed
