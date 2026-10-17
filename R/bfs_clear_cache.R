#' Clear the BFS cache
#'
#' Delete the base maps cached by [bfs_get_base_maps()] in
#' `tools::R_user_dir(package = "BFS")` and the list of Swiss Stats Explorer
#' dataflows cached for the R session by [bfs_get_sse_data()] and
#' [bfs_get_sse_metadata()]. The cached data is downloaded again when needed.
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
