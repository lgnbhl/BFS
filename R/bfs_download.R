#' Download BFS data
#'
#' @export

bfs_download <- function(row, name = "bfsData") {
  bfsDataPath <- system.file("extdata/", package = "bfsdata")
  assign("bfsDataPath", bfsDataPath, envir = .GlobalEnv)
  library(pxR)
  if(!file.exists(system.file(paste0("extdata/", bfsMetadataSubset[row, 4], ".px"), package = "bfsdata"))) {
    download.file(url = paste0("https://www.pxweb.bfs.admin.ch/DownloadFile.aspx?file=", bfsMetadataSubset[row,4], ""),
                  destfile = paste0("", bfsDataPath, "/", bfsMetadataSubset[row, 4],".px"))
  } else {
    message("WARNING: Dataset already downloaded")
  }
  bfsData <- pxR::read.px(paste0("", bfsDataPath, "/", bfsMetadataSubset[row, 4],".px"))
  assign(paste0("", name,"_px"), bfsData, envir = .GlobalEnv)
  bfsData <- as.data.frame(bfsData)
  write.csv(bfsData, file = paste0("", bfsDataPath, "/", name,".csv"), row.names = FALSE)
  assign(paste0("", name,""), bfsData, envir = .GlobalEnv)
}
