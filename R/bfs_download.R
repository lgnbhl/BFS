#' Download BFS data
#'
#' @export

bfs_download <- function(row, name = "bfsData") {
  bfsDataPath <- system.file("extdata/", package = "bfsdata")
  assign("bfsDataPath", bfsDataPath, envir = .GlobalEnv)
  if(!file.exists(system.file(paste0("extdata/", bfs_metadataSubset[row, 4], ".px"), package = "bfsdata"))) {
    download.file(url = paste0("https://www.pxweb.bfs.admin.ch/DownloadFile.aspx?file=", bfs_metadataSubset[row,4], ""),
                  destfile = paste0("", bfsDataPath, "/", bfs_metadataSubset[row, 4],".px"))
  } else {
    message("WARNING: Dataset already downloaded")
  }
  library(pxR) # read PX files
  bfsDataPX <- pxR::read.px(paste0("", bfsDataPath, "/",bfs_metadataSubset[row, 4],".px"))
  assign("bfsDataPX", bfsDataPX, envir = .GlobalEnv)
  bfsData <- as.data.frame(bfsDataPX)
  write.csv(bfsData, file = paste0("", bfsDataPath, "/", name,".csv"), row.names = FALSE)
  assign(paste0("", name,""), bfsData, envir = .GlobalEnv)
  detach("package:pxR", unload = TRUE) # pxR::as.data.frame in conflict with raster::as.data.frame
}
