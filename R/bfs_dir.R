#' Open BFS dataset directory
#'
#' @export

bfs_dir <- function(dir = paste0("", system.file("extdata/", package = "bfsdata"), "")){
    if (.Platform['OS.type'] == "windows"){
      shell.exec(dir)
    } else {
      system(paste(Sys.getenv("R_BROWSER"), dir))
  }
}
