#' Download a BFS asset file
#' 
#' This function uses the DAM API \url{https://dam-api.bfs.admin.ch/hub/swagger-ui/index.html}
#' to download a BFS file by asset number or BFS number. The file is downloaded using 
#' `curl::curl_download()` under the hood.
#' 
#' @param number_bfs The BFS number of a dataset.
#' @param number_asset The asset number of a dataset
#' @param destfile A character string with the name where the downloaded file is saved. Tilde-expansion is performed.
#' @param quiet If TRUE, suppress status messages (if any), and the progress bar.
#' @param mode A character string specifying the mode with which to write the file. Useful values are "w", "wb" (binary), "a" (append) and "ab".
#' @param handle a curl handle object
#'
#' @importFrom curl curl_download
#'
#' @returns Returns the file path where the file has been downloaded
#'
#' @export
bfs_download_asset <- function(number_asset = NULL, number_bfs = NULL, destfile, quiet = TRUE, mode = "wb", handle = curl::new_handle()) {
  
  if(is.null(number_asset) & is.null(number_bfs)) {
    stop("Please specify number_bfs or number_asset")
  } else if(!is.null(number_asset) & !is.null(number_bfs)) {
    stop("Please only specify number_bfs or number_asset")
  } else if(!is.null(number_asset)) {
    id <- number_asset
  } else if(!is.null(number_bfs)) {
    id <- paste0("orderNr:", number_bfs)
  }
  
  file_path <- curl::curl_download(
    url      = paste0("https://dam-api.bfs.admin.ch/hub/api/dam/assets/", id, "/master"),
    destfile = destfile,
    quiet = quiet,
    mode = mode,
    handle = handle
  )
  
  file_path
}

