#' Clear the BFS cache
#'
#' Delete the base maps cached by [bfs_get_base_maps()] in
#' `tools::R_user_dir(package = "BFS")` and the list of Swiss Stats Explorer
#' datasets cached for the R session by [bfs_get_sse_data()] and
#' [bfs_get_sse_metadata()]. The cached data is downloaded again when needed.
#' [bfs_sse_datasets()], [bfs_sse_dimensions()] and [bfs_sse_data()] don't
#' cache anything.
#'
#' @return Invisibly, the path of the deleted cache folder.
#'
#' @examplesIf interactive()
#' bfs_clear_cache()
#'
#' @export
bfs_clear_cache <- function() {
  sse_cache$urns <- NULL
  dir <- tools::R_user_dir(package = "BFS")
  if (fs::dir_exists(dir)) {
    fs::dir_delete(dir)
    message("BFS cache cleared: ", dir)
  } else {
    message("No BFS cache to clear")
  }
  invisible(dir)
}
