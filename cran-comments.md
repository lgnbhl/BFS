## Submission

This is an update of BFS from 0.7.2 to 0.8.0. It adds new functions for the
Swiss Stats Explorer API (`bfs_sse_datasets()`, `bfs_sse_dimensions()` and
`bfs_sse_data()`) and soft-deprecates the old ones (`bfs_get_sse_metadata()`
and `bfs_get_sse_data()`), which keep working.

## Test environments

* local Windows 11, R 4.5.1
* GitHub Actions: macOS (release), Windows (release), Ubuntu (devel, release,
  oldrel-1)

## R CMD check results

0 errors | 0 warnings | 0 notes

## Notes

* The examples that call the BFS APIs run only in interactive sessions, and
  the tests that call them are skipped on CRAN, so the checks don't depend on
  the APIs being available.

## Reverse dependencies

There are no reverse dependencies.
